//pantalla principal del turista, crear viaje
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/create_trip_screen.dart';
import '../../../places_map/presentation/map_screen.dart';
import '../pages/trip_detail_screen.dart';
import 'edit_trip_budget_screen.dart';
import '../pages/trip_model.dart';
import '../../../auth/providers/app_auth_provider.dart';
import '../../../places_map/presentation/comercios_cercanos_screen.dart';
import '../../data/trip_repository.dart';
import '../../utils/budget_calculator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/boarding_pass_card.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../../core/widgets/route_pattern_background.dart';
import '../../../../core/widgets/travel_guard_badge.dart';

class HomeScreenClient extends StatefulWidget {
  const HomeScreenClient({Key? key}) : super(key: key);

  @override
  State<HomeScreenClient> createState() => _HomeScreenClientState();
}

class _HomeScreenClientState extends State<HomeScreenClient> {
  int _selectedIndex = 0;

  final List<Trip> _trips = [];
  final TripRepository _tripRepository = TripRepository();
  bool _isLoadingTrips = true;

  static const _monthAbbrs = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];

  String get userName => context.watch<AppAuthProvider>().displayName;

  /// Viaje más próximo por `startDate`; si ninguno tiene fecha futura
  /// parseable, cae al primero con fecha válida y luego al primero de
  /// la lista — nunca deja el strip de estadísticas vacío teniendo datos.
  Trip? get _nextTrip {
    if (_trips.isEmpty) return null;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final withDates = _trips
        .map((t) => MapEntry(t, parseDdMmYyyy(t.startDate)))
        .where((e) => e.value != null)
        .toList()
      ..sort((a, b) => a.value!.compareTo(b.value!));
    final upcoming =
        withDates.where((e) => !e.value!.isBefore(todayDate)).toList();
    if (upcoming.isNotEmpty) return upcoming.first.key;
    if (withDates.isNotEmpty) return withDates.first.key;
    return _trips.first;
  }

  double get _totalBudget =>
      _trips.fold(0.0, (sum, t) => sum + t.maxBudget);

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  /// Carga los viajes ya guardados en Supabase (TG-141): sin esto, al
  /// cerrar y volver a abrir la app, `_trips` siempre arrancaba vacía
  /// aunque el viaje sí se hubiera guardado.
  Future<void> _loadTrips() async {
    final auth = context.read<AppAuthProvider>();
    final turistaId = auth.usuario?.id;
    debugPrint(
      'HomeScreenClient._loadTrips: usuario=${auth.usuario?.id} '
      'tipoUsuario=${auth.usuario?.tipoUsuario} status=${auth.status}',
    );
    if (turistaId == null) {
      debugPrint(
        'HomeScreenClient._loadTrips: sin usuario, no se puede '
        'cargar viajes todavía.',
      );
      setState(() => _isLoadingTrips = false);
      return;
    }
    try {
      final trips = await _tripRepository.fetchTripsByTurista(turistaId);
      debugPrint(
        'HomeScreenClient._loadTrips: ${trips.length} viaje(s) '
        'encontrados para turista_id=$turistaId',
      );
      if (!mounted) return;
      setState(() {
        _trips
          ..clear()
          ..addAll(trips);
        _isLoadingTrips = false;
      });
    } catch (e, st) {
      debugPrint('HomeScreenClient._loadTrips error: $e\n$st');
      if (!mounted) return;
      setState(() => _isLoadingTrips = false);
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres cerrar tu sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AppAuthProvider>().signOut();
      // `AuthGate` (main.dart) reacciona al cambio de estado y ya
      // muestra `WelcomeHome` de fondo, pero esta pantalla se abrió con
      // `Navigator.push` desde el login — sin este pop, sigue encima
      // en la pila y el usuario ve la sesión "sin cerrar" hasta que
      // presiona atrás.
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  Future<void> _handleBottomNavTap(int index) async {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        // Inicio: no hace nada.
        break;

      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MapScreen()),
        );
        break;

      case 2:
        final trip = await Navigator.push<Trip>(
          context,
          MaterialPageRoute(builder: (context) => const CreateTripScreen()),
        );
        if (!mounted) return;
        if (trip != null) {
          setState(() {
            _trips.add(trip);
            _selectedIndex = 0;
          });
        }
        break;

      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ComerciosCercanosScreen(),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildHeroAppBar(),
          SliverToBoxAdapter(
            child: ResponsiveCenter(
              maxWidth: 760,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsStrip(),
                  const SizedBox(height: 24),

                  FadeSlideIn(
                    child: _buildFeatureCard(
                      icon: Icons.luggage_outlined,
                      title: 'Crear un viaje',
                      description:
                          'Organiza tu próxima aventura, establece tu presupuesto y descubre los mejores destinos.',
                      buttonText: '+ Crear viaje',
                      onButtonPressed: () async {
                        final trip = await Navigator.push<Trip>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateTripScreen(),
                          ),
                        );

                        if (!mounted) return;

                        if (trip != null) {
                          setState(() {
                            _trips.add(trip);
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  FadeSlideIn(
                    delay: const Duration(milliseconds: 80),
                    child: _buildMapCard(),
                  ),
                  const SizedBox(height: 36),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mis viajes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryLight,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Ver todos'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    height: 156,
                    child: _isLoadingTrips
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryLight,
                            ),
                          )
                        : _trips.isEmpty
                        ? _buildEmptyTrips()
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _trips.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final trip = _trips[index];
                              return FadeSlideIn(
                                delay: Duration(milliseconds: 70 * index),
                                offset: const Offset(0.12, 0),
                                child: _buildTripCard(
                                  trip: trip,
                                  onViewDetails: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TripDetailScreen(trip: trip),
                                      ),
                                    );
                                  },
                                  onEdit: () async {
                                    final updated = await Navigator.push<Trip>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditTripBudgetScreen(trip: trip),
                                      ),
                                    );
                                    if (updated != null) _loadTrips();
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _FloatingBottomNav(
        selectedIndex: _selectedIndex,
        onItemSelected: _handleBottomNavTap,
      ),
    );
  }

  Widget _buildHeroAppBar() {
    return SliverAppBar(
      expandedHeight: 220,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primaryLight,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primaryLight, Color(0xFF0F4C5F)],
                ),
              ),
            ),
            const RoutePatternBackground(opacity: 0.12),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const TravelGuardBadge(size: 42, animate: false),
                        InkWell(
                          onTap: () => _confirmSignOut(context),
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.logout,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Cerrar sesión',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '¡Hola, $userName!',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Explora, planifica y viaja seguro',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildStatsStrip() {
    final next = _nextTrip;
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            icon: Icons.luggage_outlined,
            label: 'Viajes activos',
            value: '${_trips.length}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatChip(
            icon: Icons.flight_takeoff,
            label: 'Próximo viaje',
            value: next?.destination ?? '—',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatChip(
            icon: Icons.savings_outlined,
            label: 'Presupuesto total',
            value: _trips.isEmpty ? '—' : formatCOP(_totalBudget),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyTrips() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.luggage_outlined,
            size: 44,
            color: Color(0xFFB0D9E8),
          ),
          const SizedBox(height: 10),
          const Text(
            'Aún no tienes viajes',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Crea tu primer viaje para comenzar a planificar.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onButtonPressed,
  }) {
    return BoardingPassCard(
      leading: Icon(icon, size: 30, color: AppColors.primaryLight),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondaryLight,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onButtonPressed,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Widget _buildMapCard() {
    return BoardingPassCard(
      leading: const Icon(
        Icons.location_on_outlined,
        size: 30,
        color: AppColors.primaryLight,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mapa',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Explora destinos, encuentra comercios seguros y planifica tu ruta.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondaryLight,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MapScreen(),
                      ),
                    );
                  },
                  child: const Text('Ver mapa'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          const _MiniMapPreview(),
        ],
      ),
    );
  }

  Widget _buildTripCard({
    required Trip trip,
    required VoidCallback onViewDetails,
    required VoidCallback onEdit,
  }) {
    final startDate = parseDdMmYyyy(trip.startDate);
    return SizedBox(
      width: 220,
      child: BoardingPassCard(
        padding: const EdgeInsets.all(14),
        leadingWidth: 56,
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              startDate != null ? '${startDate.day}' : '•',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryLight,
              ),
            ),
            if (startDate != null)
              Text(
                _monthAbbrs[startDate.month - 1],
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondaryLight,
                ),
              ),
          ],
        ),
        child: InkWell(
          onTap: onViewDetails,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      trip.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.more_vert, size: 18),
                    onSelected: (value) {
                      if (value == 'details') onViewDetails();
                      if (value == 'edit') onEdit();
                      // 'delete': aún no implementado en el repositorio.
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem<String>(
                        value: 'details',
                        child: Text('Ver detalles'),
                      ),
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Editar'),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Eliminar'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${trip.startDate} - ${trip.endDate}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 13,
                    color: AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      trip.destination,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryLight),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
          ),
        ],
      ),
    );
  }
}

/// Vista decorativa simplificada de un mapa — la misma idea de la tarjeta
/// original (pines sobre un panel de color) pero reutilizando el lenguaje
/// visual nuevo (esquinas redondeadas consistentes con `BoardingPassCard`).
class _MiniMapPreview extends StatelessWidget {
  const _MiniMapPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFFC8E6F5),
      ),
      child: const Stack(
        children: [
          Positioned(
            left: 16,
            top: 14,
            child: Icon(Icons.location_on, color: AppColors.primaryLight, size: 22),
          ),
          Positioned(
            right: 18,
            bottom: 16,
            child: Icon(Icons.shield, color: AppColors.primaryLight, size: 18),
          ),
          Positioned(
            left: 34,
            bottom: 24,
            child: Icon(Icons.restaurant, color: AppColors.primaryLight, size: 16),
          ),
        ],
      ),
    );
  }
}

/// Barra de navegación flotante tipo píldora — mismos 4 ítems y misma
/// lógica de navegación que la `BottomNavigationBar` original, con un
/// tratamiento visual acorde al resto de la pantalla en vez del estilo
/// plano por defecto de Material.
class _FloatingBottomNav extends StatelessWidget {
  const _FloatingBottomNav({
    required this.selectedIndex,
    required this.onItemSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  static const _items = [
    (icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Inicio'),
    (icon: Icons.map_outlined, activeIcon: Icons.map, label: 'Mapa'),
    (
      icon: Icons.add_circle_outline,
      activeIcon: Icons.add_circle,
      label: 'Crear',
    ),
    (
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag,
      label: 'Comercios',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final selected = index == selectedIndex;
            final color =
                selected ? AppColors.primaryLight : AppColors.textSecondaryLight;
            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () => onItemSelected(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      selected ? item.activeIcon : item.icon,
                      color: color,
                      size: 22,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
