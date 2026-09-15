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
