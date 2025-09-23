-- SOLUCIÓN TEMPORAL: Deshabilitar RLS para testing
-- Ejecutar este script SOLO para testing de desarrollo

-- ============================================================================
-- OPCIÓN 1: DESHABILITAR RLS TEMPORALMENTE (SOLO PARA DESARROLLO)
-- ============================================================================

-- ATENCIÓN: Esto debe usarse SOLO en desarrollo, nunca en producción
ALTER TABLE teams DISABLE ROW LEVEL SECURITY;
ALTER TABLE team_members DISABLE ROW LEVEL SECURITY;
ALTER TABLE matches DISABLE ROW LEVEL SECURITY;
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE canchas DISABLE ROW LEVEL SECURITY;
ALTER TABLE sectors DISABLE ROW LEVEL SECURITY;

-- ============================================================================
-- OPCIÓN 2: POLÍTICAS PERMISIVAS PARA DESARROLLO
-- ============================================================================

-- Si prefieres mantener RLS habilitado pero con políticas permisivas:

-- Para teams
DROP POLICY IF EXISTS "allow_all_teams" ON teams;
CREATE POLICY "allow_all_teams" ON teams
  FOR ALL USING (true) WITH CHECK (true);

-- Para team_members  
DROP POLICY IF EXISTS "allow_all_team_members" ON team_members;
CREATE POLICY "allow_all_team_members" ON team_members
  FOR ALL USING (true) WITH CHECK (true);

-- Para matches
DROP POLICY IF EXISTS "allow_all_matches" ON matches;
CREATE POLICY "allow_all_matches" ON matches
  FOR ALL USING (true) WITH CHECK (true);

-- Para users
DROP POLICY IF EXISTS "allow_all_users" ON users;
CREATE POLICY "allow_all_users" ON users
  FOR ALL USING (true) WITH CHECK (true);

-- ============================================================================
-- VERIFICAR CONFIGURACIÓN ACTUAL
-- ============================================================================

-- Verificar si RLS está habilitado
SELECT schemaname, tablename, rowsecurity, forcerlsb 
FROM pg_tables 
WHERE tablename IN ('teams', 'team_members', 'matches', 'users', 'canchas', 'sectors');

-- Ver políticas actuales
SELECT schemaname, tablename, policyname, permissive, roles, cmd
FROM pg_policies 
WHERE tablename IN ('teams', 'team_members', 'matches', 'users')
ORDER BY tablename, policyname;
