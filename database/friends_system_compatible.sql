-- SCRIPT COMPATIBLE CON TU BASE DE DATOS EXISTENTE
-- Adaptado para trabajar con el esquema actual
-- Ejecutar en SQL Editor de Supabase

-- 1. La tabla friendships ya existe, solo necesitamos agregar políticas RLS
-- Verificar estructura actual:
-- friendships (requester_id, receiver_id, status, created_at, updated_at, accepted_at)

-- Habilitar RLS en la tabla existente
ALTER TABLE public.friendships ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas existentes si existen
DROP POLICY IF EXISTS "Users can view their own friendships" ON public.friendships;
DROP POLICY IF EXISTS "Users can create friendship requests" ON public.friendships;
DROP POLICY IF EXISTS "Users can update friendships" ON public.friendships;
DROP POLICY IF EXISTS "Users can delete their friendships" ON public.friendships;

-- Política para ver amistades propias (adaptada a tu esquema)
CREATE POLICY "Users can view their own friendships" ON public.friendships
    FOR SELECT USING (
        requester_id = auth.uid() OR receiver_id = auth.uid()
    );

-- Política para crear solicitudes de amistad
CREATE POLICY "Users can create friendship requests" ON public.friendships
    FOR INSERT WITH CHECK (
        requester_id = auth.uid()
    );

-- Política para actualizar amistades (aceptar/rechazar)
CREATE POLICY "Users can update friendships" ON public.friendships
    FOR UPDATE USING (
        receiver_id = auth.uid()  -- Solo el receptor puede aceptar/rechazar
    ) WITH CHECK (
        receiver_id = auth.uid()
    );

-- Política para eliminar amistades
CREATE POLICY "Users can delete their friendships" ON public.friendships
    FOR DELETE USING (
        requester_id = auth.uid() OR receiver_id = auth.uid()
    );

-- 2. Crear función para obtener amigos (adaptada a tu esquema)
CREATE OR REPLACE FUNCTION get_user_friends(user_id_param UUID DEFAULT auth.uid())
RETURNS TABLE (
    friend_id UUID,
    friend_email TEXT,
    friend_name TEXT,
    friend_tag TEXT,
    friend_photo TEXT,
    friendship_date TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        CASE 
            WHEN f.requester_id = user_id_param THEN f.receiver_id
            ELSE f.requester_id
        END as friend_id,
        p.email as friend_email,
        p.full_name as friend_name,
        p.tag as friend_tag,
        p.profile_picture_url as friend_photo,
        f.accepted_at as friendship_date
    FROM public.friendships f
    JOIN public.profiles p ON (
        (f.requester_id = user_id_param AND p.id = f.receiver_id) OR
        (f.receiver_id = user_id_param AND p.id = f.requester_id)
    )
    WHERE f.status = 'accepted'
    AND (f.requester_id = user_id_param OR f.receiver_id = user_id_param);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Crear función para obtener solicitudes pendientes
CREATE OR REPLACE FUNCTION get_friend_requests(user_id_param UUID DEFAULT auth.uid())
RETURNS TABLE (
    request_id UUID,
    requester_id UUID,
    requester_email TEXT,
    requester_name TEXT,
    requester_tag TEXT,
    requester_photo TEXT,
    requested_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        f.id as request_id,
        f.requester_id,
        p.email as requester_email,
        p.full_name as requester_name,
        p.tag as requester_tag,
        p.profile_picture_url as requester_photo,
        f.created_at as requested_at
    FROM public.friendships f
    JOIN public.profiles p ON p.id = f.requester_id
    WHERE f.receiver_id = user_id_param 
    AND f.status = 'pending';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Crear función para enviar solicitud de amistad
CREATE OR REPLACE FUNCTION send_friend_request_by_tag(friend_tag_param TEXT)
RETURNS JSON AS $$
DECLARE
    friend_user_id UUID;
    existing_friendship UUID;
BEGIN
    -- Buscar usuario por tag
    SELECT id INTO friend_user_id 
    FROM public.profiles 
    WHERE tag = friend_tag_param;
    
    IF friend_user_id IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Usuario no encontrado');
    END IF;
    
    IF friend_user_id = auth.uid() THEN
        RETURN json_build_object('success', false, 'message', 'No puedes agregarte a ti mismo');
    END IF;
    
    -- Verificar si ya existe una amistad
    SELECT id INTO existing_friendship 
    FROM public.friendships 
    WHERE (requester_id = auth.uid() AND receiver_id = friend_user_id)
    OR (requester_id = friend_user_id AND receiver_id = auth.uid());
    
    IF existing_friendship IS NOT NULL THEN
        RETURN json_build_object('success', false, 'message', 'Ya existe una solicitud o amistad');
    END IF;
    
    -- Insertar solicitud
    INSERT INTO public.friendships (requester_id, receiver_id, status)
    VALUES (auth.uid(), friend_user_id, 'pending');
    
    RETURN json_build_object('success', true, 'message', 'Solicitud enviada correctamente');
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'message', 'Error al enviar solicitud: ' || SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Crear función para aceptar solicitud de amistad
CREATE OR REPLACE FUNCTION accept_friend_request(friendship_id_param UUID)
RETURNS JSON AS $$
BEGIN
    UPDATE public.friendships 
    SET status = 'accepted', 
        accepted_at = NOW(),
        updated_at = NOW()
    WHERE id = friendship_id_param 
    AND receiver_id = auth.uid()
    AND status = 'pending';
    
    IF FOUND THEN
        RETURN json_build_object('success', true, 'message', 'Solicitud aceptada');
    ELSE
        RETURN json_build_object('success', false, 'message', 'Solicitud no encontrada o ya procesada');
    END IF;
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'message', 'Error al aceptar solicitud: ' || SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Crear función para rechazar solicitud de amistad
CREATE OR REPLACE FUNCTION reject_friend_request(friendship_id_param UUID)
RETURNS JSON AS $$
BEGIN
    UPDATE public.friendships 
    SET status = 'rejected', 
        updated_at = NOW()
    WHERE id = friendship_id_param 
    AND receiver_id = auth.uid()
    AND status = 'pending';
    
    IF FOUND THEN
        RETURN json_build_object('success', true, 'message', 'Solicitud rechazada');
    ELSE
        RETURN json_build_object('success', false, 'message', 'Solicitud no encontrada');
    END IF;
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'message', 'Error al rechazar solicitud: ' || SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. Crear función para buscar usuarios por nombre/tag
CREATE OR REPLACE FUNCTION search_users_for_friends(search_term TEXT)
RETURNS TABLE (
    user_id UUID,
    full_name TEXT,
    tag TEXT,
    email TEXT,
    profile_picture_url TEXT,
    is_friend BOOLEAN,
    has_pending_request BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id as user_id,
        p.full_name,
        p.tag,
        p.email,
        p.profile_picture_url,
        EXISTS (
            SELECT 1 FROM public.friendships f 
            WHERE ((f.requester_id = auth.uid() AND f.receiver_id = p.id) 
                OR (f.requester_id = p.id AND f.receiver_id = auth.uid()))
            AND f.status = 'accepted'
        ) as is_friend,
        EXISTS (
            SELECT 1 FROM public.friendships f 
            WHERE ((f.requester_id = auth.uid() AND f.receiver_id = p.id) 
                OR (f.requester_id = p.id AND f.receiver_id = auth.uid()))
            AND f.status = 'pending'
        ) as has_pending_request
    FROM public.profiles p
    WHERE p.id != auth.uid()
    AND p.is_active = true
    AND (
        p.full_name ILIKE '%' || search_term || '%' OR
        p.tag ILIKE '%' || search_term || '%' OR
        p.email ILIKE '%' || search_term || '%'
    )
    ORDER BY p.full_name
    LIMIT 20;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Crear índices si no existen
CREATE INDEX IF NOT EXISTS idx_friendships_requester_status ON public.friendships(requester_id, status);
CREATE INDEX IF NOT EXISTS idx_friendships_receiver_status ON public.friendships(receiver_id, status);
CREATE INDEX IF NOT EXISTS idx_profiles_tag ON public.profiles(tag);
CREATE INDEX IF NOT EXISTS idx_profiles_full_name ON public.profiles(full_name);

-- Mensaje de confirmación
DO $$ 
BEGIN
    RAISE NOTICE '✅ Sistema de amigos compatible creado exitosamente';
    RAISE NOTICE '📋 Tabla friendships actualizada con RLS';
    RAISE NOTICE '🔐 Políticas de seguridad configuradas';
    RAISE NOTICE '⚡ Funciones creadas: get_user_friends, get_friend_requests, send_friend_request_by_tag';
    RAISE NOTICE '🔍 Función de búsqueda: search_users_for_friends';
    RAISE NOTICE '✋ Funciones de respuesta: accept_friend_request, reject_friend_request';
END $$;