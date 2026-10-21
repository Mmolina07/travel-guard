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
