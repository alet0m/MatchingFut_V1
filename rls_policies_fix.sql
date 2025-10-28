-- Políticas de Seguridad (RLS) para la aplicación de fútbol Quilicura
-- Este script corrige los problemas de seguridad en las tablas principales

-- ============================================================================
-- DESHABILITAR RLS TEMPORALMENTE PARA CONFIGURACIÓN
-- ============================================================================

-- Primero, vamos a verificar y configurar las políticas correctamente
-- para cada tabla crítica

-- ============================================================================
-- TABLA: teams
-- ============================================================================

-- Eliminar políticas existentes si las hay
DROP POLICY IF EXISTS "teams_select_policy" ON teams;
DROP POLICY IF EXISTS "teams_insert_policy" ON teams;
DROP POLICY IF EXISTS "teams_update_policy" ON teams;
DROP POLICY IF EXISTS "teams_delete_policy" ON teams;

-- Habilitar RLS en la tabla teams
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;

-- Política para SELECT: Todos pueden ver todos los equipos
CREATE POLICY "teams_select_policy" ON teams
  FOR SELECT USING (true);

-- Política para INSERT: Solo usuarios autenticados pueden crear equipos
CREATE POLICY "teams_insert_policy" ON teams
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Política para UPDATE: Solo el capitán puede actualizar el equipo
CREATE POLICY "teams_update_policy" ON teams
  FOR UPDATE USING (
    auth.uid() = captain_id OR 
    auth.uid() IN (
      SELECT user_id FROM team_members 
      WHERE team_id = teams.id 
      AND position = 'Capitán' 
      AND is_active = true
    )
  );

-- Política para DELETE: Solo el capitán puede eliminar el equipo
CREATE POLICY "teams_delete_policy" ON teams
  FOR DELETE USING (
    auth.uid() = captain_id OR 
    auth.uid() IN (
      SELECT user_id FROM team_members 
      WHERE team_id = teams.id 
      AND position = 'Capitán' 
      AND is_active = true
    )
  );

-- ============================================================================
-- TABLA: team_members
-- ============================================================================

-- Eliminar políticas existentes si las hay
DROP POLICY IF EXISTS "team_members_select_policy" ON team_members;
DROP POLICY IF EXISTS "team_members_insert_policy" ON team_members;
DROP POLICY IF EXISTS "team_members_update_policy" ON team_members;
DROP POLICY IF EXISTS "team_members_delete_policy" ON team_members;

-- Habilitar RLS en la tabla team_members
ALTER TABLE team_members ENABLE ROW LEVEL SECURITY;

-- Política para SELECT: Todos pueden ver los miembros de los equipos
CREATE POLICY "team_members_select_policy" ON team_members
  FOR SELECT USING (true);

-- Política para INSERT: Solo usuarios autenticados pueden unirse a equipos
-- y solo el capitán o el propio usuario pueden agregar miembros
CREATE POLICY "team_members_insert_policy" ON team_members
  FOR INSERT WITH CHECK (
    auth.uid() IS NOT NULL AND (
      auth.uid() = user_id OR  -- El propio usuario se une
      auth.uid() IN (
        SELECT captain_id FROM teams WHERE id = team_id
      ) OR  -- El capitán agrega miembros
      auth.uid() IN (
        SELECT user_id FROM team_members 
        WHERE team_id = team_members.team_id 
        AND position = 'Capitán' 
        AND is_active = true
      )
    )
  );

-- Política para UPDATE: Solo el capitán o el propio usuario pueden actualizar
CREATE POLICY "team_members_update_policy" ON team_members
  FOR UPDATE USING (
    auth.uid() = user_id OR  -- El propio usuario
    auth.uid() IN (
      SELECT captain_id FROM teams WHERE id = team_id
    ) OR  -- El capitán
    auth.uid() IN (
      SELECT user_id FROM team_members 
      WHERE team_id = team_members.team_id 
      AND position = 'Capitán' 
      AND is_active = true
    )
  );

-- Política para DELETE: Solo el capitán puede remover miembros
CREATE POLICY "team_members_delete_policy" ON team_members
  FOR DELETE USING (
    auth.uid() IN (
      SELECT captain_id FROM teams WHERE id = team_id
    ) OR
    auth.uid() IN (
      SELECT user_id FROM team_members 
      WHERE team_id = team_members.team_id 
      AND position = 'Capitán' 
      AND is_active = true
    )
  );

-- ============================================================================
-- TABLA: matches
-- ============================================================================

-- Eliminar políticas existentes si las hay
DROP POLICY IF EXISTS "matches_select_policy" ON matches;
DROP POLICY IF EXISTS "matches_insert_policy" ON matches;
DROP POLICY IF EXISTS "matches_update_policy" ON matches;
DROP POLICY IF EXISTS "matches_delete_policy" ON matches;

-- Habilitar RLS en la tabla matches
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;

-- Política para SELECT: Todos pueden ver todos los partidos
CREATE POLICY "matches_select_policy" ON matches
  FOR SELECT USING (true);

-- Política para INSERT: Solo usuarios autenticados pueden crear partidos
-- y deben ser capitanes de uno de los equipos participantes
CREATE POLICY "matches_insert_policy" ON matches
  FOR INSERT WITH CHECK (
    auth.uid() IS NOT NULL AND (
      auth.uid() IN (
        SELECT captain_id FROM teams WHERE id = home_team_id
      ) OR
      auth.uid() IN (
        SELECT captain_id FROM teams WHERE id = away_team_id
      ) OR
      auth.uid() IN (
        SELECT user_id FROM team_members 
        WHERE (team_id = home_team_id OR team_id = away_team_id)
        AND position = 'Capitán' 
        AND is_active = true
      )
    )
  );

-- Política para UPDATE: Solo capitanes de los equipos participantes
CREATE POLICY "matches_update_policy" ON matches
  FOR UPDATE USING (
    auth.uid() IN (
      SELECT captain_id FROM teams WHERE id = home_team_id
    ) OR
    auth.uid() IN (
      SELECT captain_id FROM teams WHERE id = away_team_id
    ) OR
    auth.uid() IN (
      SELECT user_id FROM team_members 
      WHERE (team_id = home_team_id OR team_id = away_team_id)
      AND position = 'Capitán' 
      AND is_active = true
    )
  );

-- Política para DELETE: Solo capitanes de los equipos participantes
CREATE POLICY "matches_delete_policy" ON matches
  FOR DELETE USING (
    auth.uid() IN (
      SELECT captain_id FROM teams WHERE id = home_team_id
    ) OR
    auth.uid() IN (
      SELECT captain_id FROM teams WHERE id = away_team_id
    ) OR
    auth.uid() IN (
      SELECT user_id FROM team_members 
      WHERE (team_id = home_team_id OR team_id = away_team_id)
      AND position = 'Capitán' 
      AND is_active = true
    )
  );

-- ============================================================================
-- TABLA: users (perfil público)
-- ============================================================================

-- Eliminar políticas existentes si las hay
DROP POLICY IF EXISTS "users_select_policy" ON users;
DROP POLICY IF EXISTS "users_insert_policy" ON users;
DROP POLICY IF EXISTS "users_update_policy" ON users;

-- Habilitar RLS en la tabla users
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Política para SELECT: Todos pueden ver perfiles públicos
CREATE POLICY "users_select_policy" ON users
  FOR SELECT USING (true);

-- Política para INSERT: Solo el propio usuario puede crear su perfil
CREATE POLICY "users_insert_policy" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Política para UPDATE: Solo el propio usuario puede actualizar su perfil
CREATE POLICY "users_update_policy" ON users
  FOR UPDATE USING (auth.uid() = id);

-- ============================================================================
-- VERIFICACIÓN DE POLÍTICAS
-- ============================================================================

-- Mostrar todas las políticas creadas
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename IN ('teams', 'team_members', 'matches', 'users')
ORDER BY tablename, policyname;

-- ============================================================================
-- FUNCIONES AUXILIARES PARA DEPURACIÓN
-- ============================================================================

-- Función para verificar si un usuario es capitán de un equipo
CREATE OR REPLACE FUNCTION is_team_captain(team_uuid UUID, user_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM teams 
    WHERE id = team_uuid AND captain_id = user_uuid
  ) OR EXISTS (
    SELECT 1 FROM team_members
    WHERE team_id = team_uuid 
    AND user_id = user_uuid 
    AND position = 'Capitán' 
    AND is_active = true
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para obtener información de depuración del usuario actual
CREATE OR REPLACE FUNCTION get_auth_info()
RETURNS TABLE (
  current_user_id UUID,
  is_authenticated BOOLEAN,
  user_email TEXT
) AS $$
BEGIN
  RETURN QUERY SELECT 
    auth.uid(),
    auth.uid() IS NOT NULL,
    auth.email();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- COMENTARIOS Y DOCUMENTACIÓN
-- ============================================================================

COMMENT ON POLICY "teams_select_policy" ON teams IS 
'Permite a todos los usuarios ver todos los equipos públicamente';

COMMENT ON POLICY "teams_insert_policy" ON teams IS 
'Solo usuarios autenticados pueden crear equipos';

COMMENT ON POLICY "teams_update_policy" ON teams IS 
'Solo el capitán del equipo puede actualizar la información del equipo';

COMMENT ON POLICY "matches_insert_policy" ON matches IS 
'Solo capitanes de equipos participantes pueden crear partidos';

COMMENT ON FUNCTION is_team_captain(UUID, UUID) IS 
'Función auxiliar para verificar si un usuario es capitán de un equipo específico';

COMMENT ON FUNCTION get_auth_info() IS 
'Función de depuración para obtener información del usuario autenticado actual';
