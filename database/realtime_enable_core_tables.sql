-- Ensure core tables are published to Realtime and configured for rich payloads
-- Safe to run multiple times

do $$
begin
  -- Make sure the publication exists
  if not exists (
    select 1 from pg_publication where pubname = 'supabase_realtime'
  ) then
    execute 'create publication supabase_realtime';
  end if;

  -- Helper to add a table to publication if missing
  perform 1;
end $$;

-- Add tables to publication if not already present
-- matches (core)
do $$
begin
  if exists (
    select 1 from information_schema.tables
    where table_schema = 'public' and table_name = 'matches'
  ) then
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'matches'
    ) then
      execute 'alter publication supabase_realtime add table public.matches';
    end if;
  end if;
end $$;

-- match_events (timeline / goles, tarjetas, etc.)
do $$
begin
  if exists (
    select 1 from information_schema.tables
    where table_schema = 'public' and table_name = 'match_events'
  ) then
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'match_events'
    ) then
      execute 'alter publication supabase_realtime add table public.match_events';
    end if;
  end if;
end $$;

-- public_matches (partidos públicos)
do $$
begin
  if exists (
    select 1 from information_schema.tables
    where table_schema = 'public' and table_name = 'public_matches'
  ) then
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'public_matches'
    ) then
      execute 'alter publication supabase_realtime add table public.public_matches';
    end if;
  end if;
end $$;

-- match_applications (postulaciones a partidos públicos)
do $$
begin
  if exists (
    select 1 from information_schema.tables
    where table_schema = 'public' and table_name = 'match_applications'
  ) then
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'match_applications'
    ) then
      execute 'alter publication supabase_realtime add table public.match_applications';
    end if;
  end if;
end $$;
-- messages
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'messages'
  ) then
    execute 'alter publication supabase_realtime add table public.messages';
  end if;
end $$;

-- last_seen_chat
do $$
begin
  if exists (
    select 1 from information_schema.tables
    where table_schema = 'public' and table_name = 'last_seen_chat'
  ) then
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'last_seen_chat'
    ) then
      execute 'alter publication supabase_realtime add table public.last_seen_chat';
    end if;
  end if;
end $$;

-- team_invitations
do $$
begin
  if exists (
    select 1 from information_schema.tables
    where table_schema = 'public' and table_name = 'team_invitations'
  ) then
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'team_invitations'
    ) then
      execute 'alter publication supabase_realtime add table public.team_invitations';
    end if;
  end if;
end $$;

-- friendships
do $$
begin
  if exists (
    select 1 from information_schema.tables
    where table_schema = 'public' and table_name = 'friendships'
  ) then
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'friendships'
    ) then
      execute 'alter publication supabase_realtime add table public.friendships';
    end if;
  end if;
end $$;

-- team_members
do $$
begin
  if exists (
    select 1 from information_schema.tables
    where table_schema = 'public' and table_name = 'team_members'
  ) then
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'team_members'
    ) then
      execute 'alter publication supabase_realtime add table public.team_members';
    end if;
  end if;
end $$;

-- teams
do $$
begin
  if exists (
    select 1 from information_schema.tables
    where table_schema = 'public' and table_name = 'teams'
  ) then
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'teams'
    ) then
      execute 'alter publication supabase_realtime add table public.teams';
    end if;
  end if;
end $$;

-- notifications
do $$
begin
  if exists (
    select 1 from information_schema.tables
    where table_schema = 'public' and table_name = 'notifications'
  ) then
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'notifications'
    ) then
      execute 'alter publication supabase_realtime add table public.notifications';
    end if;
  end if;
end $$;

-- profiles (for theme_prefs and other profile updates)
do $$
begin
  if exists (
    select 1 from information_schema.tables
    where table_schema = 'public' and table_name = 'profiles'
  ) then
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'profiles'
    ) then
      execute 'alter publication supabase_realtime add table public.profiles';
    end if;
  end if;
end $$;

-- Set REPLICA IDENTITY FULL so update/delete events carry oldRecord payloads (useful for filtering)
-- It is harmless to set this repeatedly.
-- matches
do $$ begin execute 'alter table public.matches replica identity full'; exception when others then null; end $$;
-- match_events
do $$ begin execute 'alter table public.match_events replica identity full'; exception when others then null; end $$;
-- public_matches
do $$ begin execute 'alter table public.public_matches replica identity full'; exception when others then null; end $$;
-- match_applications
do $$ begin execute 'alter table public.match_applications replica identity full'; exception when others then null; end $$;
-- messages
do $$ begin execute 'alter table public.messages replica identity full'; exception when others then null; end $$;
-- last_seen_chat
do $$ begin execute 'alter table public.last_seen_chat replica identity full'; exception when others then null; end $$;
-- team_invitations
do $$ begin execute 'alter table public.team_invitations replica identity full'; exception when others then null; end $$;
-- friendships
do $$ begin execute 'alter table public.friendships replica identity full'; exception when others then null; end $$;
-- notifications
do $$ begin execute 'alter table public.notifications replica identity full'; exception when others then null; end $$;
-- team_members
do $$ begin execute 'alter table public.team_members replica identity full'; exception when others then null; end $$;
-- teams
do $$ begin execute 'alter table public.teams replica identity full'; exception when others then null; end $$;
-- profiles
do $$ begin execute 'alter table public.profiles replica identity full'; exception when others then null; end $$;
