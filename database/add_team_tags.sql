-- Agregar campo tag a la tabla teams
-- Este script debe ejecutarse en Supabase SQL Editor

ALTER TABLE public.teams 
ADD COLUMN IF NOT EXISTS tag TEXT;

-- Crear índice para búsquedas rápidas por tag
CREATE INDEX IF NOT EXISTS idx_teams_tag ON public.teams(tag);

-- Función para generar un tag automático basado en el nombre del equipo
CREATE OR REPLACE FUNCTION public.generate_team_tag(team_name TEXT)
RETURNS TEXT AS $$
DECLARE
    base_tag TEXT;
    final_tag TEXT;
    counter INTEGER := 0;
BEGIN
    -- Limpiar el nombre y crear tag base
    base_tag := LOWER(REGEXP_REPLACE(team_name, '[^a-zA-Z0-9]', '', 'g'));
    base_tag := SUBSTRING(base_tag FROM 1 FOR 15); -- Limitar a 15 caracteres
    
    -- Si el tag está vacío, usar nombre genérico
    IF base_tag = '' THEN
        base_tag := 'equipo';
    END IF;
    
    final_tag := base_tag;
    
    -- Verificar si el tag ya existe y agregar número si es necesario
    WHILE EXISTS (SELECT 1 FROM public.teams WHERE tag = final_tag) LOOP
        counter := counter + 1;
        final_tag := base_tag || counter::TEXT;
    END LOOP;
    
    RETURN final_tag;
END;
$$ LANGUAGE plpgsql;

-- Generar tags para equipos existentes que no tengan tag
UPDATE public.teams 
SET tag = public.generate_team_tag(name) 
WHERE tag IS NULL OR tag = '';

-- Notification
DO $$ 
BEGIN
    RAISE NOTICE '✅ Campo tag agregado a tabla teams';
    RAISE NOTICE 'Tags generados para % equipos', (SELECT COUNT(*) FROM public.teams WHERE tag IS NOT NULL);
    RAISE NOTICE '🏷️ Sistema de tags listo para usar';
END $$;
