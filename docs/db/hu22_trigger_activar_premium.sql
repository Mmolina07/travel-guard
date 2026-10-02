-- HU-22 / TG-293: activación automática de Premium tras pago aprobado.
--
-- Trigger en `pagos`: cuando un pago pasa a 'aprobado', crea la
-- suscripción del usuario; si pasa a 'reembolsado', la cancela. Así la
-- activación vive en la base de datos y no depende de qué código haya
-- actualizado el pago (cobro, webhook o confirmación manual) — las Edge
-- Functions solo cambian `pagos.estado`.
--
-- Corre esto DESPUÉS de hu22_suscripciones_pagos.sql.

BEGIN;

CREATE OR REPLACE FUNCTION activar_premium_por_pago() RETURNS TRIGGER AS $$
DECLARE
  meses   INT;
  inicio  TIMESTAMPTZ;
BEGIN
  IF NEW.estado = 'aprobado' AND OLD.estado IS DISTINCT FROM 'aprobado' THEN
    meses := CASE NEW.plan WHEN 'anual' THEN 12 ELSE 1 END;

    -- Si ya es Premium, el plan nuevo se suma al final del vigente en
    -- vez de pisar los días que ya había pagado.
    SELECT GREATEST(now(), COALESCE(MAX(fecha_fin), now()))
      INTO inicio
      FROM suscripciones
     WHERE usuario_id = NEW.usuario_id
       AND estado = 'activa';

    INSERT INTO suscripciones (usuario_id, plan, estado, fecha_inicio, fecha_fin, pago_id)
    VALUES (NEW.usuario_id, NEW.plan, 'activa', inicio, inicio + make_interval(months => meses), NEW.id)
    ON CONFLICT (pago_id) DO NOTHING;

  ELSIF NEW.estado = 'reembolsado' AND OLD.estado IS DISTINCT FROM 'reembolsado' THEN
    UPDATE suscripciones SET estado = 'cancelada' WHERE pago_id = NEW.id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_pagos_activar_premium ON pagos;
CREATE TRIGGER trg_pagos_activar_premium
  AFTER UPDATE OF estado ON pagos
  FOR EACH ROW EXECUTE FUNCTION activar_premium_por_pago();

COMMIT;
