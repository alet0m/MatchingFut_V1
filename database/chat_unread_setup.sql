-- Unread chat support: per-user last seen and RPC helpers
-- Safe to run multiple times

create table if not exists public.last_seen_chat (
  user_id uuid not null references auth.users(id) on delete cascade,
  team_id uuid not null references public.teams(id) on delete cascade,
  last_seen_at timestamptz not null default now(),
  primary key (user_id, team_id)
);

alter table public.last_seen_chat enable row level security;

-- Policies: a user can manage only their own last_seen rows
drop policy if exists lsc_select_own on public.last_seen_chat;
create policy lsc_select_own on public.last_seen_chat
  for select using (auth.uid() = user_id);

drop policy if exists lsc_upsert_own on public.last_seen_chat;
create policy lsc_upsert_own on public.last_seen_chat
  for insert with check (auth.uid() = user_id);

-- Allow updates by owner
drop policy if exists lsc_update_own on public.last_seen_chat;
create policy lsc_update_own on public.last_seen_chat
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Helper RPC: set last seen to now for current user and team
create or replace function public.set_last_seen_chat(p_team uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not exists (
    select 1 from public.team_members tm
    where tm.team_id = p_team and tm.player_id = auth.uid()
  ) then
    raise exception 'not a team member';
  end if;

  insert into public.last_seen_chat(user_id, team_id, last_seen_at)
  values (auth.uid(), p_team, now())
  on conflict (user_id, team_id)
  do update set last_seen_at = excluded.last_seen_at;
end $$;

-- Helper RPC: get unread count across all teams for a user (messages total)
create or replace function public.get_unread_messages_count(p_user uuid)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  c integer;
begin
  select count(*) into c
  from public.messages m
  where m.user_id <> p_user
    and exists (
      select 1 from public.team_members tm
      where tm.team_id = m.team_id and tm.player_id = p_user
    )
    and m.created_at > coalesce(
      (
        select l.last_seen_at
        from public.last_seen_chat l
        where l.user_id = p_user and l.team_id = m.team_id
      ),
      to_timestamp(0)
    );
  return coalesce(c, 0);
end $$;

-- Helper RPC: get unread conversations count (distinct teams with unread messages)
create or replace function public.get_unread_conversations_count(p_user uuid)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  c integer;
begin
  select count(distinct m.team_id) into c
  from public.messages m
  where m.user_id <> p_user
    and exists (
      select 1 from public.team_members tm
      where tm.team_id = m.team_id and tm.player_id = p_user
    )
    and m.created_at > coalesce(
      (
        select l.last_seen_at
        from public.last_seen_chat l
        where l.user_id = p_user and l.team_id = m.team_id
      ),
      to_timestamp(0)
    );
  return coalesce(c, 0);
end $$;

-- Ensure last_seen_chat is part of the Realtime publication so badge updates on read marks
do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'last_seen_chat'
  ) then
    execute 'alter publication supabase_realtime add table public.last_seen_chat';
  end if;
end $$;

-- Helper RPC: get unread by team (team_id, unread)
create or replace function public.get_unread_by_team(p_user uuid)
returns table(team_id uuid, unread integer)
language sql
security definer
set search_path = public
as $$
  select m.team_id,
         count(*)::int as unread
  from public.messages m
  join public.team_members tm on tm.team_id = m.team_id and tm.player_id = p_user
  left join public.last_seen_chat l
    on l.user_id = p_user and l.team_id = m.team_id
  where m.user_id <> p_user
    and m.created_at > coalesce(l.last_seen_at, to_timestamp(0))
  group by m.team_id;
$$;
