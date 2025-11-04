-- AGREGAR COLUMNAS FALTANTES A LA TABLA PROFILES
-- Ejecutar en Supabase SQL Editor

-- 1. Agregar columnas que faltan
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS first_name TEXT,
ADD COLUMN IF NOT EXISTS last_name TEXT,
ADD COLUMN IF NOT EXISTS photo_url TEXT;

-- 2. Actualizar datos existentes si es necesario
-- Dividir full_name en first_name y last_name para usuarios existentes
UPDATE public.profiles 
SET 
    first_name = CASE 
        WHEN full_name IS NOT NULL AND position(' ' in full_name) > 0 
        THEN split_part(full_name, ' ', 1)
        ELSE full_name
    END,
    last_name = CASE 
        WHEN full_name IS NOT NULL AND position(' ' in full_name) > 0 
        THEN substring(full_name from position(' ' in full_name) + 1)
        ELSE ''
    END,
    photo_url = profile_picture_url
WHERE first_name IS NULL OR last_name IS NULL OR photo_url IS NULL;

-- 3. Refrescar schema cache
NOTIFY pgrst, 'reload schema';

-- 4. Verificar que las columnas se agregaron correctamente
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'profiles' 
AND table_schema = 'public'
AND column_name IN ('first_name', 'last_name', 'photo_url', 'has_completed_onboarding')
ORDER BY column_name;