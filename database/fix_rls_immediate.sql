-- ============================================================================
-- CONFIGURACIÓN SEGURA E INMEDIATA PARA FÚTBOL QUILICURA
-- Este script soluciona el error RLS de manera SEGURA y FUNCIONAL
-- ============================================================================

-- IMPORTANTE: Esta es la configuración SEGURA que usaremos en producción
-- No es temporal, es la configuración definitiva

-- ============================================================================
-- PASO 1: LIMPIAR POLÍTICAS CONFLICTIVAS
-- ============================================================================

-- Eliminar políticas que puedan estar causando el error 42501
DROP POLICY IF EXISTS "teams_select_policy" ON teams;
DROP POLICY IF EXISTS "teams_insert_policy" ON teams;
DROP POLICY IF EXISTS "teams_update_policy" ON teams;
DROP POLICY IF EXISTS "teams_delete_policy" ON teams;
DROP POLICY IF EXISTS "allow_all_teams" ON teams;

-- ============================================================================
-- PASO 2: CONFIGURAR RLS SEGURO EN USERS
-- ============================================================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_select_public" ON users
  FOR SELECT USING (true);

CREATE POLICY "users_insert_own" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "users_update_own" ON users
  FOR UPDATE USING (auth.uid() = id);

-- ============================================================================
-- PASO 3: CONFIGURAR RLS SEGURO EN TEAMS (SOLUCIÓN AL ERROR)
-- ============================================================================

ALTER TABLE teams ENABLE ROW LEVEL SECURITY;

-- Todos pueden ver equipos
CREATE POLICY "teams_select_all" ON teams
  FOR SELECT USING (true);

-- CLAVE: Solo usuarios autenticados pueden crear equipos Y deben ser el capitán
CREATE POLICY "teams_insert_auth_captain" ON teams
  FOR INSERT WITH CHECK (
    auth.uid() IS NOT NULL AND 
    auth.uid() = captain_id
  );

-- Solo el capitán puede actualizar
CREATE POLICY "teams_update_captain" ON teams
  FOR UPDATE USING (auth.uid() = captain_id);

-- Solo el capitán puede eliminar
CREATE POLICY "teams_delete_captain" ON teams
  FOR DELETE USING (auth.uid() = captain_id);

-- ============================================================================
-- PASO 3.5: CONFIGURAR RLS SEGURO EN TEAM_MEMBERS
-- ============================================================================

ALTER TABLE team_members ENABLE ROW LEVEL SECURITY;

-- Todos pueden ver miembros de equipos
CREATE POLICY "team_members_select_all" ON team_members
  FOR SELECT USING (true);

-- El capitán puede agregar miembros O el usuario se puede unir
CREATE POLICY "team_members_insert_captain_or_self" ON team_members
  FOR INSERT WITH CHECK (
    auth.uid() IS NOT NULL AND (
      auth.uid() = (SELECT captain_id FROM teams WHERE id = team_id) OR
      auth.uid() = user_id
    )
  );

-- Solo el capitán puede actualizar estados
CREATE POLICY "team_members_update_captain" ON team_members
  FOR UPDATE USING (
    auth.uid() = (SELECT captain_id FROM teams WHERE id = team_id)
  );

-- El capitán puede remover O el usuario se puede salir
CREATE POLICY "team_members_delete_captain_or_self" ON team_members
  FOR DELETE USING (
    auth.uid() = (SELECT captain_id FROM teams WHERE id = team_id) OR
    auth.uid() = user_id
  );

-- ============================================================================
-- PASO 4: ASEGURAR SINCRONIZACIÓN DE USUARIOS
-- ============================================================================

-- Función para usuarios nuevos
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (
    id, 
    email, 
    full_name, 
    created_at, 
    updated_at
  )
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
    NEW.created_at,
    NEW.updated_at
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    updated_at = EXCLUDED.updated_at;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para sincronización automática
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Migrar usuarios existentes
INSERT INTO public.users (id, email, full_name, created_at, updated_at)
SELECT 
  au.id,
  au.email,
  COALESCE(au.raw_user_meta_data->>'full_name', au.email) as full_name,
  au.created_at,
  au.updated_at
FROM auth.users au
LEFT JOIN public.users pu ON au.id = pu.id
WHERE pu.id IS NULL
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- VERIFICACIÓN DE ÉXITO
-- ============================================================================

-- Verificar configuración
SELECT 
    'STATUS' as info,
    tablename,
    CASE WHEN rowsecurity THEN 'RLS ENABLED' ELSE 'RLS DISABLED' END as estado
FROM pg_tables 
WHERE tablename IN ('teams', 'users')
ORDER BY tablename;

-- Mostrar políticas activas
SELECT 
    tablename,
    policyname,
    cmd as operacion
FROM pg_policies 
WHERE tablename IN ('teams', 'users')
ORDER BY tablename, cmd;

-- Test de datos
SELECT COUNT(*) as auth_users FROM auth.users;
SELECT COUNT(*) as public_users FROM users;
