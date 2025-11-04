-- Función para obtener el ranking de equipos por comuna
CREATE OR REPLACE FUNCTION public.get_comuna_team_ranking(comuna_id_param UUID)
RETURNS json AS $$
DECLARE
    result json;
BEGIN
    SELECT json_agg(
        json_build_object(
            'rank', ROW_NUMBER() OVER (ORDER BY t.elo_rating DESC),
            'id', t.id,
            'name', t.name,
            'tag', t.tag,
            'elo_rating', t.elo_rating,
            'total_matches', COALESCE(stats.total_matches, 0),
            'wins', COALESCE(stats.wins, 0),
            'losses', COALESCE(stats.losses, 0),
            'draws', COALESCE(stats.draws, 0),
            'win_rate', CASE 
                WHEN COALESCE(stats.total_matches, 0) > 0 
                THEN ROUND((COALESCE(stats.wins, 0)::float / COALESCE(stats.total_matches, 0)::float) * 100, 1)
                ELSE 0
            END,
            'sectors_controlled', COALESCE(territories.sector_count, 0),
            'logo_url', t.logo_url,
            'captain', (
                SELECT json_build_object(
                    'id', p.id,
                    'name', p.full_name,
                    'tag', p.tag
                )
                FROM public.profiles p
                WHERE p.id = t.captain_id
            )
        )
    ) INTO result
    FROM public.teams t
    LEFT JOIN (
        SELECT 
            m.home_team_id as team_id,
            COUNT(*) as total_matches,
            SUM(CASE WHEN m.home_score > m.away_score THEN 1 ELSE 0 END) as wins,
            SUM(CASE WHEN m.home_score < m.away_score THEN 1 ELSE 0 END) as losses,
            SUM(CASE WHEN m.home_score = m.away_score THEN 1 ELSE 0 END) as draws
        FROM public.matches m
        WHERE m.status = 'completed'
        GROUP BY m.home_team_id
        
        UNION ALL
        
        SELECT 
            m.away_team_id as team_id,
            COUNT(*) as total_matches,
            SUM(CASE WHEN m.away_score > m.home_score THEN 1 ELSE 0 END) as wins,
            SUM(CASE WHEN m.away_score < m.home_score THEN 1 ELSE 0 END) as losses,
            SUM(CASE WHEN m.away_score = m.home_score THEN 1 ELSE 0 END) as draws
        FROM public.matches m
        WHERE m.status = 'completed'
        GROUP BY m.away_team_id
    ) stats ON t.id = stats.team_id
    LEFT JOIN (
        SELECT 
            controlling_team_id as team_id,
            COUNT(*) as sector_count
        FROM public.sectors
        WHERE controlling_team_id IS NOT NULL
        GROUP BY controlling_team_id
    ) territories ON t.id = territories.team_id
    WHERE t.comuna_id = comuna_id_param
    ORDER BY t.elo_rating DESC;
    
    RETURN COALESCE(result, '[]'::json);
END;
$$ LANGUAGE plpgsql;

-- Función para obtener el ranking de sectores por mayor disputa
CREATE OR REPLACE FUNCTION public.get_hottest_sectors(comuna_id_param UUID, limit_param INTEGER DEFAULT 10)
RETURNS json AS $$
DECLARE
    result json;
BEGIN
    SELECT json_agg(
        json_build_object(
            'id', s.id,
            'name', s.name,
            'description', s.description,
            'total_matches', s.total_matches,
            'last_match_date', s.last_match_date,
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
            'control_changes', (
                SELECT COUNT(*) 
                FROM public.sector_control_history sch
                WHERE sch.sector_id = s.id
            ),
            'elo_threshold', s.current_elo_threshold,
            'featured_image_url', s.featured_image_url
        )
    ) INTO result
    FROM public.sectors s
    LEFT JOIN public.teams t ON s.controlling_team_id = t.id
    WHERE s.comuna_id = comuna_id_param AND s.is_active = TRUE
    ORDER BY s.total_matches DESC, 
             (SELECT COUNT(*) FROM public.sector_control_history sch WHERE sch.sector_id = s.id) DESC
    LIMIT limit_param;
    
    RETURN COALESCE(result, '[]'::json);
END;
$$ LANGUAGE plpgsql;

-- Función para obtener el historial ELO de un equipo
CREATE OR REPLACE FUNCTION public.get_team_elo_history(team_id_param UUID)
RETURNS json AS $$
DECLARE
    result json;
BEGIN
    SELECT json_agg(
        json_build_object(
            'match_id', eh.match_id,
            'previous_elo', eh.previous_elo,
            'new_elo', eh.new_elo,
            'change', eh.change,
            'recorded_at', eh.recorded_at,
            'match_info', (
                SELECT json_build_object(
                    'home_team_id', m.home_team_id,
                    'home_team_name', ht.name,
                    'away_team_id', m.away_team_id,
                    'away_team_name', at.name,
                    'home_score', m.home_score,
                    'away_score', m.away_score,
                    'match_date', m.match_date,
                    'winner_id', m.winner_id
                )
                FROM public.matches m
                JOIN public.teams ht ON m.home_team_id = ht.id
                JOIN public.teams at ON m.away_team_id = at.id
                WHERE m.id = eh.match_id
            )
        )
    ) INTO result
    FROM public.team_elo_history eh
    WHERE eh.team_id = team_id_param
    ORDER BY eh.recorded_at DESC;
    
    RETURN COALESCE(result, '[]'::json);
END;
$$ LANGUAGE plpgsql;