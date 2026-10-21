-- =====================================================================
-- TRAVELGUARD — BASE DE DATOS COMPLETA (Supabase / PostgreSQL)
-- Generado el 2026-10-20 a partir de los scripts de docs/db/ del repo,
-- en el orden en que se aplican.
--
-- QUÉ INCLUYE
--   Tablas (17): usuarios, turistas, comercios, categorias_comercio,
--   viajes, presupuesto_categorias, viaje_colaboradores, viaje_historial,
--   gastos, categorias_gasto, lugares_interes, categorias_lugar,
--   actividades, menus, menu_productos, pagos, suscripciones.
--   Además: enums, función set_timestamp() + triggers de updated_at,
--   índices, CHECKs, catálogos iniciales (categorías), RLS y políticas,
--   trigger que activa Premium, publicación Realtime y el bucket de
--   Storage 'comercios'.
--
-- CÓMO USARLO
--   Pegar y correr completo en el SQL Editor de un proyecto de Supabase
--   NUEVO (vacío). Las secciones 6 y 7 usan objetos propios de Supabase
--   (publicación `supabase_realtime` y esquema `storage`): en un
--   PostgreSQL normal, sáltalas. La sección 9 es opcional (datos demo).
--
-- NOTAS IMPORTANTES
--   * Los ids son BIGINT/BIGSERIAL (no UUID): así está la base real y así
--     la usa la app. (CLAUDE.md dice uuid, pero está desactualizado.)
--   * Las políticas "dev_open_access_*" dejan las tablas abiertas a quien
--     tenga la llave pública: sirven para desarrollo, NO para producción.
--     `pagos` y `suscripciones` son de solo lectura para la app; solo las
--     Edge Functions (service role) escriben en ellas.
--   * Para borrar un esquema anterior antes de correr esto, existe
--     docs/db/reset_schema.sql (BORRA TODO: tablas, tipos y datos).
--   * No incluye datos de usuarios reales ni los datos de prueba de menús
--     y promociones (dependen de ids de comercios de la base original).
-- =====================================================================


-- #####################################################################
-- 1. ESQUEMA BASE (usuarios, turistas, comercios, viajes, gastos, lugares, actividades, presupuesto por categorías, viajes en grupo + catálogos y RLS)
-- (origen: docs/db/schema.sql)
-- #####################################################################

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
  foto_url          TEXT,
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
  foto_url      TEXT,
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

-- HU-05 (mejora "gestor de presupuesto"): categorías de presupuesto
-- personalizables por viaje, en vez de las 5 columnas fijas que tenía
-- `viajes` (costo_tours/costo_restaurantes/costo_discotecas/
-- costo_souvenirs/costo_actividades_pagas, que siguen ahí sin usarse
-- desde la app). Ver docs/db/hu05_presupuesto_categorias.sql.
CREATE TABLE presupuesto_categorias (
  id                  BIGSERIAL PRIMARY KEY,
  viaje_id            BIGINT NOT NULL REFERENCES viajes(id) ON DELETE CASCADE,
  nombre              VARCHAR(80) NOT NULL,
  monto               NUMERIC(12,2) NOT NULL DEFAULT 0,
  orden               INT NOT NULL DEFAULT 0,
  -- HU-13 (mejora "gestor de presupuesto", punto 3): vínculo opcional a
  -- la categoría de gasto real, para comparar estimado vs. gastado por
  -- categoría (los nombres de `presupuesto_categorias` son libres; los
  -- de `categorias_gasto` son una lista fija, no coinciden por texto).
  categoria_gasto_id  INT REFERENCES categorias_gasto(id),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_presupuesto_categorias_updated_at BEFORE UPDATE ON presupuesto_categorias
  FOR EACH ROW EXECUTE FUNCTION set_timestamp();
CREATE INDEX idx_presupuesto_categorias_viaje ON presupuesto_categorias(viaje_id);

-- HU-16 (gestión de viajes en grupo): ver docs/db/hu16_colaboradores_historial.sql
-- para el detalle de las decisiones. El dueño del viaje sigue siendo
-- `viajes.turista_id`; esta tabla solo guarda a los demás colaboradores.
CREATE TABLE viaje_colaboradores (
  id            BIGSERIAL PRIMARY KEY,
  viaje_id      BIGINT NOT NULL REFERENCES viajes(id) ON DELETE CASCADE,
  usuario_id    BIGINT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  invitado_por  BIGINT REFERENCES usuarios(id) ON DELETE SET NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (viaje_id, usuario_id)
);
CREATE INDEX idx_viaje_colaboradores_viaje ON viaje_colaboradores(viaje_id);
CREATE INDEX idx_viaje_colaboradores_usuario ON viaje_colaboradores(usuario_id);

-- Una fila por campo editado, ya formateado para mostrar (solo lectura).
CREATE TABLE viaje_historial (
  id              BIGSERIAL PRIMARY KEY,
  viaje_id        BIGINT NOT NULL REFERENCES viajes(id) ON DELETE CASCADE,
  usuario_id      BIGINT REFERENCES usuarios(id) ON DELETE SET NULL,
  campo           VARCHAR(60) NOT NULL,
  valor_anterior  TEXT,
  valor_nuevo     TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_viaje_historial_viaje ON viaje_historial(viaje_id, created_at DESC);

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
ALTER TABLE presupuesto_categorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE viaje_colaboradores    ENABLE ROW LEVEL SECURITY;
ALTER TABLE viaje_historial        ENABLE ROW LEVEL SECURITY;

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
CREATE POLICY "dev_open_access_presupuesto_categorias" ON presupuesto_categorias FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "dev_open_access_viaje_colaboradores" ON viaje_colaboradores FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "dev_open_access_viaje_historial"     ON viaje_historial     FOR ALL USING (true) WITH CHECK (true);

-- =====================================================================
-- FIN
-- =====================================================================


-- #####################################################################
-- 2. MENÚS Y PRODUCTOS DE COMERCIO + columnas nuevas de actividades
-- (origen: docs/db/hu_comercio_menus_actividades.sql)
-- #####################################################################

-- Persistencia real para "Mis menús" y "Mis actividades" del lado
-- comercio (`home_screen_comercio.dart`, `create_menu_screen.dart`,
-- `create_activity_screen.dart`, `menu_detail_screen.dart`). Hasta
-- ahora esas tres pantallas solo guardaban en memoria (`State` local)
-- y todo se perdía al salir de la pantalla — este script agrega lo
-- que falta en el esquema para que `MenusRepository` y los nuevos
-- métodos de `PlacesMapRepository` puedan persistir de verdad.
--
-- Corre esto DESPUÉS de schema.sql (y de las demás migraciones
-- incrementales ya aplicadas). Mismo patrón de RLS "dev_open_access"
-- que el resto del esquema (ver la nota #2 en schema.sql).

BEGIN;

-- =====================================================================
-- 1) MENÚS Y PRODUCTOS (no existía ninguna tabla para esto)
-- =====================================================================
--
-- `categoria` es texto libre (no un FK a una tabla de categorías): el
-- dropdown de `create_menu_screen.dart` ya tiene una lista fija propia
-- ("Comidas rápidas", "Bebidas", ...) que no corresponde a ninguna
-- tabla de categorías existente (`categorias_lugar`/`categorias_comercio`
-- son para lugares/comercios, no para menús) — crear una tabla nueva
-- solo para esto era más complejidad de la que el caso pedía.

CREATE TABLE menus (
  id           BIGSERIAL PRIMARY KEY,
  comercio_id  BIGINT NOT NULL REFERENCES comercios(usuario_id) ON DELETE CASCADE,
  nombre       VARCHAR(150) NOT NULL,
  descripcion  TEXT,
  categoria    VARCHAR(80),
  disponible   BOOLEAN NOT NULL DEFAULT TRUE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER trg_menus_updated_at BEFORE UPDATE ON menus
  FOR EACH ROW EXECUTE FUNCTION set_timestamp();
CREATE INDEX idx_menus_comercio ON menus(comercio_id);

CREATE TABLE menu_productos (
  id           BIGSERIAL PRIMARY KEY,
  menu_id      BIGINT NOT NULL REFERENCES menus(id) ON DELETE CASCADE,
  nombre       VARCHAR(150) NOT NULL,
  descripcion  TEXT,
  precio       NUMERIC(12,2) NOT NULL,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT chk_menu_productos_precio CHECK (precio >= 0)
);
CREATE TRIGGER trg_menu_productos_updated_at BEFORE UPDATE ON menu_productos
  FOR EACH ROW EXECUTE FUNCTION set_timestamp();
CREATE INDEX idx_menu_productos_menu ON menu_productos(menu_id);

-- =====================================================================
-- 2) ACTIVIDADES: columnas que la UI de comercio ya captura pero la
--    tabla `actividades` (HU-07) todavía no tenía lugar para guardar.
-- =====================================================================
--
-- `categoria` (texto libre): igual que en `menus`, la lista de
-- categorías de `create_activity_screen.dart` ("Fiesta", "Promoción",
-- "Clase", ...) es propia de actividades de comercio, no coincide con
-- `categorias_lugar` (que es para lugares de interés en el mapa) — se
-- deja `categoria_id` como está (sin usar desde este flujo) y se
-- agrega esta columna aparte en vez de forzar el dropdown a la lista
-- de `categorias_lugar`.
--
-- `estado` reemplaza para esta pantalla al booleano `activo` (que ya
-- existía pero solo distingue 2 estados, no los 3 que pide la UI:
-- Activa/Pausada/Borrador) — `activo` se sigue manteniendo en sync
-- (true solo cuando estado='activa') porque `PlacesMapRepository.
-- fetchActividadesDelLugar` (usado del lado turista, en el mapa) ya
-- filtra por `activo = true` y no debe dejar de funcionar.
--
-- `fecha_inicio`/`fecha_fin`: el formulario ya las pide pero no
-- existían en la tabla.
ALTER TABLE actividades ADD COLUMN IF NOT EXISTS categoria VARCHAR(80);
ALTER TABLE actividades ADD COLUMN IF NOT EXISTS estado VARCHAR(20) NOT NULL DEFAULT 'borrador';
ALTER TABLE actividades ADD COLUMN IF NOT EXISTS fecha_inicio DATE;
ALTER TABLE actividades ADD COLUMN IF NOT EXISTS fecha_fin DATE;
ALTER TABLE actividades DROP CONSTRAINT IF EXISTS chk_actividades_estado;
ALTER TABLE actividades ADD CONSTRAINT chk_actividades_estado
  CHECK (estado IN ('activa', 'pausada', 'borrador'));

COMMIT;

ALTER TABLE menus          ENABLE ROW LEVEL SECURITY;
ALTER TABLE menu_productos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "dev_open_access_menus"          ON menus          FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "dev_open_access_menu_productos" ON menu_productos FOR ALL USING (true) WITH CHECK (true);


-- #####################################################################
-- 3. PAGOS Y SUSCRIPCIONES PREMIUM (HU-22)
-- (origen: docs/db/hu22_suscripciones_pagos.sql)
-- #####################################################################

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


-- #####################################################################
-- 4. TRIGGER: activar Premium cuando un pago queda aprobado (HU-22)
-- (origen: docs/db/hu22_trigger_activar_premium.sql)
-- #####################################################################

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


-- #####################################################################
-- 5. TIPOS DE PRODUCTO + cancelar / cambiar plan (HU-20, HU-23)
-- (origen: docs/db/hu20_hu23_menus_suscripcion.sql)
-- #####################################################################

-- HU-20 (TG-267) y HU-23 (TG-269): lo que les falta al esquema para
-- cerrar las dos historias. HU-11 no necesita tablas: sus preferencias
-- ("Mostrar alertas", resumen diario, etc.) viven en el dispositivo
-- con `shared_preferences`, igual que el control de recordatorios ya
-- mostrados.
--
-- Corre esto DESPUÉS de hu_comercio_menus_actividades.sql y de
-- hu22_suscripciones_pagos.sql. Se puede correr más de una vez.

BEGIN;

-- =====================================================================
-- 1) HU-20 CA2: productos organizados por tipo dentro del menú
-- =====================================================================
ALTER TABLE menu_productos
  ADD COLUMN IF NOT EXISTS categoria VARCHAR(20) NOT NULL DEFAULT 'plato';
ALTER TABLE menu_productos DROP CONSTRAINT IF EXISTS chk_menu_productos_categoria;
ALTER TABLE menu_productos ADD CONSTRAINT chk_menu_productos_categoria
  CHECK (categoria IN ('plato', 'bebida', 'postre', 'otro'));

-- HU-20 CA3: el precio debe ser mayor a cero (antes se permitía 0).
-- NOT VALID: no revisa filas viejas con precio 0, solo las nuevas o
-- las que se editen.
ALTER TABLE menu_productos DROP CONSTRAINT IF EXISTS chk_menu_productos_precio;
ALTER TABLE menu_productos ADD CONSTRAINT chk_menu_productos_precio
  CHECK (precio > 0) NOT VALID;

-- =====================================================================
-- 2) HU-23: cancelar y programar cambio de plan
-- =====================================================================
--
-- Cancelar NO corta el acceso: la suscripción sigue 'activa' hasta
-- `fecha_fin` (ya está pagada) y `cancelada_at` marca que no se va a
-- renovar. `plan_siguiente` guarda el plan al que pasa al vencer
-- (cambio anual -> mensual, CA3). Las dos columnas las escribe solo la
-- Edge Function `suscripcion-gestionar` (la tabla sigue siendo de
-- solo lectura para la app).
ALTER TABLE suscripciones ADD COLUMN IF NOT EXISTS cancelada_at TIMESTAMPTZ;
ALTER TABLE suscripciones ADD COLUMN IF NOT EXISTS plan_siguiente VARCHAR(20);
ALTER TABLE suscripciones DROP CONSTRAINT IF EXISTS chk_suscripciones_plan_siguiente;
ALTER TABLE suscripciones ADD CONSTRAINT chk_suscripciones_plan_siguiente
  CHECK (plan_siguiente IS NULL OR plan_siguiente IN ('mensual', 'anual'));

COMMIT;


-- #####################################################################
-- 6. TIEMPO REAL: tablas publicadas en Supabase Realtime (HU-20)
-- (origen: docs/db/hu20_realtime.sql)
-- #####################################################################

-- HU-20 / TG-289: sincronización en tiempo real de la información del
-- comercio hacia la vista del viajero (mapa, "Comercios cercanos" y la
-- ficha del lugar — ver `lib/features/places_map/data/places_realtime.dart`).
--
-- Supabase Realtime solo emite cambios de las tablas que están en la
-- publicación `supabase_realtime`. Este script las agrega (si ya están,
-- no hace nada) y pone REPLICA IDENTITY FULL para que los DELETE traigan
-- la fila completa (así la app sabe de qué comercio era lo borrado).
--
-- Corre esto DESPUÉS de hu_comercio_menus_actividades.sql. Se puede
-- correr más de una vez.

DO $$
DECLARE
  t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY['comercios', 'menus', 'menu_productos', 'actividades'] LOOP
    IF NOT EXISTS (
      SELECT 1 FROM pg_publication_tables
       WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = t
    ) THEN
      EXECUTE format('ALTER PUBLICATION supabase_realtime ADD TABLE public.%I', t);
    END IF;
    EXECUTE format('ALTER TABLE public.%I REPLICA IDENTITY FULL', t);
  END LOOP;
END $$;


-- #####################################################################
-- 7. STORAGE: bucket público 'comercios' para fotos de portada (HU-20)
-- (origen: docs/db/hu20_foto_comercio.sql)
-- #####################################################################

-- HU-20: foto de portada del comercio. El comercio la sube desde
-- "Mi negocio" y es la que ve el viajero en "Comercios cercanos", en la
-- ficha del lugar y en la tarjeta destacada de Inicio (`comercios.foto_url`,
-- columna que ya existe desde hu07_fotos.sql).
--
-- Crea el bucket público `comercios` en Supabase Storage (solo imágenes,
-- máx. 5 MB) y sus permisos. Cada comercio guarda sus fotos en la carpeta
-- `<usuario_id>/`.
--
-- ⚠️ Mismo criterio que el resto del esquema en desarrollo
-- ("dev_open_access"): la app no tiene sesión de Supabase Auth para los
-- comercios (entran con Firebase), así que la escritura en el bucket se
-- permite con la llave pública. Antes de producción conviene restringirla
-- a un usuario autenticado dueño de la carpeta.
--
-- Se puede correr más de una vez.

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('comercios', 'comercios', TRUE, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO UPDATE
  SET public = EXCLUDED.public,
      file_size_limit = EXCLUDED.file_size_limit,
      allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS "comercios_fotos_select" ON storage.objects;
DROP POLICY IF EXISTS "comercios_fotos_insert" ON storage.objects;
DROP POLICY IF EXISTS "comercios_fotos_update" ON storage.objects;
DROP POLICY IF EXISTS "comercios_fotos_delete" ON storage.objects;

CREATE POLICY "comercios_fotos_select" ON storage.objects
  FOR SELECT USING (bucket_id = 'comercios');
CREATE POLICY "comercios_fotos_insert" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'comercios');
CREATE POLICY "comercios_fotos_update" ON storage.objects
  FOR UPDATE USING (bucket_id = 'comercios') WITH CHECK (bucket_id = 'comercios');
CREATE POLICY "comercios_fotos_delete" ON storage.objects
  FOR DELETE USING (bucket_id = 'comercios');


-- #####################################################################
-- 8. PROMOCIONES / ACTIVIDADES SOLO PREMIUM
-- (origen: docs/db/hu_promociones_premium.sql)
-- #####################################################################

-- HU "Gestionar promociones Premium": cada actividad puede ser para todo
-- el público o solo para turistas Premium. Las promociones (categoría
-- 'Promoción') son siempre exclusivas Premium.
--
-- Cambio aditivo: la columna nueva tiene valor por defecto, así que la
-- app que ya estaba desplegada sigue funcionando igual.

BEGIN;

ALTER TABLE actividades
  ADD COLUMN IF NOT EXISTS solo_premium BOOLEAN NOT NULL DEFAULT FALSE;

-- Las promociones existentes ya eran solo para Premium (HU-24).
UPDATE actividades SET solo_premium = TRUE WHERE categoria = 'Promoción';

CREATE INDEX IF NOT EXISTS idx_actividades_publicas
  ON actividades (activo, solo_premium);

COMMIT;


-- #####################################################################
-- 9. (OPCIONAL) DATOS DE EJEMPLO: lugares turísticos de Medellín para el mapa
-- (origen: docs/db/hu07_seed_places.sql)
-- #####################################################################

-- HU-07: datos de prueba para poder ver el mapa con marcadores reales.
--
-- Los comercios registrados vía HU-02 todavía no tienen latitud/longitud
-- (el formulario de registro no las captura — es una brecha de esa
-- historia, no de HU-07), así que por ahora `comercios` no aporta
-- marcadores reales. `lugares_interes` sí se puede poblar directamente
-- porque `comercio_id` es opcional (nullable): son sitios turísticos
-- independientes, no ligados a un comercio.
--
-- `foto_url` usa fotos reales del lugar (Wikimedia Commons, licencia
-- libre) — ver docs/db/hu07_fotos.sql para el detalle de cada fuente.
-- "Parque Lleras" y "Mercado del Río" quedan sin foto porque no existe
-- un archivo de Commons específico de esos lugares.
--
-- IMPORTANTE: se usa la URL directa de upload.wikimedia.org (no
-- commons.wikimedia.org/wiki/Special:FilePath/...) porque en Flutter
-- web (CanvasKit) Image.network hace la petición vía XHR/fetch, y el
-- dominio commons.wikimedia.org no manda cabecera CORS en su redirect
-- (aunque el destino final sí la tiene) — eso rompía la carga con
-- "blocked by CORS policy". La URL de upload.wikimedia.org sí trae
-- 'access-control-allow-origin: *' directamente, sin redirect.

insert into public.lugares_interes
  (categoria_id, nombre, descripcion, direccion, latitud, longitud, foto_url)
values
  (
    (select id from categorias_lugar where nombre = 'Parque'),
    'Parque Arví',
    'Reserva natural y ecoturística en las afueras de Medellín.',
    'Vereda Mazo, Santa Elena, Medellín',
    6.2678, -75.5040,
    'https://upload.wikimedia.org/wikipedia/commons/a/ab/Bosque_Parque_Arv%C3%AD.JPG'
  ),
  (
    (select id from categorias_lugar where nombre = 'Mirador'),
    'Pueblito Paisa',
    'Réplica de un pueblo antioqueño tradicional en el Cerro Nutibara, con mirador panorámico de la ciudad.',
    'Cerro Nutibara, Medellín',
    6.2461, -75.5720,
    'https://upload.wikimedia.org/wikipedia/commons/b/bc/Pueblito_Paisa-Medellin.JPG'
  ),
  (
    (select id from categorias_lugar where nombre = 'Museo'),
    'Museo de Antioquia',
    'Museo de arte junto a la Plaza Botero, con obras de Fernando Botero.',
    'Carrera 52 #52-43, Medellín',
    6.2530, -75.5687,
    'https://upload.wikimedia.org/wikipedia/commons/8/81/Medell%C3%ADn%2C_Museo_de_Antioquia%2C_2023-07_CN-01.jpg'
  ),
  (
    (select id from categorias_lugar where nombre = 'Parque'),
    'Jardín Botánico de Medellín',
    'Jardín botánico con orquideorama y senderos naturales.',
    'Carrera 52 #73-298, Medellín',
    6.2699, -75.5654,
    'https://upload.wikimedia.org/wikipedia/commons/b/b6/Jardin_Botanico_Medellin-Orquideorama.jpg'
  ),
  (
    (select id from categorias_lugar where nombre = 'Museo'),
    'Parque Explora',
    'Museo interactivo de ciencia con acuario y planetario.',
    'Carrera 52 #73-75, Medellín',
    6.2707, -75.5657,
    'https://upload.wikimedia.org/wikipedia/commons/f/fc/Parque_Explora_%28Medell%C3%ADn%2C_Colombia%29.JPG'
  ),
  (
    (select id from categorias_lugar where nombre = 'Discoteca'),
    'Parque Lleras',
    'Epicentro de la vida nocturna de El Poblado: bares, discotecas y restaurantes.',
    'Parque Lleras, El Poblado, Medellín',
    6.2088, -75.5658,
    null
  ),
  (
    (select id from categorias_lugar where nombre = 'Tour'),
    'Comuna 13',
    'Barrio icónico de Medellín, famoso por sus escaleras eléctricas, grafitis y tours guiados.',
    'Comuna 13, San Javier, Medellín',
    6.2508, -75.5747,
    'https://upload.wikimedia.org/wikipedia/commons/7/79/Escaleras_el%C3%A9ctricas_de_la_comuna_13%2C_Medell%C3%ADn_-_01.jpg'
  ),
  (
    (select id from categorias_lugar where nombre = 'Restaurante'),
    'Mercado del Río',
    'Mercado gastronómico con más de 30 locales de comida variada.',
    'Calle 24 #47-33, Medellín',
    6.1998, -75.5747,
    null
  ),
  (
    (select id from categorias_lugar where nombre = 'Otro'),
    'Plaza Mayor Medellín',
    'Centro de convenciones y exposiciones de la ciudad.',
    'Calle 41 #55-80, Medellín',
    6.2108, -75.5738,
    'https://upload.wikimedia.org/wikipedia/commons/b/bf/Plaza_Mayor_en_navidad_-_Medell%C3%ADn.JPG'
  ),
  (
    (select id from categorias_lugar where nombre = 'Parque'),
    'Parque de los Pies Descalzos',
    'Parque urbano diseñado para caminar descalzo sobre arena, grama y agua.',
    'Carrera 58 #42-125, Medellín',
    6.2436, -75.5697,
    'https://upload.wikimedia.org/wikipedia/commons/7/73/Parque_Pies_Descalzos-Medellin.JPG'
  ),
  (
    (select id from categorias_lugar where nombre = 'Museo'),
    'Museo El Castillo',
    'Castillo estilo gótico normando convertido en museo, con jardines y vista al valle.',
    'Calle 9 Sur #32-269, Medellín',
    6.2010, -75.5750,
    'https://upload.wikimedia.org/wikipedia/commons/1/18/El_Castillo-exterior.JPG'
  ),
  (
    (select id from categorias_lugar where nombre = 'Otro'),
    'Basílica Metropolitana',
    'Catedral de ladrillo, una de las más grandes del mundo en ese material.',
    'Parque Bolívar, Medellín',
    6.2486, -75.5742,
    'https://upload.wikimedia.org/wikipedia/commons/4/4c/Atrio_de_Catedral_Metropolitana_Medellin.JPG'
  );

-- =====================================================================
-- FIN
-- =====================================================================
