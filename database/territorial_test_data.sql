-- Script para crear datos de prueba para el sistema territorial
-- Este script debe ejecutarse después del script principal de migración

-- Añadir regiones de prueba (si no existen)
INSERT INTO regions (id, name, code, active)
VALUES 
  ('rm', 'Región Metropolitana', 'RM', true),
  ('v', 'Región de Valparaíso', 'V', true),
  ('vi', 'Región de O''Higgins', 'VI', true)
ON CONFLICT (id) DO NOTHING;

-- Añadir comunas de prueba
INSERT INTO comunas (id, name, region_id, active, coordinates)
VALUES 
  ('quilicura', 'Quilicura', 'rm', true, ST_GeomFromText('POINT(-70.7500 -33.3500)')),
  ('renca', 'Renca', 'rm', true, ST_GeomFromText('POINT(-70.7300 -33.4000)')),
  ('huechuraba', 'Huechuraba', 'rm', true, ST_GeomFromText('POINT(-70.6500 -33.3700)')),
  ('concon', 'Concón', 'v', true, ST_GeomFromText('POINT(-71.5200 -32.9300)')),
  ('rancagua', 'Rancagua', 'vi', true, ST_GeomFromText('POINT(-70.7400 -34.1700)'))
ON CONFLICT (id) DO NOTHING;

-- Añadir sectores de prueba para Quilicura
INSERT INTO sectors (id, name, description, comuna_id, elo_threshold, coordinates, active)
VALUES
  ('quilicura-norte', 'Quilicura Norte', 'Sector norte de Quilicura', 'quilicura', 1200, ST_GeomFromText('POLYGON((-70.7600 -33.3400, -70.7500 -33.3400, -70.7500 -33.3500, -70.7600 -33.3500, -70.7600 -33.3400))'), true),
  ('quilicura-centro', 'Quilicura Centro', 'Centro de Quilicura', 'quilicura', 1300, ST_GeomFromText('POLYGON((-70.7500 -33.3500, -70.7400 -33.3500, -70.7400 -33.3600, -70.7500 -33.3600, -70.7500 -33.3500))'), true),
  ('quilicura-sur', 'Quilicura Sur', 'Sector sur de Quilicura', 'quilicura', 1250, ST_GeomFromText('POLYGON((-70.7500 -33.3600, -70.7400 -33.3600, -70.7400 -33.3700, -70.7500 -33.3700, -70.7500 -33.3600))'), true),
  ('quilicura-este', 'Quilicura Este', 'Sector este de Quilicura', 'quilicura', 1400, ST_GeomFromText('POLYGON((-70.7400 -33.3500, -70.7300 -33.3500, -70.7300 -33.3600, -70.7400 -33.3600, -70.7400 -33.3500))'), true),
  ('quilicura-oeste', 'Quilicura Oeste', 'Sector oeste de Quilicura', 'quilicura', 1350, ST_GeomFromText('POLYGON((-70.7600 -33.3500, -70.7500 -33.3500, -70.7500 -33.3600, -70.7600 -33.3600, -70.7600 -33.3500))'), true)
ON CONFLICT (id) DO NOTHING;

-- Añadir sectores de prueba para Renca
INSERT INTO sectors (id, name, description, comuna_id, elo_threshold, coordinates, active)
VALUES
  ('renca-norte', 'Renca Norte', 'Sector norte de Renca', 'renca', 1200, ST_GeomFromText('POLYGON((-70.7400 -33.3900, -70.7300 -33.3900, -70.7300 -33.4000, -70.7400 -33.4000, -70.7400 -33.3900))'), true),
  ('renca-centro', 'Renca Centro', 'Centro de Renca', 'renca', 1300, ST_GeomFromText('POLYGON((-70.7300 -33.4000, -70.7200 -33.4000, -70.7200 -33.4100, -70.7300 -33.4100, -70.7300 -33.4000))'), true),
  ('renca-sur', 'Renca Sur', 'Sector sur de Renca', 'renca', 1250, ST_GeomFromText('POLYGON((-70.7300 -33.4100, -70.7200 -33.4100, -70.7200 -33.4200, -70.7300 -33.4200, -70.7300 -33.4100))'), true)
ON CONFLICT (id) DO NOTHING;

-- Crear equipos de prueba si no existen
-- Nota: Asegúrate de tener usuarios en la tabla auth.users
DO $$
DECLARE
    user_id1 UUID;
    user_id2 UUID;
    user_id3 UUID;
    team_id1 UUID;
    team_id2 UUID;
    team_id3 UUID;
    team_id4 UUID;
    team_id5 UUID;
BEGIN
    -- Obtener algunos usuarios existentes o crear nuevos si es necesario
    SELECT id INTO user_id1 FROM auth.users LIMIT 1;
    SELECT id INTO user_id2 FROM auth.users OFFSET 1 LIMIT 1;
    SELECT id INTO user_id3 FROM auth.users OFFSET 2 LIMIT 1;
    
    -- Si no hay suficientes usuarios, usar el mismo para todos
    IF user_id2 IS NULL THEN user_id2 := user_id1; END IF;
    IF user_id3 IS NULL THEN user_id3 := user_id1; END IF;

    -- Crear equipos de prueba
    INSERT INTO teams (name, description, logo_url, founded_date, elo, created_by, comuna_id)
    VALUES 
      ('Leones de Quilicura', 'Equipo principal de Quilicura Norte', 'https://example.com/logo1.png', CURRENT_DATE, 1450, user_id1, 'quilicura')
    RETURNING id INTO team_id1;
    
    INSERT INTO teams (name, description, logo_url, founded_date, elo, created_by, comuna_id)
    VALUES 
      ('Tigres de Quilicura', 'Equipo del centro de Quilicura', 'https://example.com/logo2.png', CURRENT_DATE, 1380, user_id2, 'quilicura')
    RETURNING id INTO team_id2;
    
    INSERT INTO teams (name, description, logo_url, founded_date, elo, created_by, comuna_id)
    VALUES 
      ('Halcones de Quilicura', 'Representantes del sur de Quilicura', 'https://example.com/logo3.png', CURRENT_DATE, 1290, user_id3, 'quilicura')
    RETURNING id INTO team_id3;
    
    INSERT INTO teams (name, description, logo_url, founded_date, elo, created_by, comuna_id)
    VALUES 
      ('FC Renca', 'El equipo más fuerte de Renca', 'https://example.com/logo4.png', CURRENT_DATE, 1520, user_id1, 'renca')
    RETURNING id INTO team_id4;
    
    INSERT INTO teams (name, description, logo_url, founded_date, elo, created_by, comuna_id)
    VALUES 
      ('Deportivo Huechuraba', 'Orgullo de Huechuraba', 'https://example.com/logo5.png', CURRENT_DATE, 1350, user_id2, 'huechuraba')
    RETURNING id INTO team_id5;
    
    -- Establecer control inicial de sectores
    -- Leones de Quilicura controla Quilicura Norte
    INSERT INTO sector_control (sector_id, team_id, control_date, match_id)
    VALUES ('quilicura-norte', team_id1, CURRENT_TIMESTAMP - INTERVAL '30 days', NULL)
    ON CONFLICT (sector_id) DO NOTHING;
    
    -- Tigres de Quilicura controla Quilicura Centro
    INSERT INTO sector_control (sector_id, team_id, control_date, match_id)
    VALUES ('quilicura-centro', team_id2, CURRENT_TIMESTAMP - INTERVAL '15 days', NULL)
    ON CONFLICT (sector_id) DO NOTHING;
    
    -- Halcones de Quilicura controla Quilicura Sur
    INSERT INTO sector_control (sector_id, team_id, control_date, match_id)
    VALUES ('quilicura-sur', team_id3, CURRENT_TIMESTAMP - INTERVAL '7 days', NULL)
    ON CONFLICT (sector_id) DO NOTHING;
    
    -- FC Renca controla Renca Centro
    INSERT INTO sector_control (sector_id, team_id, control_date, match_id)
    VALUES ('renca-centro', team_id4, CURRENT_TIMESTAMP - INTERVAL '20 days', NULL)
    ON CONFLICT (sector_id) DO NOTHING;
    
    -- Registrar historial de control
    INSERT INTO sector_control_history (sector_id, team_id, control_start, control_end, match_id)
    VALUES 
      ('quilicura-norte', team_id1, CURRENT_TIMESTAMP - INTERVAL '30 days', NULL, NULL),
      ('quilicura-centro', team_id2, CURRENT_TIMESTAMP - INTERVAL '15 days', NULL, NULL),
      ('quilicura-sur', team_id3, CURRENT_TIMESTAMP - INTERVAL '7 days', NULL, NULL),
      ('renca-centro', team_id4, CURRENT_TIMESTAMP - INTERVAL '20 days', NULL, NULL);
    
    -- Crear algunos desafíos de prueba
    -- Desafío pendiente
    INSERT INTO challenges (challenger_team_id, defender_team_id, sector_id, status, challenge_date)
    VALUES (team_id3, team_id2, 'quilicura-centro', 'pending', CURRENT_TIMESTAMP);
    
    -- Desafío aceptado
    INSERT INTO challenges (challenger_team_id, defender_team_id, sector_id, status, challenge_date, match_date)
    VALUES (team_id1, team_id3, 'quilicura-sur', 'accepted', CURRENT_TIMESTAMP - INTERVAL '3 days', CURRENT_TIMESTAMP + INTERVAL '4 days');
    
    -- Desafío completado (ganó el retador)
    INSERT INTO challenges (challenger_team_id, defender_team_id, sector_id, status, challenge_date, match_date, completion_date, winner_team_id)
    VALUES (team_id2, team_id1, 'quilicura-este', 'completed', CURRENT_TIMESTAMP - INTERVAL '10 days', CURRENT_TIMESTAMP - INTERVAL '5 days', CURRENT_TIMESTAMP - INTERVAL '5 days', team_id2);
    
    -- Desafío rechazado
    INSERT INTO challenges (challenger_team_id, defender_team_id, sector_id, status, challenge_date)
    VALUES (team_id5, team_id4, 'renca-centro', 'rejected', CURRENT_TIMESTAMP - INTERVAL '15 days');
    
    RAISE NOTICE 'Datos de prueba creados exitosamente';
END $$;

-- Crear modalidades de fútbol para sectores
INSERT INTO football_modalities (id, name, description, player_count, active)
VALUES 
  ('futbol5', 'Fútbol 5', 'Fútbol de 5 jugadores por equipo', 5, true),
  ('futbol7', 'Fútbol 7', 'Fútbol de 7 jugadores por equipo', 7, true),
  ('futbol11', 'Fútbol 11', 'Fútbol tradicional con 11 jugadores', 11, true),
  ('futsal', 'Futsal', 'Fútbol sala con reglas oficiales', 5, true)
ON CONFLICT (id) DO NOTHING;

-- Asignar modalidades a sectores
INSERT INTO sector_modalities (sector_id, modality_id)
VALUES 
  ('quilicura-norte', 'futbol7'),
  ('quilicura-norte', 'futbol5'),
  ('quilicura-centro', 'futbol11'),
  ('quilicura-centro', 'futbol7'),
  ('quilicura-sur', 'futbol5'),
  ('quilicura-este', 'futsal'),
  ('quilicura-oeste', 'futbol7'),
  ('renca-norte', 'futbol5'),
  ('renca-centro', 'futbol11'),
  ('renca-sur', 'futbol7')
ON CONFLICT (sector_id, modality_id) DO NOTHING;

-- Mostrar mensaje de éxito
DO $$
BEGIN
  RAISE NOTICE '✅ Datos de prueba generados exitosamente para el sistema territorial';
END $$;