-- Creates or replaces a view exposing each player's global rank by ELO.
-- Safe to run multiple times.

create or replace view public.player_global_rank as
select
  p.id,
  p.elo_rating,
  rank() over (
    order by p.elo_rating desc, coalesce(p.updated_at, p.created_at) desc, p.id
  ) as global_rank,
  count(*) over () as total_players
from public.players p
where p.elo_rating is not null;

-- Optional: allow reads for anon/authenticated (RLS on base tables may still apply)
do $$
begin
  execute 'grant select on public.player_global_rank to anon';
  execute 'grant select on public.player_global_rank to authenticated';
exception when others then
  -- ignore if roles don't exist in local env
  null;
end $$;

-- Tip: If RLS blocks reading players for viewers, add/select policies accordingly.
