-- Crear tabla match_events para el sistema de partidos en vivo
-- Esta tabla almacena todos los eventos que ocurren durante un partido

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

-- Crear índices para mejorar rendimiento
CREATE INDEX IF NOT EXISTS idx_match_events_match_id ON public.match_events(match_id);
CREATE INDEX IF NOT EXISTS idx_match_events_event_type ON public.match_events(event_type);
CREATE INDEX IF NOT EXISTS idx_match_events_player_id ON public.match_events(player_id);
CREATE INDEX IF NOT EXISTS idx_match_events_team_id ON public.match_events(team_id);
CREATE INDEX IF NOT EXISTS idx_match_events_minute ON public.match_events(minute);
CREATE INDEX IF NOT EXISTS idx_match_events_created_at ON public.match_events(created_at DESC);

-- Índice compuesto para consultas frecuentes
CREATE INDEX IF NOT EXISTS idx_match_events_match_minute ON public.match_events(match_id, minute);
CREATE INDEX IF NOT EXISTS idx_match_events_match_type ON public.match_events(match_id, event_type);

-- Configurar RLS (Row Level Security)
ALTER TABLE public.match_events ENABLE ROW LEVEL SECURITY;

-- Política: Los eventos son visibles públicamente
CREATE POLICY "Match events are viewable by everyone" 
ON public.match_events FOR SELECT 
USING (true);

-- Política: Solo usuarios autenticados pueden crear eventos
CREATE POLICY "Authenticated users can create match events" 
ON public.match_events FOR INSERT 
WITH CHECK (auth.role() = 'authenticated');

-- Política: Solo el creador del partido puede actualizar eventos
CREATE POLICY "Match creators can update events" 
ON public.match_events FOR UPDATE 
USING (
    auth.uid() IN (
        SELECT created_by FROM public.matches 
        WHERE id = match_events.match_id
    )
);

-- Política: Solo el creador del partido puede eliminar eventos
CREATE POLICY "Match creators can delete events" 
ON public.match_events FOR DELETE 
USING (
    auth.uid() IN (
        SELECT created_by FROM public.matches 
        WHERE id = match_events.match_id
    )
);

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION public.handle_updated_at_match_events()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para updated_at
CREATE TRIGGER trigger_match_events_updated_at
    BEFORE UPDATE ON public.match_events
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at_match_events();

-- Función para actualizar estadísticas del jugador cuando ocurre un evento
CREATE OR REPLACE FUNCTION public.update_player_stats_on_event()
RETURNS TRIGGER AS $$
BEGIN
    -- Actualizar estadísticas según el tipo de evento
    IF NEW.event_type = 'goal' AND NEW.player_id IS NOT NULL THEN
        UPDATE public.players 
        SET goals_scored = goals_scored + 1,
            updated_at = now()
        WHERE id = NEW.player_id;
        
    ELSIF NEW.event_type = 'yellow_card' AND NEW.player_id IS NOT NULL THEN
        UPDATE public.players 
        SET yellow_cards = yellow_cards + 1,
            updated_at = now()
        WHERE id = NEW.player_id;
        
    ELSIF NEW.event_type = 'red_card' AND NEW.player_id IS NOT NULL THEN
        UPDATE public.players 
        SET red_cards = red_cards + 1,
            updated_at = now()
        WHERE id = NEW.player_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar estadísticas de jugadores automáticamente
CREATE TRIGGER trigger_update_player_stats
    AFTER INSERT ON public.match_events
    FOR EACH ROW EXECUTE FUNCTION public.update_player_stats_on_event();

-- Función para obtener estadísticas de eventos de un partido
CREATE OR REPLACE FUNCTION public.get_match_event_stats(match_uuid UUID)
RETURNS TABLE(
    event_type VARCHAR(50),
    team_id UUID,
    count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        me.event_type,
        me.team_id,
        COUNT(*) as count
    FROM public.match_events me
    WHERE me.match_id = match_uuid
    GROUP BY me.event_type, me.team_id
    ORDER BY me.event_type, me.team_id;
END;
$$ LANGUAGE plpgsql;

-- Función para obtener eventos de un partido ordenados por tiempo
CREATE OR REPLACE FUNCTION public.get_match_events_timeline(match_uuid UUID)
RETURNS TABLE(
    id UUID,
    event_type VARCHAR(50),
    player_name TEXT,
    team_name TEXT,
    minute INTEGER,
    description TEXT,
    created_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        me.id,
        me.event_type,
        p.name as player_name,
        t.name as team_name,
        me.minute,
        me.description,
        me.created_at
    FROM public.match_events me
    LEFT JOIN public.players p ON p.id = me.player_id
    LEFT JOIN public.teams t ON t.id = me.team_id
    WHERE me.match_id = match_uuid
    ORDER BY me.minute ASC, me.created_at ASC;
END;
$$ LANGUAGE plpgsql;

-- Habilitar realtime para la tabla match_events
ALTER PUBLICATION supabase_realtime ADD TABLE public.match_events;

-- Insertar algunos eventos de ejemplo (opcional - solo para testing)
-- Puedes comentar esta sección si no quieres datos de ejemplo
/*
DO $$ 
DECLARE
    sample_match_id UUID;
    sample_team_id UUID;
    sample_player_id UUID;
BEGIN
    -- Obtener un partido de ejemplo
    SELECT id INTO sample_match_id FROM public.matches LIMIT 1;
    SELECT id INTO sample_team_id FROM public.teams LIMIT 1;
    SELECT id INTO sample_player_id FROM public.players LIMIT 1;
    
    IF sample_match_id IS NOT NULL AND sample_team_id IS NOT NULL THEN
        INSERT INTO public.match_events (
            match_id, event_type, team_id, player_id, minute, description
        ) VALUES 
        (sample_match_id, 'match_start', sample_team_id, NULL, 0, 'Inicio del partido'),
        (sample_match_id, 'goal', sample_team_id, sample_player_id, 25, 'Gol de ejemplo')
        ON CONFLICT DO NOTHING;
        
        RAISE NOTICE 'Eventos de ejemplo creados';
    END IF;
END $$;
*/

-- Verificación final
DO $$ 
BEGIN
    RAISE NOTICE 'Tabla match_events creada exitosamente';
    RAISE NOTICE 'Total de eventos: %', (SELECT COUNT(*) FROM public.match_events);
    RAISE NOTICE 'Funciones de estadísticas creadas';
    RAISE NOTICE 'RLS habilitado: %', (
        SELECT row_security FROM information_schema.tables 
        WHERE table_name = 'match_events' AND table_schema = 'public'
    );
    RAISE NOTICE 'Realtime habilitado para match_events';
END $$;
