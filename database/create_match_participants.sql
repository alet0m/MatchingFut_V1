-- Create match_participants table and RLS policies (idempotent)
-- Tracks player attendance/role per match and team

create extension if not exists "uuid-ossp";

create table if not exists public.match_participants (
  id uuid primary key default uuid_generate_v4(),
  match_id uuid not null references public.matches(id) on delete cascade,
  player_id uuid not null references public.profiles(id) on delete cascade,
  team_id uuid not null references public.teams(id) on delete cascade,
  status text not null default 'pending' check (status in ('pending','confirmed','declined')),
  is_starter boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (match_id, player_id)
);

-- Basic indexes
create index if not exists idx_match_participants_match on public.match_participants(match_id);
create index if not exists idx_match_participants_team on public.match_participants(team_id);
create index if not exists idx_match_participants_player on public.match_participants(player_id);
create index if not exists idx_match_participants_status on public.match_participants(status);

-- Timestamp trigger
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_match_participants_updated_at on public.match_participants;
create trigger trg_match_participants_updated_at
  before update on public.match_participants
  for each row execute function public.set_updated_at();

-- RLS
alter table public.match_participants enable row level security;

-- Read: players can read their own rows; team members of the involved match can read
drop policy if exists "Read own or match team participants" on public.match_participants;
create policy "Read own or match team participants" on public.match_participants
  for select using (
    player_id = auth.uid() or
    exists (
      select 1 from public.team_members tm
      where tm.team_id = match_participants.team_id
        and tm.player_id = auth.uid()
        and tm.is_active = true
    )
  );

-- Insert: captains/coaches of a team in the match or match creator can insert
drop policy if exists "Team captain can insert convocation" on public.match_participants;
create policy "Team captain can insert convocation" on public.match_participants
  for insert with check (
    exists (
      select 1 from public.team_members tm
      where tm.team_id = match_participants.team_id
        and tm.player_id = auth.uid()
        and tm.role in ('captain','coach')
        and tm.is_active = true
    )
    or exists (
      select 1 from public.matches m
      where m.id = match_participants.match_id and m.created_by = auth.uid()
    )
  );

-- Update: the player themself can update their status; captains/coaches can also manage
drop policy if exists "Players or captains can update" on public.match_participants;
create policy "Players or captains can update" on public.match_participants
  for update using (
    player_id = auth.uid() or
    exists (
      select 1 from public.team_members tm
      where tm.team_id = match_participants.team_id
        and tm.player_id = auth.uid()
        and tm.role in ('captain','coach')
        and tm.is_active = true
    )
  ) with check (
    player_id = auth.uid() or
    exists (
      select 1 from public.team_members tm
      where tm.team_id = match_participants.team_id
        and tm.player_id = auth.uid()
        and tm.role in ('captain','coach')
        and tm.is_active = true
    )
  );

-- Optional: publish to realtime
do $$
begin
  if not exists (
    select 1 from pg_publication where pubname = 'supabase_realtime'
  ) then
    execute 'create publication supabase_realtime';
  end if;
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'match_participants'
  ) then
    execute 'alter publication supabase_realtime add table public.match_participants';
  end if;
end $$;

do $$ begin execute 'alter table public.match_participants replica identity full'; exception when others then null; end $$;
