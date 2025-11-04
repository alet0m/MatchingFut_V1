-- Seed basic sectors for Quilicura (idempotent)
-- Requires sectors_table_setup.sql executed first

-- Ensure comunas has Quilicura and capture its UUID
with upsert_comuna as (
	insert into public.comunas (id, name, code, is_active)
	values (gen_random_uuid(), 'Quilicura', 'quilicura', true)
	on conflict (code) do update set name = excluded.name, is_active = excluded.is_active
	returning id
), c as (
	select id from upsert_comuna
	union all
	select id from public.comunas where code = 'quilicura' limit 1
)
insert into public.sectors (name, comuna_id, description, geojson, center_lat, center_lng, bounds, is_active)
select * from (
	values
		(
			'Centro Quilicura',
			(select id from c),
			'Zona céntrica de Quilicura (demo)',
			'{
				"type": "Polygon",
				"coordinates": [[
					[-70.7460, -33.3670],
					[-70.7360, -33.3670],
					[-70.7360, -33.3570],
					[-70.7460, -33.3570],
					[-70.7460, -33.3670]
				]]
			}'::jsonb,
			-33.362000,
			-70.741000,
			'{"sw": {"lat": -33.3670, "lng": -70.7460}, "ne": {"lat": -33.3570, "lng": -70.7360}}'::jsonb,
			true
		),
		(
			'Valle Lo Campino',
			(select id from c),
			'Área residencial Valle Lo Campino (demo)',
			'{
				"type": "Polygon",
				"coordinates": [[
					[-70.7355, -33.3550],
					[-70.7255, -33.3550],
					[-70.7255, -33.3450],
					[-70.7355, -33.3450],
					[-70.7355, -33.3550]
				]]
			}'::jsonb,
			-33.350000,
			-70.730500,
			'{"sw": {"lat": -33.3550, "lng": -70.7355}, "ne": {"lat": -33.3450, "lng": -70.7255}}'::jsonb,
			true
		)
) as v(name, comuna_id, description, geojson, center_lat, center_lng, bounds, is_active)
on conflict (comuna_id, name) do update set
	description = excluded.description,
	geojson = excluded.geojson,
	center_lat = excluded.center_lat,
	center_lng = excluded.center_lng,
	bounds = excluded.bounds,
	is_active = excluded.is_active,
	updated_at = now();

