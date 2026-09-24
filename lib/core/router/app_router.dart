import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/providers/app_auth_provider.dart';
import '../../features/places_map/presentation/comercios_cercanos_screen.dart';
import '../../features/places_map/presentation/home_screen_comercio.dart';
import '../../features/places_map/presentation/map_screen.dart';
import '../../features/trips/data/trip_repository.dart';
import '../../features/trips/presentation/pages/create_trip_screen.dart';
import '../../features/trips/presentation/pages/home_screen_client.dart';
import '../../features/trips/presentation/pages/trip_detail_screen.dart';
import '../../features/trips/presentation/pages/trip_model.dart';
import '../theme/app_theme.dart';
import '../utils/page_title.dart';

/// Enrutado real de Fase 5 (`WEB_LAYOUT.md`): URLs por vista, botón
/// atrás del navegador funcional y `/crear` como ruta de diálogo. Antes
/// toda la navegación vivía en un único `Navigator` imperativo apilado
/// sobre `AuthGate`, sin URL ni soporte de atrás/adelante del navegador.
class AppRouter {
  AppRouter(this._auth) {
    router = GoRouter(
      initialLocation: '/',
      refreshListenable: _auth,
      redirect: _redirect,
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) {
            setPageTitle('TravelGuard · Ingresar');
            return const LoginScreen();
          },
        ),
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) {
            setPageTitle('TravelGuard · Inicio');
            return const _RootHome();
          },
        ),
        GoRoute(
          path: '/comercios',
          name: 'comercios',
          builder: (context, state) {
            setPageTitle('TravelGuard · Comercios');
            return const ComerciosCercanosScreen();
          },
        ),
        GoRoute(
          path: '/mapa',
          name: 'mapa',
          builder: (context, state) {
            setPageTitle('TravelGuard · Mapa');
            return const MapScreen();
          },
        ),
        GoRoute(
          path: '/viajes/:id',
          name: 'tripDetail',
          pageBuilder: (context, state) {
            setPageTitle('TravelGuard · Viaje');
            final extra = state.extra;
            final child = extra is Trip
                ? TripDetailScreen(trip: extra)
                : _TripDetailLoader(
                    tripId: int.tryParse(state.pathParameters['id'] ?? ''),
                  );
            // Fase 6: reemplaza el `Hero` de tarjeta de la tabla de
            // movimiento del README por fade + 12px — cada pantalla
            // monta su propio `AppShell` con sidebar fijo, así que un
            // Hero de tarjeta anima dos sidebars superpuestos durante
            // el vuelo.
            return CustomTransitionPage<void>(
              key: state.pageKey,
              transitionDuration: AppMotion.hero,
              reverseTransitionDuration: AppMotion.hero,
              child: child,
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                final curved = CurvedAnimation(parent: animation, curve: AppMotion.enter);
                // `easeOutBack` se pasa de 1.0 antes de asentar (es su
                // gracia) — bien para el desplazamiento, pero
                // `FadeTransition` arma un `Opacity` interno que
                // revienta si `opacity > 1`. El fade usa la animación
                // sin curvear (0→1 sin overshoot); solo el
                // desplazamiento usa `curved`.
                return FadeTransition(
                  opacity: animation,
                  child: AnimatedBuilder(
                    animation: curved,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0, 12 * (1 - curved.value)),
                      child: child,
                    ),
                    child: child,
                  ),
                );
              },
            );
          },
        ),
        GoRoute(
          path: '/crear',
          name: 'crear',
          pageBuilder: (context, state) {
            setPageTitle('TravelGuard · Crear viaje');
            return buildCreateTripPage(context, state);
          },
        ),
      ],
    );
  }

  final AppAuthProvider _auth;
  late final GoRouter router;

  /// Sesión desconocida (todavía resolviendo Firebase/Supabase al
  /// recargar la página) no redirige a ningún lado — `_RootHome` es
  /// quien muestra el loader mientras tanto, igual que el `AuthGate`
  /// que reemplaza.
  String? _redirect(BuildContext context, GoRouterState state) {
    final loggingIn = state.matchedLocation == '/login';
    switch (_auth.status) {
      case AuthStatus.unknown:
        return null;
      case AuthStatus.unauthenticated:
        return loggingIn ? null : '/login';
      case AuthStatus.authenticated:
        return loggingIn ? '/' : null;
    }
  }
}

/// Reemplaza al antiguo `AuthGate`: con sesión resuelta, decide entre el
/// home de turista y el de comercio — el redirect de [AppRouter] ya se
/// encargó de que solo se llegue aquí autenticado.
class _RootHome extends StatelessWidget {
  const _RootHome();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    if (auth.status == AuthStatus.authenticated) {
      if (auth.comercio != null) return const HomeScreenComercio();
      if (auth.tourist != null) return const HomeScreenClient();
    }
    // Sesión aún desconocida, o autenticada pero con el perfil
    // turista/comercio todavía resolviéndose desde Supabase.
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

/// Resuelve `/viajes/:id` cuando se llega sin el `Trip` ya en memoria
/// (recarga de página, enlace pegado directo, atrás/adelante del
/// navegador) — los demás casos navegan con `extra: trip` y evitan este
/// viaje de red.
class _TripDetailLoader extends StatefulWidget {
  const _TripDetailLoader({required this.tripId});

  final int? tripId;

  @override
  State<_TripDetailLoader> createState() => _TripDetailLoaderState();
}

class _TripDetailLoaderState extends State<_TripDetailLoader> {
  final TripRepository _repository = TripRepository();
  late final Future<Trip?> _future = _load();

  Future<Trip?> _load() async {
    final id = widget.tripId;
    if (id == null) return null;
    final turistaId = context.read<AppAuthProvider>().usuario?.id;
    if (turistaId == null) return null;
    final trips = await _repository.fetchTripsByTurista(turistaId);
    for (final trip in trips) {
      if (trip.id == id) return trip;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Trip?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: AppColors.paper,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.ink),
            ),
          );
        }
        final trip = snapshot.data;
        if (trip == null) return const _TripNotFound();
        return TripDetailScreen(trip: trip);
      },
    );
  }
}

class _TripNotFound extends StatelessWidget {
  const _TripNotFound();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('No encontramos ese viaje.', style: AppText.display(22)),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.go('/'),
              child: const Text('Volver a inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
