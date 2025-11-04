-- Fix RLS for PostGIS metadata table to satisfy Security Advisor and keep app stable
-- Run this in Supabase SQL Editor once.

BEGIN;

-- 1) Enable and enforce RLS on spatial_ref_sys
ALTER TABLE IF EXISTS public.spatial_ref_sys ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.spatial_ref_sys FORCE ROW LEVEL SECURITY;

-- 2) Ensure read-only access is allowed for anon/auth (safe: contains SRID definitions)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' 
      AND tablename = 'spatial_ref_sys' 
      AND policyname = 'allow_select_spatial_ref_sys'
  ) THEN
    CREATE POLICY allow_select_spatial_ref_sys
      ON public.spatial_ref_sys
      FOR SELECT
      TO authenticated, anon
      USING (true);
  END IF;
END $$;

-- 3) (Optional) Ensure SELECT privilege exists (RLS + GRANT are both required)
GRANT SELECT ON TABLE public.spatial_ref_sys TO authenticated, anon;

-- 4) Reload PostgREST schema cache
NOTIFY pgrst, 'reload schema';

COMMIT;

-- Notes:
-- - We only allow SELECT. No policies exist for INSERT/UPDATE/DELETE, so those are denied.
-- - If you prefer to fully hide this table from API, remove the SELECT policy and revoke grants, but
--   some PostGIS functions might then fail for auth roles if they require reading spatial_ref_sys.
--   The current approach is both safe and eliminates the Security Advisor warning.
