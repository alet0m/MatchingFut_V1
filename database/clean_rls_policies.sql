-- Script para limpiar completamente las políticas de RLS conflictivas
-- Usar cuando hay errores de políticas duplicadas

-- Listar todas las políticas actuales
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'profiles';

-- Eliminar TODAS las políticas existentes para evitar conflictos
DO $$ 
DECLARE
    policy_record RECORD;
BEGIN
    FOR policy_record IN 
        SELECT policyname FROM pg_policies WHERE tablename = 'profiles'
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || policy_record.policyname || '" ON profiles';
    END LOOP;
END $$;

-- Deshabilitar RLS temporalmente
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

-- Esperar un momento para asegurar limpieza
SELECT pg_sleep(1);

-- Crear políticas limpias desde cero
CREATE POLICY "allow_select_all" ON profiles FOR SELECT USING (true);
CREATE POLICY "allow_insert_authenticated" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "allow_update_own" ON profiles FOR UPDATE USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- Habilitar RLS nuevamente
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Verificar políticas finales
SELECT policyname, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'profiles'
ORDER BY policyname;