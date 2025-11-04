-- Notifications setup: device registry, events, and triggers (Supabase-first)

-- 1) Device registry table for push tokens
create table if not exists public.notification_devices (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  token text not null,
  platform text not null check (platform in ('android','ios','web','other')),
  is_active boolean not null default true,
  last_seen timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(user_id, token)
);

alter table public.notification_devices enable row level security;

-- Policies: each user manages their own devices
do $$
begin
  perform 1 from pg_policies where policyname = 'nd_select_own' and schemaname = 'public' and tablename = 'notification_devices';
  if not found then
    create policy nd_select_own on public.notification_devices
      for select using (auth.uid() = user_id);
  end if;
end $$;

do $$
begin
  perform 1 from pg_policies where policyname = 'nd_insert_self' and schemaname = 'public' and tablename = 'notification_devices';
  if not found then
    create policy nd_insert_self on public.notification_devices
      for insert with check (auth.uid() = user_id);
  end if;
end $$;

do $$
begin
  perform 1 from pg_policies where policyname = 'nd_update_own' and schemaname = 'public' and tablename = 'notification_devices';
  if not found then
    create policy nd_update_own on public.notification_devices
      for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
  end if;
end $$;

do $$
begin
  perform 1 from pg_policies where policyname = 'nd_delete_own' and schemaname = 'public' and tablename = 'notification_devices';
  if not found then
    create policy nd_delete_own on public.notification_devices
      for delete using (auth.uid() = user_id);
  end if;
end $$;

-- 2) Events table: internal queue for push notifications to be processed by an Edge Function
create table if not exists public.notification_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  type text not null, -- e.g. 'team_invitation', 'friend_request', 'friend_accepted'
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.notification_events enable row level security;

-- Allow only service role to read/process the queue; normal users cannot select
do $$
begin
  perform 1 from pg_policies where policyname = 'ne_insert_any' and schemaname = 'public' and tablename = 'notification_events';
  if not found then
    create policy ne_insert_any on public.notification_events for insert with check (true);
  end if;
end $$;

-- 3) Trigger functions to enqueue events
create or replace function public.enqueue_team_invitation_event()
returns trigger language plpgsql as $$
begin
  if new.status = 'pending' then
    insert into public.notification_events(user_id, type, payload)
    values (
      new.invited_user_id,
      'team_invitation',
      jsonb_build_object(
        'invitation_id', new.id,
        'team_id', new.team_id,
        'inviter_user_id', new.inviter_user_id
      )
    );
  end if;
  return new;
end; $$;

drop trigger if exists trg_enqueue_team_invitation on public.team_invitations;
create trigger trg_enqueue_team_invitation
after insert on public.team_invitations
for each row execute procedure public.enqueue_team_invitation_event();

create or replace function public.enqueue_friendship_insert_event()
returns trigger language plpgsql as $$
begin
  if new.status = 'pending' then
    insert into public.notification_events(user_id, type, payload)
    values (
      new.receiver_id,
      'friend_request',
      jsonb_build_object('requester_id', new.requester_id)
    );
  end if;
  return new;
end; $$;

drop trigger if exists trg_enqueue_friendship_insert on public.friendships;
create trigger trg_enqueue_friendship_insert
after insert on public.friendships
for each row execute procedure public.enqueue_friendship_insert_event();

create or replace function public.enqueue_friendship_update_event()
returns trigger language plpgsql as $$
begin
  if old.status = 'pending' and new.status <> 'pending' then
    -- Notificar a quien envió la solicitud que fue aceptada/rechazada
    insert into public.notification_events(user_id, type, payload)
    values (
      new.requester_id,
      case when new.status = 'accepted' then 'friend_accepted' else 'friend_rejected' end,
      jsonb_build_object('receiver_id', new.receiver_id)
    );
  end if;
  return new;
end; $$;

drop trigger if exists trg_enqueue_friendship_update on public.friendships;
create trigger trg_enqueue_friendship_update
after update on public.friendships
for each row execute procedure public.enqueue_friendship_update_event();

-- 4) Optional: grant minimal access
do $$
begin
  execute 'grant insert on public.notification_devices to authenticated';
  execute 'grant update, delete on public.notification_devices to authenticated';
  -- notification_events: solo insert por usuarios (triggers); lectura la hará el service role
  execute 'grant insert on public.notification_events to authenticated';
exception when others then
  null;
end $$;

-- Nota: una Edge Function (functions/send-push) debe leer notification_events con service_role
-- y enviar a FCM/APNs usando secretos (guardados en Supabase Secrets), luego borrar/archivar el evento.