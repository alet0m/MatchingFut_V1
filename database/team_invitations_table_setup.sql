-- Team invitations table setup
-- Requires pgcrypto for gen_random_uuid
create extension if not exists pgcrypto;

create table if not exists public.team_invitations (
  id uuid primary key default gen_random_uuid(),
  team_id uuid not null references public.teams(id) on delete cascade,
  inviter_user_id uuid not null references public.profiles(id) on delete cascade,
  invited_user_id uuid not null references public.profiles(id) on delete cascade,
  status text not null default 'pending' check (status in ('pending','accepted','rejected','expired','cancelled')),
  created_at timestamp with time zone not null default now(),
  responded_at timestamp with time zone
);

-- Safeguards for existing databases where the table existed without columns
-- Add missing columns (nullable to avoid failing on existing rows)
alter table public.team_invitations
  add column if not exists inviter_user_id uuid references public.profiles(id) on delete cascade;
alter table public.team_invitations
  add column if not exists invited_user_id uuid references public.profiles(id) on delete cascade;

-- If an older column name was used, rename it to the expected one
do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'team_invitations' and column_name = 'invitee_user_id'
  ) and not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'team_invitations' and column_name = 'invited_user_id'
  ) then
    execute 'alter table public.team_invitations rename column invitee_user_id to invited_user_id';
  end if;
end $$;

-- Avoid duplicate pending invitations
create unique index if not exists team_invitations_unique_pending
  on public.team_invitations(team_id, invited_user_id)
  where status = 'pending';

alter table public.team_invitations enable row level security;

-- Select policies
drop policy if exists team_invitations_invited_select on public.team_invitations;
create policy team_invitations_invited_select on public.team_invitations
  for select
  using (invited_user_id = auth.uid());

drop policy if exists team_invitations_captain_select on public.team_invitations;
create policy team_invitations_captain_select on public.team_invitations
  for select
  using (exists (
    select 1 from public.teams t
    where t.id = team_id and t.captain_id = auth.uid()
  ));

-- Insert policy: only captains can invite
drop policy if exists team_invitations_captain_insert on public.team_invitations;
create policy team_invitations_captain_insert on public.team_invitations
  for insert
  with check (exists (
    select 1 from public.teams t
    where t.id = team_id and t.captain_id = auth.uid()
  ));

-- Update policy: invited user can respond to their invitations
drop policy if exists team_invitations_invited_update on public.team_invitations;
create policy team_invitations_invited_update on public.team_invitations
  for update
  using (invited_user_id = auth.uid())
  with check (invited_user_id = auth.uid());

-- Delete policy: captains may cancel invitations of their team
drop policy if exists team_invitations_captain_delete on public.team_invitations;
create policy team_invitations_captain_delete on public.team_invitations
  for delete
  using (exists (
    select 1 from public.teams t
    where t.id = team_id and t.captain_id = auth.uid()
  ));

-- Optional: when an invitation is accepted, add the member
-- Use a trigger if you want automatic membership creation upon acceptance
-- Here we keep it manual from the API/service to retain control.
