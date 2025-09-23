-- SCRIPT PARA CREAR SISTEMA DE AMIGOS EN SUPABASE
-- Ejecutar en SQL Editor de Supabase

-- 1. Crear tabla de amistades (friendships)
CREATE TABLE IF NOT EXISTS public.friendships (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    friend_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
    status text DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    
    -- Evitar duplicados
    UNIQUE(user_id, friend_id)
);

-- 2. Crear índices para optimización
CREATE INDEX IF NOT EXISTS idx_friendships_user_id ON public.friendships(user_id);
CREATE INDEX IF NOT EXISTS idx_friendships_friend_id ON public.friendships(friend_id);
CREATE INDEX IF NOT EXISTS idx_friendships_status ON public.friendships(status);

-- 3. Políticas RLS (Row Level Security)
ALTER TABLE public.friendships ENABLE ROW LEVEL SECURITY;

-- Política para ver amistades propias
CREATE POLICY "Users can view their own friendships" ON public.friendships
    FOR SELECT USING (
        auth.uid() = user_id OR auth.uid() = friend_id
    );

-- Política para crear solicitudes de amistad
CREATE POLICY "Users can create friendship requests" ON public.friendships
    FOR INSERT WITH CHECK (
        auth.uid() = user_id
    );

-- Política para actualizar amistades (aceptar/rechazar)
CREATE POLICY "Users can update friendships" ON public.friendships
    FOR UPDATE USING (
        auth.uid() = friend_id  -- Solo el destinatario puede aceptar/rechazar
    );

-- Política para eliminar amistades
CREATE POLICY "Users can delete their friendships" ON public.friendships
    FOR DELETE USING (
        auth.uid() = user_id OR auth.uid() = friend_id
    );

-- 4. Vista para obtener amigos fácilmente
CREATE OR REPLACE VIEW public.user_friends AS
SELECT DISTINCT
    CASE 
        WHEN f.user_id = auth.uid() THEN f.friend_id 
        ELSE f.user_id 
    END as friend_user_id,
    u.email,
    u.full_name,
    u.profile_image_url,
    f.status,
    f.created_at as friendship_date
FROM public.friendships f
JOIN public.users u ON (
    (f.user_id = auth.uid() AND u.id = f.friend_id) OR
    (f.friend_id = auth.uid() AND u.id = f.user_id)
)
WHERE f.status = 'accepted';

-- 5. Función para enviar solicitud de amistad
CREATE OR REPLACE FUNCTION public.send_friend_request(friend_email text)
RETURNS json AS $$
DECLARE
    friend_user_id uuid;
    result json;
BEGIN
    -- Buscar usuario por email
    SELECT id INTO friend_user_id 
    FROM auth.users 
    WHERE email = friend_email;
    
    IF friend_user_id IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Usuario no encontrado');
    END IF;
    
    IF friend_user_id = auth.uid() THEN
        RETURN json_build_object('success', false, 'message', 'No puedes agregarte a ti mismo');
    END IF;
    
    -- Insertar solicitud
    INSERT INTO public.friendships (user_id, friend_id, status)
    VALUES (auth.uid(), friend_user_id, 'pending')
    ON CONFLICT (user_id, friend_id) DO NOTHING;
    
    RETURN json_build_object('success', true, 'message', 'Solicitud enviada');
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'message', 'Error al enviar solicitud');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Función para aceptar solicitud de amistad
CREATE OR REPLACE FUNCTION public.accept_friend_request(friendship_id uuid)
RETURNS json AS $$
BEGIN
    UPDATE public.friendships 
    SET status = 'accepted', updated_at = now()
    WHERE id = friendship_id AND friend_id = auth.uid();
    
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
