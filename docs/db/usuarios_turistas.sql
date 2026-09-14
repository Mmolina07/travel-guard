-- TG-92: Tabla de turista y persistencia en Supabase.
-- HU-01: Registrar Turista.
--
-- Esquema de referencia (ya aplicado en el proyecto de Supabase del equipo,
-- ver CLAUDE.md). Este archivo documenta/reproduce únicamente las partes
-- necesarias para HU-01: la tabla global `usuarios` y el perfil `turistas`.
--
-- Nota de arquitectura: la AUTENTICACIÓN vive en Firebase Authentication
-- (TG-97/TG-102), no en Supabase Auth. `usuarios.id` es un int8
-- autogenerado por Supabase (confirmado en el Table Editor); el UID de
-- Firebase se guarda en `usuarios.google_id` (varchar unique) y es la
-- clave que usa el código para encontrar el registro entre sesiones.

do $$ begin
    create type tipo_usuario_enum as enum ('turista', 'comercio', 'administrador');
exception when duplicate_object then null; end $$;

do $$ begin
    create type proveedor_auth_enum as enum ('local', 'google');
exception when duplicate_object then null; end $$;

do $$ begin
    create type estado_usuario_enum as enum ('activo', 'inactivo', 'suspendido');
exception when duplicate_object then null; end $$;

create table if not exists public.usuarios (
    id bigint generated always as identity primary key,
    email varchar(150) not null unique,
    password_hash varchar(255),                     -- null si es google auth
    proveedor_auth proveedor_auth_enum not null default 'local',
    google_id varchar(120) unique,                   -- UID de Firebase Authentication
    tipo_usuario tipo_usuario_enum not null,
    estado estado_usuario_enum not null default 'activo',
    ultimo_login_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists public.turistas (
    usuario_id bigint primary key references public.usuarios (id) on delete cascade,
    nombre varchar(100) not null,
    apellido varchar(100),
    telefono varchar(30),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create or replace function public.set_updated_at()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

drop trigger if exists trg_usuarios_updated_at on public.usuarios;
create trigger trg_usuarios_updated_at
    before update on public.usuarios
    for each row execute function public.set_updated_at();

drop trigger if exists trg_turistas_updated_at on public.turistas;
create trigger trg_turistas_updated_at
    before update on public.turistas
    for each row execute function public.set_updated_at();

-- Row Level Security ---------------------------------------------------
alter table public.usuarios enable row level security;
alter table public.turistas enable row level security;

-- Opción recomendada: configurar "Third-Party Auth" de Supabase para
-- Firebase (Dashboard > Authentication > Sign In / Providers > Firebase),
-- lo que permite validar el JWT de Firebase y usar auth.jwt()->>'sub'
-- (el uid de Firebase, el mismo valor guardado en `google_id`):
--
-- create policy "Usuario lee su propio registro"
--     on public.usuarios for select
--     using (auth.jwt() ->> 'sub' = google_id);
--
-- create policy "Turista gestiona su propio perfil"
--     on public.turistas for all
--     using (auth.jwt() ->> 'sub' = (select google_id from public.usuarios u where u.id = usuario_id))
--     with check (auth.jwt() ->> 'sub' = (select google_id from public.usuarios u where u.id = usuario_id));

-- Mientras se configura el paso anterior en el proyecto de Supabase del
-- equipo, estas políticas dejan el acceso abierto vía anon/publishable
-- key SOLO para desarrollo. Elimínalas antes de producción.
drop policy if exists "dev_open_access_usuarios" on public.usuarios;
create policy "dev_open_access_usuarios"
    on public.usuarios for all using (true) with check (true);

drop policy if exists "dev_open_access_turistas" on public.turistas;
create policy "dev_open_access_turistas"
    on public.turistas for all using (true) with check (true);
