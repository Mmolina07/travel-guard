-- HU-02: Registrar Comercio (perfil, tabla `comercios`).
--
-- Esquema de referencia (ver CLAUDE.md). Igual que `usuarios`/`turistas`,
-- `comercios.usuario_id` es `bigint` (FK -> usuarios.id, que es int8, no
-- uuid). `categoria_id` queda nullable y sin FK forzada aquí porque
-- `categorias_comercio` no forma parte de este alcance (HU-02/categorías
-- de comercio es responsabilidad de otra tarea).

create table if not exists public.comercios (
    usuario_id bigint primary key references public.usuarios (id) on delete cascade,
    nit varchar(30) not null unique,
    nombre_comercio varchar(150) not null,
    categoria_id int,
    sede varchar(100),
    descripcion text,
    telefono_contacto varchar(30) not null,
    direccion varchar(255) not null,
    latitud numeric(9, 6),
    longitud numeric(9, 6),
    horario_apertura time,
    horario_cierre time,
    estado estado_usuario_enum not null default 'activo',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

drop trigger if exists trg_comercios_updated_at on public.comercios;
create trigger trg_comercios_updated_at
    before update on public.comercios
    for each row execute function public.set_updated_at();

alter table public.comercios enable row level security;

-- Igual que en usuarios_turistas.sql: acceso abierto SOLO para
-- desarrollo, mientras se configura Third-Party Auth (Firebase) en
-- Supabase para políticas basadas en auth.jwt()->>'sub'.
drop policy if exists "dev_open_access_comercios" on public.comercios;
create policy "dev_open_access_comercios"
    on public.comercios for all using (true) with check (true);
