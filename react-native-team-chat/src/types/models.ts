export type Message = {
  id: string;
  team_id: string;
  user_id: string;
  content: string;
  created_at: string; // ISO string
  edited_at: string | null;
};

export type Team = {
  id: string;
  name: string;
  created_at: string;
  tag?: string;
  logo_url?: string | null;
  home_color?: string | null;
  away_color?: string | null;
  elo_rating?: number;
};

export type TeamMember = {
  team_id: string;
  user_id: string; // profile id
  role: 'captain' | 'coach' | 'player' | 'owner' | 'admin' | 'member';
  joined_at: string;
  is_active?: boolean;
};

export type FootballModality = {
  id: number;
  name: string;
  code: 'baby_futbol' | 'futbolito' | 'futbol11';
  min_players: number;
  max_players: number;
  field_players: number;
};

export type PublicMatch = {
  id: string;
  host_team_id: string;
  title: string;
  description?: string | null;
  match_date: string; // ISO
  comuna_id?: string | null;
  location?: string | null;
  modality_type: 'baby_futbol' | 'futbolito' | 'futbol11' | string;
  min_players?: number | null;
  max_players?: number | null;
  field_players?: number | null;
  status: 'open' | 'filled' | 'cancelled' | 'completed' | 'matched' | string;
  created_at: string;
  match_id?: string | null;
  created_by?: string | null;
  host_team_name?: string | null;
  host_team_tag?: string | null;
};

export type Match = {
  id: string;
  home_team_id: string;
  away_team_id: string | null;
  match_date: string | null;
  status: 'scheduled' | 'in_progress' | 'completed' | 'cancelled' | string;
  modality_type?: PublicMatch['modality_type'];
  min_players?: number | null;
  max_players?: number | null;
  field_players?: number | null;
  comuna_id?: string | null;
  region_id?: number | null;
  sector_id?: string | null;
  cancha_id?: string | null;
  created_by?: string | null;
  is_public?: boolean;
  notes?: string | null;
  location?: string | null;
};

export type MatchParticipant = {
  id: string;
  match_id: string;
  player_id: string;
  team_id: string;
  status: 'pending' | 'confirmed' | 'declined';
  is_starter: boolean;
  created_at: string;
};
