//pantalla principal del turista, crear viaje
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../pages/create_trip_screen.dart';
import '../pages/trip_model.dart';
import '../../../auth/providers/app_auth_provider.dart';
import '../../../expenses/data/expense_repository.dart';
import '../../../expenses/data/models/categoria_gasto_model.dart';
import '../../../expenses/presentation/widgets/add_expense_sheet.dart';
import '../../../places_map/data/models/map_place.dart';
import '../../../places_map/data/places_map_repository.dart';
import '../../data/trip_repository.dart';
import '../../utils/budget_calculator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/boarding_pass_card.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../../core/widgets/route_pattern_background.dart';
import '../../../../core/widgets/travel_guard_badge.dart';
import '../../../../shell/app_shell.dart';
import '../../../../widgets/floating_nav_bar.dart';
import '../../../../widgets/hover_card.dart';
import '../../../../widgets/place_card.dart';
import '../../../../widgets/stagger_in.dart';
import '../../../../widgets/trip_card.dart';

class HomeScreenClient extends StatefulWidget {
  const HomeScreenClient({super.key});

  @override
  State<HomeScreenClient> createState() => _HomeScreenClientState();
}

class _HomeScreenClientState extends State<HomeScreenClient> {
  final List<Trip> _trips = [];
  final TripRepository _tripRepository = TripRepository();
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  bool _isLoadingTrips = true;

  /// Gastos reales (tabla `gastos`, HU-13) por `trip.id` — sin esto,
  /// las tarjetas de viaje y el resumen del sidebar solo contaban lo
  /// planeado al crear el viaje, no lo que en verdad se ha gastado.
  Map<int, double> _gastosPorViaje = {};

  final PlacesMapRepository _placesRepository = PlacesMapRepository();
  List<MapPlace> _nearbyPlaces = [];
  bool _isLoadingPlaces = true;

  static const _monthAbbrs = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];

  String get userName => context.watch<AppAuthProvider>().displayName;

  /// Viaje más próximo por `startDate`; si ninguno tiene fecha futura
  /// parseable, cae al primero con fecha válida y luego al primero de
  /// la lista — nunca deja el saludo/estadísticas vacíos teniendo datos.
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

  /// Gastado real de [trip]: lo planeado al crearlo más los gastos
  /// sueltos ya registrados — mismo criterio que usa el detalle del
  /// viaje (`trip.getTotalSpent() + gastos reales`).
  double _spentFor(Trip trip) {
    final real = trip.id != null ? _gastosPorViaje[trip.id] ?? 0 : 0;
    return trip.getTotalSpent() + real;
  }

  @override
  void initState() {
    super.initState();
    _loadTrips();
    _loadNearbyPlaces();
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
      _loadGastosPorViaje(trips);
    } catch (e, st) {
      debugPrint('HomeScreenClient._loadTrips error: $e\n$st');
      if (!mounted) return;
      setState(() => _isLoadingTrips = false);
    }
  }

  /// Gastos reales por viaje, para que las tarjetas y el sidebar no se
  /// queden solo con lo planeado — si falla, las tarjetas simplemente
  /// caen a `trip.getTotalSpent()` (comportamiento anterior), no vale
  /// la pena bloquear la pantalla por esto.
  Future<void> _loadGastosPorViaje(List<Trip> trips) async {
    final ids = [for (final t in trips) if (t.id != null) t.id!];
    if (ids.isEmpty) return;
    try {
      final totals = await _expenseRepository.fetchTotalGastosPorViaje(ids);
      if (!mounted) return;
      setState(() => _gastosPorViaje = totals);
    } catch (e, st) {
      debugPrint('HomeScreenClient._loadGastosPorViaje error: $e\n$st');
    }
  }

  /// Para la tarjeta "Cerca de ti" — mismos datos reales de HU-07 que
  /// usa Comercios, no un lugar de relleno.
  Future<void> _loadNearbyPlaces() async {
    try {
      final places = await _placesRepository.fetchNearbyPlaces();
      if (!mounted) return;
      setState(() {
        _nearbyPlaces = places;
        _isLoadingPlaces = false;
      });
    } catch (e, st) {
      debugPrint('HomeScreenClient._loadNearbyPlaces error: $e\n$st');
      if (!mounted) return;
      setState(() => _isLoadingPlaces = false);
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
      // El redirect de `AppRouter` (Fase 5) ya manda a `/login` en cuanto
      // `AppAuthProvider` notifica el cambio; este `go` solo evita el
      // parpadeo de un frame con esta pantalla de fondo.
      if (context.mounted) context.go('/login');
    }
  }

  Future<void> _createTrip() async {
    final trip = await showCreateTripDialog(context);
    if (!mounted) return;
    if (trip != null) setState(() => _trips.add(trip));
  }

  void _openMap() => context.go('/mapa');

  void _openComercios() => context.go('/comercios');

  void _openTripDetail(Trip trip) {
    context.go('/viajes/${trip.id}', extra: trip);
  }

  /// Acceso rápido a "añadir gasto" desde Inicio, sin pasar por el
  /// detalle del viaje: el enfoque de la app es justo registrar gastos
  /// seguido, así que si solo hay un viaje activo no tiene sentido
  /// pedir que se elija — se abre directo el formulario.
  Future<void> _quickAddExpense() async {
    if (_trips.isEmpty) {
      _showSnack('Crea un viaje primero para poder registrar un gasto.');
      return;
    }
    final trip = _trips.length == 1 ? _trips.first : await _pickTripForExpense();
    if (trip == null || !mounted) return;
    await _addExpenseToTrip(trip);
  }

  Future<Trip?> _pickTripForExpense() {
    // `isScrollControlled` + el `Flexible`/`SingleChildScrollView` de
    // adentro: sin esto, con varios viajes la lista se salía del alto
    // fijo que Flutter le da a un bottom sheet normal (RenderFlex
    // overflow, la hoja se veía cortada).
    return showModalBottomSheet<Trip>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¿A qué viaje pertenece?', style: AppText.display(22)),
              const SizedBox(height: 4),
              Text(
                'Elige el viaje para registrar el gasto.',
                style: AppText.ui(13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (var i = 0; i < _trips.length; i++) ...[
                        TripCard(
                          trip: _trips[i],
                          spent: _spentFor(_trips[i]),
                          thumbWidth: 56,
                          thumbHeight: 64,
                          onTap: () => Navigator.pop(sheetContext, _trips[i]),
                        ),
                        if (i != _trips.length - 1) const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addExpenseToTrip(Trip trip) async {
    if (trip.id == null) {
      _showSnack('Este viaje no quedó guardado en el servidor; no se pueden registrar gastos.');
      return;
    }

    List<CategoriaGasto> categorias;
    try {
      categorias = await _expenseRepository.fetchCategorias();
    } catch (e, st) {
      debugPrint('HomeScreenClient._addExpenseToTrip fetchCategorias error: $e\n$st');
      if (!mounted) return;
      _showSnack('No se pudieron cargar las categorías de gasto.');
      return;
    }
    if (categorias.isEmpty) {
      if (!mounted) return;
      _showSnack('No se pudieron cargar las categorías de gasto.');
      return;
    }
    if (!mounted) return;

    final startDate = parseDdMmYyyy(trip.startDate) ?? DateTime.now();
    final endDateRaw = parseDdMmYyyy(trip.endDate) ?? startDate;

    final result = await AddExpenseSheet.show(
      context,
      categorias: categorias,
      tripStartDate: startDate,
      tripEndDate: endDateRaw.isBefore(startDate) ? startDate : endDateRaw,
    );
    if (result == null || !mounted) return;

    try {
      await _expenseRepository.createGasto(
        viajeId: trip.id!,
        categoriaId: result.categoria.id,
        monto: result.monto,
        fecha: result.fecha,
        descripcion: result.descripcion,
      );
      if (!mounted) return;
      setState(() {
        _gastosPorViaje[trip.id!] = (_gastosPorViaje[trip.id!] ?? 0) + result.monto;
      });
      _showSnack(
        'Gasto de ${formatCOP(result.monto)} en ${result.categoria.nombre} agregado a ${trip.name}',
        color: AppColors.ink,
      );
    } catch (e, st) {
      debugPrint('HomeScreenClient._addExpenseToTrip createGasto error: $e\n$st');
      if (!mounted) return;
      _showSnack('No se pudo guardar el gasto. Intenta de nuevo.');
    }
  }

  void _showSnack(String message, {Color color = AppColors.error}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _handleSideNav(AppSection section) {
    switch (section) {
      case AppSection.inicio:
      case AppSection.misViajes:
        break; // ya estamos aquí.
      case AppSection.comercios:
        _openComercios();
        break;
      case AppSection.mapa:
        _openMap();
        break;
    }
  }

  Future<void> _handleMobileNavSelect(int index) async {
    if (index == 1) {
      _openMap();
    } else if (index == 2) {
      _openComercios();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppBreakpoints.mobile) {
          return _buildMobile(context);
        }
        final next = _nextTrip;
        return AppShell(
          section: AppSection.inicio,
          onNavigate: _handleSideNav,
          onCreateTrip: _createTrip,
          activeTrip: next,
          activeTripSpent: next != null ? _spentFor(next) : null,
          child: _buildDesktopContent(context),
        );
      },
    );
  }

  // ─── Escritorio / tablet ───

  Widget _buildDesktopContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGreetingRow(),
        const SizedBox(height: 26),
        _buildActionGrid(),
        const SizedBox(height: 40),
        _buildTripsAndPlacesRow(),
      ],
    );
  }

  Widget _buildGreetingRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hola, ${_firstName(userName)}.', style: AppText.display(42)),
              Text(
                _trips.length == 1
                    ? '1 viaje activo'
                    : '${_trips.length} viajes activos',
                style: AppText.displayItalic(42),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Text(
            _contextLine(_nextTrip),
            style: AppText.ui(14, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }

  Widget _buildActionGrid() {
    const crearFlex = 8;
    const mapaFlex = 5;
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: crearFlex,
                child: StaggerIn(
                  index: 0,
                  child: _CrearViajeCard(onTap: _createTrip),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: mapaFlex,
                child: StaggerIn(index: 1, child: _MapaCard(onTap: _openMap)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: crearFlex,
                child: StaggerIn(
                  index: 2,
                  child: _ProximoGastoCard(trip: _nextTrip, onTap: _quickAddExpense),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(flex: mapaFlex, child: SizedBox()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTripsAndPlacesRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final left = _buildMisViajesColumn();
        final right = _buildCercaDeTiColumn();
        if (constraints.maxWidth >= 820) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 16, child: left),
              const SizedBox(width: 22),
              Expanded(flex: 10, child: right),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [left, const SizedBox(height: 32), right],
        );
      },
    );
  }

  Widget _buildMisViajesColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Mis viajes', style: AppText.display(26)),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {},
                child: Text('VER TODOS', style: AppText.label(11, color: AppColors.inkSoft)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoadingTrips)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator(color: AppColors.ink)),
          )
        else if (_trips.isEmpty)
          _buildEmptyTrips()
        else
          Column(
            children: [
              for (var i = 0; i < _trips.length; i++) ...[
                StaggerIn(
                  index: i,
                  child: TripCard(
                    trip: _trips[i],
                    spent: _spentFor(_trips[i]),
                    thumbWidth: 78,
                    thumbHeight: 88,
                    onTap: () => _openTripDetail(_trips[i]),
                  ),
                ),
                if (i != _trips.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildEmptyTrips() {
    return HoverCard(
      onTap: _createTrip,
      color: AppColors.wash,
      radius: AppRadius.card,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aún no tienes viajes', style: AppText.display(22)),
          const SizedBox(height: 6),
          Text(
            'Crea tu primer viaje para comenzar a planificar.',
            style: AppText.ui(13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Crear viaje',
                style: AppText.ui(14, weight: FontWeight.w700, color: AppColors.inkSoft),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward, size: 16, color: AppColors.inkSoft),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCercaDeTiColumn() {
    final featured = _nearbyPlaces.isNotEmpty ? _nearbyPlaces.first : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cerca de ti', style: AppText.display(26)),
        const SizedBox(height: 16),
        if (_isLoadingPlaces)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator(color: AppColors.ink)),
          )
        else if (featured == null)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.wash,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Text(
              'Todavía no hay comercios ni lugares cerca registrados.',
              style: AppText.ui(13, color: AppColors.textMuted),
            ),
          )
        else
          PlaceCard(
            variant: PlaceCardVariant.featured,
            name: featured.nombre,
            imageUrl: featured.fotoUrl,
            categoryLabel: featured.categoria.toUpperCase(),
            address: featured.direccion,
            tags: const [PlaceCardTag('Verificado', emphasis: true)],
            onTap: _openComercios,
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _openComercios,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.line),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
            child: Text('Ver los ${_nearbyPlaces.length} lugares →'),
          ),
        ),
      ],
    );
  }

  String _firstName(String name) => name.trim().split(' ').first;

  String _contextLine(Trip? next) {
    if (next == null) return 'Explora, planifica y viaja seguro.';
    final pct = next.getBudgetPercentage().clamp(0, 999).round();
    final start = parseDdMmYyyy(next.startDate);
    if (start != null) {
      final days = start.difference(DateTime.now()).inDays;
      if (days > 0) {
        return '${next.destination} empieza en $days '
            '${days == 1 ? 'día' : 'días'}. El presupuesto va al $pct%.';
      }
    }
    return '${next.destination} · el presupuesto va al $pct%.';
  }

  // ─── Móvil ───
  // Estructura mobile-first del README original (hero + tarjetas +
  // nav flotante); no forma parte del alcance de esta pasada de
  // escritorio, se mantiene funcional tal como estaba.

  Widget _buildMobile(BuildContext context) {
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
                      onButtonPressed: _createTrip,
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
                          color: AppColors.ink,
                        ),
                      ),
                      TextButton(onPressed: () {}, child: const Text('Ver todos')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 156,
                    child: _isLoadingTrips
                        ? const Center(
                            child: CircularProgressIndicator(color: AppColors.ink),
                          )
                        : _trips.isEmpty
                        ? _buildMobileEmptyTrips()
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _trips.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final trip = _trips[index];
                              return FadeSlideIn(
                                delay: Duration(milliseconds: 70 * index),
                                offset: const Offset(0.12, 0),
                                child: _buildMobileTripCard(
                                  trip: trip,
                                  onViewDetails: () => _openTripDetail(trip),
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
      bottomNavigationBar: FloatingNavBar(
        index: 0,
        onSelect: _handleMobileNavSelect,
        onCreate: _createTrip,
      ),
    );
  }

  Widget _buildHeroAppBar() {
    return SliverAppBar(
      expandedHeight: 220,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.ink,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: AppColors.ink),
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
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.logout, size: 16, color: Colors.white),
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
                      style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.9)),
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

  Widget _buildMobileEmptyTrips() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.luggage_outlined, size: 44, color: Color(0xFFB0D9E8)),
          const SizedBox(height: 10),
          const Text(
            'Aún no tienes viajes',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.ink),
          ),
          const SizedBox(height: 4),
          Text(
            'Crea tu primer viaje para comenzar a planificar.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
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
      leading: Icon(icon, size: 30, color: AppColors.ink),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.ink),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(fontSize: 12.5, color: AppColors.textMuted, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(onPressed: onButtonPressed, child: Text(buttonText)),
        ],
      ),
    );
  }

  Widget _buildMapCard() {
    return BoardingPassCard(
      leading: const Icon(Icons.location_on_outlined, size: 30, color: AppColors.ink),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mapa',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.ink),
                ),
                const SizedBox(height: 6),
                Text(
                  'Explora destinos, encuentra comercios seguros y planifica tu ruta.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textMuted, height: 1.4),
                ),
                const SizedBox(height: 12),
                OutlinedButton(onPressed: _openMap, child: const Text('Ver mapa')),
              ],
            ),
          ),
          const SizedBox(width: 14),
          const _MiniMapPreview(),
        ],
      ),
    );
  }

  Widget _buildMobileTripCard({required Trip trip, required VoidCallback onViewDetails}) {
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
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.ink),
            ),
            if (startDate != null)
              Text(_monthAbbrs[startDate.month - 1], style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
        child: InkWell(
          onTap: onViewDetails,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trip.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.ink),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${trip.startDate} - ${trip.endDate}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      trip.destination,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
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

class _CrearViajeCard extends StatelessWidget {
  const _CrearViajeCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      onTap: onTap,
      color: AppColors.ink,
      radius: 28,
      baseShadow: AppShadow.raised,
      hoverShadow: AppShadow.raised,
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        height: 116,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.add, color: AppColors.ink, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Crear un viaje', style: AppText.display(26, color: AppColors.paper)),
                const SizedBox(height: 4),
                Text(
                  'Presupuesto, hospedaje e itinerario en 3 pasos',
                  style: AppText.ui(12, color: AppColors.textOnInk),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MapaCard extends StatelessWidget {
  const _MapaCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      onTap: onTap,
      color: AppColors.wash,
      radius: 28,
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        height: 116,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.ink, width: 2),
              ),
              child: const Icon(Icons.location_on_outlined, color: AppColors.ink, size: 18),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mapa', style: AppText.display(22)),
                const SizedBox(height: 4),
                Text('14 lugares cerca', style: AppText.ui(12, color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Antes solo mostraba el próximo pago de hospedaje (informativo, sin
/// acción). Ahora es también el acceso rápido a "añadir gasto" desde
/// Inicio — el "+" deja claro que se puede tocar, sin agregar una
/// tarjeta nueva a la retícula.
class _ProximoGastoCard extends StatelessWidget {
  const _ProximoGastoCard({required this.trip, required this.onTap});

  final Trip? trip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasExpense = trip != null && trip!.lodgingCost > 0;
    return HoverCard(
      onTap: onTap,
      color: AppColors.surface,
      radius: 28,
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        height: 116,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('PRÓXIMO GASTO', style: AppText.label(10)),
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.add, color: AppColors.ink, size: 16),
                ),
              ],
            ),
            if (hasExpense)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip!.lodgingType.isNotEmpty ? trip!.lodgingType : 'Hospedaje',
                    style: AppText.display(24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Se paga antes del ${trip!.startDate} · ${formatCOP(trip!.lodgingCost)}',
                    style: AppText.ui(12, color: AppColors.textMuted),
                  ),
                ],
              )
            else
              Text(
                'Registra un gasto de tu viaje en segundos.',
                style: AppText.ui(13, color: AppColors.textMuted),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.ink.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.ink),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.ink),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

/// Vista decorativa simplificada de un mapa — solo para la versión
/// móvil (README); en escritorio ese espacio lo cubre `MapPanel`.
class _MiniMapPreview extends StatelessWidget {
  const _MiniMapPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: const Color(0xFFC8E6F5)),
      child: const Stack(
        children: [
          Positioned(left: 16, top: 14, child: Icon(Icons.location_on, color: AppColors.ink, size: 22)),
          Positioned(right: 18, bottom: 16, child: Icon(Icons.shield, color: AppColors.ink, size: 18)),
          Positioned(left: 34, bottom: 24, child: Icon(Icons.restaurant, color: AppColors.ink, size: 16)),
        ],
      ),
    );
  }
}
