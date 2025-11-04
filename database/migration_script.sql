-- SCRIPT DE MIGRACIÓN PARA NUEVA ESTRUCTURA TERRITORIAL
-- Este script debe ejecutarse paso a paso en Supabase SQL Editor

-- PASO 1: ELIMINAR DATOS Y TABLAS ANTERIORES (cuidado con el orden por las dependencias)
DROP TRIGGER IF EXISTS on_match_finished ON public.matches;
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

DROP FUNCTION IF EXISTS public.update_elo_after_match();
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Eliminar políticas RLS existentes
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
DROP POLICY IF EXISTS "Users can view all profiles" ON public.users;
DROP POLICY IF EXISTS "Users can view own player profile" ON public.player_profiles;
DROP POLICY IF EXISTS "Users can insert own player profile" ON public.player_profiles;
DROP POLICY IF EXISTS "Users can update own player profile" ON public.player_profiles;
DROP POLICY IF EXISTS "Anyone can view sectors" ON public.sectors;
DROP POLICY IF EXISTS "Anyone can view matches" ON public.matches;
DROP POLICY IF EXISTS "Users can create matches" ON public.matches;

-- Eliminar tablas en orden correcto (por dependencias)
DROP TABLE IF EXISTS public.team_members CASCADE;
DROP TABLE IF EXISTS public.matches CASCADE;
DROP TABLE IF EXISTS public.teams CASCADE;
DROP TABLE IF EXISTS public.sectors CASCADE;
DROP TABLE IF EXISTS public.player_profiles CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;

-- PASO 2: CREAR NUEVAS TABLAS CON ESTRUCTURA TERRITORIAL

-- 1. TABLA DE USUARIOS (Información básica)
CREATE TABLE public.users (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email VARCHAR NOT NULL UNIQUE,
  full_name VARCHAR NOT NULL,
  nickname VARCHAR,
  date_of_birth DATE,
  age INTEGER,
  comuna_id UUID, -- Comuna donde vive (se llenará después)
  sector_name VARCHAR, -- Sector específico dentro de la comuna
  profile_image_url TEXT,
  is_email_verified BOOLEAN DEFAULT false,
  has_completed_onboarding BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 2. TABLA DE PERFILES DE JUGADOR (Datos del onboarding)
CREATE TABLE public.player_profiles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  nickname VARCHAR,
  years_playing INTEGER DEFAULT 1,
  preferred_position VARCHAR, -- goalkeeper, defender, midfielder, forward
  dominant_foot VARCHAR, -- right, left, both
  skill_level VARCHAR, -- beginner, intermediate, advanced, semi_professional
  height INTEGER, -- en centímetros
  weight INTEGER, -- en kilogramos
  preferred_game_type VARCHAR, -- futsal, football7, football11
  available_days TEXT[], -- array de días preferidos
  preferred_time TIME, -- hora preferida para jugar
  budget_per_match DECIMAL(10,0), -- presupuesto en pesos chilenos
  goals TEXT[], -- objetivos del jugador
  current_elo INTEGER DEFAULT 1200, -- ranking ELO actual
  current_sector_id UUID, -- sector actual de dominio
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 3. TABLA DE UBICACIONES GEOGRÁFICAS DE CHILE
CREATE TABLE public.regions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR NOT NULL UNIQUE,
  code VARCHAR(3) NOT NULL UNIQUE, -- RM, V, VIII, etc.
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE public.comunas (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR NOT NULL,
  region_id UUID REFERENCES public.regions(id),
  is_active BOOLEAN DEFAULT true, -- para habilitar por fases
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(name, region_id)
);

CREATE TABLE public.canchas (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR NOT NULL,
  comuna_id UUID REFERENCES public.comunas(id),
  address TEXT,
  field_type VARCHAR, -- futsal, football7, football11
  surface_type VARCHAR, -- cesped_natural, cesped_sintetico, cemento
  has_lighting BOOLEAN DEFAULT false,
  capacity INTEGER,
  hourly_rate DECIMAL(10,0), -- precio por hora en pesos chilenos
  contact_phone VARCHAR,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 4. TABLA DE SECTORES POR COMUNA (reemplaza la anterior)
CREATE TABLE public.sectores_comuna (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR NOT NULL,
  comuna_id UUID REFERENCES public.comunas(id),
  description TEXT,
  current_champion_id UUID REFERENCES public.users(id),
  total_matches INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(name, comuna_id)
);

-- 5. TABLA DE EQUIPOS (debe ir antes que matches)
CREATE TABLE public.teams (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR NOT NULL,
  captain_id UUID REFERENCES public.users(id),
  sector_id UUID REFERENCES public.sectores_comuna(id),
  average_elo INTEGER DEFAULT 1200,
  total_matches INTEGER DEFAULT 0,
  wins INTEGER DEFAULT 0,
  losses INTEGER DEFAULT 0,
  draws INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 6. TABLA DE PARTIDOS (ahora teams ya existe)
CREATE TABLE public.matches (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  home_team_id UUID REFERENCES public.teams(id),
  away_team_id UUID REFERENCES public.teams(id),
  cancha_id UUID REFERENCES public.canchas(id),
  sector_id UUID REFERENCES public.sectores_comuna(id),
  match_date TIMESTAMP WITH TIME ZONE NOT NULL,
  status VARCHAR DEFAULT 'scheduled', -- scheduled, in_progress, finished, cancelled
  home_score INTEGER DEFAULT 0,
  away_score INTEGER DEFAULT 0,
  elo_change INTEGER DEFAULT 0,
  created_by UUID REFERENCES public.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 7. TABLA DE MIEMBROS DE EQUIPOS
CREATE TABLE public.team_members (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  team_id UUID REFERENCES public.teams(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  position VARCHAR, -- posición en el equipo
  is_active BOOLEAN DEFAULT true,
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(team_id, user_id)
);

-- 8. POLÍTICAS DE SEGURIDAD (Row Level Security)
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
  FOR SELECT USING (true); -- Para poder ver otros jugadores

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

-- 9. FUNCIONES AUTOMÁTICAS
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
  -- Solo actualizar cuando el partido termine
  IF NEW.status = 'finished' AND OLD.status != 'finished' THEN
    -- Obtener ELO actual de ambos equipos
    SELECT average_elo INTO home_elo FROM public.teams WHERE id = NEW.home_team_id;
    SELECT average_elo INTO away_elo FROM public.teams WHERE id = NEW.away_team_id;
    
    -- Calcular resultado esperado
    expected_home := 1.0 / (1.0 + POWER(10, (away_elo - home_elo) / 400.0));
    
    -- Calcular nuevo ELO basado en el resultado
    IF NEW.home_score > NEW.away_score THEN
      -- Victoria del equipo local
      new_home_elo := home_elo + k_factor * (1 - expected_home);
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
