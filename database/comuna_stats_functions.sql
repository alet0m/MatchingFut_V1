-- Función para obtener estadísticas de una comuna
CREATE OR REPLACE FUNCTION public.get_comuna_stats(comuna_id_param UUID)
RETURNS json AS $$
DECLARE
    result json;
BEGIN
    WITH stats AS (
        SELECT
            c.id,
            c.name,
            c.region_id,
            r.name as region_name,
            c.total_players,
            c.total_teams,
            c.total_matches,
            (SELECT COUNT(*) FROM public.sectors s WHERE s.comuna_id = c.id) as total_sectors,
            (SELECT COUNT(*) FROM public.canchas ca WHERE ca.comuna_id = c.id) as total_canchas,
            -- Partidos en los últimos 30 días
            (SELECT COUNT(*) 
             FROM public.matches m 
             WHERE m.comuna_id = c.id 
             AND m.match_date > now() - interval '30 days') as recent_matches,
            -- Equipos más activos
            (SELECT json_agg(t.*) FROM (
                SELECT 
                    t.id, 
                    t.name, 
                    t.tag,
                    t.elo_rating,
                    COUNT(m.*) as matches_count
                FROM public.teams t
                LEFT JOIN public.matches m ON (m.home_team_id = t.id OR m.away_team_id = t.id)
                WHERE t.comuna_id = c.id
                GROUP BY t.id
                ORDER BY matches_count DESC
                LIMIT 5
            ) t) as top_teams,
            -- Sectores más disputados
            (SELECT json_agg(s.*) FROM (
                SELECT 
                    s.id, 
                    s.name, 
                    s.total_matches,
                    s.controlling_team_id,
                    t.name as controlling_team_name,
                    t.tag as controlling_team_tag
                FROM public.sectors s
                LEFT JOIN public.teams t ON s.controlling_team_id = t.id
                WHERE s.comuna_id = c.id
                ORDER BY s.total_matches DESC
                LIMIT 5
            ) s) as hot_sectors
        FROM public.comunas c
        JOIN public.regions r ON c.region_id = r.id
        WHERE c.id = comuna_id_param
    )
    
    SELECT json_build_object(
        'id', s.id,
        'name', s.name,
        'region', json_build_object('id', s.region_id, 'name', s.region_name),
        'total_players', s.total_players,
        'total_teams', s.total_teams,
        'total_matches', s.total_matches,
        'total_sectors', s.total_sectors,
        'total_canchas', s.total_canchas,
        'recent_matches', s.recent_matches,
        'top_teams', COALESCE(s.top_teams, '[]'::json),
        'hot_sectors', COALESCE(s.hot_sectors, '[]'::json),
        'last_updated', now()
    ) INTO result
    FROM stats s;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Función para obtener todas las comunas activas con estadísticas básicas
CREATE OR REPLACE FUNCTION public.get_active_comunas()
RETURNS json AS $$
DECLARE
    result json;
BEGIN
    SELECT json_agg(
        json_build_object(
            'id', c.id,
            'name', c.name,
            'region_id', c.region_id,
            'region_name', r.name,
            'total_players', c.total_players,
            'total_teams', c.total_teams,
            'total_matches', c.total_matches,
            'is_active', c.is_active,
            'featured_image_url', c.featured_image_url
        )
    ) INTO result
    FROM public.comunas c
    JOIN public.regions r ON c.region_id = r.id
    WHERE c.is_active = TRUE
    ORDER BY c.name;
    
    RETURN COALESCE(result, '[]'::json);
END;
$$ LANGUAGE plpgsql;

-- Función para obtener los sectores de una comuna con estadísticas
CREATE OR REPLACE FUNCTION public.get_comuna_sectors(comuna_id_param UUID)
RETURNS json AS $$
DECLARE
    result json;
BEGIN
    SELECT json_agg(
        json_build_object(
            'id', s.id,
            'name', s.name,
            'description', s.description,
            'elo_required', s.elo_required,
            'current_elo_threshold', s.current_elo_threshold,
            'total_matches', s.total_matches,
            'last_match_date', s.last_match_date,
            'is_active', s.is_active,
            'featured_image_url', s.featured_image_url,
            'controlling_team', CASE 
                WHEN s.controlling_team_id IS NOT NULL THEN
                    json_build_object(
                        'id', t.id,
                        'name', t.name,
                        'tag', t.tag,
                        'elo_rating', t.elo_rating,
                        'control_days', EXTRACT(DAY FROM (now() - s.control_start_date))
                    )
                ELSE NULL
            END,
            -- Historial reciente de control
            'control_history', (
                SELECT json_agg(
                    json_build_object(
                        'team_id', sch.team_id,
                        'team_name', t_hist.name,
                        'team_tag', t_hist.tag,
                        'control_start', sch.control_start,
                        'control_end', sch.control_end,
                        'total_days', sch.total_days
                    )
                )
                FROM public.sector_control_history sch
                JOIN public.teams t_hist ON sch.team_id = t_hist.id
                WHERE sch.sector_id = s.id
                ORDER BY sch.control_start DESC
                LIMIT 5
            )
        )
    ) INTO result
    FROM public.sectors s
    LEFT JOIN public.teams t ON s.controlling_team_id = t.id
    WHERE s.comuna_id = comuna_id_param
    ORDER BY s.name;
    
    RETURN COALESCE(result, '[]'::json);
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar los contadores de comunas
CREATE OR REPLACE FUNCTION public.update_comuna_counters()
RETURNS TRIGGER AS $$
BEGIN
    -- Si es INSERT en team_members y el jugador no estaba en otro equipo de la misma comuna
    IF (TG_OP = 'INSERT' AND TG_TABLE_NAME = 'team_members') THEN
        IF NOT EXISTS (
            SELECT 1 
            FROM public.team_members tm
            JOIN public.teams t ON tm.team_id = t.id
            WHERE tm.player_id = NEW.player_id
            AND t.comuna_id = (SELECT comuna_id FROM public.teams WHERE id = NEW.team_id)
            AND tm.id != NEW.id
        ) THEN
            -- Incrementar contador de jugadores en la comuna
            UPDATE public.comunas
            SET total_players = total_players + 1
            WHERE id = (SELECT comuna_id FROM public.teams WHERE id = NEW.team_id);
        END IF;
    
    -- Si es DELETE en team_members y era el único equipo del jugador en esa comuna
    ELSIF (TG_OP = 'DELETE' AND TG_TABLE_NAME = 'team_members') THEN
        IF NOT EXISTS (
            SELECT 1 
            FROM public.team_members tm
            JOIN public.teams t ON tm.team_id = t.id
            WHERE tm.player_id = OLD.player_id
            AND t.comuna_id = (SELECT comuna_id FROM public.teams WHERE id = OLD.team_id)
        ) THEN
            -- Decrementar contador de jugadores en la comuna
            UPDATE public.comunas
            SET total_players = GREATEST(0, total_players - 1)
            WHERE id = (SELECT comuna_id FROM public.teams WHERE id = OLD.team_id);
        END IF;
        
    -- Si es INSERT en teams
    ELSIF (TG_OP = 'INSERT' AND TG_TABLE_NAME = 'teams') THEN
        -- Incrementar contador de equipos en la comuna
        UPDATE public.comunas
        SET total_teams = total_teams + 1
        WHERE id = NEW.comuna_id;
        
    -- Si es DELETE en teams
    ELSIF (TG_OP = 'DELETE' AND TG_TABLE_NAME = 'teams') THEN
        -- Decrementar contador de equipos en la comuna
        UPDATE public.comunas
        SET total_teams = GREATEST(0, total_teams - 1)
        WHERE id = OLD.comuna_id;
        
    -- Si es INSERT o UPDATE en matches y cambia la comuna o el estado
    ELSIF ((TG_OP = 'INSERT' OR TG_OP = 'UPDATE') AND TG_TABLE_NAME = 'matches') THEN
        -- Si es INSERT o se cambia la comuna
        IF (TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND (OLD.comuna_id IS DISTINCT FROM NEW.comuna_id))) THEN
            -- Incrementar contador de partidos en la nueva comuna
            IF NEW.comuna_id IS NOT NULL THEN
                UPDATE public.comunas
                SET total_matches = total_matches + 1
                WHERE id = NEW.comuna_id;
            END IF;
            
            -- Decrementar contador de partidos en la antigua comuna si es UPDATE
            IF TG_OP = 'UPDATE' AND OLD.comuna_id IS NOT NULL THEN
                UPDATE public.comunas
                SET total_matches = GREATEST(0, total_matches - 1)
                WHERE id = OLD.comuna_id;
            END IF;
        END IF;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Crear o reemplazar los triggers para actualizar contadores
DROP TRIGGER IF EXISTS team_members_update_comuna_counters ON public.team_members;
CREATE TRIGGER team_members_update_comuna_counters
    AFTER INSERT OR DELETE ON public.team_members
    FOR EACH ROW
    EXECUTE FUNCTION public.update_comuna_counters();

DROP TRIGGER IF EXISTS teams_update_comuna_counters ON public.teams;
CREATE TRIGGER teams_update_comuna_counters
    AFTER INSERT OR DELETE ON public.teams
    FOR EACH ROW
    EXECUTE FUNCTION public.update_comuna_counters();
    
DROP TRIGGER IF EXISTS matches_update_comuna_counters ON public.matches;
CREATE TRIGGER matches_update_comuna_counters
    AFTER INSERT OR UPDATE ON public.matches
    FOR EACH ROW
    EXECUTE FUNCTION public.update_comuna_counters();