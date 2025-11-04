+-- Script para arreglar problemas en la vista de amistades
-- Ejecutar en SQL Editor de Supabase

-- Corregir la vista user_friends para usar la tabla profiles
CREATE OR REPLACE VIEW public.user_friends AS
SELECT DISTINCT
    CASE 
        WHEN f.user_id = auth.uid() THEN f.friend_id 
        ELSE f.user_id 
    END as friend_user_id,
    COALESCE(p.email, '') as email,
    COALESCE(p.full_name, 'Sin nombre') as full_name,
    p.profile_image_url,
    f.status,
    f.created_at as friendship_date
FROM public.friendships f
JOIN public.profiles p ON (
    (f.user_id = auth.uid() AND p.id = f.friend_id) OR
    (f.friend_id = auth.uid() AND p.id = f.user_id)
)
WHERE f.status = 'accepted';

-- Función para enviar solicitud de amistad mejorada con mejor manejo de errores
CREATE OR REPLACE FUNCTION public.send_friend_request(friend_email text)
RETURNS json AS $$
DECLARE
    friend_user_id uuid;
    existing_request uuid;
    result json;
BEGIN
    -- Buscar usuario por email en la tabla profiles en lugar de auth.users
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
        (user_id = auth.uid() AND friend_id = friend_user_id) OR
        (user_id = friend_user_id AND friend_id = auth.uid());
        
    IF existing_request IS NOT NULL THEN
        -- Verificar el estado de la solicitud existente para dar un mensaje más específico
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
    INSERT INTO public.friendships (user_id, friend_id, status)
    VALUES (auth.uid(), friend_user_id, 'pending');
    
    RETURN json_build_object('success', true, 'message', 'Solicitud enviada');
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'message', 'Error al enviar solicitud: ' || SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para rechazar solicitudes con mejor manejo de errores
CREATE OR REPLACE FUNCTION public.reject_friend_request(friendship_id uuid)
RETURNS json AS $$
DECLARE
    current_status text;
BEGIN
    -- Verificar primero si la solicitud existe y está pendiente
    SELECT status INTO current_status 
    FROM public.friendships 
    WHERE id = friendship_id AND friend_id = auth.uid();
    
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
    WHERE id = friendship_id AND friend_id = auth.uid();
    
    RETURN json_build_object('success', true, 'message', 'Solicitud rechazada');
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'message', 'Error al rechazar solicitud: ' || SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Mensajes de confirmación
DO $$ 
BEGIN
    RAISE NOTICE '✅ Sistema de amigos actualizado';
    RAISE NOTICE '🔧 Vista user_friends corregida para usar public.profiles';
    RAISE NOTICE '🔧 Función send_friend_request mejorada';
    RAISE NOTICE '🔧 Función accept_friend_request mejorada';
    RAISE NOTICE '🔧 Función reject_friend_request añadida';
END $$;
