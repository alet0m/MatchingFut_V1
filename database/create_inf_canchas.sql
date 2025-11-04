-- Crea una tabla de información de canchas con nombre de región y comuna
-- Idempotente: crea la tabla si no existe y realiza un upsert inicial de datos

BEGIN;

-- 1) Tabla destino
CREATE TABLE IF NOT EXISTS public.inf_canchas (
  cancha_id uuid PRIMARY KEY REFERENCES public.canchas(id) ON DELETE CASCADE,
  cancha_nombre text NOT NULL,
  region_cancha text,
  comuna_cancha text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- 2) Índices útiles para búsqueda
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relname = 'idx_inf_canchas_nombre' AND n.nspname = 'public'
  ) THEN
    CREATE INDEX idx_inf_canchas_nombre ON public.inf_canchas USING gin (cancha_nombre gin_trgm_ops);
  END IF;
EXCEPTION WHEN undefined_object THEN
  -- Si no está instalada la extensión pg_trgm, crear un índice btree simple
  IF NOT EXISTS (
    SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relname = 'idx_inf_canchas_nombre_btree' AND n.nspname = 'public'
  ) THEN
    CREATE INDEX idx_inf_canchas_nombre_btree ON public.inf_canchas (cancha_nombre);
  END IF;
END$$;

-- 3) Función de refresco: repuebla desde canchas + comunas + regions
CREATE OR REPLACE FUNCTION public.refresh_inf_canchas()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  -- Estrategia simple: upsert fila por fila desde la consulta base
  INSERT INTO public.inf_canchas (cancha_id, cancha_nombre, region_cancha, comuna_cancha)
  SELECT
    c.id AS cancha_id,
    c.name AS cancha_nombre,
    r.name AS region_cancha,
    co.name AS comuna_cancha
  FROM public.canchas c
  LEFT JOIN public.comunas co ON co.id = c.comuna_id
  LEFT JOIN public.regions r ON r.id = co.region_id
  ON CONFLICT (cancha_id) DO UPDATE SET
    cancha_nombre = EXCLUDED.cancha_nombre,
    region_cancha = EXCLUDED.region_cancha,
    comuna_cancha = EXCLUDED.comuna_cancha,
    updated_at = now();
END;
$$;

-- 4) Refresco inicial de datos
SELECT public.refresh_inf_canchas();

COMMIT;
