-- ============================================================================
-- CONFIGURACIÓN COMPLETA PARA ONBOARDING DE USUARIOS
-- ============================================================================

-- PASO 1: Deshabilitar RLS para desarrollo (TEMPORAL)
ALTER TABLE teams DISABLE ROW LEVEL SECURITY;
ALTER TABLE team_members DISABLE ROW LEVEL SECURITY;  
ALTER TABLE matches DISABLE ROW LEVEL SECURITY;
ALTER TABLE users DISABLE ROW LEVEL SECURITY;

-- PASO 2: Asegurar que la tabla users tenga todos los campos necesarios
-- Si la tabla no existe, crearla
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    nickname TEXT,
    birth_date DATE,
    profile_image_url TEXT,
    current_sector_id UUID REFERENCES sectors(id),
    individual_elo INTEGER DEFAULT 1200,
    position TEXT,
    bio TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- PASO 3: Función para manejar nuevos usuarios automáticamente
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
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- PASO 4: Crear trigger para usuarios nuevos
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- PASO 5: Migrar usuarios existentes si los hay
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

-- PASO 6: Crear algunos sectores de ejemplo para Quilicura
INSERT INTO sectors (id, name, boundaries, territory_level) VALUES
(gen_random_uuid(), 'Centro Quilicura', ST_GeomFromText('POLYGON((-70.7 -33.35, -70.6 -33.35, -70.6 -33.4, -70.7 -33.4, -70.7 -33.35))'), 1),
(gen_random_uuid(), 'Norte Quilicura', ST_GeomFromText('POLYGON((-70.7 -33.3, -70.6 -33.3, -70.6 -33.35, -70.7 -33.35, -70.7 -33.3))'), 1),
(gen_random_uuid(), 'Sur Quilicura', ST_GeomFromText('POLYGON((-70.7 -33.4, -70.6 -33.4, -70.6 -33.45, -70.7 -33.45, -70.7 -33.4))'), 1)
ON CONFLICT DO NOTHING;

-- PASO 7: Crear algunas canchas de ejemplo
INSERT INTO canchas (id, name, address, location, sector_id, capacity) VALUES
(gen_random_uuid(), 'Cancha Municipal Quilicura', 'Av. O''Higgins 1234, Quilicura', ST_Point(-70.65, -33.375), (SELECT id FROM sectors WHERE name = 'Centro Quilicura' LIMIT 1), 22),
(gen_random_uuid(), 'Complejo Deportivo Norte', 'Camino a Lampa 567, Quilicura', ST_Point(-70.68, -33.325), (SELECT id FROM sectors WHERE name = 'Norte Quilicura' LIMIT 1), 22),
(gen_random_uuid(), 'Estadio Comunitario Sur', 'Los Aromos 890, Quilicura', ST_Point(-70.62, -33.425), (SELECT id FROM sectors WHERE name = 'Sur Quilicura' LIMIT 1), 22)
ON CONFLICT DO NOTHING;

-- VERIFICACIÓN FINAL
SELECT 'Tabla' as tipo, 'users' as nombre, COUNT(*) as registros FROM users
UNION ALL
SELECT 'Tabla' as tipo, 'sectors' as nombre, COUNT(*) as registros FROM sectors  
UNION ALL
SELECT 'Tabla' as tipo, 'canchas' as nombre, COUNT(*) as registros FROM canchas
UNION ALL
SELECT 'Auth' as tipo, 'auth.users' as nombre, COUNT(*) as registros FROM auth.users;

-- Mostrar estructura final de users
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'users' 
ORDER BY ordinal_position;
