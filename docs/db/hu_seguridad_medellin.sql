-- Mapa de incidencia delictiva histórica por comuna — Fase 1: modelo de datos.
--
-- Fuentes (verificadas el 2026-10-22):
--   * Eventos: MEData (Alcaldía de Medellín, SISC), conjunto "Hurto a persona"
--     id 1-027-23-000011, licencia CC BY-SA 4.0. Cubre 2003-01-01 a
--     2023-11-30, ~326 mil registros, con fecha_hecho CON hora y lat/long.
--   * Polígonos de comunas: ArcGIS de la Alcaldía,
--     ServiciosCiudad/CartografiaBase/MapServer/10 (LimiteComunaCorregimiento).
--   * El MapServer seguridad_defensa/VM_Indicador_Seguridad (2015–2017, sin
--     hora) es una foto vieja de la misma serie del SISC: no se importa para
--     no duplicar eventos.
--
-- Escribe solo el importador (service role, se salta RLS); la app solo lee.
-- No se guardan datos personales de las víctimas (sexo, edad, estado civil…):
-- no hacen falta para el índice y así se minimiza lo que se almacena.
--
-- Cambio aditivo: solo crea objetos nuevos con prefijo seguridad_, no toca
-- tablas existentes y se puede volver a correr.

BEGIN;

-- ── Fuentes oficiales (trazabilidad: todo evento apunta a una) ──────────

CREATE TABLE IF NOT EXISTS seguridad_fuentes (
  id               TEXT PRIMARY KEY,
  nombre           TEXT NOT NULL,
  publicador       TEXT NOT NULL,
  url_datos        TEXT NOT NULL,
  url_diccionario  TEXT,
  licencia         TEXT,
  tiene_hora       BOOLEAN NOT NULL DEFAULT FALSE,
  notas            TEXT,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

DROP TRIGGER IF EXISTS trg_seguridad_fuentes_updated_at ON seguridad_fuentes;
CREATE TRIGGER trg_seguridad_fuentes_updated_at BEFORE UPDATE ON seguridad_fuentes
  FOR EACH ROW EXECUTE FUNCTION set_timestamp();

INSERT INTO seguridad_fuentes (id, nombre, publicador, url_datos, url_diccionario, licencia, tiene_hora, notas)
VALUES
  ('medata_hurto_persona',
   'Hurto a persona',
   'Alcaldía de Medellín — Secretaría de Seguridad y Convivencia (SISC), vía MEData',
   'http://medata.app.medellin.gov.co/sites/default/files/distribution/1-027-23-000011/hurto_a_persona.csv',
   'http://medata.app.medellin.gov.co/sites/default/files/distribution/1-027-23-000011/Modelo_Unificado_Seguridad.json',
   'CC BY-SA 4.0',
   TRUE,
   'La hora es la reportada por la víctima: ~77 % de los registros cae en :00 o :30, se analiza por franjas de una hora.'),
  ('arcgis_comunas',
   'Límite comuna / corregimiento',
   'Alcaldía de Medellín — servidor de mapas ArcGIS',
   'https://www.medellin.gov.co/servidormapas/rest/services/ServiciosCiudad/CartografiaBase/MapServer/10',
   NULL,
   NULL,
   FALSE,
   'Polígonos simplificados al importar (maxAllowableOffset) para dibujarlos en el mapa.')
ON CONFLICT (id) DO NOTHING;

-- ── Comunas y corregimientos ────────────────────────────────────────────
-- codigo con dos dígitos ('01'…'16', '50'…'90'), igual que en la capa de
-- polígonos. En los eventos viene sin cero ('1'): el importador lo normaliza.

CREATE TABLE IF NOT EXISTS seguridad_comunas (
  codigo            TEXT PRIMARY KEY CHECK (codigo ~ '^[0-9]{2}$'),
  nombre            TEXT NOT NULL,
  tipo              TEXT NOT NULL CHECK (tipo IN ('comuna', 'corregimiento')),
  -- GeoJSON (Polygon/MultiPolygon, EPSG:4326) que llena el importador.
  geometria         JSONB,
  fuente_id         TEXT NOT NULL DEFAULT 'arcgis_comunas' REFERENCES seguridad_fuentes(id),
  -- Opcional, para tasas por habitante más adelante; solo con fuente citada.
  poblacion         INT CHECK (poblacion > 0),
  poblacion_fuente  TEXT,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (poblacion IS NULL OR poblacion_fuente IS NOT NULL)
);

DROP TRIGGER IF EXISTS trg_seguridad_comunas_updated_at ON seguridad_comunas;
CREATE TRIGGER trg_seguridad_comunas_updated_at BEFORE UPDATE ON seguridad_comunas
  FOR EACH ROW EXECUTE FUNCTION set_timestamp();

-- Nombres tal como los publica la capa de polígonos (SN01/SN02 no tienen
-- nombre ni aparecen en los eventos, se omiten).
INSERT INTO seguridad_comunas (codigo, nombre, tipo) VALUES
  ('01', 'Popular', 'comuna'),
  ('02', 'Santa Cruz', 'comuna'),
  ('03', 'Manrique', 'comuna'),
  ('04', 'Aranjuez', 'comuna'),
  ('05', 'Castilla', 'comuna'),
  ('06', 'Doce de Octubre', 'comuna'),
  ('07', 'Robledo', 'comuna'),
  ('08', 'Villa Hermosa', 'comuna'),
  ('09', 'Buenos Aires', 'comuna'),
  ('10', 'La Candelaria', 'comuna'),
  ('11', 'Laureles Estadio', 'comuna'),
  ('12', 'La América', 'comuna'),
  ('13', 'San Javier', 'comuna'),
  ('14', 'El Poblado', 'comuna'),
  ('15', 'Guayabal', 'comuna'),
  ('16', 'Belén', 'comuna'),
  ('50', 'Corregimiento de San Sebastián de Palmitas', 'corregimiento'),
  ('60', 'Corregimiento de San Cristóbal', 'corregimiento'),
  ('70', 'Corregimiento de Altavista', 'corregimiento'),
  ('80', 'Corregimiento de San Antonio de Prado', 'corregimiento'),
  ('90', 'Corregimiento de Santa Elena', 'corregimiento')
ON CONFLICT (codigo) DO NOTHING;

-- ── Bitácora de importaciones ───────────────────────────────────────────

CREATE TABLE IF NOT EXISTS seguridad_importaciones (
  id                BIGSERIAL PRIMARY KEY,
  fuente_id         TEXT NOT NULL REFERENCES seguridad_fuentes(id),
  -- Last-Modified del archivo o fecha_ingestion del CSV.
  version_fuente    TEXT,
  estado            TEXT NOT NULL DEFAULT 'en_curso'
                    CHECK (estado IN ('en_curso', 'ok', 'error')),
  filas_leidas      INT NOT NULL DEFAULT 0,
  filas_insertadas  INT NOT NULL DEFAULT 0,
  filas_omitidas    INT NOT NULL DEFAULT 0,
  mensaje           TEXT,
  iniciada_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  terminada_at      TIMESTAMPTZ
);

-- ── Eventos delictivos ──────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS seguridad_eventos (
  id               BIGSERIAL PRIMARY KEY,
  fuente_id        TEXT NOT NULL REFERENCES seguridad_fuentes(id),
  -- El CSV no trae id: md5 de la fila normalizada + '#' + su número de
  -- aparición entre filas idénticas. Es determinista, así que volver a
  -- importar el mismo archivo no duplica nada.
  clave_origen     TEXT NOT NULL,
  importacion_id   BIGINT REFERENCES seguridad_importaciones(id) ON DELETE SET NULL,
  tipo_delito      TEXT NOT NULL,           -- 'hurto_persona' por ahora
  conducta         TEXT NOT NULL,
  modalidad        TEXT,
  -- NULL cuando la fuente dice 'SIN DATO' (~1,6 %): cuenta para la ciudad,
  -- no para ninguna comuna.
  comuna_codigo    TEXT REFERENCES seguridad_comunas(codigo),
  codigo_barrio    TEXT,
  nombre_barrio    TEXT,
  -- Hora local de Medellín (UTC-5 todo el año, sin horario de verano).
  fecha_hecho      TIMESTAMP NOT NULL,
  -- FALSE si la fuente solo trae el día: entonces la hora no se usa.
  tiene_hora       BOOLEAN NOT NULL,
  latitud          NUMERIC(9,6),
  longitud         NUMERIC(9,6),
  lugar            TEXT,
  medio_transporte TEXT,
  arma_medio       TEXT,
  bien             TEXT,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (fuente_id, clave_origen)
);

CREATE INDEX IF NOT EXISTS idx_seguridad_eventos_comuna_fecha
  ON seguridad_eventos (comuna_codigo, fecha_hecho);
CREATE INDEX IF NOT EXISTS idx_seguridad_eventos_tipo_fecha
  ON seguridad_eventos (tipo_delito, fecha_hecho);

-- ── Configuración del índice (una sola fila) ────────────────────────────
-- Los rangos de color y el período analizado se cambian aquí, sin tocar la
-- app.

CREATE TABLE IF NOT EXISTS seguridad_config (
  id               BOOLEAN PRIMARY KEY DEFAULT TRUE CHECK (id),
  tipo_delito      TEXT NOT NULL DEFAULT 'hurto_persona',
  periodo_inicio   DATE NOT NULL DEFAULT '2021-01-01',
  periodo_fin      DATE NOT NULL DEFAULT '2023-11-30',
  -- Índice 0–100: verde < umbral_medio ≤ amarillo < umbral_alto ≤ naranja
  -- < umbral_muy_alto ≤ rojo.
  umbral_medio     SMALLINT NOT NULL DEFAULT 25,
  umbral_alto      SMALLINT NOT NULL DEFAULT 50,
  umbral_muy_alto  SMALLINT NOT NULL DEFAULT 75,
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (periodo_inicio <= periodo_fin),
  CHECK (0 < umbral_medio AND umbral_medio < umbral_alto
         AND umbral_alto < umbral_muy_alto AND umbral_muy_alto <= 100)
);

DROP TRIGGER IF EXISTS trg_seguridad_config_updated_at ON seguridad_config;
CREATE TRIGGER trg_seguridad_config_updated_at BEFORE UPDATE ON seguridad_config
  FOR EACH ROW EXECUTE FUNCTION set_timestamp();

INSERT INTO seguridad_config (id) VALUES (TRUE) ON CONFLICT (id) DO NOTHING;

-- ── Agregados (lo que consulta la app; nunca los 326 mil eventos) ────────

CREATE MATERIALIZED VIEW IF NOT EXISTS seguridad_agregado_mensual AS
SELECT
  tipo_delito,
  comuna_codigo,
  COALESCE(modalidad, 'Sin dato')             AS modalidad,
  EXTRACT(YEAR  FROM fecha_hecho)::SMALLINT   AS anio,
  EXTRACT(MONTH FROM fecha_hecho)::SMALLINT   AS mes,
  COUNT(*)::INT                               AS total
FROM seguridad_eventos
GROUP BY 1, 2, 3, 4, 5
WITH NO DATA;

CREATE INDEX IF NOT EXISTS idx_seguridad_agregado_mensual
  ON seguridad_agregado_mensual (tipo_delito, comuna_codigo, anio, mes);

-- Solo eventos con hora real. dia_semana: 1 = lunes … 7 = domingo (ISO).
CREATE MATERIALIZED VIEW IF NOT EXISTS seguridad_agregado_horario AS
SELECT
  tipo_delito,
  comuna_codigo,
  EXTRACT(YEAR   FROM fecha_hecho)::SMALLINT  AS anio,
  EXTRACT(ISODOW FROM fecha_hecho)::SMALLINT  AS dia_semana,
  EXTRACT(HOUR   FROM fecha_hecho)::SMALLINT  AS hora,
  COUNT(*)::INT                               AS total
FROM seguridad_eventos
WHERE tiene_hora
GROUP BY 1, 2, 3, 4, 5
WITH NO DATA;

CREATE INDEX IF NOT EXISTS idx_seguridad_agregado_horario
  ON seguridad_agregado_horario (tipo_delito, comuna_codigo, anio);

-- La llama el importador al terminar. SECURITY DEFINER para que funcione
-- con la service role; la app no la puede ejecutar.
CREATE OR REPLACE FUNCTION seguridad_refrescar_agregados()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  REFRESH MATERIALIZED VIEW seguridad_agregado_mensual;
  REFRESH MATERIALIZED VIEW seguridad_agregado_horario;
END;
$$;

REVOKE ALL ON FUNCTION seguridad_refrescar_agregados() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION seguridad_refrescar_agregados() TO service_role;

-- ── Acceso ──────────────────────────────────────────────────────────────
-- Datos públicos: la app lee todo; sin políticas de escritura, Postgres
-- rechaza INSERT/UPDATE/DELETE de anon/authenticated (mismo patrón que
-- pagos/suscripciones).

ALTER TABLE seguridad_fuentes       ENABLE ROW LEVEL SECURITY;
ALTER TABLE seguridad_comunas       ENABLE ROW LEVEL SECURITY;
ALTER TABLE seguridad_importaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE seguridad_eventos       ENABLE ROW LEVEL SECURITY;
ALTER TABLE seguridad_config        ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS app_read_seguridad_fuentes ON seguridad_fuentes;
CREATE POLICY app_read_seguridad_fuentes ON seguridad_fuentes FOR SELECT USING (true);
DROP POLICY IF EXISTS app_read_seguridad_comunas ON seguridad_comunas;
CREATE POLICY app_read_seguridad_comunas ON seguridad_comunas FOR SELECT USING (true);
DROP POLICY IF EXISTS app_read_seguridad_importaciones ON seguridad_importaciones;
CREATE POLICY app_read_seguridad_importaciones ON seguridad_importaciones FOR SELECT USING (true);
DROP POLICY IF EXISTS app_read_seguridad_eventos ON seguridad_eventos;
CREATE POLICY app_read_seguridad_eventos ON seguridad_eventos FOR SELECT USING (true);
DROP POLICY IF EXISTS app_read_seguridad_config ON seguridad_config;
CREATE POLICY app_read_seguridad_config ON seguridad_config FOR SELECT USING (true);

-- Las vistas materializadas no tienen RLS: se exponen solo para lectura.
GRANT SELECT ON seguridad_agregado_mensual, seguridad_agregado_horario TO anon, authenticated;

COMMIT;
