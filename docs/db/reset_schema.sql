-- =====================================================================
-- RESET COMPLETO DEL ESQUEMA DE TRAVELGUARD
-- Basado en el travelguard_drop_all.sql real del proyecto.
-- Borra TODAS las tablas y enums (existentes o no: IF EXISTS + CASCADE).
-- Úsalo junto con schema.sql para empezar de cero.
-- =====================================================================

BEGIN;

DROP TABLE IF EXISTS reportes_generados      CASCADE;
DROP TABLE IF EXISTS resenas                 CASCADE;
DROP TABLE IF EXISTS favoritos               CASCADE;
DROP TABLE IF EXISTS pagos_suscripcion       CASCADE;
DROP TABLE IF EXISTS suscripciones           CASCADE;
DROP TABLE IF EXISTS planes_suscripcion      CASCADE;
DROP TABLE IF EXISTS promociones             CASCADE;
DROP TABLE IF EXISTS productos_comercio      CASCADE;
DROP TABLE IF EXISTS recomendaciones_log     CASCADE;
DROP TABLE IF EXISTS actividades             CASCADE;
DROP TABLE IF EXISTS lugares_interes         CASCADE;
DROP TABLE IF EXISTS categorias_lugar        CASCADE;
DROP TABLE IF EXISTS rutas_consultadas       CASCADE;
DROP TABLE IF EXISTS reportes                CASCADE;
DROP TABLE IF EXISTS franjas_riesgo          CASCADE;
DROP TABLE IF EXISTS zonas_riesgo            CASCADE;
DROP TABLE IF EXISTS niveles_riesgo          CASCADE;
DROP TABLE IF EXISTS notificaciones          CASCADE;
DROP TABLE IF EXISTS limites_categoria       CASCADE;
DROP TABLE IF EXISTS gastos                  CASCADE;
DROP TABLE IF EXISTS recibos                 CASCADE;
DROP TABLE IF EXISTS categorias_gasto        CASCADE;
DROP TABLE IF EXISTS presupuestos_diarios    CASCADE;
DROP TABLE IF EXISTS viajes                  CASCADE;
DROP TABLE IF EXISTS administradores         CASCADE;
DROP TABLE IF EXISTS comercios               CASCADE;
DROP TABLE IF EXISTS categorias_comercio     CASCADE;
DROP TABLE IF EXISTS turistas                CASCADE;
DROP TABLE IF EXISTS tokens_recuperacion     CASCADE;
DROP TABLE IF EXISTS usuarios                CASCADE;

DROP TYPE IF EXISTS tipo_notificacion_enum   CASCADE;
DROP TYPE IF EXISTS estado_reporte_enum      CASCADE;
DROP TYPE IF EXISTS estado_pago_enum         CASCADE;
DROP TYPE IF EXISTS estado_suscripcion_enum  CASCADE;
DROP TYPE IF EXISTS periodicidad_enum        CASCADE;
DROP TYPE IF EXISTS tipo_descuento_enum      CASCADE;
DROP TYPE IF EXISTS estado_promocion_enum    CASCADE;
DROP TYPE IF EXISTS estado_ocr_enum          CASCADE;
DROP TYPE IF EXISTS estado_viaje_enum        CASCADE;
DROP TYPE IF EXISTS tipo_transporte_enum     CASCADE;
DROP TYPE IF EXISTS tipo_viaje_enum          CASCADE;
DROP TYPE IF EXISTS estado_usuario_enum      CASCADE;
DROP TYPE IF EXISTS proveedor_auth_enum      CASCADE;
DROP TYPE IF EXISTS tipo_usuario_enum        CASCADE;

DROP FUNCTION IF EXISTS set_timestamp() CASCADE;

COMMIT;
