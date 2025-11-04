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

-- Set REPLICA IDENTITY FULL so update/delete events carry oldRecord payloads (useful for filtering)
-- It is harmless to set this repeatedly.
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
