-- Script para alinear el sistema de amigos con el esquema completo de la base de datos
-- Ejecutar en SQL Editor de Supabase

-- 1. Primero, verificar si tenemos que modificar la estructura de la tabla de amistades
DO $$
BEGIN
    -- Verificar si la tabla friendships tiene los campos requester_id y receiver_id
    IF EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'friendships' 
        AND column_name = 'requester_id'
    ) THEN
        -- Si tiene la estructura nueva, actualizar la vista para que use la estructura correcta
        RAISE NOTICE 'Actualizando vista para usar requester_id/receiver_id';
        
        EXECUTE '
        CREATE OR REPLACE VIEW public.user_friends AS
        SELECT DISTINCT
            CASE 
                WHEN f.requester_id = auth.uid() THEN f.receiver_id 
                ELSE f.requester_id 
            END as friend_user_id,
            COALESCE(p.email, '''') as email,
            COALESCE(p.full_name, ''Sin nombre'') as full_name,
            COALESCE(p.profile_image_url, p.profile_picture_url) as profile_image_url,
            f.status,
            f.created_at as friendship_date,
            f.accepted_at
        FROM public.friendships f
        JOIN public.profiles p ON (
            (f.requester_id = auth.uid() AND p.id = f.receiver_id) OR
            (f.receiver_id = auth.uid() AND p.id = f.requester_id)
        )
        WHERE f.status = ''accepted'';
        ';
        
        -- Actualizar función para enviar solicitudes
        EXECUTE '
        CREATE OR REPLACE FUNCTION public.send_friend_request(friend_email text)
        RETURNS json AS $$
        DECLARE
            friend_user_id uuid;
            existing_request uuid;
            result json;
        BEGIN
            -- Buscar usuario por email en la tabla profiles
            SELECT id INTO friend_user_id 
            FROM public.profiles 
            WHERE email = friend_email;
            
            IF friend_user_id IS NULL THEN
                RETURN json_build_object(''success'', false, ''message'', ''Usuario no encontrado'');
            END IF;
            
            IF friend_user_id = auth.uid() THEN
                RETURN json_build_object(''success'', false, ''message'', ''No puedes agregarte a ti mismo'');
            END IF;
            
            -- Verificar si ya existe una solicitud o amistad
            SELECT id INTO existing_request
            FROM public.friendships
            WHERE 
                (requester_id = auth.uid() AND receiver_id = friend_user_id) OR
                (requester_id = friend_user_id AND receiver_id = auth.uid());
                
            IF existing_request IS NOT NULL THEN
                -- Verificar el estado de la solicitud existente
                DECLARE
                    existing_status text;
                BEGIN
                    SELECT status INTO existing_status FROM public.friendships WHERE id = existing_request;
                    
                    IF existing_status = ''accepted'' THEN
                        RETURN json_build_object(''success'', false, ''message'', ''Esta persona ya es tu amigo'');
                    ELSIF existing_status = ''pending'' THEN
                        RETURN json_build_object(''success'', false, ''message'', ''Ya existe una solicitud pendiente'');
                    ELSE
                        RETURN json_build_object(''success'', false, ''message'', ''Ya existe una relación con este usuario'');
                    END IF;
                END;
            END IF;
            
            -- Insertar solicitud
            INSERT INTO public.friendships (requester_id, receiver_id, status)
            VALUES (auth.uid(), friend_user_id, ''pending'');
            
            RETURN json_build_object(''success'', true, ''message'', ''Solicitud enviada'');
            
        EXCEPTION WHEN OTHERS THEN
            RETURN json_build_object(''success'', false, ''message'', ''Error al enviar solicitud: '' || SQLERRM);
        END;
        $$ LANGUAGE plpgsql SECURITY DEFINER;
        ';
        
        -- Actualizar función para aceptar solicitudes
        EXECUTE '
        CREATE OR REPLACE FUNCTION public.accept_friend_request(friendship_id uuid)
        RETURNS json AS $$
        DECLARE
            current_status text;
            friend_name text;
        BEGIN
            -- Verificar primero si la solicitud existe y está pendiente
            SELECT status INTO current_status 
            FROM public.friendships 
            WHERE id = friendship_id AND receiver_id = auth.uid();
            
            IF current_status IS NULL THEN
                RETURN json_build_object(''success'', false, ''message'', ''Solicitud no encontrada o no autorizada'');
            END IF;
            
            IF current_status != ''pending'' THEN
                RETURN json_build_object(''success'', false, ''message'', ''Esta solicitud ya ha sido '' || 
                    CASE current_status 
                        WHEN ''accepted'' THEN ''aceptada'' 
                        WHEN ''rejected'' THEN ''rechazada'' 
                        ELSE ''procesada'' 
                    END);
            END IF;
            
            -- Obtener el nombre del amigo para un mensaje más personalizado
            SELECT p.full_name INTO friend_name
            FROM public.friendships f
            JOIN public.profiles p ON f.requester_id = p.id
            WHERE f.id = friendship_id;
            
            -- Actualizar la solicitud
            UPDATE public.friendships 
            SET status = ''accepted'', 
                updated_at = now(),
                accepted_at = now()
            WHERE id = friendship_id AND receiver_id = auth.uid();
            
            RETURN json_build_object(''success'', true, ''message'', ''Solicitud aceptada'' || 
                CASE WHEN friend_name IS NOT NULL THEN '', ahora eres amigo de '' || friend_name ELSE '''' END);
            
        EXCEPTION WHEN OTHERS THEN
            RETURN json_build_object(''success'', false, ''message'', ''Error al procesar solicitud: '' || SQLERRM);
        END;
        $$ LANGUAGE plpgsql SECURITY DEFINER;
        ';
        
        -- Actualizar función para rechazar solicitudes
        EXECUTE '
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
                RETURN json_build_object(''success'', false, ''message'', ''Solicitud no encontrada o no autorizada'');
            END IF;
            
            IF current_status != ''pending'' THEN
                RETURN json_build_object(''success'', false, ''message'', ''Esta solicitud ya ha sido '' || 
                    CASE current_status 
                        WHEN ''accepted'' THEN ''aceptada'' 
                        WHEN ''rejected'' THEN ''rechazada'' 
                        ELSE ''procesada'' 
                    END);
            END IF;
            
            -- Actualizar la solicitud
            UPDATE public.friendships 
            SET status = ''rejected'', 
                updated_at = now()
            WHERE id = friendship_id AND receiver_id = auth.uid();
            
            RETURN json_build_object(''success'', true, ''message'', ''Solicitud rechazada'');
            
        EXCEPTION WHEN OTHERS THEN
            RETURN json_build_object(''success'', false, ''message'', ''Error al rechazar solicitud: '' || SQLERRM);
        END;
        $$ LANGUAGE plpgsql SECURITY DEFINER;
        ';
        
    ELSE
        -- Si tiene la estructura antigua (user_id/friend_id), crear vista y funciones para esa estructura
        RAISE NOTICE 'Actualizando vista para usar user_id/friend_id';
        
        EXECUTE '
        CREATE OR REPLACE VIEW public.user_friends AS
        SELECT DISTINCT
            CASE 
                WHEN f.user_id = auth.uid() THEN f.friend_id 
                ELSE f.user_id 
            END as friend_user_id,
            COALESCE(p.email, '''') as email,
            COALESCE(p.full_name, ''Sin nombre'') as full_name,
            COALESCE(p.profile_image_url, p.profile_picture_url) as profile_image_url,
            f.status,
            f.created_at as friendship_date
        FROM public.friendships f
        JOIN public.profiles p ON (
            (f.user_id = auth.uid() AND p.id = f.friend_id) OR
            (f.friend_id = auth.uid() AND p.id = f.user_id)
        )
        WHERE f.status = ''accepted'';
        ';
        
        -- Función para enviar solicitudes (estructura antigua)
        EXECUTE '
        CREATE OR REPLACE FUNCTION public.send_friend_request(friend_email text)
        RETURNS json AS $$
        DECLARE
            friend_user_id uuid;
            existing_request uuid;
            result json;
        BEGIN
            -- Buscar usuario por email en la tabla profiles
            SELECT id INTO friend_user_id 
            FROM public.profiles 
            WHERE email = friend_email;
            
            IF friend_user_id IS NULL THEN
                RETURN json_build_object(''success'', false, ''message'', ''Usuario no encontrado'');
            END IF;
            
            IF friend_user_id = auth.uid() THEN
                RETURN json_build_object(''success'', false, ''message'', ''No puedes agregarte a ti mismo'');
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
                    
                    IF existing_status = ''accepted'' THEN
                        RETURN json_build_object(''success'', false, ''message'', ''Esta persona ya es tu amigo'');
                    ELSIF existing_status = ''pending'' THEN
                        RETURN json_build_object(''success'', false, ''message'', ''Ya existe una solicitud pendiente'');
                    ELSE
                        RETURN json_build_object(''success'', false, ''message'', ''Ya existe una relación con este usuario'');
                    END IF;
                END;
            END IF;
            
            -- Insertar solicitud
            INSERT INTO public.friendships (user_id, friend_id, status)
            VALUES (auth.uid(), friend_user_id, ''pending'');
            
            RETURN json_build_object(''success'', true, ''message'', ''Solicitud enviada'');
            
        EXCEPTION WHEN OTHERS THEN
            RETURN json_build_object(''success'', false, ''message'', ''Error al enviar solicitud: '' || SQLERRM);
        END;
        $$ LANGUAGE plpgsql SECURITY DEFINER;
        ';
    END IF;
    
END
$$;

-- 2. Función para obtener todas las solicitudes de amistad pendientes
CREATE OR REPLACE FUNCTION public.get_pending_friend_requests()
RETURNS TABLE (
    id uuid,
    sender_id uuid,
    sender_name text,
    sender_email text,
    sender_image text,
    created_at timestamptz
) AS $$
BEGIN
    -- Verificar estructura de la tabla
    IF EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'friendships' 
        AND column_name = 'requester_id'
    ) THEN
        -- Estructura nueva
        RETURN QUERY
        SELECT 
            f.id,
            f.requester_id as sender_id,
            p.full_name as sender_name,
            p.email as sender_email,
            COALESCE(p.profile_image_url, p.profile_picture_url) as sender_image,
            f.created_at
        FROM 
            public.friendships f
        JOIN 
            public.profiles p ON f.requester_id = p.id
        WHERE 
            f.receiver_id = auth.uid() AND 
            f.status = 'pending';
    ELSE
        -- Estructura antigua
        RETURN QUERY
        SELECT 
            f.id,
            f.user_id as sender_id,
            p.full_name as sender_name,
            p.email as sender_email,
            COALESCE(p.profile_image_url, p.profile_picture_url) as sender_image,
            f.created_at
        FROM 
            public.friendships f
        JOIN 
            public.profiles p ON f.user_id = p.id
        WHERE 
            f.friend_id = auth.uid() AND 
            f.status = 'pending';
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Función para eliminar amistades
CREATE OR REPLACE FUNCTION public.remove_friend(friend_id uuid)
RETURNS json AS $$
DECLARE
    friendship_deleted boolean := false;
BEGIN
    -- Verificar estructura de la tabla
    IF EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'friendships' 
        AND column_name = 'requester_id'
    ) THEN
        -- Estructura nueva
        DELETE FROM public.friendships
        WHERE 
            ((requester_id = auth.uid() AND receiver_id = friend_id) OR
            (requester_id = friend_id AND receiver_id = auth.uid())) AND
            status = 'accepted';
            
        GET DIAGNOSTICS friendship_deleted = ROW_COUNT;
    ELSE
        -- Estructura antigua
        DELETE FROM public.friendships
        WHERE 
            ((user_id = auth.uid() AND friend_id = friend_id) OR
            (user_id = friend_id AND friend_id = auth.uid())) AND
            status = 'accepted';
            
        GET DIAGNOSTICS friendship_deleted = ROW_COUNT;
    END IF;
    
    IF friendship_deleted THEN
        RETURN json_build_object('success', true, 'message', 'Amistad eliminada correctamente');
    ELSE
        RETURN json_build_object('success', false, 'message', 'No se encontró la amistad o no tienes permisos para eliminarla');
    END IF;
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'message', 'Error al eliminar amistad: ' || SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Mensajes de confirmación
DO $$ 
BEGIN
    RAISE NOTICE '✅ Sistema de amigos actualizado completamente';
    RAISE NOTICE '🔧 Ajustada vista user_friends para trabajar con la estructura actual de la base de datos';
    RAISE NOTICE '🔧 Funciones actualizadas para manejar correctamente la estructura de la base de datos';
    RAISE NOTICE '🔧 Nueva función get_pending_friend_requests agregada';
    RAISE NOTICE '🔧 Nueva función remove_friend agregada';
END $$;
