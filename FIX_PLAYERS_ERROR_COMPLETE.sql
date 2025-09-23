-- SCRIPT COMPLETO PARA SOLUCIONAR ERROR: relation "players" does not exist
-- Este script debe ejecutarse en Supabase SQL Editor
-- Ejecuta este archivo ÚNICO para solucionar todos los errores

-- ============================================
-- PASO 1: CREAR TABLA PLAYERS
-- ============================================

CREATE TABLE IF NOT EXISTS public.players (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    team_id UUID REFERENCES public.teams(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT,
    position TEXT DEFAULT 'player' CHECK (position IN ('goalkeeper', 'defender', 'midfielder', 'forward', 'player')),
    jersey_number INTEGER,
    elo INTEGER DEFAULT 1200,
    goals_scored INTEGER DEFAULT 0,
    assists INTEGER DEFAULT 0,
    yellow_cards INTEGER DEFAULT 0,
    red_cards INTEGER DEFAULT 0,
    matches_played INTEGER DEFAULT 0,
    is_captain BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    joined_at TIMESTAMPTZ DEFAULT now(),
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(team_id, jersey_number),
    UNIQUE(team_id, user_id)
);

-- Índices para players
CREATE INDEX IF NOT EXISTS idx_players_team_id ON public.players(team_id);
CREATE INDEX IF NOT EXISTS idx_players_user_id ON public.players(user_id);
CREATE INDEX IF NOT EXISTS idx_players_position ON public.players(position);
CREATE INDEX IF NOT EXISTS idx_players_is_captain ON public.players(is_captain);
CREATE INDEX IF NOT EXISTS idx_players_elo ON public.players(elo DESC);

-- RLS para players
ALTER TABLE public.players ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Players are viewable by everyone" 
ON public.players FOR SELECT USING (true);

CREATE POLICY "Team members can insert players" 
ON public.players FOR INSERT 
WITH CHECK (
    auth.uid() IN (
        SELECT user_id FROM public.team_members 
        WHERE team_id = players.team_id
    )
);

CREATE POLICY "Players can be updated by captains or themselves" 
ON public.players FOR UPDATE 
USING (
    auth.uid() = user_id OR 
    auth.uid() IN (
        SELECT user_id FROM public.team_members 
        WHERE team_id = players.team_id AND is_captain = true
    )
);

-- ============================================
-- PASO 2: CREAR TABLA MATCH_EVENTS
-- ============================================

CREATE TABLE IF NOT EXISTS public.match_events (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    match_id UUID NOT NULL REFERENCES public.matches(id) ON DELETE CASCADE,
    event_type VARCHAR(50) NOT NULL CHECK (
        event_type IN (
            'goal', 'yellow_card', 'red_card', 'substitution', 
            'corner', 'free_kick', 'penalty', 'offside',
            'match_start', 'match_end', 'half_time', 'injury_time'
        )
    ),
    player_id UUID REFERENCES public.players(id) ON DELETE SET NULL,
    team_id UUID NOT NULL REFERENCES public.teams(id) ON DELETE CASCADE,
    minute INTEGER NOT NULL CHECK (minute >= 0 AND minute <= 120),
    description TEXT,
    extra_data JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Índices para match_events
CREATE INDEX IF NOT EXISTS idx_match_events_match_id ON public.match_events(match_id);
CREATE INDEX IF NOT EXISTS idx_match_events_event_type ON public.match_events(event_type);
CREATE INDEX IF NOT EXISTS idx_match_events_player_id ON public.match_events(player_id);
CREATE INDEX IF NOT EXISTS idx_match_events_team_id ON public.match_events(team_id);
CREATE INDEX IF NOT EXISTS idx_match_events_minute ON public.match_events(minute);
CREATE INDEX IF NOT EXISTS idx_match_events_match_minute ON public.match_events(match_id, minute);

-- RLS para match_events
ALTER TABLE public.match_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Match events are viewable by everyone" 
ON public.match_events FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create match events" 
ON public.match_events FOR INSERT 
WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Match creators can update events" 
ON public.match_events FOR UPDATE 
USING (
    auth.uid() IN (
        SELECT created_by FROM public.matches 
        WHERE id = match_events.match_id
    )
);

-- ============================================
-- PASO 3: FUNCIONES Y TRIGGERS
-- ============================================

-- Función para updated_at en players
CREATE OR REPLACE FUNCTION public.handle_updated_at_players()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_players_updated_at
    BEFORE UPDATE ON public.players
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at_players();

-- Función para updated_at en match_events
CREATE OR REPLACE FUNCTION public.handle_updated_at_match_events()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_match_events_updated_at
    BEFORE UPDATE ON public.match_events
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at_match_events();

-- Función para actualizar estadísticas de jugadores
CREATE OR REPLACE FUNCTION public.update_player_stats_on_event()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.event_type = 'goal' AND NEW.player_id IS NOT NULL THEN
        UPDATE public.players 
        SET goals_scored = goals_scored + 1, updated_at = now()
        WHERE id = NEW.player_id;
    ELSIF NEW.event_type = 'yellow_card' AND NEW.player_id IS NOT NULL THEN
        UPDATE public.players 
        SET yellow_cards = yellow_cards + 1, updated_at = now()
        WHERE id = NEW.player_id;
    ELSIF NEW.event_type = 'red_card' AND NEW.player_id IS NOT NULL THEN
        UPDATE public.players 
        SET red_cards = red_cards + 1, updated_at = now()
        WHERE id = NEW.player_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_player_stats
    AFTER INSERT ON public.match_events
    FOR EACH ROW EXECUTE FUNCTION public.update_player_stats_on_event();

-- ============================================
-- PASO 4: HABILITAR REALTIME
-- ============================================

ALTER PUBLICATION supabase_realtime ADD TABLE public.players;
ALTER PUBLICATION supabase_realtime ADD TABLE public.match_events;

-- ============================================
-- PASO 5: MIGRACIÓN DE DATOS (SI EXISTE team_members)
-- ============================================

DO $$ 
BEGIN
    -- Migrar de team_members a players si existe data
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name='team_members' AND table_schema='public')
       AND EXISTS (SELECT 1 FROM public.team_members LIMIT 1) 
       AND NOT EXISTS (SELECT 1 FROM public.players LIMIT 1) THEN
        
        INSERT INTO public.players (
            team_id, user_id, name, position, elo, 
            goals_scored, assists, yellow_cards, red_cards,
            is_captain, joined_at
        )
        SELECT 
            team_id, 
            user_id,
            COALESCE(name, 'Jugador ' || SUBSTRING(user_id::text FROM 1 FOR 8)) as name,
            CASE 
                WHEN position IN ('goalkeeper', 'defender', 'midfielder', 'forward', 'player') THEN position
                WHEN position = 'Capitán' OR position = 'Captain' THEN 'player'
                WHEN position IS NULL OR position = '' THEN 'player'
                ELSE 'player'
            END as position,
            COALESCE(elo, 1200) as elo,
            COALESCE(goals_scored, 0) as goals_scored,
            COALESCE(assists, 0) as assists,
            COALESCE(yellow_cards, 0) as yellow_cards,
            COALESCE(red_cards, 0) as red_cards,
            CASE 
                WHEN position = 'Capitán' OR position = 'Captain' OR is_captain = true THEN true
                ELSE COALESCE(is_captain, false)
            END as is_captain,
            COALESCE(joined_at, now()) as joined_at
        FROM public.team_members
        WHERE team_id IS NOT NULL AND user_id IS NOT NULL
        ON CONFLICT (team_id, user_id) DO NOTHING;
        
        RAISE NOTICE 'Migrated % players from team_members', 
            (SELECT COUNT(*) FROM public.players);
    END IF;
END $$;

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

DO $$ 
BEGIN
    RAISE NOTICE '✅ SETUP COMPLETADO EXITOSAMENTE';
    RAISE NOTICE 'Tabla players: % registros', (SELECT COUNT(*) FROM public.players);
    RAISE NOTICE 'Tabla match_events: % registros', (SELECT COUNT(*) FROM public.match_events);
    RAISE NOTICE 'RLS habilitado en ambas tablas';
    RAISE NOTICE 'Realtime habilitado para live match system';
    RAISE NOTICE '';
    RAISE NOTICE '🚀 SISTEMA DE PARTIDOS EN VIVO LISTO PARA USAR';
END $$;
