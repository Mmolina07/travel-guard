-- HU-26: lista de pendientes del viaje (personal, por viaje y usuario).
--
-- - Un pendiente pertenece a un viaje y a un usuario: en viajes en grupo
--   (HU-16) cada integrante tiene su propia lista.
-- - `sugerencia_clave`: si el pendiente vino de una sugerencia de la app
--   (p. ej. 'doc_id', 'vuelo_checkin'), su clave. Así la sugerencia no se
--   repite y el título se muestra traducido. NULL = pendiente propio.
-- - `descartado`: sugerencia que el turista marcó como "no aplica"; no se
--   muestra en la lista ni vuelve a sugerirse.
--
-- Corre esto DESPUÉS de schema.sql (usa set_timestamp()). Se puede correr
-- más de una vez.

BEGIN;

CREATE TABLE IF NOT EXISTS viaje_pendientes (
  id                BIGSERIAL PRIMARY KEY,
  viaje_id          BIGINT NOT NULL REFERENCES viajes(id) ON DELETE CASCADE,
  usuario_id        BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  titulo            VARCHAR(120) NOT NULL,
  categoria         VARCHAR(20) NOT NULL DEFAULT 'otro',
  completado        BOOLEAN NOT NULL DEFAULT FALSE,
  completado_at     TIMESTAMPTZ,
  sugerencia_clave  VARCHAR(60),
  descartado        BOOLEAN NOT NULL DEFAULT FALSE,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT chk_viaje_pendientes_titulo CHECK (length(btrim(titulo)) > 0),
  CONSTRAINT chk_viaje_pendientes_categoria CHECK (categoria IN (
    'documentos', 'dinero', 'equipaje', 'salud', 'tecnologia', 'reservas', 'casa', 'otro'
  ))
);

DROP TRIGGER IF EXISTS trg_viaje_pendientes_updated_at ON viaje_pendientes;
CREATE TRIGGER trg_viaje_pendientes_updated_at BEFORE UPDATE ON viaje_pendientes
  FOR EACH ROW EXECUTE FUNCTION set_timestamp();

CREATE INDEX IF NOT EXISTS idx_viaje_pendientes_viaje_usuario
  ON viaje_pendientes (viaje_id, usuario_id);

-- Una sugerencia una sola vez por viaje y usuario.
CREATE UNIQUE INDEX IF NOT EXISTS uq_viaje_pendientes_sugerencia
  ON viaje_pendientes (viaje_id, usuario_id, sugerencia_clave)
  WHERE sugerencia_clave IS NOT NULL;

-- RLS (mismo patrón de desarrollo que el resto del esquema)
ALTER TABLE viaje_pendientes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "dev_open_access_viaje_pendientes" ON viaje_pendientes;
CREATE POLICY "dev_open_access_viaje_pendientes" ON viaje_pendientes
  FOR ALL USING (true) WITH CHECK (true);

COMMIT;

NOTIFY pgrst, 'reload schema';
