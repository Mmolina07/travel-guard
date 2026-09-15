-- HU-13 + HU-05 (mejora "gestor de presupuesto", punto 3): compara
-- estimado vs. gastado real POR CATEGORÍA, no solo el total del viaje.
--
-- Problema: las categorías de presupuesto (`presupuesto_categorias`,
-- ver hu05_presupuesto_categorias.sql) son de nombre libre ("Tours con
-- guía", "Restaurantes", etc.), mientras que los gastos reales (HU-13,
-- tabla `gastos`) se categorizan con la lista FIJA de
-- `categorias_gasto` (Comida, Movilidad, Actividades, Compras,
-- Hospedaje, Otros). Los nombres no coinciden entre sí, así que no se
-- pueden comparar por texto.
--
-- Solución: cada categoría de presupuesto puede vincularse (opcional)
-- a una `categoria_gasto` real — así el desglose sabe qué gastos
-- reales sumarle a cada estimado.

alter table public.presupuesto_categorias
  add column if not exists categoria_gasto_id int
    references public.categorias_gasto(id);
