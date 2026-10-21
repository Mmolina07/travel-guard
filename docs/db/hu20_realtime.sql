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
