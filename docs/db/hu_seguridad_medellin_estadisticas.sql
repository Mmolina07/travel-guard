-- Mapa de incidencia delictiva — Fase 4: consultas estadísticas.
-- Correr DESPUÉS de hu_seguridad_medellin_agregados.sql.
--
-- Funciones de solo lectura que llama la app (supabase.rpc). Suman sobre
-- los agregados, así la app recibe decenas de filas en vez de miles.
--
-- Período: p_inicio/p_fin opcionales; si van NULL se usa seguridad_config.
--   * Agregado mensual: se filtra por mes (cuenta el mes completo si p_inicio
--     cae a mitad de mes).
--   * Agregado horario: solo tiene año, así que se filtra por años completos.
-- p_comuna NULL = toda la ciudad (sin los registros 'SIN DATO').
--
-- Cambio aditivo: solo crea funciones nuevas, se puede volver a correr.

BEGIN;

-- Período y fuente efectivos: lo que pidió la app o, si no, la config.
CREATE OR REPLACE FUNCTION seguridad_periodo(p_inicio DATE, p_fin DATE)
RETURNS TABLE (fuente_id TEXT, inicio DATE, fin DATE)
LANGUAGE sql STABLE
AS $$
  SELECT c.fuente_id,
         date_trunc('month', COALESCE(p_inicio, c.periodo_inicio))::DATE,
         COALESCE(p_fin, c.periodo_fin)
  FROM seguridad_config c;
$$;

-- Fuente, período configurado y última importación: lo que la app muestra
-- como "Fuente: … · Datos 2021–2023 · actualizado el …".
CREATE OR REPLACE FUNCTION seguridad_metadatos()
RETURNS TABLE (
  fuente_id         TEXT,
  fuente_nombre     TEXT,
  publicador        TEXT,
  url_datos         TEXT,
  licencia          TEXT,
  tiene_hora        BOOLEAN,
  periodo_inicio    DATE,
  periodo_fin       DATE,
  umbral_medio      SMALLINT,
  umbral_alto       SMALLINT,
  umbral_muy_alto   SMALLINT,
  datos_desde       TIMESTAMP,
  datos_hasta       TIMESTAMP,
  importado_at      TIMESTAMPTZ,
  version_fuente    TEXT
)
LANGUAGE sql STABLE
AS $$
  SELECT f.id, f.nombre, f.publicador, f.url_datos, f.licencia, f.tiene_hora,
         c.periodo_inicio, c.periodo_fin,
         c.umbral_medio, c.umbral_alto, c.umbral_muy_alto,
         i.fecha_min, i.fecha_max, i.terminada_at, i.version_fuente
  FROM seguridad_config c
  JOIN seguridad_fuentes f ON f.id = c.fuente_id
  LEFT JOIN LATERAL (
    SELECT * FROM seguridad_importaciones i
    WHERE i.fuente_id = c.fuente_id AND i.estado = 'ok'
    ORDER BY i.terminada_at DESC
    LIMIT 1
  ) i ON TRUE;
$$;

-- Total por comuna en el período (las 21, con 0 si no hubo registros).
CREATE OR REPLACE FUNCTION seguridad_totales_por_comuna(
  p_inicio DATE DEFAULT NULL,
  p_fin    DATE DEFAULT NULL
)
RETURNS TABLE (codigo TEXT, nombre TEXT, tipo TEXT, total BIGINT)
LANGUAGE sql STABLE
AS $$
  SELECT co.codigo, co.nombre, co.tipo, COALESCE(SUM(m.total), 0)::BIGINT
  FROM seguridad_periodo(p_inicio, p_fin) p
  CROSS JOIN seguridad_comunas co
  LEFT JOIN seguridad_agregado_mensual m
    ON m.comuna_codigo = co.codigo
   AND m.fuente_id = p.fuente_id
   AND make_date(m.anio, m.mes, 1) BETWEEN p.inicio AND p.fin
  GROUP BY co.codigo, co.nombre, co.tipo
  ORDER BY co.codigo;
$$;

-- Por modalidad (atraco, descuido, cosquilleo…), de mayor a menor.
CREATE OR REPLACE FUNCTION seguridad_por_modalidad(
  p_comuna TEXT DEFAULT NULL,
  p_inicio DATE DEFAULT NULL,
  p_fin    DATE DEFAULT NULL
)
RETURNS TABLE (modalidad TEXT, total BIGINT, porcentaje NUMERIC)
LANGUAGE sql STABLE
AS $$
  SELECT m.modalidad,
         SUM(m.total)::BIGINT,
         ROUND(100.0 * SUM(m.total) / NULLIF(SUM(SUM(m.total)) OVER (), 0), 1)
  FROM seguridad_periodo(p_inicio, p_fin) p
  JOIN seguridad_agregado_mensual m
    ON m.fuente_id = p.fuente_id
   AND make_date(m.anio, m.mes, 1) BETWEEN p.inicio AND p.fin
  WHERE p_comuna IS NULL OR m.comuna_codigo = p_comuna
  GROUP BY m.modalidad
  ORDER BY 2 DESC, 1;
$$;

-- Evolución en el tiempo, por mes o por año. Los meses/años sin registros
-- salen con 0 para que la gráfica no salte huecos.
CREATE OR REPLACE FUNCTION seguridad_evolucion(
  p_comuna        TEXT DEFAULT NULL,
  p_granularidad  TEXT DEFAULT 'mes',
  p_inicio        DATE DEFAULT NULL,
  p_fin           DATE DEFAULT NULL
)
RETURNS TABLE (periodo DATE, total BIGINT)
LANGUAGE sql STABLE
AS $$
  WITH p AS (
    SELECT fuente_id,
           CASE WHEN p_granularidad = 'anio'
                THEN date_trunc('year', inicio)::DATE ELSE inicio END AS inicio,
           fin
    FROM seguridad_periodo(p_inicio, p_fin)
  ),
  serie AS (
    SELECT generate_series(
             p.inicio,
             p.fin,
             CASE WHEN p_granularidad = 'anio' THEN INTERVAL '1 year'
                  ELSE INTERVAL '1 month' END
           )::DATE AS periodo
    FROM p
  ),
  datos AS (
    SELECT CASE WHEN p_granularidad = 'anio' THEN make_date(m.anio, 1, 1)
                ELSE make_date(m.anio, m.mes, 1) END AS periodo,
           SUM(m.total) AS total
    FROM p
    JOIN seguridad_agregado_mensual m
      ON m.fuente_id = p.fuente_id
     AND make_date(m.anio, m.mes, 1) BETWEEN p.inicio AND p.fin
    WHERE p_comuna IS NULL OR m.comuna_codigo = p_comuna
    GROUP BY 1
  )
  SELECT s.periodo, COALESCE(d.total, 0)::BIGINT
  FROM serie s
  LEFT JOIN datos d USING (periodo)
  ORDER BY s.periodo;
$$;

-- Matriz día de la semana × hora (1 = lunes … 7 = domingo; hora 0–23).
-- Vacía si la fuente no trae hora (seguridad_fuentes.tiene_hora = FALSE).
CREATE OR REPLACE FUNCTION seguridad_por_dia_hora(
  p_comuna TEXT DEFAULT NULL,
  p_inicio DATE DEFAULT NULL,
  p_fin    DATE DEFAULT NULL
)
RETURNS TABLE (dia_semana SMALLINT, hora SMALLINT, total BIGINT)
LANGUAGE sql STABLE
AS $$
  SELECT h.dia_semana, h.hora, SUM(h.total)::BIGINT
  FROM seguridad_periodo(p_inicio, p_fin) p
  JOIN seguridad_fuentes f ON f.id = p.fuente_id AND f.tiene_hora
  JOIN seguridad_agregado_horario h
    ON h.fuente_id = p.fuente_id
   AND h.anio BETWEEN EXTRACT(YEAR FROM p.inicio) AND EXTRACT(YEAR FROM p.fin)
  WHERE p_comuna IS NULL OR h.comuna_codigo = p_comuna
  GROUP BY h.dia_semana, h.hora
  ORDER BY h.dia_semana, h.hora;
$$;

GRANT EXECUTE ON FUNCTION
  seguridad_periodo(DATE, DATE),
  seguridad_metadatos(),
  seguridad_totales_por_comuna(DATE, DATE),
  seguridad_por_modalidad(TEXT, DATE, DATE),
  seguridad_evolucion(TEXT, TEXT, DATE, DATE),
  seguridad_por_dia_hora(TEXT, DATE, DATE)
TO anon, authenticated;

COMMIT;
