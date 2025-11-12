import { supabase } from './supabase';
import type { FootballModality, Match, MatchParticipant, PublicMatch, Team, TeamMember } from '../types/models';

// Map external modality strings to DB codes
function normalizeModality(modality: string): FootballModality['code'] {
  const m = modality.toLowerCase();
  if (m === 'futbol_11' || m === 'fútbol 11' || m === 'futbol 11' || m === 'futbol11') return 'futbol11';
  if (m === 'baby' || m === 'baby_futbol' || m === 'babyfutbol' || m === 'fútbol 5' || m === 'futbol5') return 'baby_futbol';
  return 'futbolito';
}

async function getModalityByCode(code: FootballModality['code']) {
  const { data, error } = await supabase
    .from('football_modalities')
    .select('id,name,code,min_players,max_players,field_players')
    .eq('code', code)
    .single();
  if (error) throw error;
  return data as FootballModality;
}

async function getTeam(id: string) {
  const { data, error } = await supabase
    .from('teams')
    .select('id,name,tag,logo_url,home_color,away_color,elo_rating')
    .eq('id', id)
    .single();
  if (error) throw error;
  return data as Team;
}

export type CreatePublicMatchInput = {
  host_team_id: string;
  title: string;
  description?: string;
  match_date: string; // ISO
  comuna_id?: string | null;
  modality_type: string; // 'futbolito' | 'futbol_11' | 'baby_futbol'
  location_text?: string; // optional free text
};

export async function createPublicMatch(input: CreatePublicMatchInput): Promise<PublicMatch> {
  const code = normalizeModality(input.modality_type);
  const modality = await getModalityByCode(code);
  const host = await getTeam(input.host_team_id);

  const payload: Partial<PublicMatch> = {
    host_team_id: input.host_team_id,
    title: input.title,
    description: input.description ?? null,
    match_date: input.match_date,
    comuna_id: input.comuna_id ?? null,
    location: input.location_text ?? 'Cancha a definir',
    modality_type: modality.code,
    min_players: modality.min_players,
    max_players: modality.max_players,
    field_players: modality.field_players,
    status: 'open',
    host_team_name: host?.name ?? null,
    host_team_tag: host?.tag ?? null,
  } as any;

  const { data, error } = await supabase
    .from('public_matches')
    .insert(payload)
    .select('*')
    .single();
  if (error) throw error;
  return data as PublicMatch;
}

export type ListPublicMatchesFilters = {
  comuna_id?: string;
  host_team_id?: string;
  modality_type?: string;
  fecha_desde?: string; // ISO
  fecha_hasta?: string; // ISO
};

export async function listPublicMatches(filters: ListPublicMatchesFilters = {}) {
  const {
    comuna_id,
    host_team_id,
    modality_type,
    fecha_desde,
    fecha_hasta,
  } = filters;

  let query = supabase
    .from('public_matches')
    .select('*')
    .eq('status', 'open')
    .gte('match_date', fecha_desde ?? new Date().toISOString())
    .order('match_date', { ascending: true });

  if (comuna_id) query = query.eq('comuna_id', comuna_id);
  if (host_team_id) query = query.eq('host_team_id', host_team_id);
  if (modality_type) query = query.eq('modality_type', normalizeModality(modality_type));
  if (fecha_hasta) query = query.lte('match_date', fecha_hasta);

  const { data, error } = await query;
  if (error) throw error;
  return (data ?? []) as PublicMatch[];
}

export type AcceptPublicMatchInput = {
  public_match_id: string;
  away_team_id: string;
  created_by: string; // profile id (captain)
};

export async function acceptPublicMatch(input: AcceptPublicMatchInput): Promise<{ match: Match; public_match: PublicMatch; }>
{
  // Fetch public match
  const { data: pm, error: e1 } = await supabase
    .from('public_matches')
    .select('*')
    .eq('id', input.public_match_id)
    .single();
  if (e1) throw e1;
  const publicMatch = pm as PublicMatch;
  if (publicMatch.status !== 'open') throw new Error('Este partido ya no está disponible.');
  if (publicMatch.host_team_id === input.away_team_id) throw new Error('No puedes aceptar tu propio partido.');

  // Derive region from comuna if available
  let region_id: number | null = null;
  if (publicMatch.comuna_id) {
    const { data: comunaRow } = await supabase
      .from('comunas')
      .select('region_id')
      .eq('id', publicMatch.comuna_id)
      .maybeSingle();
    region_id = (comunaRow as any)?.region_id ?? null;
  }

  const matchPayload: Partial<Match> = {
    home_team_id: publicMatch.host_team_id,
    away_team_id: input.away_team_id,
    match_date: publicMatch.match_date,
    status: 'scheduled',
    modality_type: publicMatch.modality_type,
    min_players: publicMatch.min_players ?? undefined,
    max_players: publicMatch.max_players ?? undefined,
    field_players: publicMatch.field_players ?? undefined,
    comuna_id: publicMatch.comuna_id ?? null,
    region_id,
    sector_id: null,
    cancha_id: null,
    created_by: input.created_by,
    is_public: true,
    location: publicMatch.location ?? 'Cancha a definir',
  } as any;

  const { data: match, error: e2 } = await supabase
    .from('matches')
    .insert(matchPayload)
    .select('*')
    .single();
  if (e2) throw e2;

  // Update public_matches to matched and link match_id
  const { data: updatedPm, error: e3 } = await supabase
    .from('public_matches')
    .update({ status: 'matched', match_id: (match as any).id })
    .eq('id', publicMatch.id)
    .select('*')
    .single();
  if (e3) throw e3;

  // Notify players of both teams
  await notifyTeamsOfMatch((match as any).id as string, publicMatch.host_team_id, input.away_team_id);

  return { match: match as Match, public_match: updatedPm as PublicMatch };
}

async function getTeamActiveMembers(teamId: string): Promise<TeamMember[]> {
  const { data, error } = await supabase
    .from('team_members')
    .select('team_id, player_id:user_id, role, joined_at, is_active')
    .eq('team_id', teamId)
    .eq('is_active', true);
  if (error) throw error;
  // Our TeamMember type expects user_id, map from alias
  return (data ?? []).map((r: any) => ({
    team_id: r.team_id,
    user_id: r.player_id,
    role: r.role,
    joined_at: r.joined_at,
    is_active: r.is_active,
  })) as TeamMember[];
}

async function notifyTeamsOfMatch(matchId: string, homeTeamId: string, awayTeamId: string) {
  const [homeMembers, awayMembers] = await Promise.all([
    getTeamActiveMembers(homeTeamId),
    getTeamActiveMembers(awayTeamId),
  ]);

  const notifications: any[] = [];
  for (const m of homeMembers) {
    notifications.push({
      user_id: m.user_id,
      match_id: matchId,
      type: 'match_confirmed',
      title: 'Partido confirmado',
      message: 'Se confirmó un partido para tu equipo (local).',
      metadata: { team_role: 'home' },
    });
  }
  for (const m of awayMembers) {
    notifications.push({
      user_id: m.user_id,
      match_id: matchId,
      type: 'match_invitation',
      title: 'Nueva invitación a partido',
      message: 'Tu equipo fue invitado a un partido (visita). Confirma tu asistencia.',
      metadata: { team_role: 'away' },
    });
  }

  if (notifications.length) {
    const { error } = await supabase.from('notifications').insert(notifications);
    if (error) console.warn('[notifyTeamsOfMatch] insert notifications error', error.message);
  }
}

export async function createMatchConvocation(match_id: string, team_id: string) {
  // Get all active team members
  const members = await getTeamActiveMembers(team_id);
  if (!members.length) return { inserted: 0 };

  const rows = members.map((m) => ({
    match_id,
    player_id: m.user_id,
    team_id,
    status: 'pending',
    is_starter: true,
  }));

  // Use upsert-like behavior via on conflict (match_id, player_id)
  const { data, error } = await supabase
    .from('match_participants')
    .upsert(rows, { onConflict: 'match_id,player_id', ignoreDuplicates: true })
    .select('id');
  if (error) throw error;
  return { inserted: data?.length ?? 0 };
}

export async function setPlayerAttendance(match_id: string, player_id: string, status: 'pending' | 'confirmed' | 'declined') {
  // Update status
  const { data: updated, error: e1 } = await supabase
    .from('match_participants')
    .update({ status })
    .eq('match_id', match_id)
    .eq('player_id', player_id)
    .select('id, team_id')
    .single();
  if (e1) throw e1;
  const team_id = (updated as any).team_id as string;

  // Load match constraints
  const { data: matchRow, error: e2 } = await supabase
    .from('matches')
    .select('id, min_players, max_players')
    .eq('id', match_id)
    .single();
  if (e2) throw e2;

  const { count, error: e3 } = await supabase
    .from('match_participants')
    .select('*', { count: 'exact', head: true })
    .eq('match_id', match_id)
    .eq('team_id', team_id)
    .eq('status', 'confirmed');
  if (e3) throw e3;

  const confirmedCount = count ?? 0;
  const min = (matchRow as any).min_players ?? 0;
  const max = (matchRow as any).max_players ?? Number.MAX_SAFE_INTEGER;

  let atCapacity = false;
  if (status === 'confirmed' && confirmedCount > max) {
    // Rollback this update optimistically by setting back to pending
    await supabase
      .from('match_participants')
      .update({ status: 'pending' })
      .eq('match_id', match_id)
      .eq('player_id', player_id);
    throw new Error('Cupo completo para esta modalidad. No se permiten más confirmaciones.');
  }
  atCapacity = confirmedCount >= max;
  const atRisk = confirmedCount < min;

  return {
    confirmedCount,
    minRequired: min,
    maxAllowed: max,
    atRisk,
    atCapacity,
  };
}

// Kit color resolver
function hexToRgb(hex?: string | null): { r: number; g: number; b: number } | null {
  if (!hex) return null;
  const clean = hex.replace('#', '');
  if (clean.length !== 6) return null;
  const num = parseInt(clean, 16);
  return { r: (num >> 16) & 255, g: (num >> 8) & 255, b: num & 255 };
}

function colorDistance(a: string | null | undefined, b: string | null | undefined): number {
  const ra = hexToRgb(a); const rb = hexToRgb(b);
  if (!ra || !rb) return 999;
  const dr = ra.r - rb.r, dg = ra.g - rb.g, db = ra.b - rb.b;
  return Math.sqrt(dr * dr + dg * dg + db * db);
}

export function resolveKitColors(homeTeam: Team, awayTeam: Team) {
  const homeDefault = homeTeam.home_color ?? '#2E7D32';
  const awayDefault = awayTeam.home_color ?? '#2E7D32';
  let homeKit = homeDefault;
  let awayKit = awayDefault;

  // If too similar, switch away to its away_color, else pick a safe fallback (white)
  if (colorDistance(homeKit, awayKit) < 60) {
    awayKit = awayTeam.away_color ?? '#FFFFFF';
    if (colorDistance(homeKit, awayKit) < 60) {
      // Final fallback
      awayKit = '#FFFFFF';
      if (colorDistance(homeKit, awayKit) < 60) {
        // Change home instead
        homeKit = '#1B5E20';
      }
    }
  }
  return { homeKit, awayKit };
}

// Utility to fetch participants for a match (optionally by team)
export async function getMatchParticipants(match_id: string, team_id?: string) {
  let q = supabase
    .from('match_participants')
    .select('*')
    .eq('match_id', match_id)
    .order('created_at', { ascending: true });
  if (team_id) q = q.eq('team_id', team_id);
  const { data, error } = await q;
  if (error) throw error;
  return (data ?? []) as MatchParticipant[];
}
