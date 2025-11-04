-- Backfill profiles.full_name from auth.users metadata (safe to re-run)
-- Purpose: ensure blocked/report lists can show real names

-- Prefer raw_user_meta_data full_name/name; fallback to email
update public.profiles p
set full_name = coalesce(
  nullif(trim(p.full_name), ''),
  nullif(trim(au.raw_user_meta_data->>'full_name'), ''),
  nullif(trim(au.raw_user_meta_data->>'name'), ''),
  nullif(trim(au.raw_user_meta_data->>'username'), ''),
  nullif(trim(au.raw_user_meta_data->>'user_name'), ''),
  au.email
)
from auth.users au
where p.id = au.id
  and (p.full_name is null or trim(p.full_name) = '');

-- Optional: if you also store profile_image_url and it's empty, try to backfill from metadata
-- Uncomment if desired
-- update public.profiles p
-- set profile_image_url = coalesce(
--   nullif(trim(p.profile_image_url), ''),
--   nullif(trim(au.raw_user_meta_data->>'avatar_url'), ''),
--   nullif(trim(au.raw_user_meta_data->>'picture'), '')
-- )
-- from auth.users au
-- where p.id = au.id
--   and (p.profile_image_url is null or trim(p.profile_image_url) = '');
