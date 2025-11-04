-- ELIMINACIÓN COMPLETA DE TODOS LOS EQUIPOS
-- ⚠️  ADVERTENCIA: Este script eliminará TODOS los equipos y datos relacionados
-- ⚠️  NO SE PUEDE DESHACER

-- Deshabilitar temporalmente las restricciones de foreign key para evitar errores
SET session_replication_role = replica;

-- 1. Eliminar partidos que referencian equipos
DELETE FROM matches 
WHERE home_team_id IS NOT NULL OR away_team_id IS NOT NULL;

-- 2. Eliminar jugadores de equipos
DELETE FROM players 
WHERE team_id IS NOT NULL;

-- 3. Eliminar registros de ELO por modalidad
DELETE FROM team_elo_by_modality;

-- 4. Eliminar estadísticas de jugadores por modalidad (si existe)
DELETE FROM player_modality_stats 
WHERE EXISTS (
    SELECT 1 FROM teams WHERE teams.id = player_modality_stats.team_id
);

-- 5. Eliminar posts de reclutamiento asociados a equipos
DELETE FROM recruitment_posts 
WHERE team_id IS NOT NULL;

-- 6. Finalmente eliminar todos los equipos
DELETE FROM teams;

-- Reactivar las restricciones de foreign key
SET session_replication_role = DEFAULT;

-- Verificar que todo se eliminó correctamente
SELECT 'Equipos restantes:' as verificacion, COUNT(*) as cantidad FROM teams
UNION ALL
SELECT 'Jugadores con equipo:', COUNT(*) FROM players WHERE team_id IS NOT NULL
UNION ALL
SELECT 'Partidos con equipos:', COUNT(*) FROM matches WHERE home_team_id IS NOT NULL OR away_team_id IS NOT NULL
UNION ALL
SELECT 'Registros ELO:', COUNT(*) FROM team_elo_by_modality
UNION ALL
SELECT 'Posts reclutamiento:', COUNT(*) FROM recruitment_posts WHERE team_id IS NOT NULL;
