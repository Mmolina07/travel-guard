-- Mapa de incidencia delictiva — ajuste a la Fase 1: solo agregados.
-- Correr DESPUÉS de hu_seguridad_medellin.sql.
--
-- Por qué: el proyecto ya usa ~307 MB de los 500 MB del plan gratis de
-- Supabase, y guardar los ~326 mil hurtos uno a uno ocupaba ~140 MB con
-- índices. La app nunca necesita el evento individual, así que se guardan
-- solo conteos (~57 mil filas, ~7 MB):
--   * seguridad_agregado_mensual: comuna × modalidad × año × mes
--   * seguridad_agregado_horario: comuna × año × día de la semana × hora
-- La trazabilidad queda en seguridad_fuentes (URL oficial) +
-- seguridad_importaciones (versión del archivo y conteos): volver a correr
-- el importador sobre el mismo CSV público da los mismos números.
--
-- Retira seguridad_eventos y las vistas materializadas solo si siguen
-- vacías; si hubiera datos, se detiene sin tocar nada.

BEGIN;

DO $$
BEGIN
  IF to_regclass('public.seguridad_eventos') IS NOT NULL THEN
    IF EXISTS (SELECT 1 FROM seguridad_eventos LIMIT 1) THEN
      RAISE EXCEPTION 'seguridad_eventos tiene datos: revisar antes de migrar.';
    END IF;
    DROP MATERIALIZED VIEW IF EXISTS seguridad_agregado_mensual;
    DROP MATERIALIZED VIEW IF EXISTS seguridad_agregado_horario;
    DROP FUNCTION IF EXISTS seguridad_refrescar_agregados();
    DROP TABLE seguridad_eventos;
  END IF;
END;
$$;

-- Cada fuente de delitos dice qué delito mide (NULL para los polígonos).
ALTER TABLE seguridad_fuentes ADD COLUMN IF NOT EXISTS tipo_delito TEXT;
UPDATE seguridad_fuentes SET tipo_delito = 'hurto_persona' WHERE id = 'medata_hurto_persona';

-- Los registros con comuna 'SIN DATO' (~1,6 %) se cuentan aquí pero no
-- entran a ninguna comuna.
ALTER TABLE seguridad_importaciones
  ADD COLUMN IF NOT EXISTS filas_sin_comuna INT NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS fecha_min TIMESTAMP,
  ADD COLUMN IF NOT EXISTS fecha_max TIMESTAMP;
ALTER TABLE seguridad_importaciones DROP COLUMN IF EXISTS filas_insertadas;

-- El índice se configura por fuente, no por tipo de delito.
ALTER TABLE seguridad_config DROP COLUMN IF EXISTS tipo_delito;
ALTER TABLE seguridad_config
  ADD COLUMN IF NOT EXISTS fuente_id TEXT NOT NULL DEFAULT 'medata_hurto_persona'
  REFERENCES seguridad_fuentes(id);

-- ── Agregados (lo único que consulta la app) ────────────────────────────
-- La llave primaria es natural: reimportar hace upsert sobre las mismas
-- filas y no duplica nada.

CREATE TABLE IF NOT EXISTS seguridad_agregado_mensual (
  fuente_id       TEXT NOT NULL REFERENCES seguridad_fuentes(id),
  comuna_codigo   TEXT NOT NULL REFERENCES seguridad_comunas(codigo),
  modalidad       TEXT NOT NULL,             -- 'Sin dato' si la fuente no la trae
  anio            SMALLINT NOT NULL CHECK (anio BETWEEN 2000 AND 2100),
  mes             SMALLINT NOT NULL CHECK (mes BETWEEN 1 AND 12),
  total           INT NOT NULL CHECK (total > 0),
  importacion_id  BIGINT NOT NULL REFERENCES seguridad_importaciones(id),
  PRIMARY KEY (fuente_id, comuna_codigo, modalidad, anio, mes)
);

CREATE INDEX IF NOT EXISTS idx_seguridad_mensual_periodo
  ON seguridad_agregado_mensual (fuente_id, anio, mes);

-- Hora local de Medellín (UTC-5, sin horario de verano), tal como la
-- reporta la fuente. dia_semana: 1 = lunes … 7 = domingo (ISO).
-- Solo se llena para fuentes con tiene_hora = TRUE.
CREATE TABLE IF NOT EXISTS seguridad_agregado_horario (
  fuente_id       TEXT NOT NULL REFERENCES seguridad_fuentes(id),
  comuna_codigo   TEXT NOT NULL REFERENCES seguridad_comunas(codigo),
  anio            SMALLINT NOT NULL CHECK (anio BETWEEN 2000 AND 2100),
  dia_semana      SMALLINT NOT NULL CHECK (dia_semana BETWEEN 1 AND 7),
  hora            SMALLINT NOT NULL CHECK (hora BETWEEN 0 AND 23),
  total           INT NOT NULL CHECK (total > 0),
  importacion_id  BIGINT NOT NULL REFERENCES seguridad_importaciones(id),
  PRIMARY KEY (fuente_id, comuna_codigo, anio, dia_semana, hora)
);

CREATE INDEX IF NOT EXISTS idx_seguridad_horario_periodo
  ON seguridad_agregado_horario (fuente_id, anio);

ALTER TABLE seguridad_agregado_mensual ENABLE ROW LEVEL SECURITY;
ALTER TABLE seguridad_agregado_horario ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS app_read_seguridad_mensual ON seguridad_agregado_mensual;
CREATE POLICY app_read_seguridad_mensual ON seguridad_agregado_mensual FOR SELECT USING (true);
DROP POLICY IF EXISTS app_read_seguridad_horario ON seguridad_agregado_horario;
CREATE POLICY app_read_seguridad_horario ON seguridad_agregado_horario FOR SELECT USING (true);

COMMIT;
