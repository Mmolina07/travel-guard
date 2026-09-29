-- HU-16 (Gestión de viajes en grupo): un viaje deja de ser propiedad de
-- un solo turista — el dueño (`viajes.turista_id`, sin cambios) puede
-- invitar a otros turistas por correo para que vean y editen el mismo
-- viaje, y cada edición de presupuesto queda registrada en un historial.
--
-- Decisiones (confirmadas con el usuario):
-- 1) Invitar por correo es inmediato: si el correo ya está registrado en
--    `usuarios` como turista, queda agregado de una vez a
--    `viaje_colaboradores` — no hay estado "pendiente" ni bandeja de
--    invitaciones, porque la app no tiene servicio de envío de correos.
-- 2) Un colaborador puede editar todo lo que el dueño (presupuesto,
--    categorías, hospedaje, emergencias, gastos), pero solo el dueño
--    puede invitar/quitar colaboradores o eliminar el viaje.
-- 3) El historial solo registra ediciones de campos (no altas/bajas de
--    colaboradores ni borrado del viaje).
--
-- Corre esto DESPUÉS de schema.sql (o de las migraciones incrementales
-- anteriores). Mismo patrón de RLS "dev_open_access" que el resto del
-- esquema (ver la nota #2 en schema.sql).

BEGIN;

-- Un turista por viaje (además del dueño) — el dueño NO tiene fila
-- propia aquí, se sigue identificando con `viajes.turista_id`.
--
-- `usuario_id` referencia `usuarios(id)` directamente (no
-- `turistas(usuario_id)`) para que Supabase pueda resolver el embed
-- `viaje_colaboradores -> usuarios -> turistas` en una sola consulta
-- (PostgREST solo arma el JOIN automático cuando hay una FK directa
-- entre las dos tablas del embed) — que sea turista se valida en la
-- app, en `TripRepository.addCollaboratorByEmail`.
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

-- Una fila por campo editado (no por "guardado" completo): si en una
-- sola edición cambian 2 campos, quedan 2 filas con el mismo
-- created_at. `valor_anterior`/`valor_nuevo` ya vienen formateados para
-- mostrar (p.ej. "$ 500.000"), no crudos — este historial es de solo
-- lectura, no hace falta poder recalcular con esos valores.
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

ALTER TABLE viaje_colaboradores ENABLE ROW LEVEL SECURITY;
ALTER TABLE viaje_historial     ENABLE ROW LEVEL SECURITY;

CREATE POLICY "dev_open_access_viaje_colaboradores" ON viaje_colaboradores FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "dev_open_access_viaje_historial"     ON viaje_historial     FOR ALL USING (true) WITH CHECK (true);
