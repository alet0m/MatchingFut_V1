-- Optional: add kit color columns to matches (safe to run multiple times)
alter table public.matches add column if not exists home_kit_color text;
alter table public.matches add column if not exists away_kit_color text;
