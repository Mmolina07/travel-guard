-- HU "Gestionar promociones Premium": cada actividad puede ser para todo
-- el público o solo para turistas Premium. Las promociones (categoría
-- 'Promoción') son siempre exclusivas Premium.
--
-- Cambio aditivo: la columna nueva tiene valor por defecto, así que la
-- app que ya estaba desplegada sigue funcionando igual.

BEGIN;

ALTER TABLE actividades
  ADD COLUMN IF NOT EXISTS solo_premium BOOLEAN NOT NULL DEFAULT FALSE;

-- Las promociones existentes ya eran solo para Premium (HU-24).
UPDATE actividades SET solo_premium = TRUE WHERE categoria = 'Promoción';

CREATE INDEX IF NOT EXISTS idx_actividades_publicas
  ON actividades (activo, solo_premium);

COMMIT;
