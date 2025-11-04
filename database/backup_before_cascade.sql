-- ========================================
-- BACKUP COMPLETO ANTES DE CASCADE
-- Ejecutar CADA BLOQUE por separado
-- ========================================

-- PASO 1: Backup de la estructura actual de foreign keys
CREATE TABLE IF NOT EXISTS backup_foreign_keys AS
SELECT 
    tc.constraint_name,
    tc.table_name,
    tc.table_schema,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name,
    rc.delete_rule,
    rc.update_rule,
    now() as backup_date
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
AND tc.table_schema = 'public';

-- Verificar que se creó
SELECT COUNT(*) as "Foreign Keys Respaldadas" FROM backup_foreign_keys;

-- ========================================
-- PASO 2: Backup de datos críticos
-- ========================================

-- Backup de equipos y sus capitanes (EJECUTAR SEPARADO)
CREATE TABLE IF NOT EXISTS backup_teams_data AS
SELECT 
    t.*,
    p.email as captain_email,
    p.display_name as captain_name,
    now() as backup_date
FROM teams t
LEFT JOIN profiles p ON t.captain_id = p.id;

-- Verificar backup de teams
SELECT COUNT(*) as "Equipos Respaldados" FROM backup_teams_data;

-- ========================================
-- PASO 3: Backup de usuarios y perfiles
-- ========================================

-- Backup de perfiles (EJECUTAR SEPARADO)
CREATE TABLE IF NOT EXISTS backup_profiles_data AS
SELECT *, now() as backup_date FROM profiles;

-- Verificar backup de profiles
SELECT COUNT(*) as "Perfiles Respaldados" FROM backup_profiles_data;

-- ========================================
-- PASO 4: Script de ROLLBACK (por si algo sale mal)
-- ========================================

-- IMPORTANTE: Este script te permitirá restaurar todo si algo sale mal
-- EJECUTAR SOLO SI NECESITAS RESTAURAR:

/*
-- ROLLBACK SCRIPT (NO EJECUTAR AHORA)
-- Solo usar si necesitas deshacer los cambios

-- 1. Eliminar constraints CASCADE que creamos
ALTER TABLE teams DROP CONSTRAINT IF EXISTS teams_captain_id_fkey;
ALTER TABLE teams DROP CONSTRAINT IF EXISTS teams_owner_id_fkey;

-- 2. Restaurar constraints originales (ejemplo para teams)
ALTER TABLE teams ADD CONSTRAINT teams_captain_id_fkey 
FOREIGN KEY (captain_id) REFERENCES profiles(id);

ALTER TABLE teams ADD CONSTRAINT teams_owner_id_fkey 
FOREIGN KEY (owner_id) REFERENCES profiles(id);

-- 3. Verificar que se restauró
SELECT constraint_name, delete_rule 
FROM information_schema.referential_constraints 
WHERE constraint_name LIKE '%teams%';
*/

-- ========================================
-- VERIFICACIÓN FINAL ANTES DE CASCADE
-- ========================================

SELECT 
    'Teams' as tabla,
    COUNT(*) as registros
FROM teams
UNION ALL
SELECT 
    'Profiles' as tabla,
    COUNT(*) as registros  
FROM profiles
UNION ALL
SELECT 
    'Backup FK' as tabla,
    COUNT(*) as registros
FROM backup_foreign_keys
UNION ALL
SELECT 
    'Backup Teams' as tabla,
    COUNT(*) as registros
FROM backup_teams_data
UNION ALL
SELECT 
    'Backup Profiles' as tabla,
    COUNT(*) as registros
FROM backup_profiles_data;
