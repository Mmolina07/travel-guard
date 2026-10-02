-- HU-22 / TG-291: pagos con Mercado Pago (Checkout Pro, sandbox) y
-- suscripciones Premium. También es la base de HU-24 / TG-298: "es
-- Premium" = tiene una fila en `suscripciones` con estado 'activa' y
-- `fecha_fin` posterior a ahora.
--
-- Corre esto DESPUÉS de schema.sql (usa `set_timestamp()` de ahí).
--
-- ⚠️ A diferencia del resto del esquema, estas tablas NO llevan la
-- política "dev_open_access" de escritura: solo se pueden LEER desde la
-- app. Quien inserta/actualiza es únicamente el código de las Edge
-- Functions (`supabase/functions/mp-*`), que usa la service role key y
-- se salta RLS. Así nadie puede marcarse como Premium escribiendo
-- directo en la tabla con la llave pública de la app: un pago solo
-- queda 'aprobado' si Mercado Pago lo confirma.

BEGIN;

CREATE TABLE pagos (
  id                BIGSERIAL PRIMARY KEY,
  usuario_id        BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  plan              VARCHAR(20) NOT NULL,
  monto             NUMERIC(12,2) NOT NULL,
  moneda            VARCHAR(3) NOT NULL DEFAULT 'COP',
  estado            VARCHAR(20) NOT NULL DEFAULT 'pendiente',
  proveedor         VARCHAR(30) NOT NULL DEFAULT 'mercadopago',
  mp_preference_id  VARCHAR(80),
  mp_payment_id     VARCHAR(40) UNIQUE,
  mp_status_detail  VARCHAR(80),
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT chk_pagos_plan CHECK (plan IN ('mensual', 'anual')),
  CONSTRAINT chk_pagos_monto CHECK (monto > 0),
  CONSTRAINT chk_pagos_estado CHECK (
    estado IN ('pendiente', 'en_proceso', 'aprobado', 'rechazado', 'cancelado', 'reembolsado')
  )
);
CREATE TRIGGER trg_pagos_updated_at BEFORE UPDATE ON pagos
  FOR EACH ROW EXECUTE FUNCTION set_timestamp();
CREATE INDEX idx_pagos_usuario ON pagos(usuario_id);

CREATE TABLE suscripciones (
  id            BIGSERIAL PRIMARY KEY,
  usuario_id    BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  plan          VARCHAR(20) NOT NULL,
  estado        VARCHAR(20) NOT NULL DEFAULT 'activa',
  fecha_inicio  TIMESTAMPTZ NOT NULL,
  fecha_fin     TIMESTAMPTZ NOT NULL,
  -- UNIQUE: el webhook y la confirmación al volver de Mercado Pago
  -- pueden llegar los dos para el mismo pago; solo uno crea la fila.
  pago_id       BIGINT UNIQUE REFERENCES pagos(id) ON DELETE SET NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT chk_suscripciones_plan CHECK (plan IN ('mensual', 'anual')),
  CONSTRAINT chk_suscripciones_estado CHECK (estado IN ('activa', 'cancelada', 'vencida')),
  CONSTRAINT chk_suscripciones_fechas CHECK (fecha_fin > fecha_inicio)
);
CREATE TRIGGER trg_suscripciones_updated_at BEFORE UPDATE ON suscripciones
  FOR EACH ROW EXECUTE FUNCTION set_timestamp();
CREATE INDEX idx_suscripciones_usuario ON suscripciones(usuario_id, fecha_fin DESC);

ALTER TABLE pagos ENABLE ROW LEVEL SECURITY;
ALTER TABLE suscripciones ENABLE ROW LEVEL SECURITY;

-- Solo lectura desde la app (ver nota arriba): sin políticas de
-- INSERT/UPDATE/DELETE, Postgres las rechaza para anon/authenticated.
CREATE POLICY app_read_pagos ON pagos FOR SELECT USING (true);
CREATE POLICY app_read_suscripciones ON suscripciones FOR SELECT USING (true);

COMMIT;
