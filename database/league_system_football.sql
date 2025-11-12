-- Football-themed league system
-- Safe, idempotent setup for tiers + mapping + backfill + triggers

-- 1) Canonical tiers table (adapt to legacy schema). If not exists, create legacy-compatible structure.
create table if not exists public.league_tiers (
  id integer generated always as identity primary key,
  code text not null unique,
  name text not null,
  min_points integer not null,
  max_points integer not null,
  order_index integer not null
);

-- 1b) Migration guard: if table exists without expected columns, add them and ensure unique slug
do $$
begin
  -- Ensure columns exist when table pre-existed with a different schema
  if exists (
    select 1 from information_schema.tables
    where table_schema = 'public' and table_name = 'league_tiers'
  ) then
    -- Add missing columns
    alter table public.league_tiers
      add column if not exists slug text,
      add column if not exists display_name text,
      add column if not exists emoji text,
      add column if not exists sort_order integer;

    -- Ensure legacy NOT NULL max_points can represent "unlimited" using a large sentinel if needed
    -- (Optional) Allow NULL for max_points to support open-ended top tier
    begin
      alter table public.league_tiers alter column max_points drop not null;
    exception when others then null; end;

    -- Backfill slug from display_name or name if available
    if exists (
      select 1 from information_schema.columns
      where table_schema='public' and table_name='league_tiers' and column_name='slug'
    ) then
      if exists (
        select 1 from information_schema.columns
        where table_schema='public' and table_name='league_tiers' and column_name='display_name'
      ) then
        update public.league_tiers
           set slug = coalesce(slug, lower(regexp_replace(display_name, '[^a-z0-9]+','_', 'g')))
         where slug is null;
      elsif exists (
        select 1 from information_schema.columns
        where table_schema='public' and table_name='league_tiers' and column_name='name'
      ) then
        update public.league_tiers
           set slug = coalesce(slug, lower(regexp_replace(name, '[^a-z0-9]+','_', 'g')))
         where slug is null;
      end if;
    end if;

    -- Backfill new columns from legacy ones
    update public.league_tiers
       set display_name = coalesce(display_name, name),
           slug = coalesce(slug, lower(regexp_replace(coalesce(code,name), '[^a-z0-9]+','_', 'g'))),
           sort_order = coalesce(sort_order, order_index),
           emoji = coalesce(emoji, '')
     where true;

    -- Ensure unique index on slug for upsert compatibility
    if not exists (
      select 1 from pg_indexes where schemaname='public' and tablename='league_tiers' and indexname='league_tiers_slug_idx'
    ) then
      create unique index league_tiers_slug_idx on public.league_tiers(slug);
    end if;
  end if;
end$$;

-- 2) Seed / Upsert football-themed tiers using legacy + new columns
-- Use large sentinel 999999 if max_points cannot be null
insert into public.league_tiers as lt (code, name, min_points, max_points, order_index, slug, display_name, emoji, sort_order)
values
  ('pichanga',      'Pichanga',       0,     149,    10, 'pichanga',      'Pichanga',       '\uD83E\uDDBE',   10),
  ('barrio',        'Liga de Barrio', 150,   299,    20, 'barrio',        'Liga de Barrio', '\uD83C\uDFE1',   20),
  ('interbarrio',   'Interbarrio',    300,   449,    30, 'interbarrio',   'Interbarrio',    '\uD83E\uDD1D',   30),
  ('comunal',       'Comunal',        450,   599,    40, 'comunal',       'Comunal',        '\uD83C\uDFD9\uFE0F', 40),
  ('regional',      'Regional',       600,   749,    50, 'regional',      'Regional',       '\uD83C\uDF0D',   50),
  ('nacional',      'Nacional',       750,   899,    60, 'nacional',      'Nacional',       '\uD83C\uDFC6',   60),
  ('primera_b',     'Primera B',      900,   1049,   70, 'primera_b',     'Primera B',      '\u26AA\uFE0F',   70),
  ('primera_a',     'Primera A',      1050,  1199,   80, 'primera_a',     'Primera A',      '\u2B50\uFE0F',   80),
  ('libertadores',  'Libertadores',   1200,  999999, 90, 'libertadores',  'Libertadores',   '\uD83C\uDFC6',   90)
on conflict (code) do update
set name        = excluded.name,
    min_points  = excluded.min_points,
    max_points  = excluded.max_points,
    order_index = excluded.order_index,
    slug        = excluded.slug,
    display_name= excluded.display_name,
    emoji       = excluded.emoji,
    sort_order  = excluded.sort_order;

-- 3) Helper: resolve tier slug from points
create or replace function public.resolve_league_slug(points integer)
returns text
language sql
stable
as $$
  select slug
  from public.league_tiers
  where points >= min_points
    and (max_points is null or points <= max_points)
  order by sort_order desc
  limit 1;
$$;

-- 4) Ensure columns exist in players/teams
alter table if exists public.players
  add column if not exists league_points integer not null default 100,
  add column if not exists league_tier   text     not null default 'pichanga';

alter table if exists public.teams
  add column if not exists league_points integer not null default 100,
  add column if not exists league_tier   text     not null default 'pichanga';

-- 5) Backfill existing rows safely
update public.players
   set league_points = coalesce(league_points, 100)
 where league_points is null;

update public.teams
   set league_points = coalesce(league_points, 100)
 where league_points is null;

update public.players
   set league_tier = public.resolve_league_slug(league_points)
 where true;

update public.teams
   set league_tier = public.resolve_league_slug(league_points)
 where true;

-- 6) Recalc helpers (manual maintenance)
create or replace function public.recalculate_all_league_tiers()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.players
     set league_tier = public.resolve_league_slug(league_points);
  update public.teams
     set league_tier = public.resolve_league_slug(league_points);
end;
$$;

-- 7) Triggers to keep tier in sync
create or replace function public.trg_set_team_league_tier()
returns trigger
language plpgsql
as $$
begin
  new.league_tier := public.resolve_league_slug(new.league_points);
  return new;
end;
$$;

create or replace function public.trg_set_player_league_tier()
returns trigger
language plpgsql
as $$
begin
  new.league_tier := public.resolve_league_slug(new.league_points);
  return new;
end;
$$;

-- Drop existing triggers if any to ensure idempotency
drop trigger if exists set_team_league_tier on public.teams;
drop trigger if exists set_player_league_tier on public.players;

create trigger set_team_league_tier
before insert or update of league_points on public.teams
for each row execute function public.trg_set_team_league_tier();

create trigger set_player_league_tier
before insert or update of league_points on public.players
for each row execute function public.trg_set_player_league_tier();

-- 8) Optional view for UI convenience
create or replace view public.v_league_tiers_ordered as
  select slug, display_name, emoji, min_points, max_points,
         sort_order, code, name, order_index
  from public.league_tiers
  order by sort_order;

-- 9) Grants (adjust role names to your project if needed)
-- Supabase common roles: anon, authenticated, service_role (implicit)
grant select on public.league_tiers to anon, authenticated;
grant select on public.v_league_tiers_ordered to anon, authenticated;
-- Do not grant DML on tiers to anon/authenticated; keep as admin-only
