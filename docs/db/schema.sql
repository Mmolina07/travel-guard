-- =====================================================================
-- ESQUEMA COMPLETO DE TRAVELGUARD (basado en travelguard_schema_sprint1.sql)
-- Corre esto DESPUÉS de reset_schema.sql.
--
-- Cambios respecto al script original, para que coincida con el código
-- Dart actual (lib/features/auth/data/**) y no vuelva a fallar:
--
-- 1) Se eliminó el CONSTRAINT chk_auth_local de `usuarios`. Exigía
--    password_hash NOT NULL para proveedor_auth='local', pero la
--    autenticación real vive en Firebase Authentication: la app nunca
--    guarda password_hash en Supabase (ni para 'local' ni para
--    'google'). Con el constraint, TODO registro por email fallaba con
--    "violates check constraint chk_auth_local" (código 23514).
--
-- 2) Se agregó RLS habilitado + una política abierta ("dev_open_access_*")
--    en cada tabla. Sin esto, en cuanto se habilita RLS (como ya había
--    pasado) y no hay ninguna política, Postgres bloquea TODO acceso
--    con "new row violates row-level security policy" (código 42501).
--    Es la causa de los errores al registrar turista y comercio.
--    ⚠️ Estas políticas dejan las tablas abiertas a cualquiera con la
--    publishable key — sirve para desarrollo, no para producción. La
--    alternativa correcta es configurar "Third-Party Auth" de Supabase
--    para Firebase y usar políticas basadas en auth.jwt()->>'sub'.
--
-- 3) Se agregaron columnas costo_tours / costo_restaurantes /
--    costo_discotecas / costo_souvenirs a `viajes` (HU-05, TG-141): el
--    formulario de crear viaje captura un monto para cada una, pero el
--    esquema original solo tenía flags booleanos (incluye_tours_guia,
--    etc.), lo que perdía esos datos. Si ya corriste este schema.sql
--    antes de este cambio, usa la migración incremental
--    hu05_viajes_costos.sql en vez de repetir todo el reset.
-- =====================================================================

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE FUNCTION set_timestamp() RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TYPE tipo_usuario_enum    AS ENUM ('turista', 'comercio', 'administrador');
CREATE TYPE proveedor_auth_enum  AS ENUM ('local', 'google');
CREATE TYPE estado_usuario_enum  AS ENUM ('activo', 'inactivo', 'suspendido');

CREATE TYPE tipo_viaje_enum      AS ENUM ('vacaciones', 'trabajo', 'ocio', 'otro');
CREATE TYPE tipo_transporte_enum AS ENUM ('carro', 'transporte_publico', 'uber', 'vuelo', 'otro');
CREATE TYPE estado_viaje_enum    AS ENUM ('activo', 'completado', 'archivado');

CREATE TABLE usuarios (
  id                  BIGSERIAL PRIMARY KEY,
  email               VARCHAR(150) NOT NULL UNIQUE,
  password_hash       VARCHAR(255),
  proveedor_auth      proveedor_auth_enum NOT NULL DEFAULT 'local',
  google_id           VARCHAR(120) UNIQUE,
  tipo_usuario        tipo_usuario_enum NOT NULL,
  estado              estado_usuario_enum NOT NULL DEFAULT 'activo',
  ultimo_login_at     TIMESTAMPTZ,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
  -- (chk_auth_local eliminado: ver nota arriba. password_hash no se usa,
  -- la autenticación real vive en Firebase.)
);
CREATE TRIGGER trg_usuarios_updated_at BEFORE UPDATE ON usuarios
  FOR EACH ROW EXECUTE FUNCTION set_timestamp();

CREATE TABLE turistas (
  usuario_id      BIGINT PRIMARY KEY REFERENCES usuarios(id) ON DELETE CASCADE,
  nombre          VARCHAR(100) NOT NULL,
  apellido        VARCHAR(100),
  telefono        VARCHAR(30),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_turistas_updated_at BEFORE UPDATE ON turistas
  FOR EACH ROW EXECUTE FUNCTION set_timestamp();

CREATE TABLE categorias_comercio (
  id      SERIAL PRIMARY KEY,
  nombre  VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE comercios (
  usuario_id        BIGINT PRIMARY KEY REFERENCES usuarios(id) ON DELETE CASCADE,
  nit               VARCHAR(30) NOT NULL UNIQUE,
  nombre_comercio   VARCHAR(150) NOT NULL,
  categoria_id      INT REFERENCES categorias_comercio(id),
  sede              VARCHAR(100),
  descripcion       TEXT,
  telefono_contacto VARCHAR(30) NOT NULL,
  direccion         VARCHAR(255) NOT NULL,
  latitud           NUMERIC(9,6),
  longitud          NUMERIC(9,6),
  horario_apertura  TIME,
  horario_cierre    TIME,
  estado            estado_usuario_enum NOT NULL DEFAULT 'activo',
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_comercios_updated_at BEFORE UPDATE ON comercios
  FOR EACH ROW EXECUTE FUNCTION set_timestamp();
CREATE INDEX idx_comercios_categoria ON comercios(categoria_id);
CREATE INDEX idx_comercios_ubicacion ON comercios(latitud, longitud);

CREATE TABLE viajes (
  id                    BIGSERIAL PRIMARY KEY,
  turista_id            BIGINT NOT NULL REFERENCES turistas(usuario_id) ON DELETE CASCADE,
  nombre                VARCHAR(150) NOT NULL,
  destino               VARCHAR(150) NOT NULL,
  fecha_inicio          DATE NOT NULL,
  fecha_fin             DATE NOT NULL,
  numero_personas       INT NOT NULL DEFAULT 1,
  tipo_viaje            tipo_viaje_enum NOT NULL DEFAULT 'otro',
  presupuesto_maximo    NUMERIC(12,2) NOT NULL,
  pagos_anticipados     NUMERIC(12,2) DEFAULT 0,
  tipo_hospedaje        VARCHAR(80),
  costo_hospedaje       NUMERIC(12,2),
  incluye_desayuno      BOOLEAN NOT NULL DEFAULT FALSE,
  incluye_almuerzo      BOOLEAN NOT NULL DEFAULT FALSE,
  incluye_cena          BOOLEAN NOT NULL DEFAULT FALSE,
  incluye_traslado      BOOLEAN NOT NULL DEFAULT FALSE,
  transporte_inicio     tipo_transporte_enum,
  transporte_durante    tipo_transporte_enum,
  incluye_tours_guia    BOOLEAN NOT NULL DEFAULT FALSE,
  costo_tours           NUMERIC(12,2),
  incluye_restaurantes  BOOLEAN NOT NULL DEFAULT FALSE,
  costo_restaurantes    NUMERIC(12,2),
  incluye_discotecas    BOOLEAN NOT NULL DEFAULT FALSE,
  costo_discotecas      NUMERIC(12,2),
  incluye_souvenirs     BOOLEAN NOT NULL DEFAULT FALSE,
  costo_souvenirs       NUMERIC(12,2),
  incluye_actividades_pagas BOOLEAN NOT NULL DEFAULT FALSE,
  costo_actividades_pagas NUMERIC(12,2),
  dinero_emergencias    NUMERIC(12,2) DEFAULT 0,
  datos_completos       BOOLEAN NOT NULL DEFAULT TRUE,
  estado                estado_viaje_enum NOT NULL DEFAULT 'activo',
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT chk_fechas_viaje CHECK (fecha_fin >= fecha_inicio),
  CONSTRAINT chk_personas CHECK (numero_personas >= 1),
  CONSTRAINT chk_presupuesto CHECK (presupuesto_maximo > 0),
  CONSTRAINT chk_costo_hospedaje CHECK (costo_hospedaje IS NULL OR costo_hospedaje > 0),
  CONSTRAINT chk_dinero_emergencias CHECK (dinero_emergencias IS NULL OR dinero_emergencias >= 0)
);
CREATE TRIGGER trg_viajes_updated_at BEFORE UPDATE ON viajes
  FOR EACH ROW EXECUTE FUNCTION set_timestamp();
CREATE INDEX idx_viajes_turista ON viajes(turista_id);
CREATE INDEX idx_viajes_estado ON viajes(estado);

CREATE TABLE categorias_gasto (
  id      SERIAL PRIMARY KEY,
  nombre  VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE gastos (
  id            BIGSERIAL PRIMARY KEY,
  viaje_id      BIGINT NOT NULL REFERENCES viajes(id) ON DELETE CASCADE,
  categoria_id  INT NOT NULL REFERENCES categorias_gasto(id),
  descripcion   VARCHAR(200),
  monto         NUMERIC(12,2) NOT NULL,
  fecha         DATE NOT NULL,
  hora          TIME NOT NULL DEFAULT now()::time,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT chk_monto_gasto CHECK (monto > 0)
);
CREATE TRIGGER trg_gastos_updated_at BEFORE UPDATE ON gastos
  FOR EACH ROW EXECUTE FUNCTION set_timestamp();
CREATE INDEX idx_gastos_viaje_fecha ON gastos(viaje_id, fecha);
CREATE INDEX idx_gastos_categoria ON gastos(categoria_id);

CREATE TABLE categorias_lugar (
  id      SERIAL PRIMARY KEY,
  nombre  VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE lugares_interes (
  id            BIGSERIAL PRIMARY KEY,
  comercio_id   BIGINT REFERENCES comercios(usuario_id) ON DELETE CASCADE,
  categoria_id  INT NOT NULL REFERENCES categorias_lugar(id),
  nombre        VARCHAR(150) NOT NULL,
  descripcion   TEXT,
  direccion     VARCHAR(255),
  telefono      VARCHAR(30),
  latitud       NUMERIC(9,6) NOT NULL,
  longitud      NUMERIC(9,6) NOT NULL,
  horario_apertura TIME,
  horario_cierre   TIME,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_lugares_interes_updated_at BEFORE UPDATE ON lugares_interes
  FOR EACH ROW EXECUTE FUNCTION set_timestamp();
CREATE INDEX idx_lugares_interes_categoria ON lugares_interes(categoria_id);
CREATE INDEX idx_lugares_interes_ubicacion ON lugares_interes(latitud, longitud);
CREATE INDEX idx_lugares_interes_comercio ON lugares_interes(comercio_id);

CREATE TABLE actividades (
  id                BIGSERIAL PRIMARY KEY,
  comercio_id       BIGINT REFERENCES comercios(usuario_id) ON DELETE CASCADE,
  lugar_interes_id  BIGINT REFERENCES lugares_interes(id) ON DELETE SET NULL,
  categoria_id      INT REFERENCES categorias_lugar(id),
  nombre            VARCHAR(150) NOT NULL,
  descripcion       TEXT,
  precio            NUMERIC(12,2),
  duracion_min      INT,
  activo            BOOLEAN NOT NULL DEFAULT TRUE,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_actividades_updated_at BEFORE UPDATE ON actividades
  FOR EACH ROW EXECUTE FUNCTION set_timestamp();
CREATE INDEX idx_actividades_comercio ON actividades(comercio_id);

COMMIT;

INSERT INTO categorias_gasto (nombre) VALUES
  ('Comida'), ('Movilidad'), ('Actividades'), ('Compras'), ('Hospedaje'), ('Otros');

INSERT INTO categorias_comercio (nombre) VALUES
  ('Restaurante'), ('Hotel'), ('Tienda'), ('Discoteca'), ('Tour'), ('Transporte'), ('Otro');

INSERT INTO categorias_lugar (nombre) VALUES
  ('Restaurante'), ('Hotel'), ('Mirador'), ('Museo'), ('Discoteca'), ('Tour'), ('Parque'), ('Otro');

-- =====================================================================
-- ROW LEVEL SECURITY (agregado: ver nota #2 al inicio del archivo)
-- =====================================================================

ALTER TABLE usuarios            ENABLE ROW LEVEL SECURITY;
ALTER TABLE turistas            ENABLE ROW LEVEL SECURITY;
ALTER TABLE categorias_comercio ENABLE ROW LEVEL SECURITY;
ALTER TABLE comercios           ENABLE ROW LEVEL SECURITY;
ALTER TABLE viajes              ENABLE ROW LEVEL SECURITY;
ALTER TABLE categorias_gasto    ENABLE ROW LEVEL SECURITY;
ALTER TABLE gastos              ENABLE ROW LEVEL SECURITY;
ALTER TABLE categorias_lugar    ENABLE ROW LEVEL SECURITY;
ALTER TABLE lugares_interes     ENABLE ROW LEVEL SECURITY;
ALTER TABLE actividades         ENABLE ROW LEVEL SECURITY;

CREATE POLICY "dev_open_access_usuarios"            ON usuarios            FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "dev_open_access_turistas"            ON turistas            FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "dev_open_access_categorias_comercio" ON categorias_comercio FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "dev_open_access_comercios"           ON comercios           FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "dev_open_access_viajes"              ON viajes              FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "dev_open_access_categorias_gasto"    ON categorias_gasto    FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "dev_open_access_gastos"              ON gastos              FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "dev_open_access_categorias_lugar"    ON categorias_lugar    FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "dev_open_access_lugares_interes"     ON lugares_interes     FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "dev_open_access_actividades"         ON actividades         FOR ALL USING (true) WITH CHECK (true);

-- =====================================================================
-- FIN
-- =====================================================================
