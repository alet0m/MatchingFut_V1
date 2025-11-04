-- Actualizar tabla team_members para funcionar como players
-- Agregar campos adicionales necesarios para jugadores

-- Verificar si las columnas ya existen antes de agregarlas
DO $$ 
BEGIN
    -- Agregar columna name si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='team_members' AND column_name='name') THEN
        ALTER TABLE public.team_members ADD COLUMN name TEXT NOT NULL DEFAULT '';
    END IF;
    
    -- Agregar columna email si no existe  
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='team_members' AND column_name='email') THEN
        ALTER TABLE public.team_members ADD COLUMN email TEXT;
    END IF;
    
    -- Agregar columna elo si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='team_members' AND column_name='elo') THEN
        ALTER TABLE public.team_members ADD COLUMN elo INTEGER DEFAULT 1200;
    END IF;
    
    -- Agregar columna goals_scored si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='team_members' AND column_name='goals_scored') THEN
        ALTER TABLE public.team_members ADD COLUMN goals_scored INTEGER DEFAULT 0;
    END IF;
    
    -- Agregar columna assists si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='team_members' AND column_name='assists') THEN
        ALTER TABLE public.team_members ADD COLUMN assists INTEGER DEFAULT 0;
    END IF;
    
    -- Agregar columna yellow_cards si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='team_members' AND column_name='yellow_cards') THEN
        ALTER TABLE public.team_members ADD COLUMN yellow_cards INTEGER DEFAULT 0;
    END IF;
    
    -- Agregar columna red_cards si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='team_members' AND column_name='red_cards') THEN
        ALTER TABLE public.team_members ADD COLUMN red_cards INTEGER DEFAULT 0;
    END IF;
    
    -- Agregar columna is_captain si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='team_members' AND column_name='is_captain') THEN
        ALTER TABLE public.team_members ADD COLUMN is_captain BOOLEAN DEFAULT false;
    END IF;
    
    -- Agregar columna joined_at si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='team_members' AND column_name='joined_at') THEN
        ALTER TABLE public.team_members ADD COLUMN joined_at TIMESTAMPTZ DEFAULT NOW();
    END IF;
END $$;

-- Crear índices para mejorar rendimiento
CREATE INDEX IF NOT EXISTS idx_team_members_name ON public.team_members(name);
CREATE INDEX IF NOT EXISTS idx_team_members_position ON public.team_members(position);
CREATE INDEX IF NOT EXISTS idx_team_members_is_captain ON public.team_members(is_captain);
CREATE INDEX IF NOT EXISTS idx_team_members_elo ON public.team_members(elo);

-- Actualizar registros existentes para agregar nombres por defecto
UPDATE public.team_members 
SET name = 'Jugador ' || SUBSTRING(user_id::text FROM 1 FOR 8)
WHERE name = '' OR name IS NULL;
