-- =====================================
-- SISTEMA COMPLETO DE 3 MODALIDADES DE FÚTBOL
-- =====================================

-- 1. CREAR ENUM PARA MODALIDADES DE FÚTBOL
DO $$ BEGIN
    CREATE TYPE football_modality AS ENUM ('futbolito', 'futbol11', 'baby_futbol');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. ACTUALIZAR TABLA TEAMS PARA SOPORTAR MODALIDADES
ALTER TABLE public.teams 
ADD COLUMN IF NOT EXISTS modality football_modality DEFAULT 'futbolito',
ADD COLUMN IF NOT EXISTS min_players integer DEFAULT 7,
ADD COLUMN IF NOT EXISTS max_players integer DEFAULT 10,
ADD COLUMN IF NOT EXISTS field_players integer DEFAULT 7,
ADD COLUMN IF NOT EXISTS comuna TEXT DEFAULT 'quilicura',
ADD COLUMN IF NOT EXISTS tag TEXT,
ADD COLUMN IF NOT EXISTS logo_url TEXT;

-- 3. CREAR TABLA DE ELO POR MODALIDAD
CREATE TABLE IF NOT EXISTS public.team_elo_by_modality (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    team_id uuid NOT NULL,
    modality football_modality NOT NULL,
    elo_rating integer DEFAULT 1200,
    matches_played integer DEFAULT 0,
    wins integer DEFAULT 0,
    losses integer DEFAULT 0,
    draws integer DEFAULT 0,
    goals_for integer DEFAULT 0,
    goals_against integer DEFAULT 0,
    last_match_date timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    
    CONSTRAINT team_elo_by_modality_pkey PRIMARY KEY (id),
    CONSTRAINT team_elo_modality_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE,
    CONSTRAINT unique_team_modality UNIQUE(team_id, modality)
);

-- 4. CREAR TABLA DE JUGADORES POR MODALIDAD
CREATE TABLE IF NOT EXISTS public.player_modality_stats (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    modality football_modality NOT NULL,
    skill_level text DEFAULT 'principiante' CHECK (skill_level = ANY (ARRAY['principiante'::text, 'intermedio'::text, 'avanzado'::text, 'profesional'::text])),
    preferred_position text,
    matches_played integer DEFAULT 0,
    goals integer DEFAULT 0,
    assists integer DEFAULT 0,
    rating_avg decimal(3,2) DEFAULT 0.00,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    
    CONSTRAINT player_modality_stats_pkey PRIMARY KEY (id),
    CONSTRAINT player_modality_user_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE,
    CONSTRAINT unique_player_modality UNIQUE(user_id, modality)
);

-- 5. ACTUALIZAR TABLA PUBLIC_MATCHES PARA MODALIDADES
ALTER TABLE public.public_matches 
ADD COLUMN IF NOT EXISTS modality football_modality DEFAULT 'futbolito',
ADD COLUMN IF NOT EXISTS min_players integer,
ADD COLUMN IF NOT EXISTS max_players integer,
ADD COLUMN IF NOT EXISTS field_players integer;

-- 6. CREAR TABLA BASE DE RECLUTAMIENTO (si no existe)
CREATE TABLE IF NOT EXISTS public.recruitment_posts (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    author_id uuid NOT NULL,
    post_type text NOT NULL CHECK (post_type = ANY (ARRAY['team_seeking_player'::text, 'player_seeking_team'::text])),
    title text NOT NULL,
    description text,
    team_id uuid,
    position_needed text,
    experience_level text,
    age_range_min integer,
    age_range_max integer,
    training_schedule text,
    player_position text,
    player_experience text,
    availability text,
    preferred_comuna text,
    comuna text NOT NULL,
    contact_method text,
    contact_info text,
    is_active boolean DEFAULT true,
    featured boolean DEFAULT false,
    expires_at timestamp with time zone DEFAULT (now() + '30 days'::interval),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    
    CONSTRAINT recruitment_posts_pkey PRIMARY KEY (id),
    CONSTRAINT recruitment_posts_author_fkey FOREIGN KEY (author_id) REFERENCES auth.users(id) ON DELETE CASCADE,
    CONSTRAINT recruitment_posts_team_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE SET NULL
);

-- 7. ACTUALIZAR TABLA MATCHES PARA MODALIDADES (si existe)
-- 7. ACTUALIZAR TABLA MATCHES PARA MODALIDADES (si existe)
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'matches' AND table_schema = 'public') THEN
        ALTER TABLE public.matches 
        ADD COLUMN IF NOT EXISTS modality football_modality DEFAULT 'futbolito',
        ADD COLUMN IF NOT EXISTS min_players integer,
        ADD COLUMN IF NOT EXISTS max_players integer,
        ADD COLUMN IF NOT EXISTS field_players integer;
    END IF;
END $$;

-- 8. CREAR TABLA DE RECLUTAMIENTO POR MODALIDAD
-- 8. CREAR TABLA DE RECLUTAMIENTO POR MODALIDAD
CREATE TABLE IF NOT EXISTS public.recruitment_by_modality (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    post_id uuid NOT NULL,
    modality football_modality NOT NULL,
    position_needed text,
    skill_level_required text DEFAULT 'cualquiera' CHECK (skill_level_required = ANY (ARRAY['cualquiera'::text, 'principiante'::text, 'intermedio'::text, 'avanzado'::text, 'profesional'::text])),
    
    CONSTRAINT recruitment_modality_pkey PRIMARY KEY (id),
    CONSTRAINT recruitment_modality_post_fkey FOREIGN KEY (post_id) REFERENCES public.recruitment_posts(id) ON DELETE CASCADE,
    CONSTRAINT unique_post_modality UNIQUE(post_id, modality)
);

-- 9. FUNCIÓN PARA CONFIGURAR REGLAS POR MODALIDAD
CREATE OR REPLACE FUNCTION get_modality_rules(mod football_modality)
RETURNS TABLE (
    modality_name text,
    min_players integer,
    max_players integer,
    field_players integer,
    description text
) AS $$
BEGIN
    CASE mod
        WHEN 'futbolito' THEN
            RETURN QUERY SELECT 
                'Futbolito'::text,
                7::integer,
                10::integer, 
                7::integer,
                'Fútbol reducido 7v7. Mínimo 7 jugadores por equipo, máximo 10 (solo 7 en cancha)'::text;
        WHEN 'futbol11' THEN
            RETURN QUERY SELECT 
                'Fútbol 11'::text,
                11::integer,
                22::integer,
                11::integer,
                'Fútbol tradicional 11v11 con reglas oficiales FIFA'::text;
        WHEN 'baby_futbol' THEN
            RETURN QUERY SELECT 
                'Baby Fútbol'::text,
                5::integer,
                8::integer,
                5::integer,
                'Fútbol street 5v5 estilo FIFA Street. Rápido y técnico'::text;
    END CASE;
END;
$$ LANGUAGE plpgsql;

-- 10. POSICIONES POR MODALIDAD
CREATE TABLE IF NOT EXISTS public.positions_by_modality (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    modality football_modality NOT NULL,
    position_code text NOT NULL,
    position_name text NOT NULL,
    description text,
    
    CONSTRAINT positions_modality_pkey PRIMARY KEY (id),
    CONSTRAINT unique_position_modality UNIQUE(modality, position_code)
);

-- 11. INSERTAR POSICIONES PARA CADA MODALIDAD
INSERT INTO public.positions_by_modality (modality, position_code, position_name, description) VALUES
-- FUTBOLITO (7v7)
('futbolito', 'POR', 'Portero', 'Arquero del equipo'),
('futbolito', 'DEF', 'Defensor', 'Jugador defensivo'),
('futbolito', 'MED', 'Mediocampista', 'Jugador de medio campo'),
('futbolito', 'DEL', 'Delantero', 'Atacante del equipo'),
('futbolito', 'LIB', 'Líbero', 'Defensor libre'),

-- FÚTBOL 11 (11v11)
('futbol11', 'POR', 'Portero', 'Arquero'),
('futbol11', 'DFC', 'Defensor Central', 'Central en defensa'),
('futbol11', 'LAT', 'Lateral', 'Defensor por las bandas'),
('futbol11', 'MCD', 'Mediocampista Defensivo', 'Volante defensivo'),
('futbol11', 'MC', 'Mediocampista', 'Volante central'),
('futbol11', 'MCO', 'Mediocampista Ofensivo', 'Enganche'),
('futbol11', 'EXT', 'Extremo', 'Atacante por bandas'),
('futbol11', 'DC', 'Delantero Centro', 'Centrodelantero'),

-- BABY FÚTBOL (5v5)
('baby_futbol', 'POR', 'Portero', 'Arquero del equipo'),
('baby_futbol', 'DEF', 'Defensor', 'Jugador defensivo'),
('baby_futbol', 'MED', 'Todo Terreno', 'Jugador polivalente'),
('baby_futbol', 'DEL', 'Delantero', 'Atacante puro')
ON CONFLICT (modality, position_code) DO NOTHING;

-- 12. ÍNDICES PARA OPTIMIZACIÓN
CREATE INDEX IF NOT EXISTS idx_team_elo_modality ON public.team_elo_by_modality(modality, elo_rating);
CREATE INDEX IF NOT EXISTS idx_player_modality ON public.player_modality_stats(modality, skill_level);
CREATE INDEX IF NOT EXISTS idx_public_matches_modality ON public.public_matches(modality, comuna);
CREATE INDEX IF NOT EXISTS idx_recruitment_modality ON public.recruitment_by_modality(modality, skill_level_required);

-- 13. FUNCIÓN PARA INICIALIZAR STATS DE EQUIPO
CREATE OR REPLACE FUNCTION initialize_team_modality_stats(team_uuid uuid, mod football_modality)
RETURNS void AS $$
BEGIN
    INSERT INTO public.team_elo_by_modality (team_id, modality, elo_rating)
    VALUES (team_uuid, mod, 1200)
    ON CONFLICT (team_id, modality) DO NOTHING;
END;
$$ LANGUAGE plpgsql;

-- 14. FUNCIÓN PARA INICIALIZAR STATS DE JUGADOR
CREATE OR REPLACE FUNCTION initialize_player_modality_stats(user_uuid uuid, mod football_modality)
RETURNS void AS $$
BEGIN
    INSERT INTO public.player_modality_stats (user_id, modality, skill_level)
    VALUES (user_uuid, mod, 'principiante')
    ON CONFLICT (user_id, modality) DO NOTHING;
END;
$$ LANGUAGE plpgsql;

-- 15. TRIGGER PARA AUTO-INICIALIZAR STATS AL CREAR EQUIPO
CREATE OR REPLACE FUNCTION auto_initialize_team_stats()
RETURNS TRIGGER AS $$
BEGIN
    -- Inicializar stats para todas las modalidades
    PERFORM initialize_team_modality_stats(NEW.id, 'futbolito');
    PERFORM initialize_team_modality_stats(NEW.id, 'futbol11');
    PERFORM initialize_team_modality_stats(NEW.id, 'baby_futbol');
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Eliminar trigger existente si existe y crear nuevo
DROP TRIGGER IF EXISTS trigger_auto_team_stats ON public.teams;
CREATE TRIGGER trigger_auto_team_stats
    AFTER INSERT ON public.teams
    FOR EACH ROW
    EXECUTE FUNCTION auto_initialize_team_stats();

-- 16. POLÍTICAS RLS PARA NUEVAS TABLAS
ALTER TABLE public.recruitment_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_elo_by_modality ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.player_modality_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recruitment_by_modality ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.positions_by_modality ENABLE ROW LEVEL SECURITY;

-- Eliminar políticas existentes si existen
DROP POLICY IF EXISTS "Anyone can view recruitment posts" ON public.recruitment_posts;
DROP POLICY IF EXISTS "Anyone can view team ELO stats" ON public.team_elo_by_modality;
DROP POLICY IF EXISTS "Anyone can view player stats" ON public.player_modality_stats;
DROP POLICY IF EXISTS "Anyone can view recruitment by modality" ON public.recruitment_by_modality;
DROP POLICY IF EXISTS "Anyone can view positions" ON public.positions_by_modality;
DROP POLICY IF EXISTS "Users can insert their own recruitment posts" ON public.recruitment_posts;
DROP POLICY IF EXISTS "Users can update their own recruitment posts" ON public.recruitment_posts;
DROP POLICY IF EXISTS "Users can delete their own recruitment posts" ON public.recruitment_posts;

-- Políticas básicas de lectura
CREATE POLICY "Anyone can view recruitment posts" ON public.recruitment_posts FOR SELECT USING (true);
CREATE POLICY "Anyone can view team ELO stats" ON public.team_elo_by_modality FOR SELECT USING (true);
CREATE POLICY "Anyone can view player stats" ON public.player_modality_stats FOR SELECT USING (true);
CREATE POLICY "Anyone can view recruitment by modality" ON public.recruitment_by_modality FOR SELECT USING (true);
CREATE POLICY "Anyone can view positions" ON public.positions_by_modality FOR SELECT USING (true);

-- Políticas de inserción para recruitment_posts
CREATE POLICY "Users can insert their own recruitment posts" ON public.recruitment_posts 
  FOR INSERT WITH CHECK (auth.uid() = author_id);

-- Políticas de actualización para recruitment_posts  
CREATE POLICY "Users can update their own recruitment posts" ON public.recruitment_posts
  FOR UPDATE USING (auth.uid() = author_id) WITH CHECK (auth.uid() = author_id);

-- Políticas de eliminación para recruitment_posts
CREATE POLICY "Users can delete their own recruitment posts" ON public.recruitment_posts
  FOR DELETE USING (auth.uid() = author_id);

-- 17. COMENTARIOS PARA DOCUMENTACIÓN
COMMENT ON TYPE football_modality IS 'Modalidades de fútbol: futbolito (7v7), futbol11 (11v11), baby_futbol (5v5)';
COMMENT ON TABLE public.team_elo_by_modality IS 'ELO y estadísticas por modalidad para cada equipo';
COMMENT ON TABLE public.player_modality_stats IS 'Estadísticas individuales por modalidad';
COMMENT ON TABLE public.recruitment_by_modality IS 'Reclutamiento específico por modalidad';
COMMENT ON TABLE public.positions_by_modality IS 'Posiciones disponibles en cada modalidad';

-- 18. VISTA PARA RANKINGS POR MODALIDAD
CREATE OR REPLACE VIEW public.modality_rankings AS
SELECT 
    t.name as team_name,
    COALESCE(t.tag, '') as team_tag,
    COALESCE(t.logo_url, '') as logo_url,
    COALESCE(t.comuna, 'quilicura') as comuna,
    tem.modality,
    tem.elo_rating,
    tem.matches_played,
    tem.wins,
    tem.losses,
    tem.draws,
    CASE 
        WHEN tem.matches_played > 0 THEN 
            ROUND((tem.wins::decimal / tem.matches_played::decimal) * 100, 2)
        ELSE 0 
    END as win_percentage,
    tem.goals_for,
    tem.goals_against,
    (tem.goals_for - tem.goals_against) as goal_difference,
    ROW_NUMBER() OVER (PARTITION BY tem.modality ORDER BY tem.elo_rating DESC) as ranking_position
FROM public.teams t
JOIN public.team_elo_by_modality tem ON t.id = tem.team_id
ORDER BY tem.modality, tem.elo_rating DESC;

COMMENT ON VIEW public.modality_rankings IS 'Ranking de equipos por modalidad con todas las estadísticas';
