-- User Safety Setup: Blocks and Reports

-- Create user_blocks table
create table if not exists public.user_blocks (
  id uuid primary key default gen_random_uuid(),
  blocker_id uuid not null references public.profiles(id) on delete cascade,
  blocked_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamp with time zone not null default now(),
  constraint user_blocks_unique unique (blocker_id, blocked_id),
  constraint user_blocks_no_self check (blocker_id <> blocked_id)
);

alter table public.user_blocks enable row level security;

-- Policies: blocker can insert/select/delete their own records
drop policy if exists user_blocks_insert_self on public.user_blocks;
create policy user_blocks_insert_self
on public.user_blocks for insert
to authenticated
with check (auth.uid() = blocker_id);

drop policy if exists user_blocks_select_own on public.user_blocks;
create policy user_blocks_select_own
on public.user_blocks for select
to authenticated
using (auth.uid() = blocker_id or auth.uid() = blocked_id);

drop policy if exists user_blocks_delete_self on public.user_blocks;
create policy user_blocks_delete_self
on public.user_blocks for delete
to authenticated
using (auth.uid() = blocker_id);

-- Indexes
create index if not exists idx_user_blocks_blocker on public.user_blocks(blocker_id);
create index if not exists idx_user_blocks_blocked on public.user_blocks(blocked_id);

-- Create user_reports table
create table if not exists public.user_reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.profiles(id) on delete cascade,
  reported_id uuid not null references public.profiles(id) on delete cascade,
  category text not null check (category in (
    'spam','acoso','contenido_inapropiado','suplantacion','trampa','otro'
  )),
  details text,
  created_at timestamp with time zone not null default now(),
  constraint user_reports_no_self check (reporter_id <> reported_id)
);

alter table public.user_reports enable row level security;

-- Policies: reporter can insert; reporter can view own reports; admins can manage via separate role
drop policy if exists user_reports_insert_self on public.user_reports;
create policy user_reports_insert_self
on public.user_reports for insert
to authenticated
with check (auth.uid() = reporter_id);

drop policy if exists user_reports_select_own on public.user_reports;
create policy user_reports_select_own
on public.user_reports for select
to authenticated
using (auth.uid() = reporter_id);

-- Indexes
create index if not exists idx_user_reports_reporter on public.user_reports(reporter_id);
create index if not exists idx_user_reports_reported on public.user_reports(reported_id);

-- Optional: Deny public access explicitly (Supabase default grants may vary)
revoke all on public.user_blocks from anon;
revoke all on public.user_reports from anon;
