-- Script completo y actualizado para el sistema de amigos
-- Este script elimina los objetos existentes y crea una estructura limpia y consistente

-- 1. Eliminar objetos existentes para una instalación limpia
DROP FUNCTION IF EXISTS public.send_friend_request CASCADE;
DROP FUNCTION IF EXISTS public.accept_friend_request CASCADE;
DROP FUNCTION IF EXISTS public.reject_friend_request CASCADE;
DROP FUNCTION IF EXISTS public.remove_friend CASCADE;
DROP FUNCTION IF EXISTS public.get_pending_friend_requests CASCADE;
DROP VIEW IF EXISTS public.user_friends CASCADE;

-- 2. Verificar y crear la tabla de amistades si no existe
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'friendships'
    ) THEN
        CREATE TABLE public.friendships (
            id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
            requester_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
            receiver_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
            status text DEFAULT 'pending'::text NOT NULL,
            created_at timestamp with time zone DEFAULT now() NOT NULL,
            updated_at timestamp with time zone,
            accepted_at timestamp with time zone,
            CONSTRAINT unique_friendship UNIQUE (requester_id, receiver_id)
        );
        
        -- Comentario para la tabla
        COMMENT ON TABLE public.friendships IS 'Almacena todas las relaciones de amistad entre usuarios';
        
        -- Índices para optimizar consultas
        CREATE INDEX friendships_requester_id_idx ON public.friendships(requester_id);
        CREATE INDEX friendships_receiver_id_idx ON public.friendships(receiver_id);
        CREATE INDEX friendships_status_idx ON public.friendships(status);
        
        -- Habilitar RLS
        ALTER TABLE public.friendships ENABLE ROW LEVEL SECURITY;
    ELSE
        -- Si la tabla ya existe, verificar si tiene las columnas correctas y añadirlas si no
        IF NOT EXISTS (
            SELECT FROM information_schema.columns 
            WHERE table_schema = 'public' 
            AND table_name = 'friendships' 
            AND column_name = 'requester_id'
        ) THEN
            -- Si usa user_id/friend_id, realizamos la migración
            ALTER TABLE public.friendships 
            RENAME COLUMN user_id TO requester_id;
            
            ALTER TABLE public.friendships 
            RENAME COLUMN friend_id TO receiver_id;
        END IF;
        
        -- Añadir columna accepted_at si no existe
        IF NOT EXISTS (
            SELECT FROM information_schema.columns 
            WHERE table_schema = 'public' 
            AND table_name = 'friendships' 
            AND column_name = 'accepted_at'
        ) THEN
            ALTER TABLE public.friendships 
            ADD COLUMN accepted_at timestamp with time zone;
        END IF;
    END IF;
END$$;

-- 3. Crear políticas RLS
-- Eliminar políticas existentes primero
DROP POLICY IF EXISTS friendships_insert_policy ON public.friendships;
DROP POLICY IF EXISTS friendships_select_policy ON public.friendships;
DROP POLICY IF EXISTS friendships_update_policy ON public.friendships;
DROP POLICY IF EXISTS friendships_delete_policy ON public.friendships;

-- Crear nuevas políticas
CREATE POLICY friendships_insert_policy ON public.friendships 
    FOR INSERT WITH CHECK (auth.uid() = requester_id);

CREATE POLICY friendships_select_policy ON public.friendships 
    FOR SELECT USING (auth.uid() = requester_id OR auth.uid() = receiver_id);

CREATE POLICY friendships_update_policy ON public.friendships 
    FOR UPDATE USING (
        auth.uid() = receiver_id OR 
        (auth.uid() = requester_id AND status = 'pending')
    );

CREATE POLICY friendships_delete_policy ON public.friendships 
    FOR DELETE USING (auth.uid() = requester_id OR auth.uid() = receiver_id);

-- 4. Vista de amigos (muestra amistades aceptadas)
CREATE OR REPLACE VIEW public.user_friends AS
SELECT DISTINCT
    CASE 
        WHEN f.requester_id = auth.uid() THEN f.receiver_id 
        ELSE f.requester_id 
    END as friend_user_id,
    COALESCE(p.email, '') as email,
    COALESCE(p.full_name, 'Sin nombre') as full_name,
    COALESCE(p.profile_picture_url, NULL) as profile_image_url,
    f.status,
    f.created_at as friendship_date,
    f.accepted_at
FROM public.friendships f
JOIN public.profiles p ON (
    (f.requester_id = auth.uid() AND p.id = f.receiver_id) OR
    (f.receiver_id = auth.uid() AND p.id = f.requester_id)
)
WHERE f.status = 'accepted';

-- 5. Funciones RPC para operaciones de amistad

-- Función para obtener solicitudes pendientes
CREATE OR REPLACE FUNCTION public.get_pending_friend_requests()
RETURNS SETOF json AS $$
BEGIN
    RETURN QUERY
    SELECT json_build_object(
        'id', f.id,
        'sender_id', f.requester_id,
        'sender_email', p.email,
        'sender_name', p.full_name,
        'sender_image', COALESCE(p.profile_image_url, p.profile_picture_url),
        'created_at', f.created_at
    )
    FROM public.friendships f
    JOIN public.profiles p ON p.id = f.requester_id
    WHERE f.receiver_id = auth.uid() AND f.status = 'pending';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para enviar solicitud de amistad
CREATE OR REPLACE FUNCTION public.send_friend_request(friend_email text)
RETURNS json AS $$
DECLARE
    friend_user_id uuid;
    existing_request uuid;
    result json;
BEGIN
    -- Buscar usuario por email
    SELECT id INTO friend_user_id 
    FROM public.profiles 
    WHERE email = friend_email;
    
    IF friend_user_id IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Usuario no encontrado');
    END IF;
    
    IF friend_user_id = auth.uid() THEN
        RETURN json_build_object('success', false, 'message', 'No puedes agregarte a ti mismo');
    END IF;
    
    -- Verificar si ya existe una solicitud o amistad
    SELECT id INTO existing_request
    FROM public.friendships
    WHERE 
        (requester_id = auth.uid() AND receiver_id = friend_user_id) OR
        (requester_id = friend_user_id AND receiver_id = auth.uid());
        
    IF existing_request IS NOT NULL THEN
        DECLARE
            existing_status text;
        BEGIN
            SELECT status INTO existing_status FROM public.friendships WHERE id = existing_request;
            
            IF existing_status = 'accepted' THEN
                RETURN json_build_object('success', false, 'message', 'Esta persona ya es tu amigo');
            ELSIF existing_status = 'pending' THEN
                RETURN json_build_object('success', false, 'message', 'Ya existe una solicitud pendiente');
            ELSE
                RETURN json_build_object('success', false, 'message', 'Ya existe una relación con este usuario');
            END IF;
        END;
    END IF;
    
    -- Insertar solicitud
    INSERT INTO public.friendships (requester_id, receiver_id, status)
    VALUES (auth.uid(), friend_user_id, 'pending');
    
    RETURN json_build_object('success', true, 'message', 'Solicitud enviada');
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'message', 'Error al enviar solicitud: ' || SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para aceptar solicitud
CREATE OR REPLACE FUNCTION public.accept_friend_request(friendship_id uuid)
RETURNS json AS $$
DECLARE
    current_status text;
    requester_id_val uuid;
BEGIN
    -- Verificar primero si la solicitud existe y está pendiente
    SELECT status, requester_id INTO current_status, requester_id_val
    FROM public.friendships 
    WHERE id = friendship_id AND receiver_id = auth.uid();
    
    IF current_status IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Solicitud no encontrada o no autorizada');
    END IF;
    
    IF current_status != 'pending' THEN
        RETURN json_build_object('success', false, 'message', 'Esta solicitud ya ha sido ' || 
            CASE current_status 
                WHEN 'accepted' THEN 'aceptada' 
                WHEN 'rejected' THEN 'rechazada' 
                ELSE 'procesada' 
            END);
    END IF;
    
    -- Actualizar la solicitud
    UPDATE public.friendships 
    SET status = 'accepted', 
        updated_at = now(),
        accepted_at = now()
    WHERE id = friendship_id AND receiver_id = auth.uid();
    
    RETURN json_build_object('success', true, 'message', 'Solicitud aceptada');
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'message', 'Error al aceptar solicitud: ' || SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para rechazar solicitud
CREATE OR REPLACE FUNCTION public.reject_friend_request(friendship_id uuid)
RETURNS json AS $$
DECLARE
    current_status text;
BEGIN
    -- Verificar primero si la solicitud existe y está pendiente
    SELECT status INTO current_status 
    FROM public.friendships 
    WHERE id = friendship_id AND receiver_id = auth.uid();
    
    IF current_status IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Solicitud no encontrada o no autorizada');
    END IF;
    
    IF current_status != 'pending' THEN
        RETURN json_build_object('success', false, 'message', 'Esta solicitud ya ha sido ' || 
            CASE current_status 
                WHEN 'accepted' THEN 'aceptada' 
                WHEN 'rejected' THEN 'rechazada' 
                ELSE 'procesada' 
            END);
    END IF;
    
    -- Actualizar la solicitud
    UPDATE public.friendships 
    SET status = 'rejected', 
        updated_at = now()
    WHERE id = friendship_id AND receiver_id = auth.uid();
    
    RETURN json_build_object('success', true, 'message', 'Solicitud rechazada');
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'message', 'Error al rechazar solicitud: ' || SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para eliminar amistad
CREATE OR REPLACE FUNCTION public.remove_friend(friend_id uuid)
RETURNS json AS $$
DECLARE
    friendship_id uuid;
BEGIN
    -- Buscar la amistad
    SELECT id INTO friendship_id
    FROM public.friendships
    WHERE 
        ((requester_id = auth.uid() AND receiver_id = friend_id) OR
        (requester_id = friend_id AND receiver_id = auth.uid()))
        AND status = 'accepted';
    
    IF friendship_id IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Amistad no encontrada');
    END IF;
    
    -- Eliminar la amistad
    DELETE FROM public.friendships WHERE id = friendship_id;
    
    RETURN json_build_object('success', true, 'message', 'Amistad eliminada');
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'message', 'Error al eliminar amistad: ' || SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Mensajes de confirmación
DO $$ 
BEGIN
    RAISE NOTICE '✅ Sistema de amigos instalado correctamente';
    RAISE NOTICE '🔧 Tabla friendships configurada';
    RAISE NOTICE '🔧 Políticas RLS aplicadas';
    RAISE NOTICE '🔧 Vista user_friends creada';
    RAISE NOTICE '🔧 Funciones RPC instaladas';
END $$;
