-- Datos de ejemplo de la HU de promociones Premium: promociones y dos
-- actividades "Solo Premium" en comercios reales, publicadas y vigentes
-- 30-45 días desde hoy. Idempotente: no duplica si ya existe una
-- actividad con el mismo nombre en el mismo comercio.

INSERT INTO actividades
  (comercio_id, nombre, descripcion, categoria, precio, estado, activo, solo_premium, fecha_inicio, fecha_fin)
SELECT v.comercio_id, v.nombre, v.descripcion, v.categoria, v.precio, 'activa', TRUE, TRUE,
       current_date, current_date + v.dias
FROM (VALUES
  (5,  '2x1 en arepas rellenas', 'Pide una arepa rellena y la segunda va por cuenta de la casa. Válido de lunes a jueves.', 'Promoción', 18000, 30),
  (5,  '15% de descuento en la cuenta', 'Muestra tu TravelGuard Premium al pagar y te descontamos el 15% del total.', 'Promoción', NULL, 45),
  (8,  'Tinto y buñuelo gratis', 'Con cualquier plato típico te regalamos un tinto con buñuelo recién hecho.', 'Promoción', NULL, 30),
  (8,  'Recorrido guiado con descuento', 'Recorrido por el Pueblito Paisa con guía local a mitad de precio para Premium.', 'Promoción', 20000, 45),
  (18, 'Almuerzo ejecutivo + postre', 'Sopa del día, seco, jugo natural y postre de la casa a precio especial.', 'Promoción', 16000, 30),
  (14, 'Combo viajero', 'Hamburguesa, papas y gaseosa con 20% de descuento para turistas Premium.', 'Promoción', 22000, 30),
  (18, 'Clase privada de cocina paisa', 'Aprende a preparar una bandeja paisa con nuestro chef. Cupos limitados.', 'Clase', 60000, 45),
  (8,  'Noche de música en vivo VIP', 'Mesa reservada y bebida de bienvenida en nuestra noche de trova.', 'Evento', 35000, 30)
) AS v(comercio_id, nombre, descripcion, categoria, precio, dias)
WHERE EXISTS (SELECT 1 FROM comercios c WHERE c.usuario_id = v.comercio_id)
  AND NOT EXISTS (
    SELECT 1 FROM actividades a WHERE a.comercio_id = v.comercio_id AND a.nombre = v.nombre
  );
