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
};

export type TeamMember = {
  team_id: string;
  user_id: string;
  role: 'owner' | 'admin' | 'member';
  joined_at: string;
};
