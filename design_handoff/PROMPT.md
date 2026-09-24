# Prompt para Claude Code

Pega esto en Claude Code, dentro del repo de tu app Flutter, con esta carpeta de handoff copiada en
la raíz del proyecto.

---

Vas a aplicar un rediseño de UI/UX a esta app Flutter **para web de escritorio**. Especificación:

- `design_handoff_travelguard_papel_petroleo/WEB_LAYOUT.md` — **retícula, tamaños y navegación web.
  Manda sobre todo lo demás.**
- `design_handoff_travelguard_papel_petroleo/README.md` — color, tipografía, radios, sombras,
  anatomía de componentes y tabla de movimiento.
- `design_handoff_travelguard_papel_petroleo/TravelGuard Web.dc.html` — **objetivo visual exacto**.
  Ábrelo en el navegador y compáralo contra lo que construyas.
- `design_handoff_travelguard_papel_petroleo/flutter_reference/` — implementación de referencia de
  los componentes (está pensada para móvil: úsala para tokens, widgets y animaciones, **no** para el
  layout).

**Restricción número uno:** el resultado es una aplicación web de escritorio que ocupa todo el ancho
de la ventana. Nada de columna angosta centrada, nada de `maxWidth` de 400-600 px en el shell, nada
de marco de teléfono, nada de `BottomNavigationBar` ni nav flotante en escritorio. Si en algún punto
la app se ve como un celular dentro del navegador, está mal: revísalo contra `WEB_LAYOUT.md` antes de
seguir.

Trabaja en este orden y detente al final de cada fase para que yo revise:

**Fase 0 — Lectura y plan.**
Lee `WEB_LAYOUT.md` y el `README.md` completos. Recorre mi código y dime, antes de tocar nada: qué
archivos definen el tema, qué pantallas existen, qué widgets de Material uso por defecto, qué gestión
de estado y qué enrutado tengo. Dime también dónde está hoy la restricción de ancho que hace que la
app se vea de tamaño celular. Propón el mapeo archivo por archivo.

**Fase 1 — Tema y tokens.**
Crea `lib/theme/app_theme.dart` con `AppColors`, `AppRadius`, `AppShadow`, `AppMotion` y `AppText`
con los valores del README. Añade `google_fonts` e `intl`. Sin colores hardcodeados fuera de
`AppColors`. Desactiva el splash de Material (`NoSplash.splashFactory`, `highlightColor`
transparente). Añade `AppBreakpoints { mobile: 720, desktop: 1024 }` y un helper
`context.isDesktop`.

**Fase 2 — Shell responsive.** *(la fase que faltaba)*
Crea `lib/shell/app_shell.dart` con `LayoutBuilder`:
- `>= 1024`: `Row(children: [SideNav(width: 248), Expanded(child: Column([TopBar(), content]))])`,
  ambos a alto completo; el contenido scrollea, el sidebar no.
- `720–1023`: mismo shell con el sidebar colapsado a 72 px (solo iconos + CTA cuadrada).
- `< 720`: una columna con la nav flotante inferior del README.
Elimina cualquier `ConstrainedBox`/`Center` que limite el ancho global de la app. Construye
`SideNav` (marca, CTA "Crear viaje", items con estado activo, tarjeta de presupuesto, perfil) y
`TopBar` (buscador, fecha, botón de tema) tal como los describe `WEB_LAYOUT.md`.

**Fase 3 — Componentes.**
`lib/widgets/`: `Pressable`, `HoverCard` (hover: sombra `card`→`raised` y −2 px en Y, 160 ms),
`SegmentedPill`, `FilterChipsRow` (en escritorio `Wrap`, en móvil scroll horizontal), `BudgetBar`,
`StepProgress`, `StaggerIn`, `TripCard`, `PlaceCard` (destacada y compacta), `MapPanel`,
`FloatingNavBar` (solo móvil). Todos con `MouseRegion` + cursor de clic y foco visible.

**Fase 4 — Vistas, una por commit.**
Inicio → Detalle del viaje → Comercios → Crear viaje (modal) → Login. Sigue la retícula de
`WEB_LAYOUT.md`: retículas `auto-fit minmax()`, columnas 1.6:1 en Inicio y 1.5:1 en Comercios,
cabecera del detalle como tarjeta `ink` con `bottomRight: 60`, wizard como diálogo de 880 px en dos
columnas, login en split screen. Conserva mi lógica de negocio, validaciones, modelos y llamadas a
backend: solo cambia la capa de presentación. Si un campo mío no aparece en el diseño, mantenlo y
colócalo siguiendo el mismo patrón visual.

**Fase 5 — Enrutado y comportamiento web.**
URLs reales con `go_router`: `/`, `/viajes/:id`, `/comercios`, `/crear` como ruta hija con
`pageBuilder` de diálogo. Título de pestaña por ruta, botón atrás del navegador funcional, atajos
`N` / `Esc` / `/`, `Scrollbar` visible solo en el área principal.

**Fase 6 — Movimiento.**
Aplica la tabla de animaciones del README tal cual (widget + curva + duración), más el fade+scale
0.96→1 del modal. Nada de curvas lineales. En escritorio, sustituye los `Hero` de tarjeta por
transición de opacidad + desplazamiento 12 px si el Hero queda raro con el sidebar fijo.

**Fase 7 — Cierre.**
`flutter analyze` y `flutter build web --release`. Prueba y muéstrame capturas a 1440, 1100 y 720 px
de ancho. Dime qué quedó fuera y por qué.

Reglas: no rompas rutas ni nombres públicos existentes sin avisar; no añadas paquetes aparte de
`google_fonts`, `intl` y `go_router`; no toques tests sin decírmelo.
