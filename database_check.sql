-- SCRIPT DE VERIFICACIÓN Y CORRECCIÓN COMPLETA
-- Ejecutar en Supabase SQL Editor si hay problemas con usuarios

-- 1. Verificar si existen usuarios en auth.users
SELECT 'AUTH USERS:', count(*) FROM auth.users;

-- 2. Verificar si existen usuarios en public.users  
SELECT 'PUBLIC USERS:', count(*) FROM public.users;

-- 3. Verificar estructura de player_profiles
SELECT 'PLAYER_PROFILES COLUMNS:', column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'player_profiles' 
ORDER BY ordinal_position;

-- 4. Verificar si existe la función handle_new_user
SELECT 'FUNCTION EXISTS:', exists(
  SELECT 1 FROM pg_proc WHERE proname = 'handle_new_user'
);

-- 5. Verificar si existe el trigger
SELECT 'TRIGGER EXISTS:', exists(
  SELECT 1 FROM pg_trigger WHERE tgname = 'on_auth_user_created'
);

-- 6. CORREGIR: Agregar constraint faltante para current_sector_id
ALTER TABLE public.player_profiles 
ADD CONSTRAINT player_profiles_current_sector_id_fkey 
FOREIGN KEY (current_sector_id) REFERENCES public.sectores_comuna(id);

-- 7. Si no hay usuarios en public.users pero sí en auth.users, insertarlos manualmente
INSERT INTO public.users (id, email, full_name, created_at, updated_at)
SELECT 
  au.id,
  au.email,
  COALESCE(au.raw_user_meta_data->>'full_name', 'Usuario') as full_name,
  au.created_at,
  au.updated_at
FROM auth.users au
LEFT JOIN public.users pu ON au.id = pu.id
WHERE pu.id IS NULL;

-- 8. Verificar el resultado
SELECT 'USUARIOS SINCRONIZADOS:', 
  au.email as auth_email,
  pu.email as public_email,
  pu.full_name
FROM auth.users au
LEFT JOIN public.users pu ON au.id = pu.id;
