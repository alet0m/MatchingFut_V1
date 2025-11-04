-- Team Chat schema for Supabase (public schema)
-- Safe to run multiple times; avoids IF NOT EXISTS on policies by drop+create pattern.

-- Extensions
create extension if not exists pgcrypto;

-- Tables
create table if not exists public.teams (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.team_members (
  team_id uuid references public.teams(id) on delete cascade,
  player_id uuid not null,
  role text check (role in ('owner','admin','member')) not null default 'member',
  joined_at timestamptz not null default now(),
  primary key (team_id, player_id)
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  team_id uuid references public.teams(id) on delete cascade,
  user_id uuid not null,
  content text not null check (length(trim(content)) > 0 and length(content) <= 1000),
  created_at timestamptz not null default now(),
  edited_at timestamptz
);

create index if not exists messages_team_created_desc on public.messages (team_id, created_at desc);

-- Helpful index for rate-limit query (team_id + user_id + created_at)
create index if not exists messages_team_user_created on public.messages (team_id, user_id, created_at desc);

-- Optional: stabilize pagination when multiple messages share the same timestamp
create index if not exists messages_team_created_id on public.messages (team_id, created_at desc, id);

-- NOTE: Ensure Realtime publication includes messages (run once in SQL editor if needed)
-- alter publication supabase_realtime add table public.messages;

-- RLS
alter table public.teams enable row level security;
alter table public.team_members enable row level security;
alter table public.messages enable row level security;

-- Policies (drop+create to ensure idempotency)
-- IMPORTANT: We DO NOT override teams or team_members policies here to avoid
-- recursion and conflicts with the main app RLS. We'll only manage messages policies.

-- Cleanup any chat-specific policies that might have been created before
drop policy if exists teams_select_members on public.teams;
drop policy if exists teams_update_admins on public.teams;

-- Remove potentially recursive policies on team_members created by this module
drop policy if exists team_members_select_members on public.team_members;
drop policy if exists team_members_insert_admins on public.team_members;

-- Messages: only members can select/insert
drop policy if exists messages_select_team_members on public.messages;
create policy messages_select_team_members on public.messages for select
using (exists (
  select 1 from public.team_members tm where tm.team_id = team_id and tm.player_id = auth.uid()
));

drop policy if exists messages_insert_team_members on public.messages;
create policy messages_insert_team_members on public.messages for insert
with check (exists (
  select 1 from public.team_members tm where tm.team_id = team_id and tm.player_id = auth.uid()
));

-- Messages: update/delete policies
drop policy if exists messages_update_owner on public.messages;
create policy messages_update_owner on public.messages for update
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists messages_delete_owner_or_admin on public.messages;
create policy messages_delete_owner_or_admin on public.messages for delete
using (
  user_id = auth.uid()
  or exists (
    select 1 from public.team_members tm
    where tm.team_id = messages.team_id
      and tm.player_id = auth.uid()
      and tm.role in ('owner','admin')
  )
);

-- Trigger to set edited_at on content changes
create or replace function public.messages_set_edited_at()
returns trigger
language plpgsql
as $$
begin
  if TG_OP = 'UPDATE' then
    if new.content is distinct from old.content then
      new.edited_at = now();
    end if;
  end if;
  return new;
end; $$;

drop trigger if exists trg_messages_set_edited_at on public.messages;
create trigger trg_messages_set_edited_at
before update on public.messages
for each row
execute function public.messages_set_edited_at();

-- RPC: send_team_message with rate-limit and banned words
create or replace function public.send_team_message(p_team uuid, p_content text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  new_id uuid := gen_random_uuid();
  banned text[] := array['spam','insulto1','insulto2'];
  recent_count int;
begin
  -- Must be team member
  if not exists (select 1 from public.team_members where team_id = p_team and player_id = auth.uid()) then
    raise exception 'not a team member';
  end if;

  -- Content validation
  if p_content is null or length(trim(p_content)) = 0 or length(p_content) > 1000 then
    raise exception 'invalid content';
  end if;

  -- Banned words filter
  if exists (select 1 from unnest(banned) b where position(lower(b) in lower(p_content)) > 0) then
    raise exception 'banned content';
  end if;

  -- Rate limit: 5 messages in 10 seconds
  select count(*) into recent_count
  from public.messages
  where team_id = p_team and user_id = auth.uid()
    and created_at >= now() - interval '10 seconds';

  if recent_count >= 5 then
    raise exception 'rate limited';
  end if;

  insert into public.messages(id, team_id, user_id, content)
  values (new_id, p_team, auth.uid(), p_content);

  return new_id;
end $$;

comment on function public.send_team_message is 'Insert message validating membership, content, banned words and rate limiting';
