-- ============================================================
-- ARCHIVO INDEPENDIENTE PARA CREAR VISTAS
-- ============================================================
-- Este archivo contiene solo las definiciones de vistas para
-- ser ejecutado después de que todas las tablas estén creadas

-- Vista para amigos
CREATE OR REPLACE VIEW public.user_friends AS
SELECT DISTINCT
    CASE 
        WHEN f.requester_id = auth.uid() THEN f.receiver_id 
        ELSE f.requester_id 
    END as friend_user_id,
    COALESCE(p.email, '') as email,
    COALESCE(p.full_name, 'Sin nombre') as full_name,
    COALESCE(p.profile_picture_url, NULL) as profile_image_url,
    f.status,
    f.created_at as friendship_date,
    f.accepted_at
FROM friendships f
JOIN profiles p ON (
    (f.requester_id = auth.uid() AND p.id = f.receiver_id) OR
    (f.receiver_id = auth.uid() AND p.id = f.requester_id)
)
WHERE f.status = 'accepted';

-- Vista para miembros de equipo
CREATE OR REPLACE VIEW public.team_members_view AS
SELECT 
    members.id,
    members.team_id,
    members.player_id as member_player_id,
    members.role,
    members.number,
    members.position,
    members.joined_at,
    members.is_active,
    profiles.full_name,
    profiles.email,
    profiles.profile_picture_url,
    profiles.tag
FROM team_members members
JOIN profiles profiles ON profiles.id = members.player_id;

-- Vista para estadísticas de jugadores
CREATE OR REPLACE VIEW public.player_stats_view AS
SELECT 
    players.id,
    profiles.full_name,
    profiles.profile_picture_url,
    profiles.tag,
    players.goals,
    players.assists,
    players.matches_played,
    players.wins,
    players.losses,
    players.draws,
    players.yellow_cards,
    players.red_cards,
    players.minutes_played,
    players.elo_rating,
    CASE 
        WHEN players.matches_played > 0 THEN 
            ROUND((players.wins::FLOAT / players.matches_played) * 100)
        ELSE 0
    END as win_percentage,
    CASE 
        WHEN players.matches_played > 0 THEN 
            ROUND((players.goals::FLOAT / players.matches_played) * 100) / 100
        ELSE 0
    END as goals_per_match
FROM players players
JOIN profiles profiles ON players.id = profiles.id;

-- Vista para detalles de partidos
CREATE OR REPLACE VIEW public.match_details_view AS
SELECT 
    m.id,
    m.match_date,
    m.status,
    m.home_score,
    m.away_score,
    home_team.name as home_team_name,
    home_team.tag as home_team_tag,
    home_team.logo_url as home_team_logo,
    away_team.name as away_team_name,
    away_team.tag as away_team_tag,
    away_team.logo_url as away_team_logo,
    c.name as cancha_name,
    c.address as cancha_address,
    m.location,
    com.name as comuna_name,
    fm.name as modality_name,
    m.home_team_previous_elo,
    m.away_team_previous_elo,
    m.home_team_new_elo,
    m.away_team_new_elo,
    m.is_public
FROM matches m
LEFT JOIN teams home_team ON m.home_team_id = home_team.id
LEFT JOIN teams away_team ON m.away_team_id = away_team.id
LEFT JOIN canchas c ON m.cancha_id = c.id
LEFT JOIN comunas com ON m.comuna_id = com.id
LEFT JOIN football_modalities fm ON m.modality_id = fm.id;

-- Vista para detalles de desafíos
CREATE OR REPLACE VIEW public.challenge_details_view AS
SELECT 
    ch.id,
    ch.status,
    ch.proposed_date,
    ch.message,
    ch.location,
    ch.bet_amount,
    ch.bet_type,
    challenger.id as challenger_id,
    challenger.name as challenger_name,
    challenger.tag as challenger_tag,
    challenger.logo_url as challenger_logo,
    challenged.id as challenged_id,
    challenged.name as challenged_name,
    challenged.tag as challenged_tag,
    challenged.logo_url as challenged_logo,
    c.name as cancha_name,
    fm.name as modality_name,
    fm.players_per_team
FROM challenges ch
JOIN teams challenger ON ch.challenger_team_id = challenger.id
JOIN teams challenged ON ch.challenged_team_id = challenged.id
LEFT JOIN canchas c ON ch.cancha_id = c.id
LEFT JOIN football_modalities fm ON ch.modality_id = fm.id;

-- Verificación
DO $$ 
BEGIN
    RAISE NOTICE '✅ Vistas creadas correctamente en archivo separado';
END $$;
