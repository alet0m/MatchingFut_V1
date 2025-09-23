-- Añadir campo para controlar ediciones de perfil (1 vez por mes)
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS last_profile_edit TIMESTAMP WITH TIME ZONE DEFAULT NULL;

-- Comentario sobre el campo
COMMENT ON COLUMN profiles.last_profile_edit IS 'Fecha de la última edición completa del perfil (limitado a 1 vez por mes)';

-- Función para verificar si puede editar el perfil
CREATE OR REPLACE FUNCTION can_edit_profile(user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    last_edit TIMESTAMP WITH TIME ZONE;
BEGIN
    SELECT last_profile_edit INTO last_edit
    FROM profiles
    WHERE id = user_id;
    
    -- Si nunca ha editado, puede editar
    IF last_edit IS NULL THEN
        RETURN TRUE;
    END IF;
    
    -- Si han pasado 30 días desde la última edición, puede editar
    IF last_edit < (NOW() - INTERVAL '30 days') THEN
        RETURN TRUE;
    END IF;
    
    -- No puede editar
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para obtener días restantes hasta poder editar
CREATE OR REPLACE FUNCTION days_until_next_edit(user_id UUID)
RETURNS INTEGER AS $$
DECLARE
    last_edit TIMESTAMP WITH TIME ZONE;
    days_remaining INTEGER;
BEGIN
    SELECT last_profile_edit INTO last_edit
    FROM profiles
    WHERE id = user_id;
    
    -- Si nunca ha editado, puede editar ahora
    IF last_edit IS NULL THEN
        RETURN 0;
    END IF;
    
    -- Calcular días restantes
    days_remaining := 30 - EXTRACT(DAY FROM (NOW() - last_edit));
    
    -- Si ya puede editar, devolver 0
    IF days_remaining <= 0 THEN
        RETURN 0;
    END IF;
    
    RETURN days_remaining;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permisos
GRANT EXECUTE ON FUNCTION can_edit_profile(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION days_until_next_edit(UUID) TO authenticated;