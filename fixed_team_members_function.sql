-- Función para accept_challenge con columnas correctamente calificadas
CREATE OR REPLACE FUNCTION public.accept_challenge(challenge_id uuid)
RETURNS json AS $$
DECLARE
    challenged_team_id uuid;
    is_captain boolean;
    challenge_status text;
BEGIN
    -- Obtener información del desafío
    SELECT c.challenged_team_id, c.status INTO challenged_team_id, challenge_status
    FROM public.challenges c
    WHERE c.id = $1;
    
    IF challenged_team_id IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Desafío no encontrado');
    END IF;
    
    -- Verificar estado
    IF challenge_status != 'pending' THEN
        RETURN json_build_object('success', false, 'message', 'Este desafío ya ha sido procesado');
    END IF;
    
    -- Verificar si es capitán del equipo desafiado - Calificación explícita de columnas
    SELECT EXISTS (
        SELECT 1 FROM public.team_members tm
        WHERE tm.team_id = challenged_team_id AND tm.player_id = auth.uid() AND tm.role = 'captain'
    ) INTO is_captain;
    
    IF NOT is_captain THEN
        RETURN json_build_object('success', false, 'message', 'No eres capitán del equipo desafiado');
    END IF;
    
    -- Actualizar desafío
    UPDATE public.challenges
    SET status = 'accepted', updated_at = now()
    WHERE id = $1;
    
    -- Crear partido automáticamente
    INSERT INTO public.matches (
        home_team_id, away_team_id, match_date, status, modality_id, cancha_id, challenge_id, location
    )
    SELECT 
        c.challenged_team_id, c.challenger_team_id, c.proposed_date, 'scheduled', 
        c.modality_id, c.cancha_id, c.id, c.location
    FROM public.challenges c
    WHERE c.id = $1;
    
    RETURN json_build_object('success', true, 'message', 'Desafío aceptado y partido programado');
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'message', 'Error al aceptar desafío: ' || SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para reject_challenge con columnas correctamente calificadas
CREATE OR REPLACE FUNCTION public.reject_challenge(challenge_id uuid)
RETURNS json AS $$
DECLARE
    challenged_team_id uuid;
    is_captain boolean;
    challenge_status text;
BEGIN
    -- Obtener información del desafío
    SELECT c.challenged_team_id, c.status INTO challenged_team_id, challenge_status
    FROM public.challenges c
    WHERE c.id = $1;
    
    IF challenged_team_id IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Desafío no encontrado');
    END IF;
    
    -- Verificar estado
    IF challenge_status != 'pending' THEN
        RETURN json_build_object('success', false, 'message', 'Este desafío ya ha sido procesado');
    END IF;
    
    -- Verificar si es capitán del equipo desafiado - Calificación explícita de columnas
    SELECT EXISTS (
        SELECT 1 FROM public.team_members tm
        WHERE tm.team_id = challenged_team_id AND tm.player_id = auth.uid() AND tm.role = 'captain'
    ) INTO is_captain;
    
    IF NOT is_captain THEN
        RETURN json_build_object('success', false, 'message', 'No eres capitán del equipo desafiado');
    END IF;
    
    -- Actualizar desafío
    UPDATE public.challenges
    SET status = 'rejected', updated_at = now()
    WHERE id = $1;
    
    RETURN json_build_object('success', true, 'message', 'Desafío rechazado');
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'message', 'Error al rechazar desafío: ' || SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
