-- HU-18: estimación del presupuesto del viaje según destino y características.
-- Fase 1: modelo de datos + datos de referencia (ver docs/hu/hu-18.md).
--
-- Estimación gratis e "híbrida": estas tablas son la REFERENCIA (costos
-- investigados por ciudad y estilo). La calibración con gastos reales de
-- la app va en un archivo aparte (Fase 6).
--
-- Montos en pesos colombianos (COP), igual que el resto de la BD. La app
-- solo LEE estas tablas; se actualizan desde el SQL Editor.
--
-- Precios verificados el 2026-10-23 (fuentes en estimacion_fuentes). Las
-- temporadas tienen fechas concretas (Semana Santa y las ferias cambian
-- cada año): agregar las del año siguiente antes de que se acaben.
--
-- Cambio aditivo: solo crea objetos nuevos con prefijo estimacion_, no toca
-- tablas existentes y se puede volver a correr (los datos se actualizan).

BEGIN;

-- ── Fuentes (trazabilidad: lo que la app muestra como "Fuentes") ───────

CREATE TABLE IF NOT EXISTS estimacion_fuentes (
  id             TEXT PRIMARY KEY,
  nombre         TEXT NOT NULL,
  url            TEXT,
  consultado_en  DATE NOT NULL,
  notas          TEXT
);

INSERT INTO estimacion_fuentes (id, nombre, url, consultado_en, notas) VALUES
  ('eltiempo_buses_2026', 'Tarifas de buses intermunicipales 2026 (El Tiempo)',
   'https://www.eltiempo.com/economia/sectores/suben-los-pasajes-de-buses-intermunicipales-en-2026-estos-son-los-nuevos-precios-tras-aumento-en-diesel-y-salario-minimo-3522310',
   '2026-10-23', 'Tarifas publicadas por las empresas; los agregadores suelen tener precios más bajos.'),
  ('pinbus', 'Pinbus', 'https://pinbus.com/pasajes-de-bus/medellin-bogota', '2026-10-23',
   'Precios "desde" de las rutas de bus.'),
  ('kayak_vuelos', 'KAYAK (promedio de 12 meses)',
   'https://www.kayak.com.co/vuelos/Bogota-Aeropuerto-Internacional-El-Dorado-BOG/Medellin-CO1', '2026-10-23',
   'Bogotá–Medellín ida y vuelta: promedio ~242.000.'),
  ('avianca', 'Avianca', 'https://www.avianca.com/co/es/vuelos-desde-bogota-a-cartagena', '2026-10-23',
   'Tarifas "desde" de rutas nacionales.'),
  ('hoteles_2026', 'Guías de costos de hospedaje 2026 y Skyscanner Hoteles',
   'https://experienciaviajeracolombia.com/blog-costo-paquete-colombia.html', '2026-10-23',
   'Rangos por noche de hostal, 3★ y 4★ en Bogotá, Medellín y Cartagena; Skyscanner para promedios.'),
  ('creg_gasolina', 'Precio de la gasolina, octubre 2026 (CREG)',
   'https://www.vanguardia.com/colombia/2026/10/01/la-gasolina-subio-en-colombia-este-es-el-nuevo-precio-del-galon-y-las-ciudades-donde-es-mas-cara/',
   '2026-10-23', 'Galón ~16.300 en las capitales.'),
  ('ani_peajes_2026', 'Peajes ANI 2026 (Portafolio)',
   'https://www.portafolio.co/economia/infraestructura/peajes-a-cargo-de-la-ani-se-actualizaran-el-16-de-enero-de-2026-con-alza-basada-en-la-inflacion-como-quedan-486062',
   '2026-10-23', 'Categoría I (automóvil). Total por ruta aproximado.'),
  ('equipo_travelguard', 'Referencia del equipo TravelGuard', NULL, '2026-10-23',
   'Comida, transporte local, tours, rumba y souvenirs: promedios de menús, tarifas de taxi/app y tours publicados.')
ON CONFLICT (id) DO UPDATE SET
  nombre = EXCLUDED.nombre, url = EXCLUDED.url,
  consultado_en = EXCLUDED.consultado_en, notas = EXCLUDED.notas;

-- ── Ciudades (destinos + orígenes) ───────────────────────────────────────
-- es_destino = tiene costos en estimacion_costos. Las demás solo sirven
-- de origen (sus coordenadas dan la distancia cuando no hay ruta cargada).
-- variacion = ancho del rango (0.15 → ±15 %); más alto donde los precios
-- cambian más (Cartagena).

CREATE TABLE IF NOT EXISTS estimacion_ciudades (
  id                TEXT PRIMARY KEY,
  nombre            TEXT NOT NULL,
  departamento      TEXT NOT NULL,
  latitud           NUMERIC(9,6) NOT NULL,
  longitud          NUMERIC(9,6) NOT NULL,
  tiene_aeropuerto  BOOLEAN NOT NULL DEFAULT TRUE,
  es_destino        BOOLEAN NOT NULL DEFAULT FALSE,
  variacion         NUMERIC(4,2) NOT NULL DEFAULT 0.15 CHECK (variacion BETWEEN 0 AND 0.6),
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

DROP TRIGGER IF EXISTS trg_estimacion_ciudades_updated_at ON estimacion_ciudades;
CREATE TRIGGER trg_estimacion_ciudades_updated_at BEFORE UPDATE ON estimacion_ciudades
  FOR EACH ROW EXECUTE FUNCTION set_timestamp();

INSERT INTO estimacion_ciudades (id, nombre, departamento, latitud, longitud, tiene_aeropuerto, es_destino, variacion) VALUES
  ('medellin',      'Medellín',      'Antioquia',          6.244200, -75.581200, TRUE,  TRUE,  0.15),
  ('bogota',        'Bogotá',        'Cundinamarca',       4.711000, -74.072100, TRUE,  TRUE,  0.15),
  ('cali',          'Cali',          'Valle del Cauca',    3.451600, -76.532000, TRUE,  TRUE,  0.15),
  ('barranquilla',  'Barranquilla',  'Atlántico',         10.968500, -74.781300, TRUE,  TRUE,  0.18),
  ('cartagena',     'Cartagena',     'Bolívar',           10.391000, -75.479400, TRUE,  TRUE,  0.22),
  ('santa_marta',   'Santa Marta',   'Magdalena',         11.240800, -74.199000, TRUE,  FALSE, 0.15),
  ('bucaramanga',   'Bucaramanga',   'Santander',          7.119300, -73.122700, TRUE,  FALSE, 0.15),
  ('pereira',       'Pereira',       'Risaralda',          4.813300, -75.696100, TRUE,  FALSE, 0.15),
  ('manizales',     'Manizales',     'Caldas',             5.070300, -75.513800, TRUE,  FALSE, 0.15),
  ('armenia',       'Armenia',       'Quindío',            4.533900, -75.681100, TRUE,  FALSE, 0.15),
  ('ibague',        'Ibagué',        'Tolima',             4.438900, -75.232200, TRUE,  FALSE, 0.15),
  ('cucuta',        'Cúcuta',        'Norte de Santander', 7.893900, -72.507800, TRUE,  FALSE, 0.15),
  ('villavicencio', 'Villavicencio', 'Meta',               4.142000, -73.626600, TRUE,  FALSE, 0.15),
  ('pasto',         'Pasto',         'Nariño',             1.213600, -77.281100, TRUE,  FALSE, 0.15),
  ('neiva',         'Neiva',         'Huila',              2.927300, -75.281900, TRUE,  FALSE, 0.15),
  ('monteria',      'Montería',      'Córdoba',            8.747900, -75.881400, TRUE,  FALSE, 0.15),
  ('valledupar',    'Valledupar',    'Cesar',             10.463100, -73.253200, TRUE,  FALSE, 0.15),
  ('popayan',       'Popayán',       'Cauca',              2.444800, -76.614700, TRUE,  FALSE, 0.15),
  ('sincelejo',     'Sincelejo',     'Sucre',              9.304700, -75.397800, TRUE,  FALSE, 0.15),
  ('tunja',         'Tunja',         'Boyacá',             5.535300, -73.367800, FALSE, FALSE, 0.15)
ON CONFLICT (id) DO UPDATE SET
  nombre = EXCLUDED.nombre, departamento = EXCLUDED.departamento,
  latitud = EXCLUDED.latitud, longitud = EXCLUDED.longitud,
  tiene_aeropuerto = EXCLUDED.tiene_aeropuerto, es_destino = EXCLUDED.es_destino,
  variacion = EXCLUDED.variacion;

-- ── Costos por destino y estilo ──────────────────────────────────────────
-- hospedaje_noche: por HABITACIÓN (2 personas) y por noche.
--   económico = hostal privado / hotel 2★, estándar = 3★, lujo = 4-5★.
-- comida_dia, transporte_local_dia, tours_dia: por persona y por día.
-- rumba_salida: por persona y por salida. souvenirs_viaje: por persona.

CREATE TABLE IF NOT EXISTS estimacion_costos (
  ciudad_id             TEXT NOT NULL REFERENCES estimacion_ciudades(id) ON DELETE CASCADE,
  estilo                TEXT NOT NULL CHECK (estilo IN ('economico', 'estandar', 'lujo')),
  hospedaje_noche       NUMERIC(12,2) NOT NULL CHECK (hospedaje_noche > 0),
  comida_dia            NUMERIC(12,2) NOT NULL CHECK (comida_dia > 0),
  transporte_local_dia  NUMERIC(12,2) NOT NULL CHECK (transporte_local_dia >= 0),
  tours_dia             NUMERIC(12,2) NOT NULL CHECK (tours_dia >= 0),
  rumba_salida          NUMERIC(12,2) NOT NULL CHECK (rumba_salida >= 0),
  souvenirs_viaje       NUMERIC(12,2) NOT NULL CHECK (souvenirs_viaje >= 0),
  fuentes               TEXT[] NOT NULL DEFAULT '{}',
  verificado_en         DATE NOT NULL,
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (ciudad_id, estilo)
);

DROP TRIGGER IF EXISTS trg_estimacion_costos_updated_at ON estimacion_costos;
CREATE TRIGGER trg_estimacion_costos_updated_at BEFORE UPDATE ON estimacion_costos
  FOR EACH ROW EXECUTE FUNCTION set_timestamp();

INSERT INTO estimacion_costos
  (ciudad_id, estilo, hospedaje_noche, comida_dia, transporte_local_dia, tours_dia, rumba_salida, souvenirs_viaje, fuentes, verificado_en)
VALUES
  ('medellin',     'economico', 110000,  55000, 10000,  40000,  50000,  50000, '{hoteles_2026,equipo_travelguard}', '2026-10-23'),
  ('medellin',     'estandar',  210000, 100000, 35000,  90000, 120000, 120000, '{hoteles_2026,equipo_travelguard}', '2026-10-23'),
  ('medellin',     'lujo',      480000, 230000, 100000, 220000, 300000, 300000, '{hoteles_2026,equipo_travelguard}', '2026-10-23'),
  ('bogota',       'economico', 110000,  60000, 12000,  40000,  50000,  50000, '{hoteles_2026,equipo_travelguard}', '2026-10-23'),
  ('bogota',       'estandar',  220000, 110000, 40000,  90000, 120000, 120000, '{hoteles_2026,equipo_travelguard}', '2026-10-23'),
  ('bogota',       'lujo',      520000, 250000, 110000, 220000, 300000, 300000, '{hoteles_2026,equipo_travelguard}', '2026-10-23'),
  ('cali',         'economico',  95000,  50000, 10000,  35000,  45000,  45000, '{hoteles_2026,equipo_travelguard}', '2026-10-23'),
  ('cali',         'estandar',  180000,  90000, 35000,  80000, 110000, 110000, '{hoteles_2026,equipo_travelguard}', '2026-10-23'),
  ('cali',         'lujo',      400000, 200000,  90000, 180000, 280000, 280000, '{hoteles_2026,equipo_travelguard}', '2026-10-23'),
  ('barranquilla', 'economico', 100000,  55000, 10000,  30000,  45000,  45000, '{hoteles_2026,equipo_travelguard}', '2026-10-23'),
  ('barranquilla', 'estandar',  200000,  95000, 35000,  70000, 110000, 110000, '{hoteles_2026,equipo_travelguard}', '2026-10-23'),
  ('barranquilla', 'lujo',      420000, 210000,  90000, 170000, 280000, 280000, '{hoteles_2026,equipo_travelguard}', '2026-10-23'),
  ('cartagena',    'economico', 150000,  70000, 15000,  60000,  70000,  60000, '{hoteles_2026,equipo_travelguard}', '2026-10-23'),
  ('cartagena',    'estandar',  300000, 140000, 45000, 140000, 160000, 150000, '{hoteles_2026,equipo_travelguard}', '2026-10-23'),
  ('cartagena',    'lujo',      750000, 320000, 120000, 350000, 400000, 350000, '{hoteles_2026,equipo_travelguard}', '2026-10-23')
ON CONFLICT (ciudad_id, estilo) DO UPDATE SET
  hospedaje_noche = EXCLUDED.hospedaje_noche, comida_dia = EXCLUDED.comida_dia,
  transporte_local_dia = EXCLUDED.transporte_local_dia, tours_dia = EXCLUDED.tours_dia,
  rumba_salida = EXCLUDED.rumba_salida, souvenirs_viaje = EXCLUDED.souvenirs_viaje,
  fuentes = EXCLUDED.fuentes, verificado_en = EXCLUDED.verificado_en;

-- ── Rutas entre destinos ─────────────────────────────────────────────────
-- Una fila por par (ciudad_a < ciudad_b, alfabético) y medio: sirve en los
-- dos sentidos. costo_ida: avión/bus = tiquete de ida POR PERSONA (tarifa
-- estándar); carro = peajes de ida POR VEHÍCULO (la gasolina se calcula con
-- distancia_km y estimacion_parametros). Si un medio no está cargado para
-- un par, no se ofrece (p. ej. no hay vuelos Barranquilla–Cartagena).
-- recomendado = false: se puede elegir, pero la app lo marca (bus > 16 h).

CREATE TABLE IF NOT EXISTS estimacion_rutas (
  ciudad_a        TEXT NOT NULL REFERENCES estimacion_ciudades(id) ON DELETE CASCADE,
  ciudad_b        TEXT NOT NULL REFERENCES estimacion_ciudades(id) ON DELETE CASCADE,
  modo            TEXT NOT NULL CHECK (modo IN ('avion', 'bus', 'carro')),
  costo_ida       NUMERIC(12,2) NOT NULL CHECK (costo_ida >= 0),
  distancia_km    INT NOT NULL CHECK (distancia_km > 0),
  duracion_horas  NUMERIC(4,1) NOT NULL CHECK (duracion_horas > 0),
  recomendado     BOOLEAN NOT NULL DEFAULT TRUE,
  fuente_id       TEXT REFERENCES estimacion_fuentes(id),
  verificado_en   DATE NOT NULL,
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (ciudad_a, ciudad_b, modo),
  CONSTRAINT chk_estimacion_rutas_orden CHECK (ciudad_a < ciudad_b)
);

DROP TRIGGER IF EXISTS trg_estimacion_rutas_updated_at ON estimacion_rutas;
CREATE TRIGGER trg_estimacion_rutas_updated_at BEFORE UPDATE ON estimacion_rutas
  FOR EACH ROW EXECUTE FUNCTION set_timestamp();

INSERT INTO estimacion_rutas
  (ciudad_a, ciudad_b, modo, costo_ida, distancia_km, duracion_horas, recomendado, fuente_id, verificado_en)
VALUES
  ('barranquilla', 'bogota',    'avion', 220000, 1000,  1.5, TRUE,  'avianca',             '2026-10-23'),
  ('barranquilla', 'bogota',    'bus',   280000, 1000, 19.0, FALSE, 'eltiempo_buses_2026', '2026-10-23'),
  ('barranquilla', 'bogota',    'carro', 210000, 1000, 17.0, FALSE, 'ani_peajes_2026',     '2026-10-23'),
  ('barranquilla', 'cali',      'avion', 260000, 1150,  1.6, TRUE,  'avianca',             '2026-10-23'),
  ('barranquilla', 'cali',      'bus',   330000, 1150, 22.0, FALSE, 'eltiempo_buses_2026', '2026-10-23'),
  ('barranquilla', 'cali',      'carro', 250000, 1150, 20.0, FALSE, 'ani_peajes_2026',     '2026-10-23'),
  ('barranquilla', 'cartagena', 'bus',    32000,  120,  2.0, TRUE,  'pinbus',              '2026-10-23'),
  ('barranquilla', 'cartagena', 'carro',  26000,  120,  1.8, TRUE,  'ani_peajes_2026',     '2026-10-23'),
  ('barranquilla', 'medellin',  'avion', 190000,  700,  1.2, TRUE,  'avianca',             '2026-10-23'),
  ('barranquilla', 'medellin',  'bus',   180000,  700, 14.0, TRUE,  'pinbus',              '2026-10-23'),
  ('barranquilla', 'medellin',  'carro', 150000,  700, 13.0, TRUE,  'ani_peajes_2026',     '2026-10-23'),
  ('bogota',       'cali',      'avion', 170000,  460,  1.0, TRUE,  'avianca',             '2026-10-23'),
  ('bogota',       'cali',      'bus',   110000,  460, 10.0, TRUE,  'pinbus',              '2026-10-23'),
  ('bogota',       'cali',      'carro', 105000,  460,  9.0, TRUE,  'ani_peajes_2026',     '2026-10-23'),
  ('bogota',       'cartagena', 'avion', 230000, 1050,  1.5, TRUE,  'avianca',             '2026-10-23'),
  ('bogota',       'cartagena', 'bus',   260000, 1050, 20.0, FALSE, 'eltiempo_buses_2026', '2026-10-23'),
  ('bogota',       'cartagena', 'carro', 230000, 1050, 18.0, FALSE, 'ani_peajes_2026',     '2026-10-23'),
  ('bogota',       'medellin',  'avion', 160000,  415,  1.0, TRUE,  'kayak_vuelos',        '2026-10-23'),
  ('bogota',       'medellin',  'bus',   125000,  415,  9.5, TRUE,  'pinbus',              '2026-10-23'),
  ('bogota',       'medellin',  'carro',  95000,  415,  8.5, TRUE,  'ani_peajes_2026',     '2026-10-23'),
  ('cali',         'cartagena', 'avion', 260000, 1100,  1.6, TRUE,  'avianca',             '2026-10-23'),
  ('cali',         'cartagena', 'bus',   300000, 1100, 22.0, FALSE, 'eltiempo_buses_2026', '2026-10-23'),
  ('cali',         'cartagena', 'carro', 250000, 1100, 20.0, FALSE, 'ani_peajes_2026',     '2026-10-23'),
  ('cali',         'medellin',  'avion', 170000,  420,  1.0, TRUE,  'avianca',             '2026-10-23'),
  ('cali',         'medellin',  'bus',   100000,  420,  9.0, TRUE,  'pinbus',              '2026-10-23'),
  ('cali',         'medellin',  'carro', 100000,  420,  8.0, TRUE,  'ani_peajes_2026',     '2026-10-23'),
  ('cartagena',    'medellin',  'avion', 190000,  640,  1.2, TRUE,  'avianca',             '2026-10-23'),
  ('cartagena',    'medellin',  'bus',   175000,  640, 13.0, TRUE,  'eltiempo_buses_2026', '2026-10-23'),
  ('cartagena',    'medellin',  'carro', 145000,  640, 12.0, TRUE,  'ani_peajes_2026',     '2026-10-23')
ON CONFLICT (ciudad_a, ciudad_b, modo) DO UPDATE SET
  costo_ida = EXCLUDED.costo_ida, distancia_km = EXCLUDED.distancia_km,
  duracion_horas = EXCLUDED.duracion_horas, recomendado = EXCLUDED.recomendado,
  fuente_id = EXCLUDED.fuente_id, verificado_en = EXCLUDED.verificado_en;

-- ── Temporadas ───────────────────────────────────────────────────────────
-- ciudad_id NULL = aplica en todo el país. Si una noche cae en varias
-- temporadas se usa el factor MÁS ALTO (no se multiplican).
-- factor_hospedaje sube el hospedaje; factor_transporte, los tiquetes.

CREATE TABLE IF NOT EXISTS estimacion_temporadas (
  id                 SERIAL PRIMARY KEY,
  nombre             TEXT NOT NULL,
  ciudad_id          TEXT REFERENCES estimacion_ciudades(id) ON DELETE CASCADE,
  desde              DATE NOT NULL,
  hasta              DATE NOT NULL,
  factor_hospedaje   NUMERIC(4,2) NOT NULL DEFAULT 1 CHECK (factor_hospedaje >= 1),
  factor_transporte  NUMERIC(4,2) NOT NULL DEFAULT 1 CHECK (factor_transporte >= 1),
  CONSTRAINT chk_estimacion_temporadas_fechas CHECK (hasta >= desde),
  CONSTRAINT uq_estimacion_temporadas UNIQUE (nombre, desde)
);

INSERT INTO estimacion_temporadas (nombre, ciudad_id, desde, hasta, factor_hospedaje, factor_transporte) VALUES
  ('Temporada de fin de año',      NULL,           '2025-12-15', '2026-01-15', 1.35, 1.30),
  ('Carnaval de Barranquilla',     'barranquilla', '2026-02-13', '2026-02-18', 1.60, 1.30),
  ('Semana Santa',                 NULL,           '2026-03-28', '2026-04-05', 1.30, 1.30),
  ('Vacaciones de mitad de año',   NULL,           '2026-06-15', '2026-07-31', 1.20, 1.20),
  ('Feria de las Flores',          'medellin',     '2026-07-31', '2026-08-10', 1.35, 1.20),
  ('Temporada de fin de año',      NULL,           '2026-12-15', '2027-01-15', 1.35, 1.30),
  ('Feria de Cali',                'cali',         '2026-12-25', '2026-12-30', 1.45, 1.30),
  ('Carnaval de Barranquilla',     'barranquilla', '2027-02-05', '2027-02-10', 1.60, 1.30),
  ('Semana Santa',                 NULL,           '2027-03-20', '2027-03-28', 1.30, 1.30),
  ('Vacaciones de mitad de año',   NULL,           '2027-06-15', '2027-07-31', 1.20, 1.20),
  ('Feria de las Flores',          'medellin',     '2027-07-30', '2027-08-09', 1.35, 1.20),
  ('Temporada de fin de año',      NULL,           '2027-12-15', '2028-01-15', 1.35, 1.30),
  ('Feria de Cali',                'cali',         '2027-12-25', '2027-12-30', 1.45, 1.30)
ON CONFLICT (nombre, desde) DO UPDATE SET
  ciudad_id = EXCLUDED.ciudad_id, hasta = EXCLUDED.hasta,
  factor_hospedaje = EXCLUDED.factor_hospedaje, factor_transporte = EXCLUDED.factor_transporte;

-- ── Parámetros del cálculo ───────────────────────────────────────────────
-- Se pueden ajustar sin publicar la app. *_cop_km son el respaldo cuando
-- la ruta no está en estimacion_rutas (la distancia sale de las coordenadas).

CREATE TABLE IF NOT EXISTS estimacion_parametros (
  clave        TEXT PRIMARY KEY,
  valor        NUMERIC(12,4) NOT NULL,
  descripcion  TEXT NOT NULL
);

INSERT INTO estimacion_parametros (clave, valor, descripcion) VALUES
  ('precio_galon',              16300,  'Galón de gasolina corriente (COP), CREG oct 2026'),
  ('km_por_galon',                 38,  'Rendimiento de un carro particular en carretera'),
  ('personas_por_vehiculo',         4,  'Viajeros por carro'),
  ('personas_por_habitacion',       2,  'Viajeros por habitación'),
  ('factor_avion_economico',     0.85,  'Tarifa básica sin maleta'),
  ('factor_avion_estandar',      1.00,  'Tarifa con maleta de mano'),
  ('factor_avion_lujo',          1.60,  'Tarifa flexible con maleta en bodega'),
  ('factor_bus_lujo',            1.30,  'Bus de servicio preferencial'),
  ('factor_vias',                1.30,  'Línea recta → kilómetros por carretera (respaldo)'),
  ('velocidad_bus_kmh',            55,  'Para estimar horas de bus (respaldo)'),
  ('bus_cop_km',                  260,  'Tiquete de bus por km por carretera (respaldo)'),
  ('peajes_cop_km',               220,  'Peajes por km por carretera, por vehículo (respaldo)'),
  ('avion_base',               110000,  'Parte fija del tiquete de ida (respaldo)'),
  ('avion_cop_km',                180,  'Tiquete de ida por km en línea recta (respaldo)'),
  ('avion_distancia_minima_km',   150,  'Por debajo de esto no se ofrece avión'),
  ('bus_horas_max_recomendado',    16,  'Más horas que esto: bus/carro no recomendado'),
  ('variacion_ruta_estimada',    0.10,  'Se suma al rango cuando la ruta no está cargada'),
  ('calibracion_min_viajes',        3,  'Viajes reales mínimos para mezclar con la referencia'),
  ('calibracion_peso_max',       0.60,  'Peso máximo de los datos reales en la mezcla'),
  ('calibracion_k',                 5,  'peso = min(peso_max, n / (n + k))')
ON CONFLICT (clave) DO UPDATE SET valor = EXCLUDED.valor, descripcion = EXCLUDED.descripcion;

-- ── RLS: la app solo lee ─────────────────────────────────────────────────

ALTER TABLE estimacion_fuentes     ENABLE ROW LEVEL SECURITY;
ALTER TABLE estimacion_ciudades    ENABLE ROW LEVEL SECURITY;
ALTER TABLE estimacion_costos      ENABLE ROW LEVEL SECURITY;
ALTER TABLE estimacion_rutas       ENABLE ROW LEVEL SECURITY;
ALTER TABLE estimacion_temporadas  ENABLE ROW LEVEL SECURITY;
ALTER TABLE estimacion_parametros  ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS app_read_estimacion_fuentes ON estimacion_fuentes;
CREATE POLICY app_read_estimacion_fuentes ON estimacion_fuentes FOR SELECT USING (true);
DROP POLICY IF EXISTS app_read_estimacion_ciudades ON estimacion_ciudades;
CREATE POLICY app_read_estimacion_ciudades ON estimacion_ciudades FOR SELECT USING (true);
DROP POLICY IF EXISTS app_read_estimacion_costos ON estimacion_costos;
CREATE POLICY app_read_estimacion_costos ON estimacion_costos FOR SELECT USING (true);
DROP POLICY IF EXISTS app_read_estimacion_rutas ON estimacion_rutas;
CREATE POLICY app_read_estimacion_rutas ON estimacion_rutas FOR SELECT USING (true);
DROP POLICY IF EXISTS app_read_estimacion_temporadas ON estimacion_temporadas;
CREATE POLICY app_read_estimacion_temporadas ON estimacion_temporadas FOR SELECT USING (true);
DROP POLICY IF EXISTS app_read_estimacion_parametros ON estimacion_parametros;
CREATE POLICY app_read_estimacion_parametros ON estimacion_parametros FOR SELECT USING (true);

GRANT SELECT ON estimacion_fuentes, estimacion_ciudades, estimacion_costos,
  estimacion_rutas, estimacion_temporadas, estimacion_parametros TO anon, authenticated;

COMMIT;
