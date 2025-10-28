-- Agregar campo comuna a la tabla teams
ALTER TABLE public.teams 
ADD COLUMN IF NOT EXISTS comuna TEXT DEFAULT 'quilicura' CHECK (comuna IN ('quilicura'));

-- Por ahora solo permitimos Quilicura, después se agregarán más comunas
-- UPDATE para equipos existentes
UPDATE public.teams 
SET comuna = 'quilicura' 
WHERE comuna IS NULL;

-- Índice para búsquedas por comuna
CREATE INDEX IF NOT EXISTS idx_teams_comuna ON public.teams(comuna);
