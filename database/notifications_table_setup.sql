-- Notifications table setup (safe, idempotent) compatible with existing matches schema
-- This script only creates public.notifications + RLS + indexes and publishes it to Realtime.
-- It does NOT modify your existing public.matches columns.

-- Requirements
create extension if not exists pgcrypto;

-- Table
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  type text not null check (type in (
    'team_invitation','match_invitation','match_joined','match_confirmed','match_cancelled',
    'friend_request','match_reminder','system'
  )),
  match_id uuid references public.matches(id) on delete cascade,
  title text not null,
  message text not null,
  metadata jsonb not null default '{}'::jsonb,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

-- Indexes
create index if not exists idx_notifications_user_id on public.notifications(user_id);
create index if not exists idx_notifications_is_read on public.notifications(is_read);
create index if not exists idx_notifications_match_id on public.notifications(match_id);

-- RLS
alter table public.notifications enable row level security;

drop policy if exists "Users can view their own notifications" on public.notifications;
create policy "Users can view their own notifications" on public.notifications
  for select using (auth.uid() = user_id);

drop policy if exists "Users can update their own notifications" on public.notifications;
create policy "Users can update their own notifications" on public.notifications
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- If you create notifications from backend (Edge Functions/SQL), allow inserts broadly
-- Adjust if you only ever insert from privileged context
drop policy if exists "System can create notifications" on public.notifications;
create policy "System can create notifications" on public.notifications
  for insert with check (true);

-- Optional helper: mark all as read
create or replace function public.mark_all_notifications_read()
returns void
language sql
security definer
set search_path = public
as $$
  update public.notifications
  set is_read = true
  where user_id = auth.uid() and is_read = false;
$$;

-- Publish to Realtime
do $$
begin
  if not exists (
    select 1 from pg_publication where pubname = 'supabase_realtime'
  ) then
    execute 'create publication supabase_realtime';
  end if;

  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'notifications'
  ) then
    execute 'alter publication supabase_realtime add table public.notifications';
  end if;
end $$;

-- Ensure replica identity for rich update/delete payloads
do $$ begin execute 'alter table public.notifications replica identity full'; exception when others then null; end $$;
