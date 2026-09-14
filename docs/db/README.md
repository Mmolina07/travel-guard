# Notas de configuración — Auth y persistencia (TG-92, TG-97, TG-102, TG-123, TG-124)

## ⚡ Si algo no cuadra con la base de datos: usa `reset_schema.sql` + `schema.sql`

`docs/db/schema.sql` es el esquema **completo** real del proyecto
(basado en `travelguard_schema_sprint1.sql`: usuarios, turistas,
comercios, viajes, gastos, lugares_interes, actividades y sus tablas de
categorías), con dos correcciones puntuales para que funcione con el
código Dart actual:

1. Se eliminó el `CONSTRAINT chk_auth_local` de `usuarios` — exigía
   `password_hash NOT NULL` para cuentas locales, pero la app nunca
   guarda contraseñas en Supabase (la autenticación real vive en
   Firebase). Esto causaba el error `23514` en TODO registro por email.
2. Se agregó RLS habilitado + una política abierta
   (`dev_open_access_*`) en cada tabla. Sin políticas, Postgres bloquea
   todo acceso con el error `42501` ("row-level security policy") — la
   causa de los fallos al registrar turista y comercio.

Para dejar la base de datos limpia y consistente:

1. Corre `docs/db/reset_schema.sql` en el SQL Editor de Supabase (usa
   `CASCADE`: borra TODAS las tablas del proyecto, incluidas las que
   dependían de `comercios`/`turistas` como `lugares_interes` y
   `actividades`).
2. Corre `docs/db/schema.sql` completo (recrea todo desde cero, con las
   dos correcciones ya incluidas, más los datos semilla de categorías).

`usuarios_turistas.sql` y `comercios.sql` quedan como referencia
histórica (la primera versión, acotada solo a auth, antes de tener
visibilidad del esquema completo real). Para configurar o reparar la
base de datos usa siempre `reset_schema.sql` + `schema.sql`.

## Estado actual

- **Firebase Authentication**: configurado (proyecto `travelguard-5a487`,
  `lib/firebase_options.dart` generado con `flutterfire configure`,
  proveedores email/contraseña y Google habilitados).
- **Supabase**: proyecto ya existente del equipo. URL y "publishable key"
  quedan como default en `lib/core/network/supabase_client.dart`
  (`SupabaseConfig`).
- El esquema `usuarios` / `turistas` / `comercios` ya está creado en ese
  proyecto (documentado en `CLAUDE.md`). `docs/db/usuarios_turistas.sql`
  y `docs/db/comercios.sql` son la referencia/reproducción de esas
  tablas, no un paso pendiente.

## ⚠️ Discrepancia de tipos en `usuarios.id`

`CLAUDE.md` documenta `usuarios.id` como `uuid`, pero **en el Table
Editor de Supabase la columna real es `int8`** (confirmado directamente
por el equipo). Todo el código de esta capa (`UsuariosRepository`,
`TouristRepository`, `ComercioRepository`, `AppAuthProvider`) usa `int`
para `usuarios.id` / `*.usuario_id`, siguiendo el tipo real de la base de
datos. Si en algún momento se migra `usuarios.id` a `uuid`, hay que
actualizar estos archivos en consecuencia. Vale la pena actualizar
`CLAUDE.md` para que no siga diciendo `uuid`.

## ⚠️ Constraint `chk_auth_local` (bloqueaba TODO registro)

`usuarios` tenía un `CHECK CONSTRAINT` llamado `chk_auth_local` (tampoco
documentado en `CLAUDE.md`) que exigía `password_hash IS NOT NULL`
cuando `proveedor_auth = 'local'`. Como la autenticación real vive en
Firebase (no guardamos contraseñas en Supabase), todo insert local
llegaba con `password_hash = null` y Postgres lo rechazaba con:

```
PostgrestException: new row for relation "usuarios" violates check
constraint "chk_auth_local" (code 23514)
```

Se eliminó la restricción (no borra datos existentes):

```sql
alter table public.usuarios drop constraint if exists chk_auth_local;
```

Si en el futuro se vuelve a asumir un modelo de auth "local" real
(password_hash gestionado por la propia app, sin Firebase), habría que
recrear una validación equivalente.

## Cómo se enlaza Firebase con `usuarios`

`usuarios.id` es autogenerado por Supabase, no el UID de Firebase. Por
eso `AppAuthProvider`/`UsuariosRepository`:

- **Cuentas de Google**: buscan/enlazan por `usuarios.google_id`, donde
  se guarda `FirebaseAuth.instance.currentUser.uid`.
- **Cuentas locales (email/contraseña)**: buscan/enlazan por
  `usuarios.email` (columna única), ya que Firebase gestiona la
  autenticación y Supabase solo guarda el perfil.
- En ambos casos, tras crear/encontrar la fila en `usuarios`, se usa su
  `id` (int) para crear/leer el perfil en `turistas.usuario_id` o
  `comercios.usuario_id`.

## Qué se conectó en esta iteración

- `client_register_screen.dart` (turista): `_handleRegister` ahora
  registra en Firebase + Supabase vía `AppAuthProvider.registerTourist`.
  Se agregó un botón "Registrarse con Google" (nuevo, sin tocar el resto
  del diseño) que llama a `AppAuthProvider.signInWithGoogle`.
- `comercio_register_screen.dart`: `_handleRegister` registra en
  Firebase + Supabase vía `AppAuthProvider.registerComercio`. También
  se agregó "Verificar con Google": como `comercios` exige `nit`,
  `direccion` y `telefono_contacto` (NOT NULL) que Google no provee, el
  botón solo autentica (`AppAuthProvider.beginGoogleSignIn`) y precarga
  nombre/correo; el usuario completa NIT/dirección/teléfono/sede en el
  mismo formulario y presiona "Registrarse", que en ese caso llama a
  `AppAuthProvider.completeComercioGoogleRegistration` (sin contraseña).
- `login_screen.dart`: `_handleLogin` ahora inicia sesión real
  (`AppAuthProvider.signInWithEmail`) y valida que el rol de la cuenta
  coincida con el botón presionado ("Iniciar sesión como Turista" /
  "...Comercio"). Se agregó "Continuar con Google"
  (`AppAuthProvider.signInWithGoogle`), que registra automáticamente
  como turista si es la primera vez (Escenario 5 HU-01) y navega a la
  home correspondiente según `usuario.tipoUsuario`.
- `home_screen_client.dart` / `home_screen_comercio.dart`: el nombre
  hardcodeado ("Ana" / "Mi Negocio") ahora es un getter que lee
  `AppAuthProvider.displayName` (nombre de turista, nombre del comercio,
  o el usuario del email como último recurso).

## HU-02 (TG-107, TG-111, TG-112, TG-124): mensajes exactos y duplicados

`comercio_register_screen.dart` y `AppAuthProvider` ya traían el flujo de
registro/Google funcionando (ver sección anterior); esta iteración ajustó
`_validateForm` y `AppAuthProvider.registerComercio` /
`completeComercioGoogleRegistration` para calzar con los escenarios
exactos de `docs/hu/hu-02.md`:

- **Escenario 6** (campos vacíos): un solo mensaje unificado "Debe
  completar todos los campos obligatorios" en vez de mensajes por campo.
- **Escenario 2** (email): "Email inválido o ya registrado" tanto para
  formato inválido (cliente) como para email ya existente. La duplicidad
  se valida de forma anticipada en `AppAuthProvider` con
  `UsuariosRepository.findByEmail` antes de tocar Firebase.
- **Escenario 4** (NIT): "NIT inválido o ya registrado" para formato
  inválido (regex simple: 5-15 dígitos, guion y dígito de verificación
  opcional) o NIT ya existente, vía el nuevo
  `ComercioRepository.findByNit`.
- Como red de seguridad ante condiciones de carrera (dos registros
  simultáneos con el mismo NIT/email), `AppAuthProvider` también
  atrapa `PostgrestException` (violación de unicidad, código `23505`) y
  la traduce al mismo mensaje según si el conflicto es en `nit` o
  `email`.
- **TG-107**: tanto `registerComercio` como
  `completeComercioGoogleRegistration` crean el `usuarios` con
  `tipo_usuario: 'comercio'` explícitamente — un comercio nunca queda
  identificado como turista, a diferencia del login/registro genérico
  con Google (`signInWithGoogle`) que por defecto asume `'turista'` para
  cuentas nuevas.
- Contraseña mínima ajustada de 6 a 8 caracteres, según el Escenario 1.

## Qué NO se tocó

Ningún estilo, color, texto fijo, ni estructura visual de las pantallas
de `lib/features/auth/presentation/**`, `home_screen_client.dart` ni
`home_screen_comercio.dart` — solo se agregó lógica (imports, métodos,
y en `client_register_screen.dart` un botón nuevo) siguiendo el permiso
explícito de vincular eventos en la UI sin alterar la maquetación de
Ana María.
