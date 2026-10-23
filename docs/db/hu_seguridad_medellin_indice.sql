-- Mapa de incidencia delictiva — Fase 5: Índice histórico de incidencia
-- delictiva. Correr DESPUÉS de hu_seguridad_medellin_estadisticas.sql.
--
-- Método completo y limitaciones: docs/seguridad/indice_incidencia.md.
-- En corto: posición percentil del total de hurtos a persona registrados
-- en el período, comparando comunas solo con comunas y corregimientos solo
-- con corregimientos. 0 = la de menos registros de su grupo, 100 = la de
-- más. No es una medida de "peligrosidad real".
--
-- Cambio aditivo: solo crea una función nueva, se puede volver a correr.

BEGIN;

CREATE OR REPLACE FUNCTION seguridad_indice_comunas(
  p_inicio DATE DEFAULT NULL,
  p_fin    DATE DEFAULT NULL
)
RETURNS TABLE (
  codigo        TEXT,
  nombre        TEXT,
  tipo          TEXT,
  total         BIGINT,
  -- % de los hurtos de su grupo (comunas o corregimientos) en el período.
  participacion NUMERIC,
  -- 1 = la de más registros de su grupo.
  posicion      INT,
  tamano_grupo  INT,
  indice        SMALLINT,
  nivel         TEXT     -- 'bajo' | 'medio' | 'alto' | 'muy_alto'
)
LANGUAGE sql STABLE
AS $$
  WITH t AS (
    SELECT * FROM seguridad_totales_por_comuna(p_inicio, p_fin)
  ),
  r AS (
    SELECT t.*,
           ROUND(100 * PERCENT_RANK() OVER (PARTITION BY t.tipo ORDER BY t.total))::SMALLINT AS indice,
           ROUND(100.0 * t.total / NULLIF(SUM(t.total) OVER (PARTITION BY t.tipo), 0), 1) AS participacion,
           RANK() OVER (PARTITION BY t.tipo ORDER BY t.total DESC)::INT AS posicion,
           COUNT(*) OVER (PARTITION BY t.tipo)::INT AS tamano_grupo
    FROM t
  )
  SELECT r.codigo, r.nombre, r.tipo, r.total, r.participacion, r.posicion,
         r.tamano_grupo, r.indice,
         CASE
           WHEN r.indice >= c.umbral_muy_alto THEN 'muy_alto'
           WHEN r.indice >= c.umbral_alto     THEN 'alto'
           WHEN r.indice >= c.umbral_medio    THEN 'medio'
           ELSE 'bajo'
         END
  FROM r CROSS JOIN seguridad_config c
  ORDER BY r.tipo, r.indice DESC, r.codigo;
$$;

GRANT EXECUTE ON FUNCTION seguridad_indice_comunas(DATE, DATE) TO anon, authenticated;

COMMIT;
