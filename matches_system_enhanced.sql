-- Script para implementar el sistema de partidos mejorado en Supabase
-- Basado en el sistema Firebase pero adaptado para PostgreSQL

-- 1. Tabla principal de partidos mejorada
CREATE TABLE IF NOT EXISTS public.matches (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    
    -- Equipos
    host_team_id UUID REFERENCES public.teams(id) ON DELETE SET NULL,
    host_team_name TEXT NOT NULL,
    guest_team_id UUID REFERENCES public.teams(id) ON DELETE SET NULL,
    guest_team_name TEXT,
    
    -- Detalles del partido
    scheduled_date TIMESTAMPTZ NOT NULL,
    location TEXT NOT NULL,
    match_type TEXT NOT NULL CHECK (match_type IN ('futbolito', 'futbol')),
    duration_minutes INTEGER DEFAULT 90,
    half_time_minutes INTEGER DEFAULT 15,
    players_per_team INTEGER DEFAULT 11,
    description TEXT,
    
    -- Estado y configuración
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'invited', 'confirmed', 'active', 'finished', 'cancelled')),
    is_public BOOLEAN DEFAULT false,
    created_by UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Puntuación
    score_host INTEGER DEFAULT 0,
    score_guest INTEGER DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    confirmed_at TIMESTAMPTZ,
    started_at TIMESTAMPTZ,
    finished_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ,
    cancellation_reason TEXT,
    
    -- Constraints
    CONSTRAINT match_different_teams CHECK (host_team_id != guest_team_id),
    CONSTRAINT match_scores_positive CHECK (score_host >= 0 AND score_guest >= 0)
);

-- 2. Tabla de eventos de partido (goles, tarjetas, etc.)
CREATE TABLE IF NOT EXISTS public.match_events (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    match_id UUID REFERENCES public.matches(id) ON DELETE CASCADE,
    team_id UUID REFERENCES public.teams(id) ON DELETE CASCADE,
    player_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL CHECK (event_type IN ('goal', 'yellow_card', 'red_card', 'substitution', 'own_goal')),
    minute INTEGER CHECK (minute >= 0 AND minute <= 120),
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL
);

-- 3. Tabla de notificaciones
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('match_invitation', 'match_joined', 'match_confirmed', 'match_cancelled', 'friend_request', 'match_reminder')),
    match_id UUID REFERENCES public.matches(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para optimización
CREATE INDEX IF NOT EXISTS idx_matches_host_team ON public.matches(host_team_id);
CREATE INDEX IF NOT EXISTS idx_matches_guest_team ON public.matches(guest_team_id);
CREATE INDEX IF NOT EXISTS idx_matches_status ON public.matches(status);
CREATE INDEX IF NOT EXISTS idx_matches_is_public ON public.matches(is_public);
CREATE INDEX IF NOT EXISTS idx_matches_scheduled_date ON public.matches(scheduled_date);
CREATE INDEX IF NOT EXISTS idx_matches_created_by ON public.matches(created_by);

CREATE INDEX IF NOT EXISTS idx_match_events_match_id ON public.match_events(match_id);
CREATE INDEX IF NOT EXISTS idx_match_events_team_id ON public.match_events(team_id);
CREATE INDEX IF NOT EXISTS idx_match_events_player_id ON public.match_events(player_id);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON public.notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_match_id ON public.notifications(match_id);

-- Triggers para updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_matches_updated_at ON public.matches;
CREATE TRIGGER update_matches_updated_at
    BEFORE UPDATE ON public.matches
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- RLS (Row Level Security)
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.match_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Políticas para matches
DROP POLICY IF EXISTS "Users can view matches involving their teams" ON public.matches;
CREATE POLICY "Users can view matches involving their teams" ON public.matches
    FOR SELECT USING (
        -- Pueden ver partidos públicos
        is_public = true OR
        -- Pueden ver partidos donde participan sus equipos
        EXISTS (
            SELECT 1 FROM public.team_members tm 
            WHERE tm.player_id = auth.uid() 
            AND tm.is_active = true 
            AND (tm.team_id = host_team_id OR tm.team_id = guest_team_id)
        ) OR
        -- Pueden ver partidos que crearon
        created_by = auth.uid()
    );

DROP POLICY IF EXISTS "Users can create matches" ON public.matches;
CREATE POLICY "Users can create matches" ON public.matches
    FOR INSERT WITH CHECK (
        auth.uid() = created_by AND
        -- Solo pueden crear partidos de equipos donde son miembros
        EXISTS (
            SELECT 1 FROM public.team_members tm 
            WHERE tm.player_id = auth.uid() 
            AND tm.team_id = host_team_id 
            AND tm.is_active = true
        )
    );

DROP POLICY IF EXISTS "Users can update matches they created or participate in" ON public.matches;
CREATE POLICY "Users can update matches they created or participate in" ON public.matches
    FOR UPDATE USING (
        created_by = auth.uid() OR
        EXISTS (
            SELECT 1 FROM public.team_members tm 
            WHERE tm.player_id = auth.uid() 
            AND tm.is_active = true 
            AND (tm.team_id = host_team_id OR tm.team_id = guest_team_id)
        )
    );

-- Políticas para match_events
DROP POLICY IF EXISTS "Users can view match events" ON public.match_events;
CREATE POLICY "Users can view match events" ON public.match_events
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.matches m 
            WHERE m.id = match_id 
            AND (
                m.is_public = true OR
                EXISTS (
                    SELECT 1 FROM public.team_members tm 
                    WHERE tm.player_id = auth.uid() 
                    AND tm.is_active = true 
                    AND (tm.team_id = m.host_team_id OR tm.team_id = m.guest_team_id)
                )
            )
        )
    );

DROP POLICY IF EXISTS "Users can create match events" ON public.match_events;
CREATE POLICY "Users can create match events" ON public.match_events
    FOR INSERT WITH CHECK (
        auth.uid() = created_by AND
        EXISTS (
            SELECT 1 FROM public.matches m 
            WHERE m.id = match_id 
            AND m.status = 'active'
            AND EXISTS (
                SELECT 1 FROM public.team_members tm 
                WHERE tm.player_id = auth.uid() 
                AND tm.is_active = true 
                AND (tm.team_id = m.host_team_id OR tm.team_id = m.guest_team_id)
            )
        )
    );

-- Políticas para notifications
DROP POLICY IF EXISTS "Users can view their own notifications" ON public.notifications;
CREATE POLICY "Users can view their own notifications" ON public.notifications
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own notifications" ON public.notifications;
CREATE POLICY "Users can update their own notifications" ON public.notifications
    FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "System can create notifications" ON public.notifications;
CREATE POLICY "System can create notifications" ON public.notifications
    FOR INSERT WITH CHECK (true); -- Las notificaciones las crea el sistema

-- Funciones útiles

-- Función para obtener partidos de un equipo
CREATE OR REPLACE FUNCTION get_team_matches(team_id_param UUID)
RETURNS TABLE (
    match_id UUID,
    opponent_team_id UUID,
    opponent_team_name TEXT,
    is_home BOOLEAN,
    scheduled_date TIMESTAMPTZ,
    status TEXT,
    score_for INTEGER,
    score_against INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.id as match_id,
        CASE 
            WHEN m.host_team_id = team_id_param THEN m.guest_team_id
            ELSE m.host_team_id
        END as opponent_team_id,
        CASE 
            WHEN m.host_team_id = team_id_param THEN m.guest_team_name
            ELSE m.host_team_name
        END as opponent_team_name,
        (m.host_team_id = team_id_param) as is_home,
        m.scheduled_date,
        m.status,
        CASE 
            WHEN m.host_team_id = team_id_param THEN m.score_host
            ELSE m.score_guest
        END as score_for,
        CASE 
            WHEN m.host_team_id = team_id_param THEN m.score_guest
            ELSE m.score_host
        END as score_against
    FROM public.matches m
    WHERE m.host_team_id = team_id_param OR m.guest_team_id = team_id_param
    ORDER BY m.scheduled_date DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para obtener partidos públicos disponibles
CREATE OR REPLACE FUNCTION get_available_public_matches(comuna_id_param UUID DEFAULT NULL)
RETURNS TABLE (
    match_id UUID,
    host_team_id UUID,
    host_team_name TEXT,
    scheduled_date TIMESTAMPTZ,
    location TEXT,
    match_type TEXT,
    description TEXT,
    players_per_team INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.id as match_id,
        m.host_team_id,
        m.host_team_name,
        m.scheduled_date,
        m.location,
        m.match_type,
        m.description,
        m.players_per_team
    FROM public.matches m
    LEFT JOIN public.teams t ON t.id = m.host_team_id
    WHERE m.is_public = true 
    AND m.status = 'pending'
    AND m.guest_team_id IS NULL
    AND m.scheduled_date > NOW()
    AND (comuna_id_param IS NULL OR t.comuna_id = comuna_id_param)
    ORDER BY m.scheduled_date ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para crear notificación de partido
CREATE OR REPLACE FUNCTION create_match_notification(
    user_id_param UUID,
    match_id_param UUID,
    notification_type TEXT,
    title_param TEXT,
    message_param TEXT
)
RETURNS UUID AS $$
DECLARE
    notification_id UUID;
BEGIN
    INSERT INTO public.notifications (user_id, match_id, type, title, message)
    VALUES (user_id_param, match_id_param, notification_type, title_param, message_param)
    RETURNING id INTO notification_id;
    
    RETURN notification_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Verificación final
DO $$
BEGIN
    -- Verificar que las tablas existen
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'matches') THEN
        RAISE NOTICE '✅ Tabla matches creada correctamente';
    ELSE
        RAISE EXCEPTION 'Error: No se pudo crear la tabla matches';
    END IF;
    
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'match_events') THEN
        RAISE NOTICE '✅ Tabla match_events creada correctamente';
    END IF;
    
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'notifications') THEN
        RAISE NOTICE '✅ Tabla notifications creada correctamente';
    END IF;
    
    -- Verificar RLS
    IF (SELECT relrowsecurity FROM pg_class WHERE relname = 'matches') THEN
        RAISE NOTICE '✅ RLS habilitado correctamente en matches';
    END IF;
    
    -- Verificar funciones
    IF EXISTS (SELECT FROM information_schema.routines WHERE routine_name = 'get_team_matches') THEN
        RAISE NOTICE '✅ Función get_team_matches creada correctamente';
    END IF;
    
    RAISE NOTICE '🎉 Sistema de partidos mejorado implementado exitosamente';
END $$;