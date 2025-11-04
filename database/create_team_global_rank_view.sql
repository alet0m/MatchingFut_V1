-- Creates or replaces a view exposing each team's global rank by ELO.
-- Safe to run multiple times.

create or replace view public.team_global_rank as
select
  t.id,
  t.name,
  t.elo_rating,
  rank() over (
    order by t.elo_rating desc, coalesce(t.updated_at, t.created_at) desc, t.id
  ) as rank,
  count(*) over () as total_teams
from public.teams t
where t.elo_rating is not null and coalesce(t.is_active, true) = true;

-- Optional: allow reads for anon/authenticated (RLS on base tables may still apply)
do $$
begin
  execute 'grant select on public.team_global_rank to anon';
  execute 'grant select on public.team_global_rank to authenticated';
exception when others then
  null;
end $$;
