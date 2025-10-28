-- ESQUEMA DE BASE DE DATOS PARA FÚTBOL APP QUILICURA
-- Este archivo debe ejecutarse en el SQL Editor de Supabase

-- 1. TABLA DE REGIONES
CREATE TABLE public.regions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying NOT NULL UNIQUE,
  code character varying NOT NULL UNIQUE,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT regions_pkey PRIMARY KEY (id)
);

-- 2. TABLA DE COMUNAS
CREATE TABLE public.comunas (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying NOT NULL,
  region_id uuid,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT comunas_pkey PRIMARY KEY (id),
  CONSTRAINT comunas_region_id_fkey FOREIGN KEY (region_id) REFERENCES public.regions(id)
);

-- 3. TABLA DE USUARIOS (Información básica)
CREATE TABLE public.users (
  id uuid NOT NULL,
  email character varying NOT NULL UNIQUE,
  full_name character varying NOT NULL,
  nickname character varying,
  date_of_birth date,
  age integer,
  comuna_id uuid,
  sector_name character varying,
  profile_image_url text,
  is_email_verified boolean DEFAULT false,
  has_completed_onboarding boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT users_pkey PRIMARY KEY (id),
  CONSTRAINT users_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);

-- 4. TABLA DE SECTORES POR COMUNA
CREATE TABLE public.sectores_comuna (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying NOT NULL,
  comuna_id uuid,
  description text,
  current_champion_id uuid,
  total_matches integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT sectores_comuna_pkey PRIMARY KEY (id),
  CONSTRAINT sectores_comuna_current_champion_id_fkey FOREIGN KEY (current_champion_id) REFERENCES public.users(id),
  CONSTRAINT sectores_comuna_comuna_id_fkey FOREIGN KEY (comuna_id) REFERENCES public.comunas(id)
);

-- 5. TABLA DE PERFILES DE JUGADOR (Datos del onboarding)
CREATE TABLE public.player_profiles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  nickname character varying,
  years_playing integer DEFAULT 1,
  preferred_position character varying,
  dominant_foot character varying,
  skill_level character varying,
  height integer,
  weight integer,
  preferred_game_type character varying,
  available_days ARRAY,
  preferred_time time without time zone,
  budget_per_match numeric,
  goals ARRAY,
  current_elo integer DEFAULT 1200,
  current_sector_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT player_profiles_pkey PRIMARY KEY (id),
  CONSTRAINT player_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);

-- 6. TABLA DE EQUIPOS
CREATE TABLE public.teams (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying NOT NULL,
  captain_id uuid,
  sector_id uuid,
  average_elo integer DEFAULT 1200,
  total_matches integer DEFAULT 0,
  wins integer DEFAULT 0,
  losses integer DEFAULT 0,
  draws integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT teams_pkey PRIMARY KEY (id),
  CONSTRAINT teams_captain_id_fkey FOREIGN KEY (captain_id) REFERENCES public.users(id),
  CONSTRAINT teams_sector_id_fkey FOREIGN KEY (sector_id) REFERENCES public.sectores_comuna(id)
);

-- 7. TABLA DE MIEMBROS DE EQUIPOS
CREATE TABLE public.team_members (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  team_id uuid,
  user_id uuid,
  position character varying,
  is_active boolean DEFAULT true,
  joined_at timestamp with time zone DEFAULT now(),
  CONSTRAINT team_members_pkey PRIMARY KEY (id),
  CONSTRAINT team_members_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id),
  CONSTRAINT team_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);

-- 8. TABLA DE CANCHAS
CREATE TABLE public.canchas (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying NOT NULL,
  comuna_id uuid,
  address text,
  field_type character varying,
  surface_type character varying,
  has_lighting boolean DEFAULT false,
  capacity integer,
  hourly_rate numeric,
  contact_phone character varying,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT canchas_pkey PRIMARY KEY (id),
  CONSTRAINT canchas_comuna_id_fkey FOREIGN KEY (comuna_id) REFERENCES public.comunas(id)
);

-- 9. TABLA DE PARTIDOS
CREATE TABLE public.matches (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  home_team_id uuid,
  away_team_id uuid,
  cancha_id uuid,
  sector_id uuid,
  match_date timestamp with time zone NOT NULL,
  status character varying DEFAULT 'scheduled'::character varying,
  home_score integer DEFAULT 0,
  away_score integer DEFAULT 0,
  elo_change integer DEFAULT 0,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT matches_pkey PRIMARY KEY (id),
  CONSTRAINT matches_home_team_id_fkey FOREIGN KEY (home_team_id) REFERENCES public.teams(id),
  CONSTRAINT matches_away_team_id_fkey FOREIGN KEY (away_team_id) REFERENCES public.teams(id),
  CONSTRAINT matches_cancha_id_fkey FOREIGN KEY (cancha_id) REFERENCES public.canchas(id),
  CONSTRAINT matches_sector_id_fkey FOREIGN KEY (sector_id) REFERENCES public.sectores_comuna(id),
  CONSTRAINT matches_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id)
);

-- POLÍTICAS DE SEGURIDAD (Row Level Security)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.player_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.regions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comunas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.canchas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sectores_comuna ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_members ENABLE ROW LEVEL SECURITY;

-- Políticas para usuarios
CREATE POLICY "Users can view own profile" ON public.users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can view all profiles" ON public.users
  FOR SELECT USING (true);

-- Políticas para perfiles de jugador
CREATE POLICY "Users can view own player profile" ON public.player_profiles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own player profile" ON public.player_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own player profile" ON public.player_profiles
  FOR UPDATE USING (auth.uid() = user_id);

-- Políticas para sectores (todos pueden ver)
CREATE POLICY "Anyone can view regions" ON public.regions
  FOR SELECT USING (true);

CREATE POLICY "Anyone can view comunas" ON public.comunas
  FOR SELECT USING (true);

CREATE POLICY "Anyone can view canchas" ON public.canchas
  FOR SELECT USING (true);

CREATE POLICY "Anyone can view sectores_comuna" ON public.sectores_comuna
  FOR SELECT USING (true);

-- Políticas para partidos (todos pueden ver)
CREATE POLICY "Anyone can view matches" ON public.matches
  FOR SELECT USING (true);

CREATE POLICY "Users can create matches" ON public.matches
  FOR INSERT WITH CHECK (auth.uid() = created_by);

-- FUNCIONES AUTOMÁTICAS
-- Crear perfil de usuario automáticamente al registrarse
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, full_name)
  VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'full_name');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para crear usuario automáticamente
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Función para actualizar ELO después de un partido
CREATE OR REPLACE FUNCTION public.update_elo_after_match()
RETURNS TRIGGER AS $$
DECLARE
  home_elo INTEGER;
  away_elo INTEGER;
  expected_home DECIMAL;
  new_home_elo INTEGER;
  new_away_elo INTEGER;
  k_factor INTEGER := 32;
BEGIN
  IF NEW.status = 'finished' AND OLD.status != 'finished' THEN
    SELECT average_elo INTO home_elo FROM public.teams WHERE id = NEW.home_team_id;
    SELECT average_elo INTO away_elo FROM public.teams WHERE id = NEW.away_team_id;
    
    expected_home := 1.0 / (1.0 + POWER(10, (away_elo - home_elo) / 400.0));
    
    IF NEW.home_score > NEW.away_score THEN
      new_home_elo := home_elo + k_factor * (1 - expected_home);
      new_away_elo := away_elo + k_factor * (0 - (1 - expected_home));
    ELSIF NEW.home_score < NEW.away_score THEN
      new_home_elo := home_elo + k_factor * (0 - expected_home);
      new_away_elo := away_elo + k_factor * (1 - (1 - expected_home));
    ELSE
      new_home_elo := home_elo + k_factor * (0.5 - expected_home);
      new_away_elo := away_elo + k_factor * (0.5 - (1 - expected_home));
    END IF;
    
    UPDATE public.teams SET average_elo = new_home_elo WHERE id = NEW.home_team_id;
    UPDATE public.teams SET average_elo = new_away_elo WHERE id = NEW.away_team_id;
    
    NEW.elo_change := new_home_elo - home_elo;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar ELO
CREATE TRIGGER update_elo_trigger
  BEFORE UPDATE ON public.matches
  FOR EACH ROW EXECUTE PROCEDURE public.update_elo_after_match();

-- DATOS INICIALES
-- Insertar regiones de Chile (principales)
INSERT INTO public.regions (name, code) VALUES
('Región Metropolitana', 'RM'),
('Región de Valparaíso', 'V'),
('Región del Biobío', 'VIII'),
('Región de la Araucanía', 'IX'),
('Región de Los Lagos', 'X');

-- Insertar comunas de la Región Metropolitana
INSERT INTO public.comunas (name, region_id) 
SELECT 'Quilicura', id FROM public.regions WHERE code = 'RM';

INSERT INTO public.comunas (name, region_id)
SELECT name, id FROM public.regions WHERE code = 'RM'
CROSS JOIN (VALUES 
  ('Santiago'), ('Las Condes'), ('Providencia'), ('Ñuñoa'), 
  ('Maipú'), ('Pudahuel'), ('Cerro Navia'), ('Renca'),
  ('Independencia'), ('Recoleta'), ('Huechuraba')
) AS comunas_names(name);

-- Insertar sectores de Quilicura
INSERT INTO public.sectores_comuna (name, comuna_id, description)
SELECT name, id, description FROM public.comunas 
WHERE name = 'Quilicura'
CROSS JOIN (VALUES
  ('Centro', 'Sector céntrico de Quilicura'),
  ('Norte Alto', 'Zona norte de Quilicura'),
  ('Villa España', 'Sector Villa España'),
  ('Los Libertadores', 'Sector Los Libertadores'),
  ('Santa Rosa', 'Sector Santa Rosa')
) AS sectores_data(name, description);
      new_away_elo := away_elo + k_factor * (0 - (1 - expected_home));
    ELSIF NEW.home_score < NEW.away_score THEN
      -- Victoria del equipo visitante
      new_home_elo := home_elo + k_factor * (0 - expected_home);
      new_away_elo := away_elo + k_factor * (1 - (1 - expected_home));
    ELSE
      -- Empate
      new_home_elo := home_elo + k_factor * (0.5 - expected_home);
      new_away_elo := away_elo + k_factor * (0.5 - (1 - expected_home));
    END IF;
    
    -- Actualizar ELO de los equipos
    UPDATE public.teams SET average_elo = new_home_elo WHERE id = NEW.home_team_id;
    UPDATE public.teams SET average_elo = new_away_elo WHERE id = NEW.away_team_id;
    
    -- Guardar el cambio de ELO en el partido
    NEW.elo_change := new_home_elo - home_elo;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para actualizar ELO
CREATE TRIGGER on_match_finished
  BEFORE UPDATE ON public.matches
  FOR EACH ROW EXECUTE PROCEDURE public.update_elo_after_match();

-- 10. DATOS INICIALES DE CHILE - EMPEZANDO POR RM Y QUILICURA

-- Insertar Región Metropolitana
INSERT INTO public.regions (name, code) VALUES 
('Región Metropolitana', 'RM');

-- Insertar Comuna de Quilicura (solo esta por ahora)
INSERT INTO public.comunas (name, region_id, is_active) 
SELECT 'Quilicura', r.id, true 
FROM public.regions r WHERE r.code = 'RM';

-- Insertar Sectores de Quilicura
INSERT INTO public.sectores_comuna (name, comuna_id, description) 
SELECT 'Centro', c.id, 'Sector centro de Quilicura - Plaza principal'
FROM public.comunas c WHERE c.name = 'Quilicura';

INSERT INTO public.sectores_comuna (name, comuna_id, description) 
SELECT 'Norte', c.id, 'Sector norte - Zona residencial Norte'
FROM public.comunas c WHERE c.name = 'Quilicura';

INSERT INTO public.sectores_comuna (name, comuna_id, description) 
SELECT 'Sur', c.id, 'Sector sur - Zona industrial y residencial'
FROM public.comunas c WHERE c.name = 'Quilicura';

INSERT INTO public.sectores_comuna (name, comuna_id, description) 
SELECT 'Oriente', c.id, 'Sector oriente - Hacia la cordillera'
FROM public.comunas c WHERE c.name = 'Quilicura';

INSERT INTO public.sectores_comuna (name, comuna_id, description) 
SELECT 'Poniente', c.id, 'Sector poniente - Zona comercial'
FROM public.comunas c WHERE c.name = 'Quilicura';

INSERT INTO public.sectores_comuna (name, comuna_id, description) 
SELECT 'Piedra Roja', c.id, 'Sector Piedra Roja - Zona norte-oriente'
FROM public.comunas c WHERE c.name = 'Quilicura';

-- Insertar Canchas Reales de Quilicura
INSERT INTO public.canchas (name, comuna_id, address, field_type, surface_type, has_lighting, capacity, hourly_rate, contact_phone, is_active) 
SELECT 'Complejo Deportivo Municipal Quilicura', c.id, 'Av. Carlos Valdovinos 120, Quilicura', 'football11', 'cesped_natural', true, 500, 80000, '+56912345678', true
FROM public.comunas c WHERE c.name = 'Quilicura';

INSERT INTO public.canchas (name, comuna_id, address, field_type, surface_type, has_lighting, capacity, hourly_rate, contact_phone, is_active) 
SELECT 'Cancha Norte Quilicura', c.id, 'Av. Américo Vespucio Norte 1234, Quilicura', 'football7', 'cesped_sintetico', true, 200, 50000, '+56987654321', true
FROM public.comunas c WHERE c.name = 'Quilicura';

INSERT INTO public.canchas (name, comuna_id, address, field_type, surface_type, has_lighting, capacity, hourly_rate, contact_phone, is_active) 
SELECT 'Futsal Piedra Roja', c.id, 'Av. Piedra Roja 567, Quilicura', 'futsal', 'cemento', false, 100, 30000, '+56911223344', true
FROM public.comunas c WHERE c.name = 'Quilicura';

INSERT INTO public.canchas (name, comuna_id, address, field_type, surface_type, has_lighting, capacity, hourly_rate, contact_phone, is_active) 
SELECT 'Cancha Centro Quilicura', c.id, 'Calle Salvador Allende 890, Quilicura', 'football7', 'cesped_sintetico', true, 250, 45000, '+56955667788', true
FROM public.comunas c WHERE c.name = 'Quilicura';

INSERT INTO public.canchas (name, comuna_id, address, field_type, surface_type, has_lighting, capacity, hourly_rate, contact_phone, is_active) 
SELECT 'Complejo Los Aromos', c.id, 'Los Aromos 1000, Quilicura', 'football11', 'cesped_natural', false, 400, 70000, '+56933445566', true
FROM public.comunas c WHERE c.name = 'Quilicura';

-- 11. ÍNDICES PARA RENDIMIENTO
CREATE INDEX idx_users_email ON public.users(email);
CREATE INDEX idx_users_comuna ON public.users(comuna_id);
CREATE INDEX idx_player_profiles_user_id ON public.player_profiles(user_id);
CREATE INDEX idx_player_profiles_elo ON public.player_profiles(current_elo);
CREATE INDEX idx_player_profiles_sector ON public.player_profiles(current_sector_id);
CREATE INDEX idx_comunas_region ON public.comunas(region_id);
CREATE INDEX idx_canchas_comuna ON public.canchas(comuna_id);
CREATE INDEX idx_sectores_comuna_id ON public.sectores_comuna(comuna_id);
CREATE INDEX idx_matches_date ON public.matches(match_date);
CREATE INDEX idx_matches_sector ON public.matches(sector_id);
CREATE INDEX idx_matches_cancha ON public.matches(cancha_id);
CREATE INDEX idx_team_members_team_id ON public.team_members(team_id);
CREATE INDEX idx_team_members_user_id ON public.team_members(user_id);
