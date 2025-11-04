-- Script para verificar y arreglar datos de comunas para crear equipos

-- 1. Verificar si existe la tabla comunas y sus datos
SELECT * FROM comunas WHERE code = 'quilicura';

-- 2. Si no existe Quilicura, insertarla
INSERT INTO comunas (id, name, code, is_active) 
VALUES (
  uuid_generate_v4(),
  'Quilicura',
  'quilicura',
  true
) 
ON CONFLICT (code) DO NOTHING;

-- 3. Obtener el ID de Quilicura para usar en el código
SELECT id, name, code FROM comunas WHERE code = 'quilicura';

-- 4. Verificar si existe la función para generar tags únicos
SELECT routines.routine_name
FROM information_schema.routines
WHERE routines.specific_schema = 'public'
AND routines.routine_name = 'generate_team_tag';

-- 5. Crear la función si no existe
CREATE OR REPLACE FUNCTION generate_team_tag(team_name TEXT)
RETURNS TEXT AS $$
DECLARE
    base_tag TEXT;
    final_tag TEXT;
    counter INTEGER := 1;
BEGIN
    -- Generar tag base desde el nombre
    base_tag := lower(regexp_replace(team_name, '[^a-zA-Z0-9]', '', 'g'));
    base_tag := left(base_tag, 15); -- Limitar a 15 caracteres
    
    final_tag := base_tag;
    
    -- Verificar unicidad y agregar número si es necesario
    WHILE EXISTS (SELECT 1 FROM teams WHERE tag = final_tag) LOOP
        final_tag := base_tag || counter::TEXT;
        counter := counter + 1;
    END LOOP;
    
    RETURN final_tag;
END;
$$ LANGUAGE plpgsql;

-- 6. Verificar las políticas RLS de la tabla teams
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies 
WHERE tablename = 'teams';

-- 7. Verificar si se pueden insertar datos en teams (test)
-- Esta query NO se ejecutará, solo para verificar estructura
-- INSERT INTO teams (name, tag, captain_id, comuna_id) 
-- VALUES ('Test Team', 'testteam', 'user-id-here', 'comuna-id-here');