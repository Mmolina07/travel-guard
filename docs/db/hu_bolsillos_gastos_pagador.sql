-- Bolsillo personal por viaje + quién pagó cada gasto y con qué dinero.
-- Corrido en Supabase el 2026-10-21 (para la rama anasprint3 de Ana).
--
-- - La plata del bolsillo es aparte del viaje: los aportes van en su propia
--   tabla (`bolsillo_aportes`) y no tocan `viajes` ni el presupuesto
--   compartido.
-- - Un bolsillo por persona y por viaje: UNIQUE (viaje_id, usuario_id).
-- - Un gasto pagado desde el bolsillo sigue guardándose en `gastos`, con
--   `pagado_con_dinero_viaje = false` y `pagado_por_id` = quien pagó. Así
--   la tarjeta "Gasto por persona" lo puede mostrar, pero el saldo y los
--   aportes quedan solo en las tablas del bolsillo.
-- - `gastos.establecimiento`: nombre del negocio (lo usa "Top 3
--   establecimientos").
--
-- Los gastos que ya existían quedan con `pagado_con_dinero_viaje = true`.
-- Corre esto DESPUÉS de schema.sql (usa set_timestamp()). Se puede correr
-- más de una vez.

BEGIN;

-- 1) Bolsillo personal: uno por persona y por viaje
CREATE TABLE IF NOT EXISTS bolsillos (
  id          BIGSERIAL PRIMARY KEY,
  viaje_id    BIGINT NOT NULL REFERENCES viajes(id) ON DELETE CASCADE,
  usuario_id  BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (viaje_id, usuario_id)
);
DROP TRIGGER IF EXISTS trg_bolsillos_updated_at ON bolsillos;
CREATE TRIGGER trg_bolsillos_updated_at BEFORE UPDATE ON bolsillos
  FOR EACH ROW EXECUTE FUNCTION set_timestamp();
CREATE INDEX IF NOT EXISTS idx_bolsillos_usuario ON bolsillos(usuario_id);

-- 2) Dinero que la persona agrega a su bolsillo (plata propia, no del viaje)
CREATE TABLE IF NOT EXISTS bolsillo_aportes (
  id           BIGSERIAL PRIMARY KEY,
  bolsillo_id  BIGINT NOT NULL REFERENCES bolsillos(id) ON DELETE CASCADE,
  monto        NUMERIC(12,2) NOT NULL,
  nota         VARCHAR(200),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT chk_bolsillo_aportes_monto CHECK (monto > 0)
);
CREATE INDEX IF NOT EXISTS idx_bolsillo_aportes_bolsillo ON bolsillo_aportes(bolsillo_id);

-- 3) Columnas nuevas de `gastos` (quién pagó, con qué dinero, dónde)
ALTER TABLE gastos ADD COLUMN IF NOT EXISTS establecimiento VARCHAR(150);
ALTER TABLE gastos ADD COLUMN IF NOT EXISTS pagado_por_id BIGINT REFERENCES usuarios(id) ON DELETE SET NULL;
ALTER TABLE gastos ADD COLUMN IF NOT EXISTS pagado_con_dinero_viaje BOOLEAN NOT NULL DEFAULT TRUE;

CREATE INDEX IF NOT EXISTS idx_gastos_pagado_bolsillo
  ON gastos (viaje_id, pagado_por_id) WHERE pagado_con_dinero_viaje = FALSE;

-- 4) RLS (mismo patrón de desarrollo que el resto de tu esquema)
ALTER TABLE bolsillos        ENABLE ROW LEVEL SECURITY;
ALTER TABLE bolsillo_aportes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "dev_open_access_bolsillos" ON bolsillos;
DROP POLICY IF EXISTS "dev_open_access_bolsillo_aportes" ON bolsillo_aportes;
CREATE POLICY "dev_open_access_bolsillos"        ON bolsillos        FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "dev_open_access_bolsillo_aportes" ON bolsillo_aportes FOR ALL USING (true) WITH CHECK (true);

COMMIT;

NOTIFY pgrst, 'reload schema';
