-- Some databases use profile_image_url, others profile_picture_url, and some have neither.
-- Choose the right insert shape based on existing columns.

do $$
begin
       if exists (
              select 1 from information_schema.columns
              where table_schema = 'public' and table_name = 'profiles' and column_name = 'profile_image_url'
       ) then
              insert into public.profiles (id, email, full_name, profile_image_url)
              select au.id,
                                    au.email,
                                    coalesce(nullif(trim(au.raw_user_meta_data->>'full_name'), ''),
                                                                      nullif(trim(au.raw_user_meta_data->>'name'), ''),
                                                                      au.email) as full_name,
                                    null as profile_image_url
              from auth.users au
              left join public.profiles p on p.id = au.id
              where p.id is null;
       elsif exists (
              select 1 from information_schema.columns
              where table_schema = 'public' and table_name = 'profiles' and column_name = 'profile_picture_url'
       ) then
              insert into public.profiles (id, email, full_name, profile_picture_url)
              select au.id,
                                    au.email,
                                    coalesce(nullif(trim(au.raw_user_meta_data->>'full_name'), ''),
                                                                      nullif(trim(au.raw_user_meta_data->>'name'), ''),
                                                                      au.email) as full_name,
                                    null as profile_picture_url
              from auth.users au
              left join public.profiles p on p.id = au.id
              where p.id is null;
       else
              insert into public.profiles (id, email, full_name)
              select au.id,
                                    au.email,
                                    coalesce(nullif(trim(au.raw_user_meta_data->>'full_name'), ''),
                                                                      nullif(trim(au.raw_user_meta_data->>'name'), ''),
                                                                      au.email) as full_name
              from auth.users au
              left join public.profiles p on p.id = au.id
              where p.id is null;
       end if;
end
$$;
