-- Add a JSONB column to store per-user theme preferences.
-- Safe to run multiple times.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'theme_prefs'
  ) THEN
    ALTER TABLE public.profiles
      ADD COLUMN theme_prefs jsonb NOT NULL DEFAULT '{}';
  END IF;
END $$;

-- Optional: initialize theme_prefs with app defaults for existing rows if empty
UPDATE public.profiles
SET theme_prefs = jsonb_build_object(
  'seed', '#2E7D32',
  'accent', '#FF6F00',
  'mode', 'system',
  'style', 'default'
)
WHERE (theme_prefs IS NULL OR theme_prefs = '{}'::jsonb);
