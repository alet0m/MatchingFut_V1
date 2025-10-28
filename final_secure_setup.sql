-- ============================================================================
-- SOLUCIÓN DEFINITIVA: CONFIGURACIÓN RLS SEGURA PARA FÚTBOL QUILICURA
-- Ejecutar este script completo en Supabase SQL Editor
-- ============================================================================

-- ============================================================================
-- PASO 1: LIMPIAR CONFIGURACIÓN ANTERIOR
-- ============================================================================

-- Eliminar políticas conflictivas
DROP POLICY IF EXISTS "teams_select_policy" ON teams;
DROP POLICY IF EXISTS "teams_insert_policy" ON teams;
DROP POLICY IF EXISTS "teams_update_policy" ON teams;
DROP POLICY IF EXISTS "teams_delete_policy" ON teams;
DROP POLICY IF EXISTS "allow_all_teams" ON teams;

DROP POLICY IF EXISTS "team_members_select_policy" ON team_members;
DROP POLICY IF EXISTS "team_members_insert_policy" ON team_members;
DROP POLICY IF EXISTS "team_members_update_policy" ON team_members;
DROP POLICY IF EXISTS "team_members_delete_policy" ON team_members;

-- ============================================================================
-- PASO 2: CONFIGURAR SINCRONIZACIÓN DE USUARIOS
-- ============================================================================

-- Función para sincronizar usuarios automáticamente
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

-- Trigger para usuarios nuevos
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
-- PASO 3: CONFIGURAR RLS SEGURO PARA USERS
-- ============================================================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_select_public" ON users
  FOR SELECT USING (true);

CREATE POLICY "users_insert_own" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "users_update_own" ON users
  FOR UPDATE USING (auth.uid() = id);

-- ============================================================================
-- PASO 4: CONFIGURAR RLS SEGURO PARA TEAMS
-- ============================================================================

ALTER TABLE teams ENABLE ROW LEVEL SECURITY;

-- Todos pueden ver equipos (necesario para funcionalidad)
CREATE POLICY "teams_select_all" ON teams
  FOR SELECT USING (true);

-- Solo usuarios autenticados pueden crear equipos como capitanes
CREATE POLICY "teams_insert_auth_captain" ON teams
  FOR INSERT WITH CHECK (
    auth.uid() IS NOT NULL AND 
    auth.uid() = captain_id
  );

-- Solo el capitán puede actualizar su equipo
CREATE POLICY "teams_update_captain" ON teams
  FOR UPDATE USING (auth.uid() = captain_id);

-- Solo el capitán puede eliminar su equipo
CREATE POLICY "teams_delete_captain" ON teams
  FOR DELETE USING (auth.uid() = captain_id);

-- ============================================================================
-- PASO 5: CONFIGURAR RLS SEGURO PARA TEAM_MEMBERS
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

-- Solo el capitán puede actualizar estados de miembros
CREATE POLICY "team_members_update_captain" ON team_members
  FOR UPDATE USING (
    auth.uid() = (SELECT captain_id FROM teams WHERE id = team_id)
  );

-- El capitán puede remover miembros O el usuario se puede salir
CREATE POLICY "team_members_delete_captain_or_self" ON team_members
  FOR DELETE USING (
    auth.uid() = (SELECT captain_id FROM teams WHERE id = team_id) OR
    auth.uid() = user_id
  );

-- ============================================================================
-- PASO 6: CONFIGURAR RLS BÁSICO PARA MATCHES
-- ============================================================================

ALTER TABLE matches ENABLE ROW LEVEL SECURITY;

-- Todos pueden ver partidos
CREATE POLICY "matches_select_all" ON matches
  FOR SELECT USING (true);

-- Solo capitanes pueden crear partidos entre sus equipos
CREATE POLICY "matches_insert_captain" ON matches
  FOR INSERT WITH CHECK (
    auth.uid() IS NOT NULL AND (
      auth.uid() = (SELECT captain_id FROM teams WHERE id = home_team_id) OR
      auth.uid() = (SELECT captain_id FROM teams WHERE id = away_team_id)
    )
  );

-- ============================================================================
-- PASO 7: CREAR TABLAS FALTANTES Y CONFIGURAR REFERENCIAS
-- ============================================================================

-- Crear tabla sectors si no existe
CREATE TABLE IF NOT EXISTS sectors (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    boundaries GEOMETRY(POLYGON, 4326),
    territory_level INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear tabla canchas si no existe
CREATE TABLE IF NOT EXISTS canchas (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT,
    location GEOMETRY(POINT, 4326),
    sector_id UUID REFERENCES sectors(id),
    capacity INTEGER DEFAULT 22,
    surface_type TEXT DEFAULT 'césped',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Deshabilitar RLS en tablas de referencia
ALTER TABLE canchas DISABLE ROW LEVEL SECURITY;
ALTER TABLE sectors DISABLE ROW LEVEL SECURITY;

-- ============================================================================
-- VERIFICACIÓN FINAL
-- ============================================================================

-- Verificar configuración RLS
SELECT 
    'RLS STATUS' as tipo,
    tablename,
    CASE WHEN rowsecurity THEN 'ENABLED ✅' ELSE 'DISABLED ❌' END as estado
FROM pg_tables 
WHERE tablename IN ('teams', 'team_members', 'matches', 'users')
  AND schemaname = 'public'
ORDER BY tablename;

-- Verificar si existen las tablas de referencia
SELECT 
    'TABLE EXISTS' as tipo,
    table_name as tabla,
    'YES ✅' as estado
FROM information_schema.tables 
WHERE table_name IN ('canchas', 'sectors')
  AND table_schema = 'public'
ORDER BY table_name;

-- Verificar políticas creadas
SELECT 
    'POLICIES' as tipo,
    tablename,
    COUNT(*) as total_policies
FROM pg_policies 
WHERE tablename IN ('teams', 'team_members', 'matches', 'users')
GROUP BY tablename
ORDER BY tablename;

-- Verificar datos de usuarios
SELECT 
    'USER DATA' as tipo,
    'auth.users' as tabla, 
    COUNT(*) as total 
FROM auth.users
UNION ALL
SELECT 
    'USER DATA' as tipo,
    'public.users' as tabla, 
    COUNT(*) as total 
FROM public.users;

-- ============================================================================
-- MENSAJE DE ÉXITO
-- ============================================================================

SELECT '🎉 CONFIGURACIÓN COMPLETADA EXITOSAMENTE 🎉' as resultado;

/*
✅ QUE SE HA CONFIGURADO:

SEGURIDAD:
- ✅ RLS habilitado en tablas críticas (teams, team_members, matches, users)
- ✅ Políticas restrictivas pero funcionales
- ✅ Solo usuarios autenticados pueden crear equipos
- ✅ Solo capitanes pueden gestionar sus equipos

FUNCIONALIDAD:
- ✅ Sincronización automática de usuarios
- ✅ Ver equipos públicamente (necesario para la app)
- ✅ Gestión de miembros de equipos
- ✅ Sistema de partidos funcional

PRÓXIMO PASO:
🚀 Probar crear un equipo en la app Flutter
🚀 NO debería haber más errores 42501
*/
