-- HU-18: ajuste de parámetros de respaldo (después de hu18_estimacion_presupuesto.sql).
--
-- Con 1.30 y 55 km/h las rutas sin cargar salían cortas para las vías de
-- montaña: Pasto→Cali daba 341 km / 6,2 h (real ~390 km / 9 h) y
-- Medellín–Bogotá tiene 240 km en línea recta vs. 415 km por carretera.
-- Con 1.50 y 45 km/h Pasto→Cali queda en ~393 km / 8,7 h.
-- Se puede volver a correr.

UPDATE estimacion_parametros SET valor = 1.50 WHERE clave = 'factor_vias';
UPDATE estimacion_parametros SET valor = 45   WHERE clave = 'velocidad_bus_kmh';
