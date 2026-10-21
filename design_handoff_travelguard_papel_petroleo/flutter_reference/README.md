# TravelGuard — "Papel Petróleo" (Flutter Web)

Implementación de la dirección **1b** del rediseño.

## Estructura

```
lib/
  main.dart                  App + WebShell (lienzo centrado, máx. 480 px)
  theme/app_theme.dart       Tokens: AppColors, AppRadius, AppShadow, AppMotion, AppText
  models/trip.dart           Modelo Trip + datos demo
  routes/hero_scale_route.dart  HeroScaleRoute (FAB→Crear viaje), TripDetailRoute
  widgets/
    pressable.dart           Pressable + PressableCard (escala 0.96, easeOutCubic 120 ms)
    segmented_pill.dart      Toggle Turista/Comercio (AnimatedAlign, easeOutBack 320 ms)
    filter_chips.dart        Chips animados (elasticOut 380 ms)
    budget_bar.dart          Medidor (TweenAnimationBuilder, easeOutQuart 700 ms)
    step_progress.dart       Progreso 3 pasos (easeOutBack 360 ms)
    stagger_in.dart          Entrada escalonada de listas (60 ms/índice)
    floating_nav_bar.dart    Nav flotante + FAB con Hero
    trip_card.dart           Tarjeta-target completa, Hero de thumb y título
  screens/
    login_screen.dart  home_screen.dart  create_trip_screen.dart  trip_detail_screen.dart
```

## Reglas del sistema

- **Sin componentes Material por defecto**: los botones son `Pressable` sobre `Container`; el splash está desactivado (`NoSplash`) porque el feedback lo da la escala.
- **Radios mixtos**: 14 controles · 22-28 tarjetas · 38-44 pantallas/cabeceras, con **una sola esquina grande por bloque** (`AppRadius.headerAsym`).
- **Sombra única direccional** en `AppShadow`; nunca `elevation`.
- **Tipografía**: Instrument Serif (display, itálica como acento), Instrument Sans (UI), JetBrains Mono (etiquetas con tracking +0.14em).
- **Movimiento**: entrada con sobre-impulso (`easeOutBack`), salida limpia; `elasticOut` reservado a micro-elementos (chips).

## Correr en web

```bash
flutter pub get
flutter run -d chrome
flutter build web --release --web-renderer canvaskit
```

Añade `intl` si tu SDK no lo trae transitivamente: `flutter pub add intl`.

## Pendiente (siguiente iteración)

- Pasos 2 y 3 de "Crear viaje" (`_PlaceholderStep`) con los campos reales de hospedaje y transporte.
- Pantalla de Comercios cercanos (usa `FilterChipsRow` + tarjeta-target ya listas).
- Conexión de datos: `demoTrips` es estático.
