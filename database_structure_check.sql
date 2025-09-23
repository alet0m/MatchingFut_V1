-- ============================================================================
-- VERIFICACIÓN DE ESTRUCTURA DE BASE DE DATOS
-- Ejecutar PRIMERO para ver qué tablas existen
-- ============================================================================

-- Ver todas las tablas que existen
SELECT 
    'TABLES' as categoria,
    table_name as nombre,
    'EXISTS' as estado
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_name;

-- Ver estructura de la tabla teams si existe
SELECT 
    'TEAMS COLUMNS' as categoria,
    column_name as nombre,
    data_type as tipo,
    is_nullable as nullable
FROM information_schema.columns 
WHERE table_name = 'teams' AND table_schema = 'public'
ORDER BY ordinal_position;

-- Ver estructura de la tabla users si existe
SELECT 
    'USERS COLUMNS' as categoria,
    column_name as nombre,
    data_type as tipo,
    is_nullable as nullable
FROM information_schema.columns 
WHERE table_name = 'users' AND table_schema = 'public'
ORDER BY ordinal_position;

-- Ver estructura de la tabla team_members si existe
SELECT 
    'TEAM_MEMBERS COLUMNS' as categoria,
    column_name as nombre,
    data_type as tipo,
    is_nullable as nullable
FROM information_schema.columns 
WHERE table_name = 'team_members' AND table_schema = 'public'
ORDER BY ordinal_position;

-- Ver estructura de la tabla matches si existe
SELECT 
    'MATCHES COLUMNS' as categoria,
    column_name as nombre,
    data_type as tipo,
    is_nullable as nullable
FROM information_schema.columns 
WHERE table_name = 'matches' AND table_schema = 'public'
ORDER BY ordinal_position;

-- Verificar estado actual de RLS
SELECT 
    'RLS CURRENT' as categoria,
    tablename as tabla,
    CASE WHEN rowsecurity THEN 'ENABLED' ELSE 'DISABLED' END as estado
FROM pg_tables 
WHERE schemaname = 'public'
  AND tablename IN ('teams', 'team_members', 'users', 'matches', 'sectors', 'canchas')
ORDER BY tablename;

-- Ver políticas existentes
SELECT 
    'POLICIES CURRENT' as categoria,
    tablename as tabla,
    policyname as politica,
    cmd as comando
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- Verificar datos de autenticación
SELECT 
    'AUTH DATA' as categoria,
    'auth.users' as tabla,
    COUNT(*) as total,
    'records' as unidad
FROM auth.users
UNION ALL
SELECT 
    'AUTH DATA' as categoria,
    'public.users' as tabla,
    COUNT(*) as total,
    'records' as unidad
FROM public.users
WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users' AND table_schema = 'public');

-- Ver si hay equipos existentes
SELECT 
    'TEAMS DATA' as categoria,
    'teams' as tabla,
    COUNT(*) as total,
    'records' as unidad
FROM teams
WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'teams' AND table_schema = 'public');
