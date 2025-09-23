-- SCRIPT COMPLETO DE BASE DE DATOS PARA FÚTBOL APP QUILICURA
-- Este script configura toda la estructura de la base de datos desde cero
-- Ejecutar en el SQL Editor de Supabase

-- ============================================================
-- LIMPIEZA INICIAL - Eliminar objetos existentes
-- ============================================================

-- Eliminar vistas
DROP VIEW IF EXISTS public.user_friends CASCADE;
DROP VIEW IF EXISTS public.team_members_view CASCADE;
DROP VIEW IF EXISTS public.player_stats_view CASCADE;
DROP VIEW IF EXISTS public.match_details_view CASCADE;
DROP VIEW IF EXISTS public.challenge_details_view CASCADE;

-- Eliminar funciones
DROP FUNCTION IF EXISTS public.send_friend_request CASCADE;
DROP FUNCTION IF EXISTS public.accept_friend_request CASCADE;
DROP FUNCTION IF EXISTS public.reject_friend_request CASCADE;
DROP FUNCTION IF EXISTS public.remove_friend CASCADE;
DROP FUNCTION IF EXISTS public.get_pending_friend_requests CASCADE;
DROP FUNCTION IF EXISTS public.join_team CASCADE;
DROP FUNCTION IF EXISTS public.leave_team CASCADE;
DROP FUNCTION IF EXISTS public.send_team_invitation CASCADE;
DROP FUNCTION IF EXISTS public.accept_team_invitation CASCADE;
DROP FUNCTION IF EXISTS public.reject_team_invitation CASCADE;
DROP FUNCTION IF EXISTS public.create_challenge CASCADE;
DROP FUNCTION IF EXISTS public.accept_challenge CASCADE;
DROP FUNCTION IF EXISTS public.reject_challenge CASCADE;
DROP FUNCTION IF EXISTS public.record_match_result CASCADE;
DROP FUNCTION IF EXISTS public.update_team_elo CASCADE;

-- ============================================================
-- EXTENSIONES
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- ============================================================
-- TABLAS PRINCIPALES
-- ============================================================

-- Tabla de perfiles (extiende la tabla auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT UNIQUE,
    full_name TEXT,
    tag TEXT UNIQUE,
    profile_picture_url TEXT,
    bio TEXT,
    comuna TEXT,
    position TEXT,
    skill_level INTEGER CHECK (skill_level BETWEEN 1 AND 10),
    preferred_foot TEXT,
    has_completed_onboarding BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Tabla de regiones
CREATE TABLE IF NOT EXISTS public.regions (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    code TEXT NOT NULL UNIQUE
);

-- Tabla de comunas
CREATE TABLE IF NOT EXISTS public.comunas (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    region_id INTEGER REFERENCES public.regions(id),
    code TEXT NOT NULL UNIQUE,
    coordinates GEOMETRY(Point, 4326),
    UNIQUE(name, region_id)
);

-- Tabla de modalidades de fútbol
CREATE TABLE IF NOT EXISTS public.football_modalities (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    players_per_team INTEGER NOT NULL,
    description TEXT
);

-- Tabla de equipos
CREATE TABLE IF NOT EXISTS public.teams (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    tag TEXT UNIQUE,
    logo_url TEXT,
    description TEXT,
    captain_id UUID REFERENCES public.profiles(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    comuna_id UUID REFERENCES public.comunas(id),
    modality_id INTEGER REFERENCES public.football_modalities(id),
    is_active BOOLEAN DEFAULT TRUE,
    max_members INTEGER DEFAULT 15,
    home_color TEXT DEFAULT '#2E7D32',
    away_color TEXT DEFAULT '#FFFFFF',
    elo_rating INTEGER DEFAULT 1200
);

-- Tabla de etiquetas de equipo
CREATE TABLE IF NOT EXISTS public.team_tags (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT
);

-- Tabla de relación equipo-etiqueta
CREATE TABLE IF NOT EXISTS public.team_tag_relations (
    team_id UUID REFERENCES public.teams(id) ON DELETE CASCADE,
    tag_id INTEGER REFERENCES public.team_tags(id) ON DELETE CASCADE,
    PRIMARY KEY (team_id, tag_id)
);

-- Tabla de miembros de equipo
CREATE TABLE IF NOT EXISTS public.team_members (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    team_id UUID REFERENCES public.teams(id) ON DELETE CASCADE,
    player_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'player', -- 'captain', 'player', 'coach'
    number INTEGER,
    position TEXT,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE (team_id, player_id)
);

-- Tabla de invitaciones a equipos
CREATE TABLE IF NOT EXISTS public.team_invitations (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    team_id UUID REFERENCES public.teams(id) ON DELETE CASCADE,
    player_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES public.profiles(id),
    status TEXT DEFAULT 'pending', -- 'pending', 'accepted', 'rejected'
    message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE (team_id, player_id, status)
);

-- Tabla de amistades
CREATE TABLE IF NOT EXISTS public.friendships (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    requester_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    receiver_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'pending', -- 'pending', 'accepted', 'rejected'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    accepted_at TIMESTAMP WITH TIME ZONE,
    UNIQUE (requester_id, receiver_id)
);

-- Tabla de canchas
CREATE TABLE IF NOT EXISTS public.canchas (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT,
    comuna_id UUID REFERENCES public.comunas(id),
    coordinates GEOMETRY(Point, 4326),
    image_url TEXT,
    description TEXT,
    has_lights BOOLEAN DEFAULT FALSE,
    has_parking BOOLEAN DEFAULT FALSE,
    surface_type TEXT, -- 'pasto', 'sintético', 'cemento', etc.
    price_per_hour DECIMAL(10, 2),
    contact_phone TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Tabla de desafíos entre equipos
CREATE TABLE IF NOT EXISTS public.challenges (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    challenger_team_id UUID REFERENCES public.teams(id) ON DELETE CASCADE,
    challenged_team_id UUID REFERENCES public.teams(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'pending', -- 'pending', 'accepted', 'rejected', 'completed'
    modality_id INTEGER REFERENCES public.football_modalities(id),
    message TEXT,
    proposed_date TIMESTAMP WITH TIME ZONE,
    location TEXT,
    cancha_id UUID REFERENCES public.canchas(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    bet_amount INTEGER DEFAULT 0,
    bet_type TEXT DEFAULT 'none', -- 'none', 'money', 'drinks', 'points'
    CONSTRAINT different_teams CHECK (challenger_team_id <> challenged_team_id)
);

-- Tabla de partidos
CREATE TABLE IF NOT EXISTS public.matches (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    home_team_id UUID REFERENCES public.teams(id),
    away_team_id UUID REFERENCES public.teams(id),
    home_score INTEGER DEFAULT 0,
    away_score INTEGER DEFAULT 0,
    match_date TIMESTAMP WITH TIME ZONE,
    status TEXT DEFAULT 'scheduled', -- 'scheduled', 'in_progress', 'completed', 'cancelled'
    modality_id INTEGER REFERENCES public.football_modalities(id),
    cancha_id UUID REFERENCES public.canchas(id),
    challenge_id UUID REFERENCES public.challenges(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    winner_id UUID REFERENCES public.teams(id),
    duration INTEGER, -- duración en minutos
    notes TEXT,
    home_team_previous_elo INTEGER,
    away_team_previous_elo INTEGER,
    home_team_new_elo INTEGER,
    away_team_new_elo INTEGER,
    location TEXT,
    comuna_id UUID REFERENCES public.comunas(id),
    coordinates GEOMETRY(Point, 4326),
    is_public BOOLEAN DEFAULT FALSE,
    CONSTRAINT different_teams CHECK (home_team_id <> away_team_id)
);

-- Tabla de eventos de partido
CREATE TABLE IF NOT EXISTS public.match_events (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    match_id UUID REFERENCES public.matches(id) ON DELETE CASCADE,
    player_id UUID REFERENCES public.profiles(id),
    team_id UUID REFERENCES public.teams(id),
    event_type TEXT NOT NULL, -- 'goal', 'assist', 'yellow_card', 'red_card', 'injury', etc.
    minute INTEGER,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Tabla de jugadores (estadísticas y detalles)
CREATE TABLE IF NOT EXISTS public.players (
    id UUID REFERENCES public.profiles(id) PRIMARY KEY,
    goals INTEGER DEFAULT 0,
    assists INTEGER DEFAULT 0,
    matches_played INTEGER DEFAULT 0,
    wins INTEGER DEFAULT 0,
    losses INTEGER DEFAULT 0,
    draws INTEGER DEFAULT 0,
    yellow_cards INTEGER DEFAULT 0,
    red_cards INTEGER DEFAULT 0,
    minutes_played INTEGER DEFAULT 0,
    elo_rating INTEGER DEFAULT 1200,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Tabla para el historial de ELO de equipos
CREATE TABLE IF NOT EXISTS public.team_elo_history (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    team_id UUID REFERENCES public.teams(id) ON DELETE CASCADE,
    match_id UUID REFERENCES public.matches(id) ON DELETE CASCADE,
    previous_elo INTEGER NOT NULL,
    new_elo INTEGER NOT NULL,
    change INTEGER GENERATED ALWAYS AS (new_elo - previous_elo) STORED,
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Tabla para sectores de comunas (para dominio territorial)
CREATE TABLE IF NOT EXISTS public.sectors (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    comuna_id UUID REFERENCES public.comunas(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    boundaries GEOMETRY(Polygon, 4326),
    controlling_team_id UUID REFERENCES public.teams(id),
    elo_required INTEGER DEFAULT 1200,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ============================================================
-- VISTAS
-- ============================================================

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
FROM public.friendships f
JOIN public.profiles p ON (
    (f.requester_id = auth.uid() AND p.id = f.receiver_id) OR
    (f.receiver_id = auth.uid() AND p.id = f.requester_id)
)
WHERE f.status = 'accepted';

-- Vista para miembros de equipo
CREATE OR REPLACE VIEW public.team_members_view AS
SELECT 
    tm.id,
    tm.team_id,
    tm.player_id,
    tm.role,
    tm.number,
    tm.position,
    tm.joined_at,
    tm.is_active,
    p.full_name,
    p.email,
    p.profile_picture_url,
    p.tag
FROM public.team_members tm
JOIN public.profiles p ON tm.player_id = p.id;

-- Vista para estadísticas de jugadores
CREATE OR REPLACE VIEW public.player_stats_view AS
SELECT 
    p.id,
    pr.full_name,
    pr.profile_picture_url,
    pr.tag,
    p.goals,
    p.assists,
    p.matches_played,
    p.wins,
    p.losses,
    p.draws,
    p.yellow_cards,
    p.red_cards,
    p.minutes_played,
    p.elo_rating,
    CASE 
        WHEN p.matches_played > 0 THEN 
            ROUND((p.wins::FLOAT / p.matches_played) * 100)
        ELSE 0
    END as win_percentage,
    CASE 
        WHEN p.matches_played > 0 THEN 
            ROUND((p.goals::FLOAT / p.matches_played) * 100) / 100
        ELSE 0
    END as goals_per_match
FROM public.players p
JOIN public.profiles pr ON p.id = pr.id;

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
FROM public.matches m
LEFT JOIN public.teams home_team ON m.home_team_id = home_team.id
LEFT JOIN public.teams away_team ON m.away_team_id = away_team.id
LEFT JOIN public.canchas c ON m.cancha_id = c.id
LEFT JOIN public.comunas com ON m.comuna_id = com.id
LEFT JOIN public.football_modalities fm ON m.modality_id = fm.id;

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
FROM public.challenges ch
JOIN public.teams challenger ON ch.challenger_team_id = challenger.id
JOIN public.teams challenged ON ch.challenged_team_id = challenged.id
LEFT JOIN public.canchas c ON ch.cancha_id = c.id
LEFT JOIN public.football_modalities fm ON ch.modality_id = fm.id;

-- ============================================================
-- FUNCIONES RPC
-- ============================================================

-- SISTEMA DE AMIGOS --

-- Función para obtener solicitudes pendientes
CREATE OR REPLACE FUNCTION public.get_pending_friend_requests()
RETURNS SETOF json AS $$
BEGIN
    RETURN QUERY
    SELECT json_build_object(
        'id', f.id,
        'sender_id', f.requester_id,
        'sender_email', p.email,
        'sender_name', p.full_name,
        'sender_image', p.profile_picture_url,
        'created_at', f.created_at
    )
    FROM public.friendships f
    JOIN public.profiles p ON p.id = f.requester_id
    WHERE f.receiver_id = auth.uid() AND f.status = 'pending';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para enviar solicitud de amistad
CREATE OR REPLACE FUNCTION public.send_friend_request(friend_email text)
RETURNS json AS $$
DECLARE
    friend_user_id uuid;
    existing_request uuid;
    result json;
BEGIN
    -- Buscar usuario por email
    SELECT id INTO friend_user_id 
    FROM public.profiles 
    WHERE email = friend_email;
    
    IF friend_user_id IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Usuario no encontrado');
    END IF;
    
    IF friend_user_id = auth.uid() THEN
        RETURN json_build_object('success', false, 'message', 'No puedes agregarte a ti mismo');
    END IF;
    
    -- Verificar si ya existe una solicitud o amistad
    SELECT id INTO existing_request
    FROM public.friendships
    WHERE 
        (requester_id = auth.uid() AND receiver_id = friend_user_id) OR
        (requester_id = friend_user_id AND receiver_id = auth.uid());
        
    IF existing_request IS NOT NULL THEN
        DECLARE
            existing_status text;
        BEGIN
            SELECT status INTO existing_status FROM public.friendships WHERE id = existing_request;
            
            IF existing_status = 'accepted' THEN
                RETURN json_build_object('success', false, 'message', 'Esta persona ya es tu amigo');
            ELSIF existing_status = 'pending' THEN
                RETURN json_build_object('success', false, 'message', 'Ya existe una solicitud pendiente');
            ELSE
                RETURN json_build_object('success', false, 'message', 'Ya existe una relación con este usuario');
            END IF;
        END;
    END IF;
    
    -- Insertar solicitud
    INSERT INTO public.friendships (requester_id, receiver_id, status)
    VALUES (auth.uid(), friend_user_id, 'pending');
    
    RETURN json_build_object('success', true, 'message', 'Solicitud enviada');
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'message', 'Error al enviar solicitud: ' || SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para aceptar solicitud
CREATE OR REPLACE FUNCTION public.accept_friend_request(friendship_id uuid)
RETURNS json AS $$
DECLARE
    current_status text;
    requester_id_val uuid;
BEGIN
    -- Verificar primero si la solicitud existe y está pendiente
    SELECT status, requester_id INTO current_status, requester_id_val
    FROM public.friendships 
    WHERE id = friendship_id AND receiver_id = auth.uid();
    
    IF current_status IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Solicitud no encontrada o no autorizada');
    END IF;
    
    IF current_status != 'pending' THEN
        RETURN json_build_object('success', false, 'message', 'Esta solicitud ya ha sido ' || 
            CASE current_status 
                WHEN 'accepted' THEN 'aceptada' 
                WHEN 'rejected' THEN 'rechazada' 
                ELSE 'procesada' 
            END);
    END IF;
    
    -- Actualizar la solicitud
    UPDATE public.friendships 
    SET status = 'accepted', 
        updated_at = now(),
        accepted_at = now()
    WHERE id = friendship_id AND receiver_id = auth.uid();
    
    RETURN json_build_object('success', true, 'message', 'Solicitud aceptada');
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'message', 'Error al aceptar solicitud: ' || SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para rechazar solicitud
CREATE OR REPLACE FUNCTION public.reject_friend_request(friendship_id uuid)
RETURNS json AS $$
DECLARE
    current_status text;
BEGIN
    -- Verificar primero si la solicitud existe y está pendiente
    SELECT status INTO current_status 
    FROM public.friendships 
    WHERE id = friendship_id AND receiver_id = auth.uid();
    
    IF current_status IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Solicitud no encontrada o no autorizada');
    END IF;
    
    IF current_status != 'pending' THEN
        RETURN json_build_object('success', false, 'message', 'Esta solicitud ya ha sido ' || 
            CASE current_status 
                WHEN 'accepted' THEN 'aceptada' 
                WHEN 'rejected' THEN 'rechazada' 
                ELSE 'procesada' 
            END);
    END IF;
    
    -- Actualizar la solicitud
    UPDATE public.friendships 
    SET status = 'rejected', 
        updated_at = now()
    WHERE id = friendship_id AND receiver_id = auth.uid();
    
    RETURN json_build_object('success', true, 'message', 'Solicitud rechazada');
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'message', 'Error al rechazar solicitud: ' || SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para eliminar amistad
CREATE OR REPLACE FUNCTION public.remove_friend(friend_id uuid)
RETURNS json AS $$
DECLARE
    friendship_id uuid;
BEGIN
    -- Buscar la amistad
    SELECT id INTO friendship_id
    FROM public.friendships
    WHERE 
        ((requester_id = auth.uid() AND receiver_id = friend_id) OR
        (requester_id = friend_id AND receiver_id = auth.uid()))
        AND status = 'accepted';
    
    IF friendship_id IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Amistad no encontrada');
    END IF;
    
    -- Eliminar la amistad
    DELETE FROM public.friendships WHERE id = friendship_id;
    
    RETURN json_build_object('success', true, 'message', 'Amistad eliminada');
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'message', 'Error al eliminar amistad: ' || SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- SISTEMA DE EQUIPOS --

-- Función para unirse a un equipo
CREATE OR REPLACE FUNCTION public.join_team(team_id uuid)
RETURNS json AS $$
DECLARE
    is_member boolean;
    has_invitation boolean;
BEGIN
    -- Verificar si ya es miembro
    SELECT EXISTS (
        SELECT 1 FROM public.team_members 
        WHERE team_id = $1 AND player_id = auth.uid()
    ) INTO is_member;
    
    IF is_member THEN
        RETURN json_build_object('success', false, 'message', 'Ya eres miembro de este equipo');
    END IF;
    
    -- Verificar si tiene invitación pendiente
    SELECT EXISTS (
        SELECT 1 FROM public.team_invitations 
        WHERE team_id = $1 AND player_id = auth.uid() AND status = 'pending'
    ) INTO has_invitation;
    
    IF NOT has_invitation THEN
        RETURN json_build_object('success', false, 'message', 'No tienes una invitación para este equipo');
    END IF;
    
    -- Aceptar la invitación
    UPDATE public.team_invitations
    SET status = 'accepted', updated_at = now()
    WHERE team_id = $1 AND player_id = auth.uid() AND status = 'pending';
    
    -- Añadir al equipo
    INSERT INTO public.team_members (team_id, player_id, role)
    VALUES ($1, auth.uid(), 'player');
    
    RETURN json_build_object('success', true, 'message', 'Te has unido al equipo');
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'message', 'Error al unirse al equipo: ' || SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para salir de un equipo
CREATE OR REPLACE FUNCTION public.leave_team(team_id uuid)
RETURNS json AS $$
DECLARE
    is_member boolean;
    is_captain boolean;
BEGIN
    -- Verificar si es miembro
    SELECT EXISTS (
        SELECT 1 FROM public.team_members 
        WHERE team_id = $1 AND player_id = auth.uid()
    ) INTO is_member;
    
    IF NOT is_member THEN
        RETURN json_build_object('success', false, 'message', 'No eres miembro de este equipo');
    END IF;
    
    -- Verificar si es capitán
    SELECT EXISTS (
        SELECT 1 FROM public.team_members 
        WHERE team_id = $1 AND player_id = auth.uid() AND role = 'captain'
    ) INTO is_captain;
    
    IF is_captain THEN
        RETURN json_build_object('success', false, 'message', 'No puedes salir del equipo siendo el capitán. Transfiere la capitanía primero.');
    END IF;
    
    -- Eliminar del equipo
    DELETE FROM public.team_members
    WHERE team_id = $1 AND player_id = auth.uid();
    
    RETURN json_build_object('success', true, 'message', 'Has salido del equipo');
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'message', 'Error al salir del equipo: ' || SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para enviar invitación a equipo
CREATE OR REPLACE FUNCTION public.send_team_invitation(player_email text, team_id uuid, message text DEFAULT NULL)
RETURNS json AS $$
DECLARE
    player_id uuid;
    is_team_member boolean;
    can_invite boolean;
    existing_invitation uuid;
BEGIN
    -- Verificar si el usuario tiene permisos en el equipo
    SELECT EXISTS (
        SELECT 1 FROM public.team_members 
        WHERE team_id = $2 AND player_id = auth.uid() AND (role = 'captain' OR role = 'coach')
    ) INTO can_invite;
    
    IF NOT can_invite THEN
        RETURN json_build_object('success', false, 'message', 'No tienes permisos para invitar a este equipo');
    END IF;
    
    -- Buscar jugador por email
    SELECT id INTO player_id 
    FROM public.profiles 
    WHERE email = player_email;
    
    IF player_id IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Jugador no encontrado');
    END IF;
    
    -- Verificar si ya es miembro
    SELECT EXISTS (
        SELECT 1 FROM public.team_members 
        WHERE team_id = $2 AND player_id = player_id
    ) INTO is_team_member;
    
    IF is_team_member THEN
        RETURN json_build_object('success', false, 'message', 'Este jugador ya es miembro del equipo');
    END IF;
    
    -- Verificar si ya tiene invitación pendiente
    SELECT id INTO existing_invitation
    FROM public.team_invitations
    WHERE team_id = $2 AND player_id = player_id AND status = 'pending';
    
    IF existing_invitation IS NOT NULL THEN
        RETURN json_build_object('success', false, 'message', 'Este jugador ya tiene una invitación pendiente');
    END IF;
    
    -- Crear invitación
    INSERT INTO public.team_invitations (team_id, player_id, sender_id, message)
    VALUES ($2, player_id, auth.uid(), $3);
    
    RETURN json_build_object('success', true, 'message', 'Invitación enviada');
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'message', 'Error al enviar invitación: ' || SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para aceptar invitación a equipo
CREATE OR REPLACE FUNCTION public.accept_team_invitation(invitation_id uuid)
RETURNS json AS $$
DECLARE
    team_id_val uuid;
    current_status text;
BEGIN
    -- Verificar si la invitación existe y está pendiente
    SELECT team_id, status INTO team_id_val, current_status
    FROM public.team_invitations
    WHERE id = $1 AND player_id = auth.uid();
    
    IF team_id_val IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Invitación no encontrada o no autorizada');
    END IF;
    
    IF current_status != 'pending' THEN
        RETURN json_build_object('success', false, 'message', 'Esta invitación ya ha sido procesada');
    END IF;
    
    -- Actualizar invitación
    UPDATE public.team_invitations
    SET status = 'accepted', updated_at = now()
    WHERE id = $1;
    
    -- Añadir al equipo
    INSERT INTO public.team_members (team_id, player_id, role)
    VALUES (team_id_val, auth.uid(), 'player');
    
    RETURN json_build_object('success', true, 'message', 'Te has unido al equipo');
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'message', 'Error al aceptar invitación: ' || SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para rechazar invitación a equipo
CREATE OR REPLACE FUNCTION public.reject_team_invitation(invitation_id uuid)
RETURNS json AS $$
DECLARE
    current_status text;
BEGIN
    -- Verificar si la invitación existe y está pendiente
    SELECT status INTO current_status
    FROM public.team_invitations
    WHERE id = $1 AND player_id = auth.uid();
    
    IF current_status IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Invitación no encontrada o no autorizada');
    END IF;
    
    IF current_status != 'pending' THEN
        RETURN json_build_object('success', false, 'message', 'Esta invitación ya ha sido procesada');
    END IF;
    
    -- Actualizar invitación
    UPDATE public.team_invitations
    SET status = 'rejected', updated_at = now()
    WHERE id = $1;
    
    RETURN json_build_object('success', true, 'message', 'Invitación rechazada');
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'message', 'Error al rechazar invitación: ' || SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- SISTEMA DE DESAFÍOS --

-- Función para crear un desafío
CREATE OR REPLACE FUNCTION public.create_challenge(
    challenged_team_id uuid,
    modality_id integer,
    message text,
    proposed_date timestamp with time zone,
    location text DEFAULT NULL,
    cancha_id uuid DEFAULT NULL,
    bet_amount integer DEFAULT 0,
    bet_type text DEFAULT 'none'
)
RETURNS json AS $$
DECLARE
    challenger_team_id uuid;
    is_captain boolean;
BEGIN
    -- Obtener equipo del retador (primer equipo donde es capitán)
    SELECT team_id INTO challenger_team_id
    FROM public.team_members
    WHERE player_id = auth.uid() AND role = 'captain'
    LIMIT 1;
    
    IF challenger_team_id IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'No eres capitán de ningún equipo');
    END IF;
    
    -- Verificar que sean equipos diferentes
    IF challenger_team_id = challenged_team_id THEN
        RETURN json_build_object('success', false, 'message', 'No puedes desafiar a tu propio equipo');
    END IF;
    
    -- Verificar si ya existe un desafío pendiente entre estos equipos
    IF EXISTS (
        SELECT 1 FROM public.challenges
        WHERE 
            (challenger_team_id = challenger_team_id AND challenged_team_id = $1) OR
            (challenger_team_id = $1 AND challenged_team_id = challenger_team_id)
        AND status = 'pending'
    ) THEN
        RETURN json_build_object('success', false, 'message', 'Ya existe un desafío pendiente entre estos equipos');
    END IF;
    
    -- Crear desafío
    INSERT INTO public.challenges (
        challenger_team_id, challenged_team_id, modality_id, message, 
        proposed_date, location, cancha_id, bet_amount, bet_type
    )
    VALUES (
        challenger_team_id, $1, $2, $3, $4, $5, $6, $7, $8
    );
    
    RETURN json_build_object('success', true, 'message', 'Desafío enviado');
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'message', 'Error al crear desafío: ' || SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para aceptar un desafío
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
    
    -- Verificar si es capitán del equipo desafiado
    SELECT EXISTS (
        SELECT 1 FROM public.team_members
        WHERE team_id = challenged_team_id AND player_id = auth.uid() AND role = 'captain'
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

-- Función para rechazar un desafío
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
    
    -- Verificar si es capitán del equipo desafiado
    SELECT EXISTS (
        SELECT 1 FROM public.team_members
        WHERE team_id = challenged_team_id AND player_id = auth.uid() AND role = 'captain'
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

-- SISTEMA DE PARTIDOS --

-- Función para registrar resultado de partido
CREATE OR REPLACE FUNCTION public.record_match_result(
    match_id uuid,
    home_score integer,
    away_score integer,
    duration integer DEFAULT 90
)
RETURNS json AS $$
DECLARE
    home_team_id uuid;
    away_team_id uuid;
    is_captain boolean;
    challenge_id_val uuid;
    winner_id_val uuid;
BEGIN
    -- Obtener información del partido
    SELECT m.home_team_id, m.away_team_id, m.challenge_id
    INTO home_team_id, away_team_id, challenge_id_val
    FROM public.matches m
    WHERE m.id = $1;
    
    IF home_team_id IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Partido no encontrado');
    END IF;
    
    -- Verificar si es capitán de alguno de los equipos
    SELECT EXISTS (
        SELECT 1 FROM public.team_members
        WHERE (team_id = home_team_id OR team_id = away_team_id) 
        AND player_id = auth.uid() AND role = 'captain'
    ) INTO is_captain;
    
    IF NOT is_captain THEN
        RETURN json_build_object('success', false, 'message', 'No eres capitán de ninguno de los equipos');
    END IF;
    
    -- Determinar ganador
    IF $2 > $3 THEN
        winner_id_val := home_team_id;
    ELSIF $3 > $2 THEN
        winner_id_val := away_team_id;
    END IF;
    
    -- Actualizar partido
    UPDATE public.matches
    SET 
        home_score = $2,
        away_score = $3,
        status = 'completed',
        winner_id = winner_id_val,
        duration = $4,
        updated_at = now()
    WHERE id = $1;
    
    -- Si viene de un desafío, actualizar el desafío
    IF challenge_id_val IS NOT NULL THEN
        UPDATE public.challenges
        SET status = 'completed', updated_at = now()
        WHERE id = challenge_id_val;
    END IF;
    
    -- Actualizar ELO de los equipos
    PERFORM public.update_team_elo($1);
    
    RETURN json_build_object('success', true, 'message', 'Resultado registrado');
    
EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object('success', false, 'message', 'Error al registrar resultado: ' || SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para actualizar ELO de equipos
CREATE OR REPLACE FUNCTION public.update_team_elo(match_id uuid)
RETURNS void AS $$
DECLARE
    home_team_id uuid;
    away_team_id uuid;
    home_score integer;
    away_score integer;
    home_elo integer;
    away_elo integer;
    home_new_elo integer;
    away_new_elo integer;
    k_factor integer := 32; -- Factor de ajuste ELO
    expected_home_win float;
    expected_away_win float;
    actual_home_result float;
BEGIN
    -- Obtener información del partido
    SELECT 
        m.home_team_id, m.away_team_id, m.home_score, m.away_score,
        h.elo_rating, a.elo_rating
    INTO 
        home_team_id, away_team_id, home_score, away_score,
        home_elo, away_elo
    FROM public.matches m
    JOIN public.teams h ON m.home_team_id = h.id
    JOIN public.teams a ON m.away_team_id = a.id
    WHERE m.id = $1;
    
    -- Calcular probabilidad de victoria
    expected_home_win := 1.0 / (1.0 + 10.0 ^ ((away_elo - home_elo) / 400.0));
    expected_away_win := 1.0 / (1.0 + 10.0 ^ ((home_elo - away_elo) / 400.0));
    
    -- Determinar resultado real (1=victoria, 0.5=empate, 0=derrota)
    IF home_score > away_score THEN
        actual_home_result := 1.0;
    ELSIF home_score = away_score THEN
        actual_home_result := 0.5;
    ELSE
        actual_home_result := 0.0;
    END IF;
    
    -- Calcular nuevos ELO
    home_new_elo := home_elo + (k_factor * (actual_home_result - expected_home_win))::integer;
    away_new_elo := away_elo + (k_factor * ((1 - actual_home_result) - expected_away_win))::integer;
    
    -- Actualizar equipos
    UPDATE public.teams SET elo_rating = home_new_elo WHERE id = home_team_id;
    UPDATE public.teams SET elo_rating = away_new_elo WHERE id = away_team_id;
    
    -- Guardar historial ELO
    INSERT INTO public.team_elo_history (team_id, match_id, previous_elo, new_elo)
    VALUES 
        (home_team_id, $1, home_elo, home_new_elo),
        (away_team_id, $1, away_elo, away_new_elo);
    
    -- Actualizar partido con ELO
    UPDATE public.matches
    SET 
        home_team_previous_elo = home_elo,
        away_team_previous_elo = away_elo,
        home_team_new_elo = home_new_elo,
        away_team_new_elo = away_new_elo
    WHERE id = $1;
    
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- POLÍTICAS RLS
-- ============================================================

-- Habilitar RLS en todas las tablas
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.friendships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.match_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.players ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_elo_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sectors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_tag_relations ENABLE ROW LEVEL SECURITY;

-- Políticas para perfiles
CREATE POLICY profiles_select_policy ON public.profiles
    FOR SELECT USING (true);
    
CREATE POLICY profiles_update_policy ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

-- Políticas para equipos
CREATE POLICY teams_select_policy ON public.teams
    FOR SELECT USING (true);
    
CREATE POLICY teams_insert_policy ON public.teams
    FOR INSERT WITH CHECK (auth.uid() = captain_id);
    
CREATE POLICY teams_update_policy ON public.teams
    FOR UPDATE USING (
        auth.uid() = captain_id OR
        EXISTS (
            SELECT 1 FROM public.team_members
            WHERE team_id = id AND player_id = auth.uid() AND role IN ('captain', 'coach')
        )
    );
    
CREATE POLICY teams_delete_policy ON public.teams
    FOR DELETE USING (auth.uid() = captain_id);

-- Políticas para miembros de equipo
CREATE POLICY team_members_select_policy ON public.team_members
    FOR SELECT USING (true);
    
CREATE POLICY team_members_insert_policy ON public.team_members
    FOR INSERT WITH CHECK (
        auth.uid() = player_id OR
        EXISTS (
            SELECT 1 FROM public.team_members
            WHERE team_id = team_id AND player_id = auth.uid() AND role = 'captain'
        )
    );
    
CREATE POLICY team_members_update_policy ON public.team_members
    FOR UPDATE USING (
        (auth.uid() = player_id AND role != 'captain') OR
        EXISTS (
            SELECT 1 FROM public.team_members
            WHERE team_id = team_id AND player_id = auth.uid() AND role = 'captain'
        )
    );
    
CREATE POLICY team_members_delete_policy ON public.team_members
    FOR DELETE USING (
        auth.uid() = player_id OR
        EXISTS (
            SELECT 1 FROM public.team_members
            WHERE team_id = team_id AND player_id = auth.uid() AND role = 'captain'
        )
    );

-- Políticas para invitaciones a equipos
CREATE POLICY team_invitations_select_policy ON public.team_invitations
    FOR SELECT USING (
        auth.uid() = player_id OR
        auth.uid() = sender_id OR
        EXISTS (
            SELECT 1 FROM public.team_members
            WHERE team_id = team_id AND player_id = auth.uid() AND role IN ('captain', 'coach')
        )
    );
    
CREATE POLICY team_invitations_insert_policy ON public.team_invitations
    FOR INSERT WITH CHECK (
        auth.uid() = sender_id AND
        EXISTS (
            SELECT 1 FROM public.team_members
            WHERE team_id = team_id AND player_id = auth.uid() AND role IN ('captain', 'coach')
        )
    );
    
CREATE POLICY team_invitations_update_policy ON public.team_invitations
    FOR UPDATE USING (
        auth.uid() = player_id OR
        EXISTS (
            SELECT 1 FROM public.team_members
            WHERE team_id = team_id AND player_id = auth.uid() AND role IN ('captain', 'coach')
        )
    );

-- Políticas para amistades
CREATE POLICY friendships_select_policy ON public.friendships
    FOR SELECT USING (auth.uid() = requester_id OR auth.uid() = receiver_id);
    
CREATE POLICY friendships_insert_policy ON public.friendships
    FOR INSERT WITH CHECK (auth.uid() = requester_id);
    
CREATE POLICY friendships_update_policy ON public.friendships
    FOR UPDATE USING (
        auth.uid() = receiver_id OR 
        (auth.uid() = requester_id AND status = 'pending')
    );
    
CREATE POLICY friendships_delete_policy ON public.friendships
    FOR DELETE USING (auth.uid() = requester_id OR auth.uid() = receiver_id);

-- Políticas para desafíos
CREATE POLICY challenges_select_policy ON public.challenges
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.team_members
            WHERE (team_id = challenger_team_id OR team_id = challenged_team_id) AND player_id = auth.uid()
        ) OR
        status = 'completed' -- Los desafíos completados son públicos
    );
    
CREATE POLICY challenges_insert_policy ON public.challenges
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.team_members
            WHERE team_id = challenger_team_id AND player_id = auth.uid() AND role = 'captain'
        )
    );
    
CREATE POLICY challenges_update_policy ON public.challenges
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.team_members
            WHERE (team_id = challenger_team_id OR team_id = challenged_team_id) AND player_id = auth.uid() AND role = 'captain'
        )
    );

-- Políticas para partidos
CREATE POLICY matches_select_policy ON public.matches
    FOR SELECT USING (
        is_public OR
        EXISTS (
            SELECT 1 FROM public.team_members
            WHERE (team_id = home_team_id OR team_id = away_team_id) AND player_id = auth.uid()
        )
    );
    
CREATE POLICY matches_insert_policy ON public.matches
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.team_members
            WHERE (team_id = home_team_id OR team_id = away_team_id) AND player_id = auth.uid() AND role = 'captain'
        )
    );
    
CREATE POLICY matches_update_policy ON public.matches
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.team_members
            WHERE (team_id = home_team_id OR team_id = away_team_id) AND player_id = auth.uid() AND role = 'captain'
        )
    );

-- Políticas para eventos de partido
CREATE POLICY match_events_select_policy ON public.match_events
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.matches m
            WHERE m.id = match_id AND (
                m.is_public OR
                EXISTS (
                    SELECT 1 FROM public.team_members
                    WHERE (team_id = m.home_team_id OR team_id = m.away_team_id) AND player_id = auth.uid()
                )
            )
        )
    );
    
CREATE POLICY match_events_insert_policy ON public.match_events
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.matches m
            WHERE m.id = match_id AND (
                EXISTS (
                    SELECT 1 FROM public.team_members
                    WHERE (team_id = m.home_team_id OR team_id = m.away_team_id) AND player_id = auth.uid() AND role IN ('captain', 'coach')
                )
            )
        )
    );

-- Políticas para jugadores
CREATE POLICY players_select_policy ON public.players
    FOR SELECT USING (true);
    
CREATE POLICY players_update_policy ON public.players
    FOR UPDATE USING (auth.uid() = id);

-- ============================================================
-- DATOS INICIALES
-- ============================================================

-- Modalidades de fútbol
INSERT INTO public.football_modalities (name, players_per_team, description)
VALUES
    ('Fútbol 5', 5, 'Fútbol con 5 jugadores por equipo'),
    ('Fútbol 7', 7, 'Fútbol con 7 jugadores por equipo'),
    ('Fútbol 8', 8, 'Fútbol con 8 jugadores por equipo'),
    ('Fútbol 11', 11, 'Fútbol tradicional con 11 jugadores por equipo')
ON CONFLICT (name) DO NOTHING;

-- Etiquetas de equipo
INSERT INTO public.team_tags (name, description)
VALUES
    ('Recreativo', 'Equipo que juega por diversión'),
    ('Competitivo', 'Equipo que juega para ganar'),
    ('Principiante', 'Equipo de nivel básico'),
    ('Intermedio', 'Equipo de nivel medio'),
    ('Avanzado', 'Equipo de nivel alto'),
    ('Amateur', 'Equipo no profesional'),
    ('Femenino', 'Equipo de mujeres'),
    ('Masculino', 'Equipo de hombres'),
    ('Mixto', 'Equipo con hombres y mujeres'),
    ('Nocturno', 'Equipo que juega por la noche'),
    ('Diurno', 'Equipo que juega durante el día'),
    ('Veteranos', 'Equipo de jugadores mayores'),
    ('Juvenil', 'Equipo de jugadores jóvenes')
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- MENSAJE FINAL
-- ============================================================

DO $$ 
BEGIN
    RAISE NOTICE '✅ Base de datos instalada correctamente';
    RAISE NOTICE '🔧 Tablas creadas y configuradas';
    RAISE NOTICE '🔧 Vistas y funciones instaladas';
    RAISE NOTICE '🔧 Políticas de seguridad aplicadas';
    RAISE NOTICE '🔧 Datos iniciales cargados';
    RAISE NOTICE '';
    RAISE NOTICE '🏆 Sistema listo para comenzar a usar';
END $$;
