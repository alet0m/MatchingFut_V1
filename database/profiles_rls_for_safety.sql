-- Profiles RLS policies needed for safety JOINs (blocked/report lists)
-- Safe to re-run: drops existing SELECT policies first and recreates permissive ones

-- Ensure RLS is enabled (no-op if already enabled)
alter table public.profiles enable row level security;

-- Ensure authenticated role has SELECT privilege (RLS will still control rows)
grant select on table public.profiles to authenticated;
-- Ensure authenticated role can INSERT/UPDATE (RLS will still control which rows)
grant insert, update on table public.profiles to authenticated;

-- Drop existing SELECT policies on public.profiles to avoid restrictive conflicts
do $$
declare r record;
begin
  for r in (
    select policyname from pg_policies
    where schemaname = 'public' and tablename = 'profiles' and cmd = 'SELECT'
  ) loop
    execute format('drop policy if exists %I on public.profiles', r.policyname);
  end loop;
end $$;

-- Allow users to INSERT their own profile row (needed for onboarding upsert)
drop policy if exists profiles_insert_own on public.profiles;
create policy profiles_insert_own
on public.profiles for insert
to authenticated
with check (auth.uid() = id);

-- Allow users to UPDATE their own profile row
drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own
on public.profiles for update
to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

-- Backend safety: ensure inserts set id from auth.uid() if client omitted it
create or replace function public.profiles_set_id_from_auth()
returns trigger
language plpgsql
as $$
begin
  if NEW.id is null then
    NEW.id := auth.uid();
  end if;
  return NEW;
end;
$$;

drop trigger if exists profiles_set_id_from_auth on public.profiles;
create trigger profiles_set_id_from_auth
before insert on public.profiles
for each row execute function public.profiles_set_id_from_auth();

-- View my own profile
create policy profiles_select_self
on public.profiles for select
to authenticated
using (auth.uid() = id);

-- View profiles that I have blocked (for blocked users list)
create policy profiles_select_blocked_by_me
on public.profiles for select
to authenticated
using (
  exists (
    select 1
    from public.user_blocks b
    where b.blocker_id = auth.uid()
      and b.blocked_id = profiles.id
  )
);

-- View profiles that I have reported (for "Tus reportes")
create policy profiles_select_reported_by_me
on public.profiles for select
to authenticated
using (
  exists (
    select 1
    from public.user_reports r
    where r.reporter_id = auth.uid()
      and r.reported_id = profiles.id
  )
);

-- View profiles for friends/pending context (friends lists and requests)
create policy profiles_select_friends_context
on public.profiles for select
to authenticated
using (
  exists (
    select 1
    from public.friendships f
    where (
      f.requester_id = auth.uid() and f.receiver_id = profiles.id
    ) or (
      f.receiver_id = auth.uid() and f.requester_id = profiles.id
    )
  )
);

-- General discovery/search: allow seeing other profiles unless blocked either direction
create policy profiles_select_discovery
on public.profiles for select
to authenticated
using (
  not exists (
    select 1
    from public.user_blocks b
    where (b.blocker_id = auth.uid() and b.blocked_id = profiles.id)
       or (b.blocker_id = profiles.id and b.blocked_id = auth.uid())
  )
);
