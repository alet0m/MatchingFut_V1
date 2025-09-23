-- Agregar columna tag a la tabla teams
ALTER TABLE public.teams ADD COLUMN IF NOT EXISTS tag TEXT;
