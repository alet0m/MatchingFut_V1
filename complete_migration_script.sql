-- SCRIPT COMPLETO DE MIGRACIÓN PARA FÚTBOL APP QUILICURA
-- Versión: 1.0.0
-- Fecha: 2025-09-16
-- Descripción: Script completo para la creación y configuración de la base de datos
--              con enfoque en Quilicura y soporte para expansión a otras comunas

-- ============================================================
-- CONFIGURACIÓN INICIAL
-- ============================================================
SET client_min_messages TO 'debug';
-- Desactivar temporalmente las restricciones de foreign key para la migración
SET session_replication_role = 'replica';

-- Habilitar logs detallados para diagnóstico
DO $$
BEGIN
    RAISE NOTICE '🔄 Iniciando proceso de migración...';
    RAISE NOTICE '🔄 Configurado para eliminar estructuras existentes y recrear completamente';
    RAISE NOTICE '🔄 Modo de replicación activado para ignorar restricciones durante la migración';
END $$;

-- ============================================================
-- LIMPIEZA DE OBJETOS EXISTENTES
-- ============================================================

-- Eliminar vistas existentes
DO $$ 
DECLARE
    view_rec RECORD;
    error_message TEXT;
BEGIN
    RAISE NOTICE '🔄 Eliminando vistas existentes...';
    -- Intenta eliminar todas las vistas existentes
    FOR view_rec IN (
        SELECT table_name, table_schema
        FROM information_schema.views 
        WHERE table_schema = 'public'
    )
    LOOP
        BEGIN
            EXECUTE 'DROP VIEW IF EXISTS public.' || quote_ident(view_rec.table_name) || ' CASCADE';
            RAISE NOTICE 'Vista % eliminada', view_rec.table_name;
        EXCEPTION WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
            RAISE NOTICE 'Error al eliminar vista %: %', view_rec.table_name, error_message;
        END;
    END LOOP;
END $$;

-- Eliminar triggers existentes - OMITIDO para evitar problemas con triggers de restricciones
-- Los triggers serán eliminados automáticamente cuando eliminemos las restricciones y tablas
DO $$
BEGIN
    RAISE NOTICE 'Omitiendo eliminación directa de triggers para evitar errores con restricciones';
END $$;

-- Eliminar funciones existentes
DO $$
DECLARE
    func_rec RECORD;
BEGIN
    FOR func_rec IN (
        SELECT proname, oidvectortypes(proargtypes) as args
        FROM pg_proc 
        WHERE pronamespace = 'public'::regnamespace
    ) LOOP
        BEGIN
            EXECUTE format('DROP FUNCTION IF EXISTS public.%I(%s) CASCADE', 
                           func_rec.proname, func_rec.args);
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'Error al eliminar función %(%): %', 
                         func_rec.proname, func_rec.args, SQLERRM;
        END;
    END LOOP;
END $$;

-- Eliminar tablas existentes y sus dependencias
DO $$
DECLARE
    table_rec RECORD;
    constraint_rec RECORD;
    error_message TEXT;
BEGIN
    -- Identificar y eliminar todas las restricciones de clave foránea en todas las tablas
    -- Incluyendo las que podrían no estar en las tablas que vamos a eliminar después
    FOR constraint_rec IN (
        SELECT 
            tc.constraint_name, 
            tc.table_name
        FROM 
            information_schema.table_constraints tc
        WHERE 
            tc.constraint_type = 'FOREIGN KEY' 
            AND tc.table_schema = 'public'
    ) LOOP
        BEGIN
            EXECUTE format('ALTER TABLE public.%I DROP CONSTRAINT IF EXISTS %I CASCADE', 
                          constraint_rec.table_name, constraint_rec.constraint_name);
            RAISE NOTICE 'Eliminada restricción % de la tabla %', 
                        constraint_rec.constraint_name, constraint_rec.table_name;
        EXCEPTION WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
            RAISE NOTICE 'Error al eliminar restricción % de la tabla %: %', 
                         constraint_rec.constraint_name, constraint_rec.table_name, error_message;
        END;
    END LOOP;

    -- Manejar específicamente la tabla activity_feed mencionada en el error
    BEGIN
        EXECUTE 'DROP TABLE IF EXISTS public.activity_feed CASCADE';
        RAISE NOTICE 'Tabla activity_feed eliminada (si existía)';
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
        RAISE NOTICE 'Error al eliminar tabla activity_feed: %', error_message;
    END;

    -- Luego eliminar todas las tablas
    FOR table_rec IN (
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'public'
        AND tablename NOT IN ('spatial_ref_sys') -- No eliminar tablas de PostGIS
    ) LOOP
        BEGIN
            EXECUTE 'DROP TABLE IF EXISTS public.' || table_rec.tablename || ' CASCADE';
            RAISE NOTICE 'Tabla % eliminada', table_rec.tablename;
        EXCEPTION WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS error_message = MESSAGE_TEXT;
            RAISE NOTICE 'Error al eliminar tabla %: %', 
                         table_rec.tablename, error_message;
        END;
    END LOOP;
END $$;

-- ============================================================
-- EXTENSIONES REQUERIDAS
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- ============================================================
-- TABLAS PRINCIPALES
-- ============================================================

-- Tabla de perfiles (extiende auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT UNIQUE,
    full_name TEXT,
    tag TEXT UNIQUE, -- Tag único de 4 dígitos
    display_name TEXT,
    profile_picture_url TEXT,
    bio TEXT,
    comuna TEXT,
    position TEXT,
    skill_level TEXT,
    preferred_foot TEXT,
    date_of_birth DATE,
    genero TEXT,
    nacionalidad TEXT,
    altura INTEGER,
    peso INTEGER,
    has_completed_onboarding BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Tabla de regiones
CREATE TABLE IF NOT EXISTS public.regions (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    code TEXT NOT NULL UNIQUE,
    ordinal INTEGER NOT NULL, -- Número oficial de la región (ej: Región Metropolitana = 13)
    is_active BOOLEAN DEFAULT TRUE -- Para activar/desactivar regiones en la app
);

-- Tabla de comunas
CREATE TABLE IF NOT EXISTS public.comunas (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    region_id INTEGER REFERENCES public.regions(id),
    code TEXT NOT NULL UNIQUE,
    coordinates GEOMETRY(Point, 4326),
    boundaries GEOMETRY(Polygon, 4326), -- Límites geográficos de la comuna
    is_active BOOLEAN DEFAULT FALSE, -- Solo Quilicura empieza activa
    total_players INTEGER DEFAULT 0, -- Contador de jugadores en la comuna
    total_teams INTEGER DEFAULT 0, -- Contador de equipos en la comuna
    total_matches INTEGER DEFAULT 0, -- Contador de partidos en la comuna
    featured_image_url TEXT, -- Imagen destacada de la comuna
    description TEXT, -- Descripción de la comuna
    UNIQUE(name, region_id)
);

-- Tabla para sectores de comunas (para dominio territorial)
-- Movida aquí arriba para evitar referencias circulares
CREATE TABLE IF NOT EXISTS public.sectors (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    comuna_id UUID REFERENCES public.comunas(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    boundaries GEOMETRY(Polygon, 4326),
    controlling_team_id UUID, -- Se establecerá con una referencia después de crear la tabla teams
    elo_required INTEGER DEFAULT 1200,
    current_elo_threshold INTEGER DEFAULT 1200, -- ELO mínimo para desafiar el control
    total_matches INTEGER DEFAULT 0, -- Partidos jugados en este sector
    last_match_date TIMESTAMP WITH TIME ZONE,
    control_start_date TIMESTAMP WITH TIME ZONE, -- Desde cuándo lo controla el equipo actual
    featured_image_url TEXT, -- Imagen destacada del sector
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE(comuna_id, name)
);

-- Tabla de modalidades de fútbol
CREATE TABLE IF NOT EXISTS public.football_modalities (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    code TEXT UNIQUE, -- Código como 'futbol5', 'futbol7', 'futbol11'
    players_per_team INTEGER NOT NULL, -- Jugadores por equipo
    min_players INTEGER NOT NULL, -- Mínimo para jugar
    max_players INTEGER NOT NULL, -- Máximo en plantel
    field_players INTEGER NOT NULL, -- Jugadores en cancha
    description TEXT,
    color_hex TEXT -- Color temático
);

-- Tabla de equipos
CREATE TABLE IF NOT EXISTS public.teams (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    tag TEXT UNIQUE,
    logo_url TEXT,
    description TEXT,
    captain_id UUID REFERENCES public.profiles(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    comuna_id UUID REFERENCES public.comunas(id),
    modality_id INTEGER REFERENCES public.football_modalities(id),
    is_active BOOLEAN DEFAULT TRUE,
    max_members INTEGER DEFAULT 15,
    home_color TEXT DEFAULT '#2E7D32',
    away_color TEXT DEFAULT '#FFFFFF',
    elo_rating INTEGER DEFAULT 1200,
    total_matches INTEGER DEFAULT 0,
    wins INTEGER DEFAULT 0,
    losses INTEGER DEFAULT 0,
    draws INTEGER DEFAULT 0
);

-- Actualizar la referencia controlling_team_id en sectors
ALTER TABLE public.sectors
ADD CONSTRAINT sectors_controlling_team_id_fkey
FOREIGN KEY (controlling_team_id) REFERENCES public.teams(id);

-- Tabla de etiquetas de equipo
CREATE TABLE IF NOT EXISTS public.team_tags (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT
);

-- Tabla de relación equipo-etiqueta
CREATE TABLE IF NOT EXISTS public.team_tag_relations (
    team_id UUID REFERENCES public.teams(id) ON DELETE CASCADE,
    tag_id INTEGER REFERENCES public.team_tags(id) ON DELETE CASCADE,
    PRIMARY KEY (team_id, tag_id)
);

-- Tabla de miembros de equipo
CREATE TABLE IF NOT EXISTS public.team_members (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    team_id UUID REFERENCES public.teams(id) ON DELETE CASCADE,
    player_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'player', -- 'captain', 'player', 'coach'
    number INTEGER,
    position TEXT,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE (team_id, player_id)
);

-- Tabla de invitaciones a equipos
CREATE TABLE IF NOT EXISTS public.team_invitations (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    team_id UUID REFERENCES public.teams(id) ON DELETE CASCADE,
    player_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES public.profiles(id),
    status TEXT DEFAULT 'pending', -- 'pending', 'accepted', 'rejected'
    message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE (team_id, player_id, status)
);

-- Tabla de amistades
CREATE TABLE IF NOT EXISTS public.friendships (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    requester_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    receiver_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'pending', -- 'pending', 'accepted', 'rejected'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    accepted_at TIMESTAMP WITH TIME ZONE,
    UNIQUE (requester_id, receiver_id)
);

-- Tabla de canchas
CREATE TABLE IF NOT EXISTS public.canchas (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT,
    comuna_id UUID REFERENCES public.comunas(id),
    coordinates GEOMETRY(Point, 4326),
    image_url TEXT,
    description TEXT,
    has_lights BOOLEAN DEFAULT FALSE,
    has_parking BOOLEAN DEFAULT FALSE,
    surface_type TEXT, -- 'pasto', 'sintético', 'cemento', etc.
    price_per_hour DECIMAL(10, 2),
    contact_phone TEXT,
    modalities INTEGER[], -- Array de IDs de modalidades disponibles
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Tabla de desafíos entre equipos
CREATE TABLE IF NOT EXISTS public.challenges (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    challenger_team_id UUID REFERENCES public.teams(id) ON DELETE CASCADE,
    challenged_team_id UUID REFERENCES public.teams(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'pending', -- 'pending', 'accepted', 'rejected', 'completed'
    modality_id INTEGER REFERENCES public.football_modalities(id),
    modality_type TEXT, -- 'futbolito', 'futbol11', 'baby_futbol'
    message TEXT,
    proposed_date TIMESTAMP WITH TIME ZONE,
    location TEXT,
    cancha_id UUID REFERENCES public.canchas(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    bet_amount INTEGER DEFAULT 0,
    bet_type TEXT DEFAULT 'none', -- 'none', 'money', 'drinks', 'points'
    comuna_id UUID REFERENCES public.comunas(id),
    sector_id UUID REFERENCES public.sectors(id),
    CONSTRAINT different_teams CHECK (challenger_team_id <> challenged_team_id)
);

-- Tabla de partidos
CREATE TABLE IF NOT EXISTS public.matches (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    home_team_id UUID REFERENCES public.teams(id),
    away_team_id UUID REFERENCES public.teams(id),
    home_score INTEGER DEFAULT 0,
    away_score INTEGER DEFAULT 0,
    match_date TIMESTAMP WITH TIME ZONE,
    status TEXT DEFAULT 'scheduled', -- 'scheduled', 'in_progress', 'completed', 'cancelled'
    modality_id INTEGER REFERENCES public.football_modalities(id),
    modality_type TEXT DEFAULT 'futbolito', -- 'futbolito', 'futbol11', 'baby_futbol'
    min_players INTEGER, -- Mínimo de jugadores requeridos
    max_players INTEGER, -- Máximo de jugadores permitidos
    field_players INTEGER, -- Jugadores en cancha por equipo
    cancha_id UUID REFERENCES public.canchas(id),
    challenge_id UUID REFERENCES public.challenges(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    winner_id UUID REFERENCES public.teams(id),
    duration INTEGER, -- duración en minutos
    notes TEXT,
    home_team_previous_elo INTEGER,
    away_team_previous_elo INTEGER,
    home_team_new_elo INTEGER,
    away_team_new_elo INTEGER,
    location TEXT,
    comuna_id UUID REFERENCES public.comunas(id),
    region_id INTEGER REFERENCES public.regions(id),
    sector_id UUID REFERENCES public.sectors(id),
    coordinates GEOMETRY(Point, 4326),
    is_public BOOLEAN DEFAULT FALSE,
    created_by UUID REFERENCES public.profiles(id),
    CONSTRAINT different_teams CHECK (home_team_id <> away_team_id)
);

-- Tabla de eventos de partido
CREATE TABLE IF NOT EXISTS public.match_events (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    match_id UUID REFERENCES public.matches(id) ON DELETE CASCADE,
    player_id UUID REFERENCES public.profiles(id),
    team_id UUID REFERENCES public.teams(id),
    event_type TEXT NOT NULL, -- 'goal', 'assist', 'yellow_card', 'red_card', 'injury', etc.
    minute INTEGER,
    description TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    verified_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Tabla de jugadores (estadísticas y detalles)
CREATE TABLE IF NOT EXISTS public.players (
    id UUID REFERENCES public.profiles(id) PRIMARY KEY,
    goals INTEGER DEFAULT 0,
    assists INTEGER DEFAULT 0,
    matches_played INTEGER DEFAULT 0,
    wins INTEGER DEFAULT 0,
    losses INTEGER DEFAULT 0,
    draws INTEGER DEFAULT 0,
    yellow_cards INTEGER DEFAULT 0,
    red_cards INTEGER DEFAULT 0,
    minutes_played INTEGER DEFAULT 0,
    elo_rating INTEGER DEFAULT 1200,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Tabla para el historial de ELO de equipos
CREATE TABLE IF NOT EXISTS public.team_elo_history (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    team_id UUID REFERENCES public.teams(id) ON DELETE CASCADE,
    match_id UUID REFERENCES public.matches(id) ON DELETE CASCADE,
    previous_elo INTEGER NOT NULL,
    new_elo INTEGER NOT NULL,
    change INTEGER GENERATED ALWAYS AS (new_elo - previous_elo) STORED,
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Tabla para historial de control de sectores
CREATE TABLE IF NOT EXISTS public.sector_control_history (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    sector_id UUID REFERENCES public.sectors(id) ON DELETE CASCADE,
    team_id UUID REFERENCES public.teams(id),
    control_start TIMESTAMP WITH TIME ZONE DEFAULT now(),
    control_end TIMESTAMP WITH TIME ZONE,
    elo_at_start INTEGER,
    elo_at_end INTEGER,
    total_days INTEGER, -- Días que controló el sector
    match_id UUID REFERENCES public.matches(id), -- Partido que le dio el control
    loss_match_id UUID REFERENCES public.matches(id), -- Partido en que perdió el control
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Tabla para partidos públicos
CREATE TABLE IF NOT EXISTS public.public_matches (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    host_team_id UUID REFERENCES public.teams(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    match_date TIMESTAMP WITH TIME ZONE NOT NULL,
    comuna_id UUID REFERENCES public.comunas(id),
    location TEXT,
    modality_type TEXT DEFAULT 'futbolito',
    min_players INTEGER,
    max_players INTEGER,
    field_players INTEGER,
    min_elo_range INTEGER,
    max_elo_range INTEGER,
    host_team_name TEXT, -- Desnormalizado para rendimiento
    host_team_tag TEXT, -- Desnormalizado para rendimiento
    status TEXT DEFAULT 'open', -- 'open', 'filled', 'cancelled', 'completed'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    expires_at TIMESTAMP WITH TIME ZONE,
    match_id UUID REFERENCES public.matches(id), -- Referencia al partido creado cuando se llena
    created_by UUID REFERENCES public.profiles(id)
);

-- Asegurarnos de que todas las tablas se creen antes de continuar
DO $$ 
BEGIN
    RAISE NOTICE '✅ Tablas creadas correctamente';
END $$;

-- ============================================================
-- FUNCIONES Y TRIGGERS
-- ============================================================

-- Función para actualizar el control de sectores cuando un partido termina
CREATE OR REPLACE FUNCTION public.update_sector_control()
RETURNS TRIGGER AS $$
DECLARE
    current_controller UUID;
    control_start_date TIMESTAMP WITH TIME ZONE;
    team_elo INTEGER;
    days_controlled INTEGER;
BEGIN
    -- Solo si el partido está completado, tiene sector, y tiene ganador
    IF NEW.status = 'completed' AND NEW.sector_id IS NOT NULL AND NEW.winner_id IS NOT NULL AND 
       (OLD.status != 'completed' OR OLD.winner_id IS NULL) THEN
        
        -- Obtener controlador actual y su fecha de inicio
        SELECT controlling_team_id, control_start_date INTO current_controller, control_start_date
        FROM public.sectors
        WHERE id = NEW.sector_id;
        
        -- Obtener ELO del equipo ganador
        SELECT elo_rating INTO team_elo
        FROM public.teams
        WHERE id = NEW.winner_id;
        
        -- Verificar si el ELO del ganador supera el umbral del sector
        IF team_elo >= (SELECT current_elo_threshold FROM public.sectors WHERE id = NEW.sector_id) THEN
            
            -- Si hay un controlador actual y es diferente al ganador
            IF current_controller IS NOT NULL AND current_controller != NEW.winner_id THEN
                -- Calcular días que controló el sector
                days_controlled := EXTRACT(DAY FROM (now() - control_start_date))::INTEGER;
                
                -- Registrar en el historial que el equipo anterior perdió el control
                INSERT INTO public.sector_control_history (
                    sector_id, team_id, control_start, control_end, 
                    elo_at_start, elo_at_end, total_days, match_id, loss_match_id
                )
                VALUES (
                    NEW.sector_id,
                    current_controller,
                    control_start_date,
                    now(),
                    (SELECT elo_rating FROM public.teams WHERE id = current_controller),
                    (SELECT elo_rating FROM public.teams WHERE id = current_controller),
                    days_controlled,
                    NULL, -- No tenemos el partido que le dio el control
                    NEW.id  -- Partido en que perdió el control
                );
            END IF;
            
            -- Actualizar sector con nuevo controlador
            UPDATE public.sectors
            SET 
                controlling_team_id = NEW.winner_id,
                control_start_date = now(),
                current_elo_threshold = team_elo, -- El nuevo umbral es el ELO del ganador
                total_matches = total_matches + 1,
                last_match_date = now(),
                updated_at = now()
            WHERE id = NEW.sector_id;
            
            -- Registrar nuevo control en el historial
            INSERT INTO public.sector_control_history (
                sector_id, team_id, control_start, elo_at_start, match_id
            )
            VALUES (
                NEW.sector_id,
                NEW.winner_id,
                now(),
                team_elo,
                NEW.id
            );
            
            -- Bonus de ELO por capturar un sector
            UPDATE public.teams
            SET elo_rating = elo_rating + 10 -- Pequeño bonus por capturar territorio
            WHERE id = NEW.winner_id;
            
            RETURN NEW;
        END IF;
        
        -- Siempre incrementar el contador de partidos del sector
        UPDATE public.sectors
        SET 
            total_matches = total_matches + 1,
            last_match_date = now(),
            updated_at = now()
        WHERE id = NEW.sector_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear trigger para control de sectores
DROP TRIGGER IF EXISTS match_completed_sector_control ON public.matches;
CREATE TRIGGER match_completed_sector_control
    AFTER UPDATE ON public.matches
    FOR EACH ROW
    EXECUTE FUNCTION public.update_sector_control();

-- Función para actualizar contadores de comuna
CREATE OR REPLACE FUNCTION public.update_comuna_counters()
RETURNS TRIGGER AS $$
BEGIN
    -- Si es INSERT en team_members y el jugador no estaba en otro equipo de la misma comuna
    IF (TG_OP = 'INSERT' AND TG_TABLE_NAME = 'team_members') THEN
        IF NOT EXISTS (
            SELECT 1 
            FROM public.team_members tm
            JOIN public.teams t ON tm.team_id = t.id
            WHERE tm.player_id = NEW.player_id
            AND t.comuna_id = (SELECT comuna_id FROM public.teams WHERE id = NEW.team_id)
            AND tm.id != NEW.id
        ) THEN
            -- Incrementar contador de jugadores en la comuna
            UPDATE public.comunas
            SET total_players = total_players + 1
            WHERE id = (SELECT comuna_id FROM public.teams WHERE id = NEW.team_id);
        END IF;
    
    -- Si es DELETE en team_members y era el único equipo del jugador en esa comuna
    ELSIF (TG_OP = 'DELETE' AND TG_TABLE_NAME = 'team_members') THEN
        IF NOT EXISTS (
            SELECT 1 
            FROM public.team_members tm
            JOIN public.teams t ON tm.team_id = t.id
            WHERE tm.player_id = OLD.player_id
            AND t.comuna_id = (SELECT comuna_id FROM public.teams WHERE id = OLD.team_id)
        ) THEN
            -- Decrementar contador de jugadores en la comuna
            UPDATE public.comunas
            SET total_players = GREATEST(0, total_players - 1)
            WHERE id = (SELECT comuna_id FROM public.teams WHERE id = OLD.team_id);
        END IF;
        
    -- Si es INSERT en teams
    ELSIF (TG_OP = 'INSERT' AND TG_TABLE_NAME = 'teams') THEN
        -- Incrementar contador de equipos en la comuna
        UPDATE public.comunas
        SET total_teams = total_teams + 1
        WHERE id = NEW.comuna_id;
        
    -- Si es DELETE en teams
    ELSIF (TG_OP = 'DELETE' AND TG_TABLE_NAME = 'teams') THEN
        -- Decrementar contador de equipos en la comuna
        UPDATE public.comunas
        SET total_teams = GREATEST(0, total_teams - 1)
        WHERE id = OLD.comuna_id;
        
    -- Si es INSERT o UPDATE en matches y cambia la comuna o el estado
    ELSIF ((TG_OP = 'INSERT' OR TG_OP = 'UPDATE') AND TG_TABLE_NAME = 'matches') THEN
        -- Si es INSERT o se cambia la comuna
        IF (TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND (OLD.comuna_id IS DISTINCT FROM NEW.comuna_id))) THEN
            -- Incrementar contador de partidos en la nueva comuna
            IF NEW.comuna_id IS NOT NULL THEN
                UPDATE public.comunas
                SET total_matches = total_matches + 1
                WHERE id = NEW.comuna_id;
            END IF;
            
            -- Decrementar contador de partidos en la antigua comuna si es UPDATE
            IF TG_OP = 'UPDATE' AND OLD.comuna_id IS NOT NULL THEN
                UPDATE public.comunas
                SET total_matches = GREATEST(0, total_matches - 1)
                WHERE id = OLD.comuna_id;
            END IF;
        END IF;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Crear triggers para actualizar contadores de comuna
DROP TRIGGER IF EXISTS team_members_update_comuna_counters ON public.team_members;
CREATE TRIGGER team_members_update_comuna_counters
    AFTER INSERT OR DELETE ON public.team_members
    FOR EACH ROW
    EXECUTE FUNCTION public.update_comuna_counters();

DROP TRIGGER IF EXISTS teams_update_comuna_counters ON public.teams;
CREATE TRIGGER teams_update_comuna_counters
    AFTER INSERT OR DELETE ON public.teams
    FOR EACH ROW
    EXECUTE FUNCTION public.update_comuna_counters();
    
DROP TRIGGER IF EXISTS matches_update_comuna_counters ON public.matches;
CREATE TRIGGER matches_update_comuna_counters
    AFTER INSERT OR UPDATE ON public.matches
    FOR EACH ROW
    EXECUTE FUNCTION public.update_comuna_counters();

-- Función para actualizar ELO de equipos
CREATE OR REPLACE FUNCTION public.update_team_elo(match_id uuid)
RETURNS void AS $$
DECLARE
    home_team_id uuid;
    away_team_id uuid;
    home_score integer;
    away_score integer;
    home_elo integer;
    away_elo integer;
    home_new_elo integer;
    away_new_elo integer;
    k_factor integer := 32; -- Factor de ajuste ELO
    expected_home_win float;
    expected_away_win float;
    actual_home_result float;
    sector_id_val uuid;
BEGIN
    -- Obtener información del partido
    SELECT 
        m.home_team_id, m.away_team_id, m.home_score, m.away_score,
        h.elo_rating, a.elo_rating, m.sector_id
    INTO 
        home_team_id, away_team_id, home_score, away_score,
        home_elo, away_elo, sector_id_val
    FROM public.matches m
    JOIN public.teams h ON m.home_team_id = h.id
    JOIN public.teams a ON m.away_team_id = a.id
    WHERE m.id = match_id;
    
    -- Calcular probabilidad de victoria
    expected_home_win := 1.0 / (1.0 + 10.0 ^ ((away_elo - home_elo) / 400.0));
    expected_away_win := 1.0 / (1.0 + 10.0 ^ ((home_elo - away_elo) / 400.0));
    
    -- Determinar resultado real (1=victoria, 0.5=empate, 0=derrota)
    IF home_score > away_score THEN
        actual_home_result := 1.0;
    ELSIF home_score = away_score THEN
        actual_home_result := 0.5;
    ELSE
        actual_home_result := 0.0;
    END IF;
    
    -- Ajustar K factor si el partido es en sector disputado
    IF sector_id_val IS NOT NULL THEN
        k_factor := 40; -- Mayor impacto en ELO para partidos territoriales
    END IF;
    
    -- Calcular nuevos ELO
    home_new_elo := home_elo + (k_factor * (actual_home_result - expected_home_win))::integer;
    away_new_elo := away_elo + (k_factor * ((1 - actual_home_result) - expected_away_win))::integer;
    
    -- Actualizar equipos
    UPDATE public.teams 
    SET 
        elo_rating = home_new_elo,
        wins = CASE WHEN home_score > away_score THEN wins + 1 ELSE wins END,
        losses = CASE WHEN home_score < away_score THEN losses + 1 ELSE losses END,
        draws = CASE WHEN home_score = away_score THEN draws + 1 ELSE draws END,
        total_matches = total_matches + 1
    WHERE id = home_team_id;
    
    UPDATE public.teams 
    SET 
        elo_rating = away_new_elo,
        wins = CASE WHEN away_score > home_score THEN wins + 1 ELSE wins END,
        losses = CASE WHEN away_score < home_score THEN losses + 1 ELSE losses END,
        draws = CASE WHEN away_score = home_score THEN draws + 1 ELSE draws END,
        total_matches = total_matches + 1
    WHERE id = away_team_id;
    
    -- Guardar historial ELO
    INSERT INTO public.team_elo_history (team_id, match_id, previous_elo, new_elo)
    VALUES 
        (home_team_id, match_id, home_elo, home_new_elo),
        (away_team_id, match_id, away_elo, away_new_elo);
    
    -- Actualizar partido con ELO
    UPDATE public.matches
    SET 
        home_team_previous_elo = home_elo,
        away_team_previous_elo = away_elo,
        home_team_new_elo = home_new_elo,
        away_team_new_elo = away_new_elo
    WHERE id = match_id;
    
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- FUNCIONES API
-- ============================================================

-- Función para obtener estadísticas de una comuna
CREATE OR REPLACE FUNCTION public.get_comuna_stats(comuna_id_param UUID)
RETURNS json AS $$
DECLARE
    result json;
BEGIN
    WITH stats AS (
        SELECT
            c.id,
            c.name,
            c.region_id,
            r.name as region_name,
            c.total_players,
            c.total_teams,
            c.total_matches,
            (SELECT COUNT(*) FROM public.sectors s WHERE s.comuna_id = c.id) as total_sectors,
            (SELECT COUNT(*) FROM public.canchas ca WHERE ca.comuna_id = c.id) as total_canchas,
            -- Partidos en los últimos 30 días
            (SELECT COUNT(*) 
             FROM public.matches m 
             WHERE m.comuna_id = c.id 
             AND m.match_date > now() - interval '30 days') as recent_matches,
            -- Equipos más activos
            (SELECT json_agg(t.*) FROM (
                SELECT 
                    t.id, 
                    t.name, 
                    t.tag,
                    t.elo_rating,
                    COUNT(m.*) as matches_count
                FROM public.teams t
                LEFT JOIN public.matches m ON (m.home_team_id = t.id OR m.away_team_id = t.id)
                WHERE t.comuna_id = c.id
                GROUP BY t.id
                ORDER BY matches_count DESC
                LIMIT 5
            ) t) as top_teams,
            -- Sectores más disputados
            (SELECT json_agg(s.*) FROM (
                SELECT 
                    s.id, 
                    s.name, 
                    s.total_matches,
                    s.controlling_team_id,
                    t.name as controlling_team_name,
                    t.tag as controlling_team_tag
                FROM public.sectors s
                LEFT JOIN public.teams t ON s.controlling_team_id = t.id
                WHERE s.comuna_id = c.id
                ORDER BY s.total_matches DESC
                LIMIT 5
            ) s) as hot_sectors
        FROM public.comunas c
        JOIN public.regions r ON c.region_id = r.id
        WHERE c.id = comuna_id_param
    )
    
    SELECT json_build_object(
        'id', s.id,
        'name', s.name,
        'region', json_build_object('id', s.region_id, 'name', s.region_name),
        'total_players', s.total_players,
        'total_teams', s.total_teams,
        'total_matches', s.total_matches,
        'total_sectors', s.total_sectors,
        'total_canchas', s.total_canchas,
        'recent_matches', s.recent_matches,
        'top_teams', COALESCE(s.top_teams, '[]'::json),
        'hot_sectors', COALESCE(s.hot_sectors, '[]'::json),
        'last_updated', now()
    ) INTO result
    FROM stats s;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Función para obtener todas las comunas activas con estadísticas básicas
CREATE OR REPLACE FUNCTION public.get_active_comunas()
RETURNS json AS $$
DECLARE
    result json;
BEGIN
    SELECT json_agg(
        json_build_object(
            'id', c.id,
            'name', c.name,
            'region_id', c.region_id,
            'region_name', r.name,
            'total_players', c.total_players,
            'total_teams', c.total_teams,
            'total_matches', c.total_matches,
            'is_active', c.is_active,
            'featured_image_url', c.featured_image_url
        )
    ) INTO result
    FROM public.comunas c
    JOIN public.regions r ON c.region_id = r.id
    WHERE c.is_active = TRUE
    ORDER BY c.name;
    
    RETURN COALESCE(result, '[]'::json);
END;
$$ LANGUAGE plpgsql;

-- Función para obtener el ranking de equipos por comuna
CREATE OR REPLACE FUNCTION public.get_comuna_team_ranking(comuna_id_param UUID)
RETURNS json AS $$
DECLARE
    result json;
BEGIN
    SELECT json_agg(
        json_build_object(
            'rank', ROW_NUMBER() OVER (ORDER BY t.elo_rating DESC),
            'id', t.id,
            'name', t.name,
            'tag', t.tag,
            'elo_rating', t.elo_rating,
            'total_matches', t.total_matches,
            'wins', t.wins,
            'losses', t.losses,
            'draws', t.draws,
            'win_rate', CASE 
                WHEN t.total_matches > 0 
                THEN ROUND((t.wins::float / t.total_matches::float) * 100, 1)
                ELSE 0
            END,
            'sectors_controlled', (
                SELECT COUNT(*) 
                FROM public.sectors
                WHERE controlling_team_id = t.id
            ),
            'logo_url', t.logo_url,
            'captain', (
                SELECT json_build_object(
                    'id', p.id,
                    'name', p.full_name,
                    'tag', p.tag
                )
                FROM public.profiles p
                WHERE p.id = t.captain_id
            )
        )
    ) INTO result
    FROM public.teams t
    WHERE t.comuna_id = comuna_id_param AND t.is_active = TRUE
    ORDER BY t.elo_rating DESC;
    
    RETURN COALESCE(result, '[]'::json);
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- POLÍTICAS RLS
-- ============================================================

-- Habilitar RLS en todas las tablas
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.friendships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.match_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.players ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_elo_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sectors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sector_control_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_tag_relations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.public_matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.regions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comunas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.canchas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.football_modalities ENABLE ROW LEVEL SECURITY;

-- Políticas generales para datos públicos
CREATE POLICY "Lectura pública" ON public.regions FOR SELECT USING (true);
CREATE POLICY "Lectura pública" ON public.comunas FOR SELECT USING (true);
CREATE POLICY "Lectura pública" ON public.sectors FOR SELECT USING (true);
CREATE POLICY "Lectura pública" ON public.football_modalities FOR SELECT USING (true);
CREATE POLICY "Lectura pública" ON public.team_tags FOR SELECT USING (true);
CREATE POLICY "Lectura pública" ON public.canchas FOR SELECT USING (true);

-- Políticas específicas para perfiles
CREATE POLICY "Lectura de perfiles" ON public.profiles
    FOR SELECT USING (true);
    
CREATE POLICY "Actualización de perfil propio" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

-- Políticas para equipos
CREATE POLICY "Lectura de equipos" ON public.teams
    FOR SELECT USING (true);
    
CREATE POLICY "Creación de equipos" ON public.teams
    FOR INSERT WITH CHECK (auth.uid() = captain_id);
    
CREATE POLICY "Actualización de equipos" ON public.teams
    FOR UPDATE USING (
        auth.uid() = captain_id OR
        EXISTS (
            SELECT 1 FROM public.team_members
            WHERE team_id = teams.id AND player_id = auth.uid() AND role IN ('captain', 'coach')
        )
    );
    
CREATE POLICY "Eliminación de equipos" ON public.teams
    FOR DELETE USING (auth.uid() = captain_id);

-- Políticas para miembros de equipo
CREATE POLICY "Lectura de miembros de equipo" ON public.team_members
    FOR SELECT USING (true);
    
CREATE POLICY "Gestión de membresía" ON public.team_members
    FOR INSERT WITH CHECK (
        auth.uid() = player_id OR
        EXISTS (
            SELECT 1 FROM public.team_members tm
            WHERE tm.team_id = team_members.team_id AND tm.player_id = auth.uid() AND tm.role = 'captain'
        )
    );
    
CREATE POLICY "Actualización de miembros" ON public.team_members
    FOR UPDATE USING (
        (auth.uid() = player_id AND role != 'captain') OR
        EXISTS (
            SELECT 1 FROM public.team_members tm
            WHERE tm.team_id = team_members.team_id AND tm.player_id = auth.uid() AND tm.role = 'captain'
        )
    );
    
CREATE POLICY "Eliminación de miembros" ON public.team_members
    FOR DELETE USING (
        auth.uid() = player_id OR
        EXISTS (
            SELECT 1 FROM public.team_members tm
            WHERE tm.team_id = team_members.team_id AND tm.player_id = auth.uid() AND tm.role = 'captain'
        )
    );

-- Políticas para partidos
CREATE POLICY "Lectura de partidos" ON public.matches
    FOR SELECT USING (
        is_public OR
        EXISTS (
            SELECT 1 FROM public.team_members tm
            WHERE (tm.team_id = matches.home_team_id OR tm.team_id = matches.away_team_id) 
            AND tm.player_id = auth.uid()
        )
    );
    
CREATE POLICY "Creación de partidos" ON public.matches
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.team_members tm
            WHERE (tm.team_id = matches.home_team_id OR tm.team_id = matches.away_team_id) 
            AND tm.player_id = auth.uid() AND tm.role = 'captain'
        ) OR
        auth.uid() = created_by
    );
    
CREATE POLICY "Actualización de partidos" ON public.matches
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.team_members tm
            WHERE (tm.team_id = matches.home_team_id OR tm.team_id = matches.away_team_id) 
            AND tm.player_id = auth.uid() AND tm.role = 'captain'
        ) OR
        auth.uid() = created_by
    );

-- ============================================================
-- DATOS INICIALES
-- ============================================================

-- Regiones de Chile (inicialmente solo activamos la Región Metropolitana)
INSERT INTO public.regions (id, name, code, ordinal, is_active)
VALUES
    (1, 'Región de Tarapacá', 'TPCA', 1, FALSE),
    (2, 'Región de Antofagasta', 'ANTOF', 2, FALSE),
    (3, 'Región de Atacama', 'ATCM', 3, FALSE),
    (4, 'Región de Coquimbo', 'COQ', 4, FALSE),
    (5, 'Región de Valparaíso', 'VALPO', 5, FALSE),
    (6, 'Región del Libertador General Bernardo O''Higgins', 'LBOH', 6, FALSE),
    (7, 'Región del Maule', 'MAULE', 7, FALSE),
    (8, 'Región del Biobío', 'BBIO', 8, FALSE),
    (9, 'Región de La Araucanía', 'ARAUC', 9, FALSE),
    (10, 'Región de Los Lagos', 'LAGOS', 10, FALSE),
    (11, 'Región Aysén del General Carlos Ibáñez del Campo', 'AYSEN', 11, FALSE),
    (12, 'Región de Magallanes y de la Antártica Chilena', 'MAG', 12, FALSE),
    (13, 'Región Metropolitana de Santiago', 'RM', 13, TRUE),
    (14, 'Región de Los Ríos', 'RIOS', 14, FALSE),
    (15, 'Región de Arica y Parinacota', 'ARICA', 15, FALSE),
    (16, 'Región de Ñuble', 'NUBLE', 16, FALSE)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    code = EXCLUDED.code,
    ordinal = EXCLUDED.ordinal,
    is_active = EXCLUDED.is_active;

-- Comunas de la Región Metropolitana (solo activamos Quilicura inicialmente)
INSERT INTO public.comunas (name, region_id, code, is_active, description)
VALUES
    ('Quilicura', 13, 'QUILIC', TRUE, 'Comuna ubicada en el sector norte de Santiago, con una creciente comunidad futbolera y múltiples canchas para practicar el deporte.'),
    ('Huechuraba', 13, 'HUECH', FALSE, 'Comuna del sector norte de Santiago, vecina a Quilicura.'),
    ('Renca', 13, 'RENCA', FALSE, 'Comuna del sector norponiente de Santiago.'),
    ('Conchalí', 13, 'CONCH', FALSE, 'Comuna ubicada en el sector norte de Santiago.'),
    ('Independencia', 13, 'INDEP', FALSE, 'Comuna cercana al centro de Santiago.'),
    ('Recoleta', 13, 'RECOL', FALSE, 'Comuna ubicada en el sector norte de Santiago.'),
    ('Providencia', 13, 'PROVI', FALSE, 'Comuna del sector oriente de Santiago.'),
    ('Las Condes', 13, 'LCOND', FALSE, 'Comuna del sector oriente de Santiago.'),
    ('Santiago', 13, 'STGO', FALSE, 'Comuna central de la capital.'),
    ('La Florida', 13, 'LFLOR', FALSE, 'Comuna del sector sur de Santiago.'),
    ('Puente Alto', 13, 'PALT', FALSE, 'Comuna del sector sur de Santiago.')
ON CONFLICT (name, region_id) DO UPDATE SET
    code = EXCLUDED.code,
    is_active = EXCLUDED.is_active,
    description = EXCLUDED.description;

-- Modalidades de fútbol
INSERT INTO public.football_modalities (name, code, players_per_team, min_players, max_players, field_players, description, color_hex)
VALUES
    ('Fútbol 5', 'baby_futbol', 5, 5, 8, 5, 'Fútbol con 5 jugadores por equipo, formato rápido y técnico ideal para canchas pequeñas', '#FF6F00'),
    ('Fútbol 7', 'futbolito', 7, 7, 10, 7, 'Fútbol con 7 jugadores por equipo, balance perfecto entre espacio y acción', '#2E7D32'),
    ('Fútbol 11', 'futbol11', 11, 11, 18, 11, 'Fútbol tradicional con 11 jugadores por equipo, formato oficial FIFA', '#1565C0')
ON CONFLICT (name) DO UPDATE SET
    code = EXCLUDED.code,
    players_per_team = EXCLUDED.players_per_team,
    min_players = EXCLUDED.min_players,
    max_players = EXCLUDED.max_players,
    field_players = EXCLUDED.field_players,
    description = EXCLUDED.description,
    color_hex = EXCLUDED.color_hex;

-- Sectores de Quilicura (para el sistema de dominio territorial)
INSERT INTO public.sectors (comuna_id, name, description, elo_required, is_active)
VALUES
    ((SELECT id FROM public.comunas WHERE name = 'Quilicura' AND region_id = 13), 'Lo Marcoleta', 'Sector residencial popular con varias canchas de fútbol comunitarias', 1200, TRUE),
    ((SELECT id FROM public.comunas WHERE name = 'Quilicura' AND region_id = 13), 'Valle Lo Campino', 'Sector residencial con un amplio parque deportivo', 1250, TRUE),
    ((SELECT id FROM public.comunas WHERE name = 'Quilicura' AND region_id = 13), 'El Mañío', 'Sector con múltiples canchas sintéticas y escuelas de fútbol', 1300, TRUE),
    ((SELECT id FROM public.comunas WHERE name = 'Quilicura' AND region_id = 13), 'Centro', 'Zona central de Quilicura con estadio municipal', 1350, TRUE),
    ((SELECT id FROM public.comunas WHERE name = 'Quilicura' AND region_id = 13), 'Parque Industrial', 'Sector con canchas disponibles durante horarios no laborales', 1200, TRUE)
ON CONFLICT (comuna_id, name) DO UPDATE SET
    description = EXCLUDED.description,
    elo_required = EXCLUDED.elo_required,
    is_active = EXCLUDED.is_active;

-- Etiquetas de equipo
INSERT INTO public.team_tags (name, description)
VALUES
    ('Recreativo', 'Equipo que juega por diversión'),
    ('Competitivo', 'Equipo que juega para ganar'),
    ('Principiante', 'Equipo de nivel básico'),
    ('Intermedio', 'Equipo de nivel medio'),
    ('Avanzado', 'Equipo de nivel alto'),
    ('Amateur', 'Equipo no profesional'),
    ('Femenino', 'Equipo de mujeres'),
    ('Masculino', 'Equipo de hombres'),
    ('Mixto', 'Equipo con hombres y mujeres'),
    ('Nocturno', 'Equipo que juega por la noche'),
    ('Diurno', 'Equipo que juega durante el día'),
    ('Veteranos', 'Equipo de jugadores mayores'),
    ('Juvenil', 'Equipo de jugadores jóvenes'),
    ('Local Quilicura', 'Equipo local de Quilicura'),
    ('Barrial', 'Equipo de barrio o población')
ON CONFLICT (id) DO UPDATE SET 
    description = EXCLUDED.description;

-- ============================================================
-- CONFIGURACIÓN FINAL
-- ============================================================

-- Restaurar las restricciones de foreign key
SET session_replication_role = 'origin';

-- ============================================================
-- MENSAJE FINAL
-- ============================================================

DO $$ 
BEGIN
    RAISE NOTICE '✅ Base de datos instalada correctamente';
    RAISE NOTICE '✅ Sistema configurado para comenzar con Quilicura y expandirse a más comunas';
    RAISE NOTICE '✅ Estructura de datos optimizada para el sistema de mapas territoriales';
    RAISE NOTICE '✅ Soporte completo para diferentes modalidades de fútbol (5, 7, 11)';
    RAISE NOTICE '✅ Políticas de seguridad y permisos implementados';
    RAISE NOTICE '';
    RAISE NOTICE '🏆 Sistema listo para usar';
END $$;