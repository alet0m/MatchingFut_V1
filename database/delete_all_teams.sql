-- Script para eliminar todos los equipos existentes
-- ⚠️  ADVERTENCIA: Este script eliminará TODOS los equipos y datos relacionados

-- 1. Primero verificar qué equipos existen
SELECT 
    id, 
    name, 
    tag, 
    comuna,
    created_at,
    (SELECT COUNT(*) FROM players WHERE team_id = teams.id) as player_count
FROM teams 
ORDER BY created_at DESC;

-- 2. Verificar partidos asociados a estos equipos
SELECT 
    m.id,
    m.home_team_id,
    ht.name as home_team,
    m.away_team_id,
    at.name as away_team,
    m.status,
    m.modality
FROM matches m
LEFT JOIN teams ht ON m.home_team_id = ht.id
LEFT JOIN teams at ON m.away_team_id = at.id
WHERE m.home_team_id IS NOT NULL OR m.away_team_id IS NOT NULL;

-- 3. Verificar players asociados
SELECT 
    p.id,
    p.user_id,
    p.team_id,
    t.name as team_name,
    p.position,
    p.is_captain
FROM players p
LEFT JOIN teams t ON p.team_id = t.id
WHERE p.team_id IS NOT NULL;

-- COMENTARIO: Para ejecutar la eliminación, descomenta las siguientes líneas
-- SOLO DESPUÉS de verificar que es seguro hacerlo

/*
-- 4. Eliminar en orden correcto (respetando foreign keys)

-- Eliminar partidos que referencian equipos
DELETE FROM matches 
WHERE home_team_id IS NOT NULL OR away_team_id IS NOT NULL;

-- Eliminar jugadores de equipos
DELETE FROM players 
WHERE team_id IS NOT NULL;

-- Eliminar ELO de equipos por modalidad
DELETE FROM team_elo_by_modality;

-- Eliminar los equipos
DELETE FROM teams;

-- Verificar que todo se eliminó correctamente
SELECT COUNT(*) as teams_remaining FROM teams;
SELECT COUNT(*) as players_remaining FROM players WHERE team_id IS NOT NULL;
SELECT COUNT(*) as matches_remaining FROM matches WHERE home_team_id IS NOT NULL OR away_team_id IS NOT NULL;
SELECT COUNT(*) as elo_remaining FROM team_elo_by_modality;
*/
