-- ELIMINACIÓN SEGURA - Solo equipos sin jugadores
-- Este script solo elimina equipos que no tienen jugadores asociados

-- 1. Verificar qué equipos NO tienen jugadores
SELECT 
    t.id,
    t.name,
    t.tag,
    t.comuna,
    COUNT(p.id) as player_count
FROM teams t
LEFT JOIN players p ON t.id = p.team_id
GROUP BY t.id, t.name, t.tag, t.comuna
HAVING COUNT(p.id) = 0
ORDER BY t.created_at;

-- 2. Eliminar ELO de equipos sin jugadores
DELETE FROM team_elo_by_modality 
WHERE team_id IN (
    SELECT t.id 
    FROM teams t
    LEFT JOIN players p ON t.id = p.team_id
    GROUP BY t.id
    HAVING COUNT(p.id) = 0
);

-- 3. Eliminar posts de reclutamiento de equipos sin jugadores
DELETE FROM recruitment_posts 
WHERE team_id IN (
    SELECT t.id 
    FROM teams t
    LEFT JOIN players p ON t.id = p.team_id
    GROUP BY t.id
    HAVING COUNT(p.id) = 0
);

-- 4. Eliminar equipos que no tienen jugadores
DELETE FROM teams 
WHERE id IN (
    SELECT t.id 
    FROM teams t
    LEFT JOIN players p ON t.id = p.team_id
    GROUP BY t.id
    HAVING COUNT(p.id) = 0
);

-- Verificar resultado
SELECT 
    'Equipos eliminados (sin jugadores)' as accion,
    'Completado' as estado;

SELECT 
    t.id,
    t.name,
    t.tag,
    COUNT(p.id) as player_count
FROM teams t
LEFT JOIN players p ON t.id = p.team_id
GROUP BY t.id, t.name, t.tag
ORDER BY t.created_at;
