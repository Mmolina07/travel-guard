-- HU-05 / TG-141: agrega las columnas de costo que faltaban en `viajes`.
-- Úsalo SOLO si ya corriste schema.sql antes de este cambio (evita tener
-- que resetear toda la base de datos). Es aditivo, no borra nada.
--
-- El formulario de "Crear viaje" captura un monto para tours, restaurantes,
-- discotecas y souvenirs, pero el esquema original solo tenía flags
-- booleanos (incluye_tours_guia, etc.) sin dónde guardar el valor.

alter table public.viajes add column if not exists costo_tours numeric(12,2);
alter table public.viajes add column if not exists costo_restaurantes numeric(12,2);
alter table public.viajes add column if not exists costo_discotecas numeric(12,2);
alter table public.viajes add column if not exists costo_souvenirs numeric(12,2);
alter table public.viajes add column if not exists costo_actividades_pagas numeric(12,2);
