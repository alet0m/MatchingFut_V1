-- Crear tabla de desafíos/challenges
CREATE TABLE IF NOT EXISTS public.challenges (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    challenger_team_id UUID NOT NULL REFERENCES public.teams(id) ON DELETE CASCADE,
    challenged_team_id UUID NOT NULL REFERENCES public.teams(id) ON DELETE CASCADE,
    message TEXT,
    proposed_date TIMESTAMPTZ,
    location TEXT, -- Ubicación propuesta como texto libre por ahora
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'expired')),
    created_by UUID NOT NULL REFERENCES public.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    responded_at TIMESTAMPTZ,
    responded_by UUID REFERENCES public.users(id),
    match_id UUID REFERENCES public.matches(id),
    
    -- Evitar que un equipo se desafíe a sí mismo
    CONSTRAINT different_teams CHECK (challenger_team_id != challenged_team_id)
);

-- Índices para mejorar rendimiento
CREATE INDEX IF NOT EXISTS idx_challenges_challenger_team ON public.challenges(challenger_team_id);
CREATE INDEX IF NOT EXISTS idx_challenges_challenged_team ON public.challenges(challenged_team_id);
CREATE INDEX IF NOT EXISTS idx_challenges_status ON public.challenges(status);
CREATE INDEX IF NOT EXISTS idx_challenges_created_at ON public.challenges(created_at);

-- Políticas RLS para challenges
ALTER TABLE public.challenges ENABLE ROW LEVEL SECURITY;

-- Política para ver desafíos: usuarios pueden ver desafíos de sus equipos
CREATE POLICY "Users can view challenges of their teams"
    ON public.challenges FOR SELECT
    USING (
        challenger_team_id IN (
            SELECT team_id FROM public.team_members 
            WHERE user_id = auth.uid() AND is_active = true
        )
        OR 
        challenged_team_id IN (
            SELECT team_id FROM public.team_members 
            WHERE user_id = auth.uid() AND is_active = true
        )
    );

-- Política para crear desafíos: usuarios pueden crear desafíos desde sus equipos
CREATE POLICY "Users can create challenges from their teams"
    ON public.challenges FOR INSERT
    WITH CHECK (
        challenger_team_id IN (
            SELECT team_id FROM public.team_members 
            WHERE user_id = auth.uid() AND is_active = true
        )
        AND created_by = auth.uid()
    );

-- Política para actualizar desafíos: usuarios pueden responder a desafíos de sus equipos
CREATE POLICY "Users can respond to challenges of their teams"
    ON public.challenges FOR UPDATE
    USING (
        challenged_team_id IN (
            SELECT team_id FROM public.team_members 
            WHERE user_id = auth.uid() AND is_active = true
        )
    )
    WITH CHECK (
        challenged_team_id IN (
            SELECT team_id FROM public.team_members 
            WHERE user_id = auth.uid() AND is_active = true
        )
    );

-- Función para actualizar desafíos expirados (opcional)
CREATE OR REPLACE FUNCTION expire_old_challenges()
RETURNS void AS $$
BEGIN
    UPDATE public.challenges 
    SET status = 'expired'
    WHERE status = 'pending' 
    AND created_at < NOW() - INTERVAL '7 days';
END;
$$ LANGUAGE plpgsql;
