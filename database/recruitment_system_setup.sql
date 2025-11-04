-- =====================================
-- SISTEMA DE RECLUTAMIENTO - SETUP SQL
-- =====================================

-- 1. Tabla para publicaciones de reclutamiento
CREATE TABLE public.recruitment_posts (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    author_id uuid NOT NULL, -- Usuario que publica (capitán/jugador)
    post_type text NOT NULL CHECK (post_type = ANY (ARRAY['team_seeking_player'::text, 'player_seeking_team'::text])),
    title text NOT NULL,
    description text NOT NULL,
    
    -- Datos específicos para equipos buscando jugadores
    team_id uuid, -- Solo para team_seeking_player
    position_needed text, -- 'delantero', 'mediocampo', 'defensa', 'arquero'
    experience_level text, -- 'principiante', 'intermedio', 'avanzado'
    age_range_min integer,
    age_range_max integer,
    training_schedule text, -- 'lunes_miercoles', 'fines_de_semana', etc.
    
    -- Datos específicos para jugadores buscando equipos  
    player_position text, -- Para player_seeking_team
    player_experience text, -- Para player_seeking_team
    availability text, -- horarios disponibles
    preferred_comuna text,
    
    -- Datos generales
    comuna text NOT NULL,
    contact_method text DEFAULT 'app'::text CHECK (contact_method = ANY (ARRAY['app'::text, 'whatsapp'::text, 'email'::text])),
    contact_info text,
    is_active boolean DEFAULT true,
    featured boolean DEFAULT false, -- Para destacar publicaciones premium
    expires_at timestamp with time zone DEFAULT (now() + '30 days'::interval),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    
    CONSTRAINT recruitment_posts_pkey PRIMARY KEY (id),
    CONSTRAINT recruitment_posts_author_fkey FOREIGN KEY (author_id) REFERENCES public.profiles(id),
    CONSTRAINT recruitment_posts_team_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id)
);

-- 2. Tabla para aplicaciones a publicaciones de reclutamiento
CREATE TABLE public.recruitment_applications (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    post_id uuid NOT NULL,
    applicant_id uuid NOT NULL,
    message text,
    status text DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'accepted'::text, 'rejected'::text, 'withdrawn'::text])),
    
    -- Datos adicionales del aplicante (para cuando aplican)
    player_stats jsonb, -- estadísticas del jugador
    preferred_position text,
    availability_details text,
    
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    
    CONSTRAINT recruitment_applications_pkey PRIMARY KEY (id),
    CONSTRAINT recruitment_applications_post_fkey FOREIGN KEY (post_id) REFERENCES public.recruitment_posts(id) ON DELETE CASCADE,
    CONSTRAINT recruitment_applications_applicant_fkey FOREIGN KEY (applicant_id) REFERENCES public.profiles(id),
    CONSTRAINT unique_application UNIQUE(post_id, applicant_id)
);

-- 3. Tabla para estadísticas detalladas de jugadores
CREATE TABLE public.player_profiles (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    user_id uuid UNIQUE NOT NULL,
    
    -- Información básica
    preferred_positions text[] DEFAULT '{}', -- ['delantero', 'mediocampo']
    secondary_positions text[] DEFAULT '{}',
    preferred_foot text CHECK (preferred_foot = ANY (ARRAY['derecho'::text, 'izquierdo'::text, 'ambidiestro'::text])),
    height integer, -- en cm
    weight integer, -- en kg
    birth_date date,
    
    -- Experiencia y nivel
    experience_level text DEFAULT 'intermedio'::text CHECK (experience_level = ANY (ARRAY['principiante'::text, 'intermedio'::text, 'avanzado'::text, 'profesional'::text])),
    years_playing integer DEFAULT 0,
    previous_teams text[], -- nombres de equipos anteriores
    achievements text[], -- logros destacados
    
    -- Características físicas/técnicas
    speed_rating integer DEFAULT 5 CHECK (speed_rating >= 1 AND speed_rating <= 10),
    technique_rating integer DEFAULT 5 CHECK (technique_rating >= 1 AND speed_rating <= 10),
    strength_rating integer DEFAULT 5 CHECK (strength_rating >= 1 AND strength_rating <= 10),
    endurance_rating integer DEFAULT 5 CHECK (endurance_rating >= 1 AND endurance_rating <= 10),
    
    -- Disponibilidad
    available_days text[] DEFAULT '{}', -- ['lunes', 'miércoles', 'sábado']
    preferred_time_slots text[] DEFAULT '{}', -- ['mañana', 'tarde', 'noche']
    preferred_comunas text[] DEFAULT '{}',
    
    -- Estado
    looking_for_team boolean DEFAULT false,
    open_to_offers boolean DEFAULT true,
    profile_visibility text DEFAULT 'public'::text CHECK (profile_visibility = ANY (ARRAY['public'::text, 'teams_only'::text, 'private'::text])),
    
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    
    CONSTRAINT player_profiles_pkey PRIMARY KEY (id),
    CONSTRAINT player_profiles_user_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);

-- 4. Tabla para perfiles extendidos de equipos (para reclutamiento)
CREATE TABLE public.team_recruitment_profiles (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    team_id uuid UNIQUE NOT NULL,
    
    -- Información del equipo
    team_philosophy text, -- filosofía de juego
    training_frequency text, -- frecuencia de entrenamientos
    training_location text, -- dónde entrenan
    competitive_level text DEFAULT 'amateur'::text CHECK (competitive_level = ANY (ARRAY['amateur'::text, 'semi_profesional'::text, 'competitivo'::text])),
    
    -- Requisitos generales para jugadores
    min_age integer,
    max_age integer,
    required_experience text,
    required_commitment text, -- nivel de compromiso esperado
    
    -- Información de contacto y reclutamiento
    recruitment_contact_id uuid, -- quién maneja el reclutamiento
    recruitment_active boolean DEFAULT true,
    tryout_process text, -- proceso de pruebas
    
    -- Beneficios que ofrece el equipo
    offers_equipment boolean DEFAULT false,
    offers_transportation boolean DEFAULT false,
    covers_match_fees boolean DEFAULT false,
    social_activities boolean DEFAULT false,
    
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    
    CONSTRAINT team_recruitment_profiles_pkey PRIMARY KEY (id),
    CONSTRAINT team_recruitment_profiles_team_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id),
    CONSTRAINT team_recruitment_profiles_contact_fkey FOREIGN KEY (recruitment_contact_id) REFERENCES public.profiles(id)
);

-- 5. Índices para optimizar búsquedas
CREATE INDEX IF NOT EXISTS idx_recruitment_posts_type ON public.recruitment_posts(post_type);
CREATE INDEX IF NOT EXISTS idx_recruitment_posts_comuna ON public.recruitment_posts(comuna);
CREATE INDEX IF NOT EXISTS idx_recruitment_posts_position ON public.recruitment_posts(position_needed);
CREATE INDEX IF NOT EXISTS idx_recruitment_posts_active ON public.recruitment_posts(is_active);
CREATE INDEX IF NOT EXISTS idx_recruitment_posts_expires ON public.recruitment_posts(expires_at);
CREATE INDEX IF NOT EXISTS idx_player_profiles_positions ON public.player_profiles USING GIN(preferred_positions);
CREATE INDEX IF NOT EXISTS idx_player_profiles_looking ON public.player_profiles(looking_for_team);
CREATE INDEX IF NOT EXISTS idx_player_profiles_comunas ON public.player_profiles USING GIN(preferred_comunas);

-- 6. Configurar RLS (Row Level Security)
ALTER TABLE public.recruitment_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recruitment_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.player_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_recruitment_profiles ENABLE ROW LEVEL SECURITY;

-- Políticas para recruitment_posts
CREATE POLICY "Users can view all active posts" 
ON public.recruitment_posts FOR SELECT 
USING (is_active = true AND expires_at > now());

CREATE POLICY "Users can create posts" 
ON public.recruitment_posts FOR INSERT 
WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Authors can update their posts" 
ON public.recruitment_posts FOR UPDATE 
USING (auth.uid() = author_id);

-- Políticas para recruitment_applications
CREATE POLICY "Users can view applications for their posts or applications they made" 
ON public.recruitment_applications FOR SELECT 
USING (
    auth.uid() = applicant_id OR 
    auth.uid() IN (SELECT author_id FROM recruitment_posts WHERE id = post_id)
);

CREATE POLICY "Users can create applications" 
ON public.recruitment_applications FOR INSERT 
WITH CHECK (auth.uid() = applicant_id);

CREATE POLICY "Users can update their own applications" 
ON public.recruitment_applications FOR UPDATE 
USING (auth.uid() = applicant_id OR 
       auth.uid() IN (SELECT author_id FROM recruitment_posts WHERE id = post_id));

-- Políticas para player_profiles
CREATE POLICY "Users can view public profiles" 
ON public.player_profiles FOR SELECT 
USING (profile_visibility = 'public' OR auth.uid() = user_id);

CREATE POLICY "Users can manage their own profile" 
ON public.player_profiles FOR ALL 
USING (auth.uid() = user_id);

-- Políticas para team_recruitment_profiles
CREATE POLICY "Users can view team profiles" 
ON public.team_recruitment_profiles FOR SELECT 
USING (recruitment_active = true);

CREATE POLICY "Team members can manage recruitment profile" 
ON public.team_recruitment_profiles FOR ALL 
USING (auth.uid() IN (
    SELECT unnest(member_ids) FROM teams WHERE id = team_id
    UNION 
    SELECT captain_id FROM teams WHERE id = team_id
    UNION
    SELECT owner_id FROM teams WHERE id = team_id
));

-- 7. Triggers para updated_at
CREATE TRIGGER update_recruitment_posts_updated_at 
    BEFORE UPDATE ON public.recruitment_posts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_recruitment_applications_updated_at 
    BEFORE UPDATE ON public.recruitment_applications 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_player_profiles_updated_at 
    BEFORE UPDATE ON public.player_profiles 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_team_recruitment_profiles_updated_at 
    BEFORE UPDATE ON public.team_recruitment_profiles 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 8. Función para limpiar posts expirados
CREATE OR REPLACE FUNCTION cleanup_expired_recruitment_posts()
RETURNS void AS $$
BEGIN
    UPDATE public.recruitment_posts 
    SET is_active = false
    WHERE is_active = true AND expires_at < now();
END;
$$ language 'plpgsql';

-- =====================================
-- DATOS DE EJEMPLO (opcional)
-- =====================================
/*
-- Insertar algunos posts de ejemplo
INSERT INTO public.recruitment_posts 
(author_id, post_type, title, description, team_id, position_needed, experience_level, comuna) 
VALUES
(
    (SELECT id FROM profiles LIMIT 1),
    'team_seeking_player',
    'Se busca delantero centro',
    'Equipo competitivo busca delantero centro con experiencia. Entrenamientos martes y jueves 19:00. Buen ambiente y nivel intermedio-avanzado.',
    (SELECT id FROM teams LIMIT 1),
    'delantero',
    'intermedio',
    'Quilicura'
);

INSERT INTO public.recruitment_posts 
(author_id, post_type, title, description, player_position, player_experience, comuna) 
VALUES
(
    (SELECT id FROM profiles OFFSET 1 LIMIT 1),
    'player_seeking_team',
    'Mediocampista busca equipo',
    'Jugador de mediocampo con 5 años de experiencia. Disponible fines de semana. Buen pase y visión de juego.',
    'mediocampo',
    'intermedio',
    'Las Condes'
);
*/
