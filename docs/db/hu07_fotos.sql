-- HU-07: fotos reales de los lugares/comercios en el mapa.
--
-- Antes el detalle de cada punto (mapa, "Comercios cercanos", bottom
-- sheet de detalle) solo mostraba un ícono genérico según la categoría.
-- Se agrega una columna `foto_url` para poder mostrar una foto real del
-- lugar; si es null, la UI sigue cayendo de vuelta al ícono/gradiente
-- de CategoryVisual (no se rompe nada para los registros sin foto).

alter table public.comercios
  add column if not exists foto_url text;

alter table public.lugares_interes
  add column if not exists foto_url text;

-- Fotos reales (Wikimedia Commons, licencia libre) para los lugares de
-- interés sembrados en hu07_seed_places.sql. Se actualiza por nombre en
-- vez de reinsertar para no duplicar filas si el seed ya corrió.
--
-- "Parque Lleras" y "Mercado del Río" quedan sin foto: no existe un
-- archivo específico de esos lugares en Wikimedia Commons (solo fotos
-- de sitios de terceros con derechos no verificados) — se prefiere no
-- tener foto a mostrar una que no sea realmente del lugar.

update public.lugares_interes set foto_url =
  'https://upload.wikimedia.org/wikipedia/commons/a/ab/Bosque_Parque_Arv%C3%AD.JPG'
  where nombre = 'Parque Arví';

update public.lugares_interes set foto_url =
  'https://upload.wikimedia.org/wikipedia/commons/b/bc/Pueblito_Paisa-Medellin.JPG'
  where nombre = 'Pueblito Paisa';

update public.lugares_interes set foto_url =
  'https://upload.wikimedia.org/wikipedia/commons/8/81/Medell%C3%ADn%2C_Museo_de_Antioquia%2C_2023-07_CN-01.jpg'
  where nombre = 'Museo de Antioquia';

update public.lugares_interes set foto_url =
  'https://upload.wikimedia.org/wikipedia/commons/b/b6/Jardin_Botanico_Medellin-Orquideorama.jpg'
  where nombre = 'Jardín Botánico de Medellín';

update public.lugares_interes set foto_url =
  'https://upload.wikimedia.org/wikipedia/commons/f/fc/Parque_Explora_%28Medell%C3%ADn%2C_Colombia%29.JPG'
  where nombre = 'Parque Explora';

update public.lugares_interes set foto_url =
  'https://upload.wikimedia.org/wikipedia/commons/7/79/Escaleras_el%C3%A9ctricas_de_la_comuna_13%2C_Medell%C3%ADn_-_01.jpg'
  where nombre = 'Comuna 13';

update public.lugares_interes set foto_url =
  'https://upload.wikimedia.org/wikipedia/commons/b/bf/Plaza_Mayor_en_navidad_-_Medell%C3%ADn.JPG'
  where nombre = 'Plaza Mayor Medellín';

update public.lugares_interes set foto_url =
  'https://upload.wikimedia.org/wikipedia/commons/7/73/Parque_Pies_Descalzos-Medellin.JPG'
  where nombre = 'Parque de los Pies Descalzos';

update public.lugares_interes set foto_url =
  'https://upload.wikimedia.org/wikipedia/commons/1/18/El_Castillo-exterior.JPG'
  where nombre = 'Museo El Castillo';

update public.lugares_interes set foto_url =
  'https://upload.wikimedia.org/wikipedia/commons/4/4c/Atrio_de_Catedral_Metropolitana_Medellin.JPG'
  where nombre = 'Basílica Metropolitana';

-- 'Parque Lleras' y 'Mercado del Río' se dejan sin actualizar (foto_url
-- queda null) por lo explicado arriba.

-- Nota para una siguiente iteración: para que los comercios (HU-02)
-- también tengan foto real del negocio (no un stock genérico), lo
-- correcto es que el propio comercio suba su foto al registrarse —
-- eso requiere un bucket de Supabase Storage + UI de selección de
-- imagen en el formulario de registro, que todavía no está implementado.
