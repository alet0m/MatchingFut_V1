-- Creates a normalized view of accepted friends for the current user
-- Uses auth.uid() so it always returns friends of the requesting user

drop view if exists public.user_friends cascade;
create or replace view public.user_friends as
select
  case when f.requester_id = auth.uid() then f.receiver_id else f.requester_id end as friend_user_id,
  p.email,
  p.full_name,
  'accepted'::text as status,
  f.created_at as friendship_date,
  f.accepted_at as accepted_at,
  false as is_online
from public.friendships f
join public.profiles p
  on p.id = case when f.requester_id = auth.uid() then f.receiver_id else f.requester_id end
where f.status = 'accepted'
  and (f.requester_id = auth.uid() or f.receiver_id = auth.uid());

-- Note:
-- RLS is enforced on underlying tables (friendships, profiles).
-- Ensure policies allow SELECT where (user_id = auth.uid() or friend_id = auth.uid()).
