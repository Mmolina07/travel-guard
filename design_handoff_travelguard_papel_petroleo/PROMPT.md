# Prompt para Claude Code

Pega esto en Claude Code, dentro del repo de tu app Flutter, con esta carpeta de handoff copiada en la raíz del proyecto.

---

Vas a aplicar un rediseño de UI/UX a esta app Flutter (web). La especificación completa está en
`design_handoff_travelguard_papel_petroleo/README.md` y hay una implementación de referencia en
`design_handoff_travelguard_papel_petroleo/flutter_reference/`.

Trabaja así, en este orden, y detente al final de cada fase para que yo revise:

**Fase 0 — Lectura.**
1. Lee el README del handoff completo.
2. Recorre mi código y dime, antes de tocar nada: qué archivos definen el tema/colores, qué pantallas
   existen (login, home, crear viaje, comercios, detalle), qué widgets de Material estoy usando por
   defecto y qué gestión de estado tengo. Propón el mapeo archivo-por-archivo del rediseño.

**Fase 1 — Tema y tokens.**
Crea `lib/theme/app_theme.dart` con `AppColors`, `AppRadius`, `AppShadow`, `AppMotion` y `AppText`
copiando los valores del handoff. Añade `google_fonts` e `intl` al pubspec. No dejes colores
hardcodeados fuera de `AppColors`, y desactiva el splash de Material (`NoSplash.splashFactory`).

**Fase 2 — Widgets del sistema.**
Crea `lib/widgets/`: `Pressable`, `PressableCard`, `SegmentedPill`, `FilterChipsRow`, `BudgetBar`,
`StepProgress`, `StaggerIn`, `FloatingNavBar`, `TripCard`. Usa la referencia como base, pero
adáptalos a mis modelos de datos reales en vez de a los datos demo.

**Fase 3 — Pantallas, una por PR/commit.**
En este orden: Login → Home → Crear Viaje → Comercios → Detalle del Viaje. En cada una:
- respeta la jerarquía y las medidas del README (radios mixtos, una sola esquina grande por bloque,
  sombra direccional única, tipografía Instrument Serif / Instrument Sans / JetBrains Mono);
- elimina los botones sueltos: en Home van dos tarjetas táctiles asimétricas (flex 100 : 135) más la
  nav flotante con un único FAB; en Comercios la tarjeta completa es el target (fuera el botón
  "Ver detalles"); "Crear Viaje" pasa a 3 pasos con CTA fija; el Detalle usa pestañas en vez de tabla
  clave-valor;
- conserva mi lógica de negocio, navegación real, validaciones y llamadas a backend. Solo cambia la
  capa de presentación. Si un campo de mi formulario no aparece en el diseño, mantenlo y ubícalo
  siguiendo el mismo patrón visual.

**Fase 4 — Movimiento.**
Aplica la tabla de animaciones del README tal cual (widget + curva + duración), incluidas las
transiciones Hero `trip-thumb-{id}` / `trip-title-{id}` y las rutas `HeroScaleRoute` y
`TripDetailRoute`. Nada de curvas lineales.

**Fase 5 — Cierre.**
Corre `flutter analyze` y `flutter build web --release`. Arregla warnings. Dime qué quedó fuera del
diseño y por qué.

Reglas: no rompas rutas ni nombres públicos existentes sin avisar; no metas paquetes nuevos aparte de
`google_fonts` e `intl`; no toques tests sin decírmelo.
