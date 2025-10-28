-- SCRIPT PARA REFRESCAR EL SCHEMA CACHE DE SUPABASE
-- Ejecutar en Supabase SQL Editor

-- 1. Forzar refresco del schema cache
NOTIFY pgrst, 'reload schema';

-- 2. Verificar que la columna existe
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'profiles' 
AND table_schema = 'public'
AND column_name = 'has_completed_onboarding';

-- 3. Verificar permisos en la tabla profiles
SELECT 
    grantee, 
    privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name = 'profiles' 
AND table_schema = 'public';

-- 4. Si es necesario, recrear la columna (como último recurso)
-- ALTER TABLE profiles DROP COLUMN IF EXISTS has_completed_onboarding;
-- ALTER TABLE profiles ADD COLUMN has_completed_onboarding BOOLEAN DEFAULT FALSE;