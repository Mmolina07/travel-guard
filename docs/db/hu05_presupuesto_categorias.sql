-- HU-05: categorías de presupuesto personalizables por viaje.
--
-- Antes el presupuesto por rubro (tours, restaurantes, discotecas,
-- souvenirs, actividades pagas) eran 5 columnas FIJAS en `viajes`
-- (incluye_tours_guia/costo_tours, etc.) — el turista no podía
-- renombrarlas, quitarlas, ni agregar una categoría propia (p.ej.
-- "Transporte interno"). Esta tabla las reemplaza: una fila por
-- categoría, nombre y monto libres.
--
-- Las 5 columnas fijas viejas (incluye_tours_guia, costo_tours,
-- incluye_restaurantes, costo_restaurantes, incluye_discotecas,
-- costo_discotecas, incluye_souvenirs, costo_souvenirs,
-- incluye_actividades_pagas, costo_actividades_pagas) quedan en
-- `viajes` sin usarse desde la app a partir de ahora — no se borran
-- acá porque DROP COLUMN es destructivo; si el equipo confirma que no
-- hace falta conservarlas, se pueden eliminar en un paso aparte.

create table if not exists public.presupuesto_categorias (
  id bigserial primary key,
  viaje_id bigint not null references public.viajes(id) on delete cascade,
  nombre varchar(80) not null,
  monto numeric(12,2) not null default 0,
  orden int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger trg_presupuesto_categorias_updated_at
  before update on public.presupuesto_categorias
  for each row execute function set_timestamp();

create index if not exists idx_presupuesto_categorias_viaje
  on public.presupuesto_categorias(viaje_id);

-- RLS: mismo patrón "dev_open_access" que el resto de tablas del
-- proyecto (ver docs/db/README.md — política insegura, solo para
-- desarrollo; falta reemplazarla por reglas basadas en auth.jwt()).
alter table public.presupuesto_categorias enable row level security;

create policy "dev_open_access_presupuesto_categorias"
  on public.presupuesto_categorias
  for all using (true) with check (true);
