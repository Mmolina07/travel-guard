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
