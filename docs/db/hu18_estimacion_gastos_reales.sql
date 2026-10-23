-- HU-18 Fase 6: calibración de la estimación con gastos reales de TravelGuard.
-- Corre después de hu18_estimacion_presupuesto.sql. Se puede volver a correr.
--
-- estimacion_gastos_reales(ciudad) devuelve SOLO agregados (mediana y número
-- de viajes) de los viajes ya terminados a esa ciudad; nunca filas de un
-- usuario. Si un componente tiene menos viajes que
-- estimacion_parametros.calibracion_min_viajes, su valor sale NULL.
--
-- Qué se mide por viaje (solo gastos con fecha dentro del viaje):
--   comida      = gastos "Comida" / (personas × días)
--   transporte  = gastos "Movilidad" / (personas × días)
--   hospedaje   = (viajes.costo_hospedaje + gastos "Hospedaje")
--                 / (noches × habitaciones), habitaciones = ⌈personas / 2⌉
-- Se descartan valores imposibles: por debajo de la mitad del estilo
-- económico o por encima del doble del de lujo (p. ej. hospedaje de $100).
--
-- El destino es texto libre: se compara sin tildes ni mayúsculas y por
-- palabra completa ("Medellin, colombia", "medellín" → Medellín).

CREATE OR REPLACE FUNCTION estimacion_gastos_reales(p_ciudad TEXT)
RETURNS TABLE (
  viajes                       INT,
  viajes_comida                INT,
  comida_persona_dia           NUMERIC,
  viajes_transporte            INT,
  transporte_persona_dia       NUMERIC,
  viajes_hospedaje             INT,
  hospedaje_noche_habitacion   NUMERIC
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  WITH ciudad AS (
    SELECT translate(lower(c.nombre), 'áéíóúü', 'aeiouu') AS nombre_norm
    FROM estimacion_ciudades c
    WHERE c.id = p_ciudad AND c.es_destino
  ),
  limites AS (
    SELECT
      min(comida_dia) * 0.5            AS comida_min,  max(comida_dia) * 2           AS comida_max,
      min(transporte_local_dia) * 0.5  AS transp_min,  max(transporte_local_dia) * 2 AS transp_max,
      min(hospedaje_noche) * 0.5       AS hosp_min,    max(hospedaje_noche) * 2      AS hosp_max
    FROM estimacion_costos
    WHERE ciudad_id = p_ciudad
  ),
  minimo AS (
    SELECT COALESCE(
      (SELECT valor::INT FROM estimacion_parametros WHERE clave = 'calibracion_min_viajes'), 3
    ) AS n
  ),
  viajes_ciudad AS (
    SELECT
      v.id,
      GREATEST(v.numero_personas, 1)          AS personas,
      (v.fecha_fin - v.fecha_inicio) + 1      AS dias,
      (v.fecha_fin - v.fecha_inicio)          AS noches,
      COALESCE(v.costo_hospedaje, 0)          AS costo_hospedaje,
      v.fecha_inicio,
      v.fecha_fin
    FROM viajes v, ciudad c
    WHERE v.fecha_fin < current_date
      AND v.fecha_fin >= v.fecha_inicio
      AND (v.fecha_fin - v.fecha_inicio) < 60
      AND translate(lower(v.destino), 'áéíóúü', 'aeiouu') ~ ('\m' || c.nombre_norm || '\M')
  ),
  por_viaje AS (
    SELECT
      vc.id,
      SUM(g.monto) FILTER (WHERE cg.nombre = 'Comida')
        / (vc.personas * vc.dias)                                   AS comida,
      SUM(g.monto) FILTER (WHERE cg.nombre = 'Movilidad')
        / (vc.personas * vc.dias)                                   AS transporte,
      CASE WHEN vc.noches > 0 THEN
        NULLIF(vc.costo_hospedaje + COALESCE(SUM(g.monto) FILTER (WHERE cg.nombre = 'Hospedaje'), 0), 0)
          / (vc.noches * CEIL(vc.personas / 2.0))
      END                                                           AS hospedaje
    FROM viajes_ciudad vc
    LEFT JOIN gastos g
      ON g.viaje_id = vc.id AND g.fecha BETWEEN vc.fecha_inicio AND vc.fecha_fin
    LEFT JOIN categorias_gasto cg ON cg.id = g.categoria_id
    GROUP BY vc.id, vc.personas, vc.dias, vc.noches, vc.costo_hospedaje
  ),
  validos AS (
    SELECT
      CASE WHEN p.comida     BETWEEN l.comida_min AND l.comida_max THEN p.comida     END AS comida,
      CASE WHEN p.transporte BETWEEN l.transp_min AND l.transp_max THEN p.transporte END AS transporte,
      CASE WHEN p.hospedaje  BETWEEN l.hosp_min   AND l.hosp_max   THEN p.hospedaje  END AS hospedaje
    FROM por_viaje p, limites l
  ),
  agregado AS (
    SELECT
      COUNT(*) FILTER (WHERE comida IS NOT NULL OR transporte IS NOT NULL OR hospedaje IS NOT NULL)::INT AS viajes,
      COUNT(comida)::INT     AS n_comida,
      percentile_cont(0.5) WITHIN GROUP (ORDER BY comida)     AS comida,
      COUNT(transporte)::INT AS n_transporte,
      percentile_cont(0.5) WITHIN GROUP (ORDER BY transporte) AS transporte,
      COUNT(hospedaje)::INT  AS n_hospedaje,
      percentile_cont(0.5) WITHIN GROUP (ORDER BY hospedaje)  AS hospedaje
    FROM validos
  )
  SELECT
    a.viajes,
    a.n_comida,
    CASE WHEN a.n_comida >= m.n THEN round(a.comida::NUMERIC, 2) END,
    a.n_transporte,
    CASE WHEN a.n_transporte >= m.n THEN round(a.transporte::NUMERIC, 2) END,
    a.n_hospedaje,
    CASE WHEN a.n_hospedaje >= m.n THEN round(a.hospedaje::NUMERIC, 2) END
  FROM agregado a, minimo m;
$$;

REVOKE ALL ON FUNCTION estimacion_gastos_reales(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION estimacion_gastos_reales(TEXT) TO anon, authenticated;
