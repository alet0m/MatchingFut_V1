-- ELIMINACIÓN COMPLETA DE TODOS LOS EQUIPOS
-- Script basado en el esquema real de la base de datos
-- ⚠️  ADVERTENCIA: Este script eliminará TODOS los equipos y datos relacionados

-- Primero verificar qué equipos existen
SELECT 
    id, 
    name, 
    tag, 
    comuna,
    modality,
    created_at,
    ARRAY_LENGTH(member_ids, 1) as member_count
FROM teams 
ORDER BY created_at DESC;

-- ELIMINAR EN ORDEN CORRECTO (respetando foreign keys)

-- 1. Eliminar aplicaciones a partidos públicos
DELETE FROM match_applications 
WHERE applicant_team_id IN (SELECT id FROM teams);

-- 2. Eliminar partidos públicos creados por equipos
DELETE FROM public_matches 
WHERE host_team_id IN (SELECT id FROM teams) 
   OR accepted_team_id IN (SELECT id FROM teams);

-- 3. Eliminar recruitment_by_modality relacionado (ANTES de posts)
DELETE FROM recruitment_by_modality 
WHERE post_id IN (
    SELECT id FROM recruitment_posts 
    WHERE team_id IN (SELECT id FROM teams)
);

-- 4. Eliminar posts de reclutamiento de equipos
DELETE FROM recruitment_posts 
WHERE team_id IN (SELECT id FROM teams);

-- 5. Eliminar registros de ELO por modalidad
DELETE FROM team_elo_by_modality 
WHERE team_id IN (SELECT id FROM teams);

-- 6. Finalmente eliminar todos los equipos
DELETE FROM teams;

-- VERIFICACIÓN FINAL
SELECT 
    'Equipos restantes:' as verificacion, 
    COUNT(*) as cantidad 
FROM teams
UNION ALL
SELECT 
    'ELO restante:', 
    COUNT(*) 
FROM team_elo_by_modality
UNION ALL
SELECT 
    'Posts reclutamiento:', 
    COUNT(*) 
FROM recruitment_posts WHERE team_id IS NOT NULL
UNION ALL
SELECT 
    'Partidos públicos:', 
    COUNT(*) 
FROM public_matches
UNION ALL
SELECT 
    'Aplicaciones:', 
    COUNT(*) 
FROM match_applications;
