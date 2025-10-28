-- Solución rápida para el error de RLS al registrar nuevos usuarios
-- Error: new row violates row-level security policy for table "profiles"

-- Eliminar todas las políticas existentes para evitar conflictos
DROP POLICY IF EXISTS "profiles_select_policy" ON profiles;
DROP POLICY IF EXISTS "profiles_insert_policy" ON profiles;
DROP POLICY IF EXISTS "profiles_update_policy" ON profiles;
DROP POLICY IF EXISTS "profiles_delete_policy" ON profiles;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON profiles;
DROP POLICY IF EXISTS "Enable read access for all users" ON profiles;
DROP POLICY IF EXISTS "Enable update for users based on email" ON profiles;

-- Deshabilitar temporalmente RLS para limpiar
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

-- Crear políticas nuevas y funcionales
CREATE POLICY "profiles_select_policy" ON profiles FOR SELECT USING (true);
CREATE POLICY "profiles_insert_policy" ON profiles FOR INSERT WITH CHECK (true);
CREATE POLICY "profiles_update_policy" ON profiles FOR UPDATE USING (auth.uid() = id);

-- Habilitar RLS nuevamente
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Verificar políticas creadas
SELECT policyname, permissive, roles, cmd 
FROM pg_policies 
WHERE tablename = 'profiles';