-- VERIFICAR Y CONFIGURAR RLS (ROW LEVEL SECURITY) PARA PROFILES
-- El error PGRST204 a veces ocurre por problemas de permisos

-- 1. Verificar estado actual de RLS
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled,
    relowner
FROM pg_tables 
LEFT JOIN pg_class ON pg_tables.tablename = pg_class.relname
WHERE tablename = 'profiles';

-- 2. Verificar políticas existentes
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'profiles';

-- 3. Si no hay políticas adecuadas, crear políticas básicas
-- NOTA: Solo ejecutar si no existen políticas o están mal configuradas

-- Permitir SELECT para usuarios autenticados
DROP POLICY IF EXISTS "profiles_select_policy" ON public.profiles;
CREATE POLICY "profiles_select_policy" 
ON public.profiles FOR SELECT 
TO authenticated 
USING (true);

-- Permitir UPDATE para el propio usuario
DROP POLICY IF EXISTS "profiles_update_policy" ON public.profiles;
CREATE POLICY "profiles_update_policy" 
ON public.profiles FOR UPDATE 
TO authenticated 
USING (auth.uid() = id) 
WITH CHECK (auth.uid() = id);

-- Permitir INSERT para usuarios autenticados (registro)
DROP POLICY IF EXISTS "profiles_insert_policy" ON public.profiles;
CREATE POLICY "profiles_insert_policy" 
ON public.profiles FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid() = id);

-- 4. Asegurar que RLS está habilitado
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;