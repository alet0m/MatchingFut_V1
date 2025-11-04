-- =====================================
-- SISTEMA DUAL DE PARTIDOS - SETUP SQL
-- =====================================

-- 1. Tabla para partidos públicos (los que se publican en comunas)
CREATE TABLE public.public_matches (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    host_team_id uuid NOT NULL,
    title text NOT NULL,
    description text,
    match_date timestamp with time zone NOT NULL,
    venue_id uuid,
    comuna text NOT NULL,
    max_elo_range integer,
    min_elo_range integer,
    status text DEFAULT 'open'::text CHECK (status = ANY (ARRAY['open'::text, 'closed'::text, 'in_progress'::text, 'completed'::text, 'cancelled'::text])),
    accepted_team_id uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    expires_at timestamp with time zone DEFAULT (now() + '7 days'::interval),
    
    CONSTRAINT public_matches_pkey PRIMARY KEY (id),
    CONSTRAINT public_matches_host_team_fkey FOREIGN KEY (host_team_id) REFERENCES public.teams(id),
    CONSTRAINT public_matches_accepted_team_fkey FOREIGN KEY (accepted_team_id) REFERENCES public.teams(id),
    CONSTRAINT public_matches_venue_fkey FOREIGN KEY (venue_id) REFERENCES public.venues(id)
);

-- 2. Tabla para aplicaciones a partidos públicos
CREATE TABLE public.match_applications (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    public_match_id uuid NOT NULL,
    applicant_team_id uuid NOT NULL,
    message text,
    status text DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'accepted'::text, 'rejected'::text])),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    
    CONSTRAINT match_applications_pkey PRIMARY KEY (id),
    CONSTRAINT match_applications_match_fkey FOREIGN KEY (public_match_id) REFERENCES public.public_matches(id) ON DELETE CASCADE,
    CONSTRAINT match_applications_team_fkey FOREIGN KEY (applicant_team_id) REFERENCES public.teams(id),
    CONSTRAINT unique_team_application UNIQUE(public_match_id, applicant_team_id)
);

-- 3. Agregar campos faltantes a la tabla matches para el sistema dual
ALTER TABLE public.matches 
ADD COLUMN IF NOT EXISTS match_message text,
ADD COLUMN IF NOT EXISTS match_source text DEFAULT 'direct'::text CHECK (match_source = ANY (ARRAY['direct'::text, 'public'::text])),
ADD COLUMN IF NOT EXISTS home_team_id uuid REFERENCES public.teams(id),
ADD COLUMN IF NOT EXISTS away_team_id uuid REFERENCES public.teams(id),
ADD COLUMN IF NOT EXISTS elo_multiplier numeric DEFAULT 1.0,
ADD COLUMN IF NOT EXISTS bonus_elo integer DEFAULT 0;

-- 4. Agregar índices para optimizar búsquedas
CREATE INDEX IF NOT EXISTS idx_public_matches_comuna ON public.public_matches(comuna);
CREATE INDEX IF NOT EXISTS idx_public_matches_status ON public.public_matches(status);
CREATE INDEX IF NOT EXISTS idx_public_matches_date ON public.public_matches(match_date);
CREATE INDEX IF NOT EXISTS idx_match_applications_status ON public.match_applications(status);

-- 5. Configurar RLS (Row Level Security)
ALTER TABLE public.public_matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.match_applications ENABLE ROW LEVEL SECURITY;

-- Políticas para public_matches
CREATE POLICY "Users can view all open public matches" 
ON public.public_matches FOR SELECT 
USING (status = 'open' OR auth.uid() IN (
    SELECT unnest(member_ids) FROM teams WHERE id = host_team_id
    UNION
    SELECT unnest(member_ids) FROM teams WHERE id = accepted_team_id
));

CREATE POLICY "Team members can create public matches" 
ON public.public_matches FOR INSERT 
WITH CHECK (auth.uid() IN (
    SELECT unnest(member_ids) FROM teams WHERE id = host_team_id
));

CREATE POLICY "Host team can update their matches" 
ON public.public_matches FOR UPDATE 
USING (auth.uid() IN (
    SELECT unnest(member_ids) FROM teams WHERE id = host_team_id
));

-- Políticas para match_applications
CREATE POLICY "Users can view applications for their matches or teams" 
ON public.match_applications FOR SELECT 
USING (auth.uid() IN (
    SELECT unnest(member_ids) FROM teams WHERE id = applicant_team_id
    UNION
    SELECT unnest(member_ids) FROM teams t 
    JOIN public_matches pm ON pm.host_team_id = t.id 
    WHERE pm.id = public_match_id
));

CREATE POLICY "Team members can create applications" 
ON public.match_applications FOR INSERT 
WITH CHECK (auth.uid() IN (
    SELECT unnest(member_ids) FROM teams WHERE id = applicant_team_id
));

-- 6. Función para actualizar timestamps automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para actualizar updated_at
CREATE TRIGGER update_public_matches_updated_at 
    BEFORE UPDATE ON public.public_matches 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_match_applications_updated_at 
    BEFORE UPDATE ON public.match_applications 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 7. Función para limpiar partidos expirados (opcional)
CREATE OR REPLACE FUNCTION cleanup_expired_matches()
RETURNS void AS $$
BEGIN
    UPDATE public.public_matches 
    SET status = 'cancelled'
    WHERE status = 'open' AND expires_at < now();
END;
$$ language 'plpgsql';

-- =====================================
-- DATOS DE PRUEBA (opcional)
-- =====================================

-- Insertar algunos partidos públicos de ejemplo
-- (Ejecutar solo si tienes equipos creados)
/*
INSERT INTO public.public_matches (host_team_id, title, description, match_date, comuna, min_elo_range, max_elo_range) VALUES
(
    (SELECT id FROM teams LIMIT 1),
    'Partido amistoso nivel intermedio',
    'Buscamos rival para partido entretenido. Cancha sintética con iluminación.',
    now() + interval '3 days',
    'Quilicura',
    1200,
    1400
);
*/
