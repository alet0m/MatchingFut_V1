-- Crear tabla players faltante
-- Esta tabla es requerida por match_events y otros servicios

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

-- Crear índices para mejorar rendimiento
CREATE INDEX IF NOT EXISTS idx_players_team_id ON public.players(team_id);
CREATE INDEX IF NOT EXISTS idx_players_user_id ON public.players(user_id);
CREATE INDEX IF NOT EXISTS idx_players_position ON public.players(position);
CREATE INDEX IF NOT EXISTS idx_players_is_captain ON public.players(is_captain);
CREATE INDEX IF NOT EXISTS idx_players_elo ON public.players(elo DESC);
CREATE INDEX IF NOT EXISTS idx_players_is_active ON public.players(is_active);

-- Configurar RLS (Row Level Security)
ALTER TABLE public.players ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios pueden ver jugadores de equipos públicos
CREATE POLICY "Players are viewable by everyone" 
ON public.players FOR SELECT 
USING (true);

-- Política: Solo miembros del equipo pueden insertar jugadores
CREATE POLICY "Team members can insert players" 
ON public.players FOR INSERT 
WITH CHECK (
    auth.uid() IN (
        SELECT user_id FROM public.team_members 
        WHERE team_id = players.team_id
    )
);

-- Política: Solo capitanes y el mismo jugador pueden actualizar
CREATE POLICY "Players can be updated by captains or themselves" 
ON public.players FOR UPDATE 
USING (
    auth.uid() = user_id OR 
    auth.uid() IN (
        SELECT user_id FROM public.team_members 
        WHERE team_id = players.team_id AND is_captain = true
    )
);

-- Política: Solo capitanes pueden eliminar jugadores
CREATE POLICY "Only captains can delete players" 
ON public.players FOR DELETE 
USING (
    auth.uid() IN (
        SELECT user_id FROM public.team_members 
        WHERE team_id = players.team_id AND is_captain = true
    )
);

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION public.handle_updated_at_players()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para updated_at
CREATE TRIGGER trigger_players_updated_at
    BEFORE UPDATE ON public.players
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at_players();

-- Migrar datos existentes de team_members a players (si existen)
DO $$ 
BEGIN
    -- Solo migrar si team_members tiene datos y players está vacía
    IF EXISTS (SELECT 1 FROM public.team_members LIMIT 1) 
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
            COALESCE(position, 'player') as position,
            COALESCE(elo, 1200) as elo,
            COALESCE(goals_scored, 0) as goals_scored,
            COALESCE(assists, 0) as assists,
            COALESCE(yellow_cards, 0) as yellow_cards,
            COALESCE(red_cards, 0) as red_cards,
            COALESCE(is_captain, false) as is_captain,
            COALESCE(joined_at, now()) as joined_at
        FROM public.team_members
        WHERE team_id IS NOT NULL AND user_id IS NOT NULL;
        
        RAISE NOTICE 'Migrated % players from team_members', 
            (SELECT COUNT(*) FROM public.players);
    END IF;
END $$;

-- Habilitar realtime para la tabla players
ALTER PUBLICATION supabase_realtime ADD TABLE public.players;

-- Insertar algunos datos de ejemplo (opcional - solo para testing)
-- Puedes comentar esta sección si no quieres datos de ejemplo
/*
INSERT INTO public.players (name, position, jersey_number, elo) VALUES 
('Jugador Ejemplo 1', 'forward', 10, 1250),
('Jugador Ejemplo 2', 'midfielder', 8, 1200),
('Jugador Ejemplo 3', 'defender', 4, 1180)
ON CONFLICT DO NOTHING;
*/

-- Verificación final
DO $$ 
BEGIN
    RAISE NOTICE 'Tabla players creada exitosamente';
    RAISE NOTICE 'Total de jugadores: %', (SELECT COUNT(*) FROM public.players);
    RAISE NOTICE 'RLS habilitado: %', (
        SELECT row_security FROM information_schema.tables 
        WHERE table_name = 'players' AND table_schema = 'public'
    );
END $$;
