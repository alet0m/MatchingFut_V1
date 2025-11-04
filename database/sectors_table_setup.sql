-- Sectors table setup for territorial maps (read-only MVP)
-- Idempotent and safe to re-run

-- Ensure UUID generator is available
create extension if not exists pgcrypto;

-- Base table (additive if already exists)
create table if not exists public.sectors (
	id uuid primary key default gen_random_uuid(),
	name text not null,
	comuna_id uuid not null,
	description text,
	-- GeoJSON geometry (Polygon or MultiPolygon)
	geojson jsonb,
	center_lat numeric(9,6),
	center_lng numeric(9,6),
	bounds jsonb,
	-- Future integration fields (nullable for now)
	current_champion_id uuid,
	total_matches integer not null default 0,
	is_active boolean not null default true,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now()
);

-- Add missing columns if the table existed with a smaller schema
alter table public.sectors
	add column if not exists description text,
	add column if not exists geojson jsonb,
	add column if not exists center_lat numeric(9,6),
	add column if not exists center_lng numeric(9,6),
	add column if not exists bounds jsonb,
	add column if not exists current_champion_id uuid,
	add column if not exists total_matches integer not null default 0,
	add column if not exists is_active boolean not null default true,
	add column if not exists created_at timestamptz not null default now(),
	add column if not exists updated_at timestamptz not null default now();

-- If comuna_id exists but with a different type, try to align to uuid (no-op if already uuid)
do $$
begin
	if exists (
		select 1 from information_schema.columns
		where table_schema='public' and table_name='sectors' and column_name='comuna_id' and data_type <> 'uuid'
	) then
		alter table public.sectors alter column comuna_id type uuid using comuna_id::uuid;
	end if;
exception when others then
	-- If cast fails due to non-uuid data, skip type change to avoid breaking existing data
	null;
end$$;

-- Helpful indexes
create index if not exists sectors_comuna_idx on public.sectors (comuna_id);
create index if not exists sectors_is_active_idx on public.sectors (is_active);
create index if not exists sectors_geojson_gin on public.sectors using gin (geojson);
create index if not exists sectors_bounds_gin on public.sectors using gin (bounds);
create unique index if not exists sectors_unique_name_comuna on public.sectors (comuna_id, name);

-- RLS: read-only for authenticated users
alter table public.sectors enable row level security;
grant select on table public.sectors to authenticated;

-- Clean up previous SELECT policies (idempotent)
drop policy if exists sectors_select_active on public.sectors;
drop policy if exists sectors_select_all on public.sectors;

-- Allow selecting active sectors
create policy sectors_select_active
on public.sectors for select
to authenticated
using (is_active);

-- Updated_at trigger
create or replace function public.set_updated_at()
returns trigger as $$
begin
	new.updated_at = now();
	return new;
end;
$$ language plpgsql;

drop trigger if exists set_updated_at on public.sectors;
create trigger set_updated_at
before update on public.sectors
for each row execute function public.set_updated_at();

