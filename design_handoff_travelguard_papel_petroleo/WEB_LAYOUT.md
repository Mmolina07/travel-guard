# Layout web de escritorio — TravelGuard "Papel Petróleo"

Este archivo **manda sobre el README** en todo lo que tenga que ver con retícula, tamaños de
contenedor y navegación. El README sigue siendo la verdad para color, tipografía, radios, sombras y
movimiento.

Referencia visual: `TravelGuard Web.dc.html` (ábrelo en el navegador; es el objetivo exacto).

## Regla principal

La app **no es una pantalla de celular centrada en el navegador**. No hay ancho fijo de 380-480 px,
no hay marco de teléfono, no hay `ConstrainedBox(maxWidth: 480)` envolviendo la app, no hay
`BottomNavigationBar` ni nav flotante en escritorio. El contenido ocupa todo el ancho de la ventana y
se reordena por breakpoints.

```dart
// Prohibido en el shell:
Center(child: SizedBox(width: 420, child: app))   // ❌
// Correcto:
LayoutBuilder(builder: (_, c) => c.maxWidth >= 1024 ? DesktopShell() : MobileShell())  // ✅
```

## Breakpoints

| Nombre | Ancho | Shell |
|---|---|---|
| `mobile` | < 720 | Una columna, nav flotante inferior (el diseño del README tal cual) |
| `tablet` | 720 – 1023 | Una columna con márgenes de 28, sidebar colapsado a iconos (72 px) |
| `desktop` | ≥ 1024 | Sidebar fijo de 248 px + contenido fluido |

Usa `LayoutBuilder` / `MediaQuery.sizeOf(context).width`, nunca `Platform.isAndroid`.

## Shell de escritorio

`Row` de dos hijos, alto completo de la ventana:

**1. Sidebar — 248 px fijo**, fondo `paperDeep` (#F1EEE5), borde derecho 1 px `line`, padding
26 vertical / 18 horizontal, `position: sticky` (en Flutter: hijo fijo del `Row`, no dentro del
scroll). De arriba abajo, gap 26:
- Marca: cuadro 30×30 `ink` radio 11 con punto `mint` 10 radio 3 + `TRAVELGUARD` mono 11,
  letterSpacing 0.18em, padding lateral 8.
- **CTA "Crear viaje"**: tarjeta `ink` radio 22, padding 18/16, texto 15/w700 `paper` a la izquierda
  y cuadro 30×30 `mint` radio 11 con `+` `ink` a la derecha, sombra `inkButton`. Abre el wizard.
- Lista de navegación: etiqueta `NAVEGACIÓN` mono 10 `textLabel`; items Inicio / Mis viajes /
  Comercios / Mapa, padding 14/12, radio 16, 15 px. Activo: fondo `wash`, color `ink`, w700;
  inactivo: transparente, `textMuted`, w400. Transición 300 ms `easeOutBack`.
- Al pie (`margin-top: auto`): tarjeta `wash` radio 22 con `PRESUPUESTO SEP` mono 10 `inkSoft`,
  cifra display 26, `BudgetBar` 5 px sobre pista blanca y "40% de $7.000.000" 11; debajo, fila de
  perfil: avatar 34×34 `ink` radio 12 con inicial `mint`, nombre 14/w600, rol 11 `textLabel`, icono
  de salir a la derecha.

**2. Área principal** — `Expanded`, fondo `paper`, columna:
- **Topbar sticky**, padding 34/22, borde inferior 1 px `line`, fondo `paper` al 92% con blur 8:
  buscador `paperDeep` radio 18, padding 16/11, `maxWidth: 420`, `flex: 1`, placeholder "Buscar
  viajes, comercios o ciudades"; a la derecha la fecha mono 11 y un botón 38×38 radio 14 con borde
  `line`.
- **Contenido**: padding 34 lateral / 36 arriba / 60 abajo, `SingleChildScrollView`. Sin ancho
  máximo artificial salvo lo indicado por vista.

## Vistas

### Inicio
1. Saludo: display `clamp(34, 3.4vw, 46)` "Hola, Mateo." + itálica `inkSoft`; a la derecha una línea
   de contexto 14 `textMuted` (máx 300 px). Se envuelven si no caben.
2. **Retícula de acciones**: `auto-fit, minmax(230px, 1fr)`, gap 14, alto mín 164.
   - "Crear un viaje" ocupa **2 columnas**, `ink`, radio 28, sombra `raised`.
   - "Mapa" `wash` radio 28.
   - "Próximo gasto" blanca radio 28 con sombra `card`.
3. **Dos columnas 1.6 : 1**, gap 22, alineadas arriba:
   - Izquierda: "Mis viajes" display 26 + `VER TODOS` mono 11, y las `TripCard` a ancho completo
     (thumb 78×88, misma anatomía del README).
   - Derecha: "Cerca de ti" display 26, una tarjeta de comercio destacada (imagen 120) y un botón de
     borde `line` radio 22 "Ver los 14 lugares →".
   Por debajo de 1200 px la columna derecha pasa debajo.

### Detalle del viaje
- **Cabecera como tarjeta**, no como app bar: margen 22, fondo `ink`, radio 30 con
  `bottomRight: 60`, padding 36/32. Migaja `← INICIO / MIS VIAJES` mono 11, título display
  `clamp(34, 3.6vw, 48)` con el destino en itálica `mint`, metadatos mono 11, y a la derecha dos
  botones ("Editar" translúcido, "Añadir gasto" `mint` con texto `ink`). Abajo: `GASTADO` +
  cifra display 44 a la izquierda, `TOPE` a la derecha, `BudgetBar` 8 px `mint`.
- Pestañas (Resumen / Hospedaje / Transporte / Gastos) alineadas al margen 36, indicador `ink` 2 px.
- Contenido en `auto-fit, minmax(280px, 1fr)`, gap 16: tarjeta "Hospedaje", par de `_MiniCard`
  (`ink` + `wash`) y tarjeta "Últimos gastos" con filas separadas por 1 px `line`.

### Comercios
- Encabezado en fila: a la izquierda `14 LUGARES` mono 11 `inkSoft`, título display
  `clamp(32, 3.2vw, 44)` "Cerca *de ti*" y subtítulo; a la derecha los chips de filtro en `wrap`
  (no en scroll horizontal: en escritorio caben).
- Cuerpo en **1.5 : 1**: izquierda retícula de tarjetas `auto-fit, minmax(260px, 1fr)` gap 16
  (imagen 140, badges de categoría y distancia, tags, flecha); derecha **panel de mapa sticky**
  (`top: 96`), `ink`, radio 28, alto mín 520, con retícula de líneas al 5%, cabecera
  `MAPA · MEDELLÍN` + botón "Satélite" y tarjeta del lugar seleccionado al pie.
- Por debajo de 1100 px el mapa se convierte en una banda de 320 px de alto encima de la lista.

### Crear viaje — **modal, no pantalla**
En escritorio el wizard es un diálogo centrado sobre la vista actual:
- Overlay `ink` al 55% con blur 3; `showGeneralDialog` con fade + scale 0.96→1, 240 ms `easeOutBack`.
- Caja `maxWidth: 880`, radio 34, fondo `paper`, sombra fuerte, en dos columnas 260 : resto.
- Columna izquierda `ink`: `PASO n DE 3` mono 10, título display 34 con segunda línea itálica `mint`,
  `StepProgress` de 3 tramos, y al pie la lista de pasos (activo `paper` w700, resto #9DB3B0).
- Columna derecha `paper`: botón cerrar 34×34 radio 12 arriba a la derecha; nombre y destino en dos
  columnas; fila de tres cajas `paperDeep` radio 18 (INICIO / FIN / PERSONAS); chips de tipo de
  viaje; presupuesto con cifra display 32 `inkSoft` y slider `ink`/`hair` con thumb `mint`; pie
  separado por 1 px `line` con `SIGUIENTE · Hospedaje` a la izquierda y botón `ink` radio 20
  "Continuar →" a la derecha.
- En `mobile` el mismo wizard se abre a pantalla completa con la CTA fija del README.

### Login
`Row` de dos paneles a alto completo (`1.05 : 1`); por debajo de 900 px solo queda el panel derecho.
- Izquierda `ink` con `bottomRight: 120`, padding 56/48, halo radial `mint` al 20% arriba a la
  derecha: marca arriba, titular display `clamp(40, 4.4vw, 64)` con segunda línea itálica `mint`,
  párrafo 16 #9DB3B0 y dos cifras al pie (display 34 + etiqueta mono 10).
- Derecha `paper` centrada: tarjeta blanca `maxWidth: 420`, radio 30, padding 32/34, sombra `raised`,
  con el contenido del login del README (pill de rol, campos, CTA, Google, registro).

## Interacción propia de web

- `MouseRegion` + `SystemMouseCursors.click` en todo lo pulsable; hover eleva la sombra de `card` a
  `raised` y sube el bloque 2 px, 160 ms `easeOutCubic`.
- Foco visible con anillo `inkSoft` 2 px (`FocusRing`), navegación por Tab funcional.
- Atajos: `N` abre el wizard, `Esc` lo cierra, `/` enfoca el buscador.
- Scroll: `Scrollbar` con `thumbVisibility: true` solo en el área principal; el sidebar no scrollea.
- URL real por vista (`go_router`): `/`, `/viajes/:id`, `/comercios`, `/crear` (el modal es una ruta
  hija con `pageBuilder` de diálogo).
