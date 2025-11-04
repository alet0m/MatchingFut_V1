-- SCRIPT ACTUALIZADO PARA CREAR SISTEMA DE AMIGOS EN SUPABASE
-- Compatible con FriendsService
-- Ejecutar en SQL Editor de Supabase

-- 1. Crear tabla de amistades (friendships) actualizada
CREATE TABLE IF NOT EXISTS public.friendships (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    requester_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    receiver_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    status text DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
    requested_at timestamptz DEFAULT now(),
    responded_at timestamptz,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    
    -- Constraints
    CONSTRAINT friendship_no_self CHECK (requester_id != receiver_id),
    CONSTRAINT friendship_unique UNIQUE (requester_id, receiver_id)
);

-- 2. Crear índices para optimización
CREATE INDEX IF NOT EXISTS idx_friendships_requester ON public.friendships(requester_id);
CREATE INDEX IF NOT EXISTS idx_friendships_receiver ON public.friendships(receiver_id);
CREATE INDEX IF NOT EXISTS idx_friendships_status ON public.friendships(status);
CREATE INDEX IF NOT EXISTS idx_friendships_requester_status ON public.friendships(requester_id, status);
CREATE INDEX IF NOT EXISTS idx_friendships_receiver_status ON public.friendships(receiver_id, status);

-- 3. Trigger para actualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_friendships_updated_at ON public.friendships;
CREATE TRIGGER update_friendships_updated_at
    BEFORE UPDATE ON public.friendships
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 4. Políticas RLS (Row Level Security)
ALTER TABLE public.friendships ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas existentes si existen
DROP POLICY IF EXISTS "Users can view their own friendships" ON public.friendships;
DROP POLICY IF EXISTS "Users can create friendship requests" ON public.friendships;
DROP POLICY IF EXISTS "Users can update friendships" ON public.friendships;
DROP POLICY IF EXISTS "Users can delete their friendships" ON public.friendships;

-- Política para ver amistades propias
CREATE POLICY "Users can view their own friendships" ON public.friendships
    FOR SELECT USING (
        auth.uid() = requester_id OR auth.uid() = receiver_id
    );

-- Política para crear solicitudes de amistad
CREATE POLICY "Users can create friendship requests" ON public.friendships
    FOR INSERT WITH CHECK (
        auth.uid() = requester_id
    );

-- Política para actualizar amistades (aceptar/rechazar)
CREATE POLICY "Users can update friendships" ON public.friendships
    FOR UPDATE USING (
        auth.uid() = receiver_id  -- Solo el destinatario puede aceptar/rechazar
    ) WITH CHECK (
        auth.uid() = receiver_id
    );

-- Política para eliminar amistades
CREATE POLICY "Users can delete their friendships" ON public.friendships
    FOR DELETE USING (
        auth.uid() = requester_id OR auth.uid() = receiver_id
    );

-- 4. Vista para obtener amigos fácilmente
-- Nota: CREATE OR REPLACE VIEW no permite eliminar columnas existentes.
-- Para evitar el error 42P16 (cannot drop columns from view),
-- primero eliminamos la vista si existe y luego la recreamos.
DROP VIEW IF EXISTS public.user_friends CASCADE;
CREATE OR REPLACE VIEW public.user_friends AS
SELECT DISTINCT
    CASE 
        WHEN f.requester_id = auth.uid() THEN f.receiver_id 
        ELSE f.requester_id 
    END as friend_user_id,
    p.email,
    p.full_name,
    p.profile_picture_url,
    f.status,
    f.created_at as friendship_date
FROM public.friendships f
JOIN public.profiles p ON (
    (f.requester_id = auth.uid() AND p.id = f.receiver_id) OR
    (f.receiver_id = auth.uid() AND p.id = f.requester_id)
)
WHERE f.status = 'accepted';

-- 5. Función para enviar solicitud de amistad
-- Asegurar reemplazo limpio de la función si ya existe con otra firma/nombres
DROP FUNCTION IF EXISTS public.send_friend_request(text);
CREATE OR REPLACE FUNCTION public.send_friend_request(friend_email text)
RETURNS json AS $$
DECLARE
    friend_user_id uuid;
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
    
    -- Insertar solicitud
    INSERT INTO public.friendships (requester_id, receiver_id, status)
    VALUES (auth.uid(), friend_user_id, 'pending')
    ON CONFLICT (requester_id, receiver_id) DO NOTHING;
    
    RETURN json_build_object('success', true, 'message', 'Solicitud enviada');
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'message', 'Error al enviar solicitud');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Función para aceptar solicitud de amistad
-- Asegurar reemplazo limpio de la función si ya existe con otra firma/nombres
DROP FUNCTION IF EXISTS public.accept_friend_request(uuid);
CREATE OR REPLACE FUNCTION public.accept_friend_request(friendship_id uuid)
RETURNS json AS $$
BEGIN
    UPDATE public.friendships 
    SET status = 'accepted', updated_at = now()
    WHERE id = friendship_id AND receiver_id = auth.uid();
    
    IF FOUND THEN
        RETURN json_build_object('success', true, 'message', 'Solicitud aceptada');
    ELSE
        RETURN json_build_object('success', false, 'message', 'Solicitud no encontrada');
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Mensaje de confirmación
DO $$ 
BEGIN
    RAISE NOTICE '✅ Sistema de amigos creado exitosamente';
    RAISE NOTICE '📋 Tablas: friendships, user_friends (vista)';
    RAISE NOTICE '🔐 Políticas RLS configuradas';
    RAISE NOTICE '⚡ Funciones: send_friend_request, accept_friend_request';
END $$;
