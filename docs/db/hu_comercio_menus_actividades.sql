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
