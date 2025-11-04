-- ANÁLISIS DE RELACIONES ENTRE USUARIOS Y EQUIPOS
-- Para determinar qué pasa si eliminamos usuarios que son capitanes/owners

-- 1. Ver la estructura de la tabla teams
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'teams' 
AND column_name IN ('captain_id', 'owner_id')
ORDER BY ordinal_position;

-- 2. Ver las foreign key constraints de la tabla teams
SELECT 
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name,
    rc.delete_rule
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
JOIN information_schema.referential_constraints AS rc
    ON tc.constraint_name = rc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' 
AND tc.table_name = 'teams'
AND kcu.column_name IN ('captain_id', 'owner_id');

-- 3. Ver equipos actuales y sus capitanes
SELECT 
    t.id as team_id,
    t.name as team_name,
    t.captain_id,
    t.owner_id,
    p.display_name as captain_name,
    p.email as captain_email
FROM teams t
LEFT JOIN profiles p ON t.captain_id = p.id
ORDER BY t.created_at DESC;

-- 4. Verificar si hay equipos huérfanos (sin capitán válido)
SELECT 
    t.id as team_id,
    t.name as team_name,
    t.captain_id,
    p.id as profile_exists
FROM teams t
LEFT JOIN profiles p ON t.captain_id = p.id
WHERE p.id IS NULL;

-- ESCENARIOS POSIBLES:

-- CASO 1: Si las foreign keys tienen ON DELETE CASCADE
-- Los equipos se eliminarían automáticamente

-- CASO 2: Si las foreign keys tienen ON DELETE SET NULL  
-- Los captain_id y owner_id se pondrían en NULL

-- CASO 3: Si las foreign keys tienen ON DELETE RESTRICT/NO ACTION
-- No se podría eliminar el usuario hasta eliminar los equipos primero

-- CASO 4: Si NO hay foreign keys (solo referencias)
-- Los equipos quedarían huérfanos con captain_id inválido
