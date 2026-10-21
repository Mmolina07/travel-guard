-- Datos de prueba: menús y productos para los comercios que salen en el
-- mapa (HU-20). Sirve para ver desde un turista la sección "Menú" en la
-- ficha del comercio, organizada por Platos / Bebidas / Postres / Otros.
--
-- Comercios (usuario_id): 5 La Migueria · 8 Pueblito paisa · 12 comida ·
-- 14 comida rapida · 16 comida · 17 Test2. El 1 ("test") no tiene
-- ubicación, así que no sale en el mapa y no se incluye.
--
-- Precios en COP. Se puede correr más de una vez: cada menú solo se crea
-- si ese comercio todavía no tiene un menú con ese nombre.
--
-- Para probar el filtro de disponibilidad, "Menú de temporada" (Pueblito
-- paisa) va con disponible = false: el comercio lo ve, el turista NO.

BEGIN;

CREATE OR REPLACE FUNCTION pg_temp.seed_menu(
  p_comercio BIGINT, p_nombre TEXT, p_descripcion TEXT, p_categoria TEXT,
  p_disponible BOOLEAN, p_productos JSONB
) RETURNS VOID AS $$
DECLARE
  v_menu BIGINT;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM comercios WHERE usuario_id = p_comercio) THEN
    RAISE NOTICE 'Comercio % no existe, se omite "%"', p_comercio, p_nombre;
    RETURN;
  END IF;
  IF EXISTS (SELECT 1 FROM menus WHERE comercio_id = p_comercio AND nombre = p_nombre) THEN
    RETURN;
  END IF;

  INSERT INTO menus (comercio_id, nombre, descripcion, categoria, disponible)
  VALUES (p_comercio, p_nombre, p_descripcion, p_categoria, p_disponible)
  RETURNING id INTO v_menu;

  INSERT INTO menu_productos (menu_id, nombre, descripcion, precio, categoria)
  SELECT v_menu, p->>'nombre', NULLIF(p->>'descripcion', ''), (p->>'precio')::NUMERIC, p->>'categoria'
    FROM jsonb_array_elements(p_productos) AS p;
END;
$$ LANGUAGE plpgsql;

-- 5 · La Migueria (Laureles) — arepas y desayunos
SELECT pg_temp.seed_menu(5, 'Desayunos paisas', 'Arepas recién asadas y desayunos completos, de 7 a 11 a.m.', 'Desayunos', TRUE, '[
  {"nombre": "Arepa de chócolo con quesito", "descripcion": "Arepa dulce de maíz tierno con quesito campesino", "precio": 9500, "categoria": "plato"},
  {"nombre": "Calentado paisa", "descripcion": "Fríjoles, arroz, huevo, arepa y chorizo", "precio": 18000, "categoria": "plato"},
  {"nombre": "Huevos pericos con arepa", "descripcion": "", "precio": 12000, "categoria": "plato"},
  {"nombre": "Arepa rellena de carne desmechada", "descripcion": "Con hogao y queso", "precio": 14500, "categoria": "plato"},
  {"nombre": "Chocolate santafereño", "descripcion": "Con queso y pan", "precio": 7000, "categoria": "bebida"},
  {"nombre": "Tinto campesino", "descripcion": "", "precio": 2500, "categoria": "bebida"},
  {"nombre": "Jugo de naranja natural", "descripcion": "", "precio": 6000, "categoria": "bebida"},
  {"nombre": "Buñuelo", "descripcion": "", "precio": 2500, "categoria": "otro"}
]');

-- 8 · Pueblito paisa — comida típica
SELECT pg_temp.seed_menu(8, 'Menú típico antioqueño', 'Lo más tradicional de la cocina paisa, porciones generosas.', 'Menú turístico', TRUE, '[
  {"nombre": "Bandeja paisa", "descripcion": "Fríjoles, arroz, carne molida, chicharrón, chorizo, huevo, maduro, aguacate y arepa", "precio": 38000, "categoria": "plato"},
  {"nombre": "Sancocho de gallina", "descripcion": "Con arroz, aguacate y arepa", "precio": 32000, "categoria": "plato"},
  {"nombre": "Mondongo antioqueño", "descripcion": "", "precio": 29000, "categoria": "plato"},
  {"nombre": "Chicharrón carnudo", "descripcion": "Con arepa y limón", "precio": 22000, "categoria": "plato"},
  {"nombre": "Aguapanela con limón", "descripcion": "", "precio": 5000, "categoria": "bebida"},
  {"nombre": "Limonada de coco", "descripcion": "", "precio": 11000, "categoria": "bebida"},
  {"nombre": "Mazamorra con panela", "descripcion": "", "precio": 7000, "categoria": "postre"},
  {"nombre": "Brevas con arequipe", "descripcion": "", "precio": 9000, "categoria": "postre"}
]');
SELECT pg_temp.seed_menu(8, 'Menú de temporada', 'Platos de Feria de las Flores (oculto: aún no disponible).', 'Otro', FALSE, '[
  {"nombre": "Fiambre de Feria", "descripcion": "Envuelto en hoja de plátano", "precio": 30000, "categoria": "plato"},
  {"nombre": "Natilla con buñuelo", "descripcion": "", "precio": 8000, "categoria": "postre"}
]');

-- 12 · comida — almuerzo ejecutivo
SELECT pg_temp.seed_menu(12, 'Almuerzo ejecutivo', 'Sopa del día + plato fuerte + jugo, de lunes a viernes.', 'Almuerzos', TRUE, '[
  {"nombre": "Ejecutivo de pechuga a la plancha", "descripcion": "Con arroz, ensalada y papa criolla", "precio": 19000, "categoria": "plato"},
  {"nombre": "Ejecutivo de carne asada", "descripcion": "Con arroz, fríjoles y maduro", "precio": 21000, "categoria": "plato"},
  {"nombre": "Ejecutivo vegetariano", "descripcion": "Lentejas, arroz integral, ensalada y aguacate", "precio": 18000, "categoria": "plato"},
  {"nombre": "Sopa del día", "descripcion": "", "precio": 7000, "categoria": "plato"},
  {"nombre": "Jugo de mora en agua", "descripcion": "", "precio": 5000, "categoria": "bebida"},
  {"nombre": "Jugo de lulo en leche", "descripcion": "", "precio": 6500, "categoria": "bebida"},
  {"nombre": "Gelatina", "descripcion": "", "precio": 3000, "categoria": "postre"}
]');

-- 14 · comida rapida
SELECT pg_temp.seed_menu(14, 'Comidas rápidas', 'Hamburguesas, perros y salchipapas hasta la medianoche.', 'Comidas rápidas', TRUE, '[
  {"nombre": "Hamburguesa clásica", "descripcion": "Carne de res 150 g, queso, tocineta y papas", "precio": 22000, "categoria": "plato"},
  {"nombre": "Hamburguesa doble", "descripcion": "Doble carne, doble queso", "precio": 29000, "categoria": "plato"},
  {"nombre": "Perro caliente especial", "descripcion": "Salchicha americana, queso gratinado y papita", "precio": 16000, "categoria": "plato"},
  {"nombre": "Salchipapa para dos", "descripcion": "", "precio": 24000, "categoria": "plato"},
  {"nombre": "Gaseosa 400 ml", "descripcion": "", "precio": 4000, "categoria": "bebida"},
  {"nombre": "Malteada de vainilla", "descripcion": "", "precio": 12000, "categoria": "bebida"},
  {"nombre": "Porción de papas a la francesa", "descripcion": "", "precio": 7000, "categoria": "otro"},
  {"nombre": "Salsas extra", "descripcion": "Piña, tártara o BBQ", "precio": 1500, "categoria": "otro"}
]');

-- 16 · comida — parrilla
SELECT pg_temp.seed_menu(16, 'Parrilla y asados', 'Cortes a la parrilla con acompañamientos.', 'Cenas', TRUE, '[
  {"nombre": "Churrasco 350 g", "descripcion": "Con papa salada y chimichurri", "precio": 42000, "categoria": "plato"},
  {"nombre": "Punta de anca", "descripcion": "Con yuca frita y ensalada", "precio": 45000, "categoria": "plato"},
  {"nombre": "Costillas BBQ", "descripcion": "", "precio": 39000, "categoria": "plato"},
  {"nombre": "Picada para compartir", "descripcion": "Chorizo, morcilla, chicharrón, papa criolla y arepa", "precio": 58000, "categoria": "plato"},
  {"nombre": "Cerveza nacional", "descripcion": "", "precio": 6000, "categoria": "bebida"},
  {"nombre": "Limonada de hierbabuena", "descripcion": "", "precio": 8000, "categoria": "bebida"},
  {"nombre": "Postre de natas", "descripcion": "", "precio": 9000, "categoria": "postre"}
]');

-- 17 · Test2 (Belén) — postres y café
SELECT pg_temp.seed_menu(17, 'Postres y café', 'Repostería artesanal y café de origen.', 'Postres', TRUE, '[
  {"nombre": "Torta de chocolate", "descripcion": "Porción", "precio": 9500, "categoria": "postre"},
  {"nombre": "Cheesecake de maracuyá", "descripcion": "", "precio": 11000, "categoria": "postre"},
  {"nombre": "Obleas con arequipe", "descripcion": "", "precio": 6000, "categoria": "postre"},
  {"nombre": "Copa de helado (3 bolas)", "descripcion": "", "precio": 12000, "categoria": "postre"},
  {"nombre": "Café americano", "descripcion": "Café de origen Antioquia", "precio": 4500, "categoria": "bebida"},
  {"nombre": "Capuchino", "descripcion": "", "precio": 7000, "categoria": "bebida"},
  {"nombre": "Pandebono", "descripcion": "", "precio": 3000, "categoria": "otro"}
]');

COMMIT;

-- Verificación: debería listar 7 menús (6 disponibles + 1 oculto).
SELECT c.nombre_comercio, m.nombre AS menu, m.disponible, count(p.id) AS productos
  FROM menus m
  JOIN comercios c ON c.usuario_id = m.comercio_id
  LEFT JOIN menu_productos p ON p.menu_id = m.id
 GROUP BY c.nombre_comercio, m.nombre, m.disponible
 ORDER BY c.nombre_comercio, m.nombre;
