# Notas de configuración — Auth y persistencia (TG-92, TG-97, TG-102, TG-123, TG-124)

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

## Qué NO se tocó

Ningún estilo, color, texto fijo, ni estructura visual de las pantallas
de `lib/features/auth/presentation/**`, `home_screen_client.dart` ni
`home_screen_comercio.dart` — solo se agregó lógica (imports, métodos,
y en `client_register_screen.dart` un botón nuevo) siguiendo el permiso
explícito de vincular eventos en la UI sin alterar la maquetación de
Ana María.
