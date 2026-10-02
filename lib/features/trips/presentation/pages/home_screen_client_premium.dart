import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../pages/create_trip_screen.dart';
import '../pages/trip_model.dart';
import '../../../auth/providers/app_auth_provider.dart';
import '../../../expenses/data/expense_repository.dart';
import '../../../expenses/data/models/categoria_gasto_model.dart';
import '../../../expenses/presentation/widgets/add_expense_sheet.dart';
import '../../../expenses/providers/budget_alerts_provider.dart';
import '../../../expenses/utils/daily_budget_calculator.dart';
import '../../../subscriptions/providers/subscription_provider.dart';
import '../../../places_map/data/models/map_place.dart';
import '../../../places_map/data/places_map_repository.dart';
import '../../data/trip_repository.dart';
import '../../utils/budget_calculator.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/settings/currency_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shell/app_shell.dart';
import '../../../../widgets/floating_nav_bar.dart';
import '../../../../widgets/hover_card.dart';
import '../../../../widgets/stagger_in.dart';
import '../../../../widgets/trip_card.dart';

class HomeScreenClientPremium extends StatefulWidget {
  const HomeScreenClientPremium({super.key});

  @override
  State<HomeScreenClientPremium> createState() => _HomeScreenClientPremiumState();
}

class _HomeScreenClientPremiumState extends State<HomeScreenClientPremium> {
  final List<Trip> _trips = [];
  final TripRepository _tripRepository = TripRepository();
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  bool _isLoadingTrips = true;
  Map<int, double> _gastosPorViaje = {};
  final PlacesMapRepository _placesRepository = PlacesMapRepository();
  List<MapPlace> _nearbyPlaces = [];
  bool _isLoadingPlaces = true;

  String get userName => context.watch<AppAuthProvider>().displayName;

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

  Future<void> _loadTrips() async {
    final auth = context.read<AppAuthProvider>();
    final turistaId = auth.usuario?.id;
    if (turistaId == null) {
      setState(() => _isLoadingTrips = false);
      return;
    }
    try {
      final trips = await _tripRepository.fetchTripsByTurista(turistaId);
      if (!mounted) return;
      setState(() {
        _trips
          ..clear()
          ..addAll(trips);
        _isLoadingTrips = false;
      });
      _loadGastosPorViaje(trips);
    } catch (e, st) {
      debugPrint('HomeScreenClientPremium._loadTrips error: $e\n$st');
      if (!mounted) return;
      setState(() => _isLoadingTrips = false);
    }
  }

  Future<void> _cancelarSuscripcion() async {
  final confirmar = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Cancelar suscripción'),
        content: const Text(
          '¿Estás seguro de que quieres cancelar tu suscripción Premium?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('No, volver'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sí, cancelar'),
          ),
        ],
      );
    },
  );

  if (confirmar != true || !mounted) return;

  // TEMPORAL: probamos solamente la navegación.
  context.go('/home-normal');
}




  Future<void> _loadGastosPorViaje(List<Trip> trips) async {
    final ids = [for (final t in trips) if (t.id != null) t.id!];
    if (ids.isEmpty) return;
    try {
      final totals = await _expenseRepository.fetchTotalGastosPorViaje(ids);
      if (!mounted) return;
      setState(() => _gastosPorViaje = totals);
    } catch (e, st) {
      debugPrint('HomeScreenClientPremium._loadGastosPorViaje error: $e\n$st');
    }
  }

  Future<void> _loadNearbyPlaces() async {
    try {
      final places = await _placesRepository.fetchNearbyPlaces();
      if (!mounted) return;
      setState(() {
        _nearbyPlaces = places;
        _isLoadingPlaces = false;
      });
    } catch (e, st) {
      debugPrint('HomeScreenClientPremium._loadNearbyPlaces error: $e\n$st');
      if (!mounted) return;
      setState(() => _isLoadingPlaces = false);
    }
  }

  // ════════════════════════════════════════════════════════════════════════════════
  // NAVEGACIÓN - MISMA LÓGICA QUE HomeScreenClient
  // ════════════════════════════════════════════════════════════════════════════════

  void _handleSideNav(AppSection section) {
    switch (section) {
      case AppSection.inicio:
      case AppSection.misViajes:
        break; // ya estamos en Inicio y los viajes se muestran aquí.
      case AppSection.comercios:
        _openComercios();
        break;
      case AppSection.mapa:
        _openMap();
        break;
      case AppSection.promociones:
        context.go('/promociones');
        break;
      case AppSection.suscripciones:
        context.go('/suscripciones');
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

  Future<void> _createTrip() async {
    // Exactamente el mismo flujo que Client:
    // ambos botones de "Crear viaje" abren el mismo diálogo/página.
    final trip = await showCreateTripDialog(context);
    if (!mounted) return;
    if (trip != null) {
      setState(() => _trips.add(trip));
    }
  }

  void _openMap() => context.go('/mapa');

  void _openComercios() => context.go('/comercios');

  void _openTripDetail(Trip trip) {
    context.go('/viajes/${trip.id}', extra: trip);
  }

  Future<void> _quickAddExpense() async {
    if (_trips.isEmpty) {
      _showSnack('Crea un viaje primero');
      return;
    }

    final trip =
        _trips.length == 1 ? _trips.first : await _pickTripForExpense();

    if (trip == null || !mounted) return;
    await _addExpenseToTrip(trip);
  }

  Future<Trip?> _pickTripForExpense() {
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
              Text('Selecciona un viaje', style: AppText.display(22)),
              const SizedBox(height: 4),
              Text(
                '¿A qué viaje quieres asociar este gasto?',
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
                          onTap: () =>
                              Navigator.pop(sheetContext, _trips[i]),
                        ),
                        if (i != _trips.length - 1)
                          const SizedBox(height: 10),
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
      _showSnack('El viaje no se ha guardado aún');
      return;
    }

    List<CategoriaGasto> categorias;
    try {
      categorias = await _expenseRepository.fetchCategorias();
    } catch (e, st) {
      debugPrint('Error fetchCategorias: $e\n$st');
      if (!mounted) return;
      _showSnack('Error al cargar categorías');
      return;
    }

    if (categorias.isEmpty) {
      if (!mounted) return;
      _showSnack('Sin categorías disponibles');
      return;
    }

    if (!mounted) return;

    DailyBudgetCalculator? dailyBudget;
    if (context.read<SubscriptionProvider>().isPremium) {
      try {
        final gastos =
            await _expenseRepository.fetchGastosDelViaje(trip.id!);
        dailyBudget = DailyBudgetCalculator(trip: trip, gastos: gastos);
      } catch (e, st) {
        debugPrint(
          'Error fetchGastosDelViaje: $e\\n$st',
        );
      }
    }

    if (!mounted) return;

    final startDate = parseDdMmYyyy(trip.startDate) ?? DateTime.now();
    final endDateRaw = parseDdMmYyyy(trip.endDate) ?? startDate;

    final result = await AddExpenseSheet.show(
      context,
      categorias: categorias,
      tripStartDate: startDate,
      tripEndDate: endDateRaw.isBefore(startDate) ? startDate : endDateRaw,
      dailyBudget: dailyBudget,
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
        _gastosPorViaje[trip.id!] =
            (_gastosPorViaje[trip.id!] ?? 0) + result.monto;
      });

      context.read<BudgetAlertsProvider>().refresh();

      _showSnack(
        'Gasto registrado ✓',
        color: AppColors.ink,
      );
    } catch (e, st) {
      debugPrint('Error createGasto: $e\n$st');
      if (!mounted) return;
      _showSnack('Error al guardar gasto');
    }
  }

  Future<void> _openFavorites() async {
    _showSnack('🚀 Favoritos está en desarrollo');
  }

  Future<void> _viewAnalytics() async {
    _showSnack('🚀 Análisis está en desarrollo');
  }

  Future<void> _viewBudgetComparison() async {
    _showSnack('🚀 Comparación de presupuesto está en desarrollo');
  }

  void _showSnack(String message, {Color color = AppColors.error}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    context.watch<CurrencyProvider>();
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppBreakpoints.mobile) {
          return _buildMobilePremium(context);
        }
        final next = _nextTrip;
        return AppShell(
          section: AppSection.inicio,
          onNavigate: _handleSideNav,
          onCreateTrip: _createTrip,
          onCancelSubscription: _cancelarSuscripcion,
          activeTrip: next,
          activeTripSpent: next != null ? _spentFor(next) : null,
          child: _buildDesktopContentPremium(context),
        );

      },
    );
  }

  Widget _buildDesktopContentPremium(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGreetingRowPremium(),
        const SizedBox(height: 26),
        _buildActionGrid(),
        const SizedBox(height: 40),
        _buildAnalyticsSection(),
        const SizedBox(height: 40),
        _buildMisViajesColumn(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildGreetingRowPremium() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.homeClientGreeting(_firstName(userName)),
                      style: AppText.display(42),
                    ),
                    Text(
                      context.l10n.homeClientActiveTripsCount(_trips.length),
                      style: AppText.displayItalic(42),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.mint,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppShadow.card,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'PREMIUM',
                          style: AppText.label(
                            10,
                            color: AppColors.ink,
                            weight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '⭐ Activo',
                          style: AppText.ui(
                            11,
                            color: AppColors.ink,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionGrid() {
    return Column(
      children: [
        // ─── Fila 1: Crear viaje + Mapa ───
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 8,
                child: StaggerIn(
                  index: 0,
                  child: _CrearViajeCard(onTap: _createTrip),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 5,
                child: StaggerIn(index: 1, child: _MapaCard(onTap: _openMap)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        
        // ─── Fila 2: Gasto manual + Escanear recibos ───
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 8,
                child: StaggerIn(
                  index: 2,
                  child: _GastoManualCard(onTap: _quickAddExpense),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 5,
                child: StaggerIn(
                  index: 3,
                  child: _ScanReceiptCard(onTap: _quickAddExpense),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        
        // ─── Fila 3: Favoritos + Analytics ───
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 8,
                child: StaggerIn(
                  index: 4,
                  child: _FavoritesCard(onTap: _openFavorites),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 5,
                child: StaggerIn(
                  index: 5,
                  child: _SpendingAnalyticsCard(trip: _nextTrip, onTap: _viewAnalytics),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        
        // ─── Fila 4: Comparar presupuesto ───
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 8,
                child: StaggerIn(
                  index: 6,
                  child: _BudgetComparisonCard(
                    totalBudget: _totalBudget,
                    totalSpent: _trips.fold(0.0, (sum, t) => sum + _spentFor(t)),
                    onTap: _viewBudgetComparison,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(flex: 5, child: SizedBox()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMisViajesColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.homeClientMyTripsTitle,
              style: AppText.display(26),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {},
                child: Text(
                  context.l10n.homeClientViewAllLabel,
                  style: AppText.label(
                    11,
                    color: AppColors.inkSoft,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoadingTrips)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.ink),
            ),
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
                if (i != _trips.length - 1)
                  const SizedBox(height: 12),
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
          Text(
            context.l10n.homeClientNoTripsTitle,
            style: AppText.display(22),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.homeClientNoTripsSubtitle,
            style: AppText.ui(
              13,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.homeClientCreateTripLabel,
                style: AppText.ui(
                  14,
                  weight: FontWeight.w700,
                  color: AppColors.inkSoft,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward,
                size: 16,
                color: AppColors.inkSoft,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection() {
    final total = _totalBudget;
    final gastado = _trips.fold(0.0, (sum, t) => sum + _spentFor(t));
    final porcentaje = total > 0 ? (gastado / total * 100).clamp(0, 100) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Análisis Premium 📊',
          style: AppText.display(26),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: AppShadow.card,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total invertido en viajes',
                        style: AppText.ui(14, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.formatMoney(total),
                        style: AppText.display(32, color: AppColors.inkSoft),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Gastado',
                        style: AppText.ui(14, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${porcentaje.toStringAsFixed(1)}%',
                        style: AppText.display(32, color: AppColors.mint),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 12,
                  value: porcentaje / 100,
                  backgroundColor: AppColors.line,
                  valueColor: AlwaysStoppedAnimation(
                    porcentaje > 80 ? Colors.red[500] : AppColors.mint,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                gastado > 0
                    ? '${context.formatMoney(gastado)} de ${context.formatMoney(total)}'
                    : 'Sin gastos registrados',
                style: AppText.ui(12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.trending_down,
                label: 'Promedio por viaje',
                value: _trips.isEmpty
                    ? '—'
                    : context.formatMoney(_totalBudget / _trips.length),
                color: AppColors.inkSoft,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.flight_takeoff,
                label: 'Viajes activos',
                value: '${_trips.length}',
                color: AppColors.mint,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.wash,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(label, style: AppText.ui(12, color: AppColors.textMuted)),
          const SizedBox(height: 6),
          Text(value, style: AppText.display(20, color: color)),
        ],
      ),
    );
  }

  Widget _buildMobilePremium(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreetingRowPremium(),
            const SizedBox(height: 32),
            _buildActionGrid(),
            const SizedBox(height: 40),
            _buildAnalyticsSection(),
            const SizedBox(height: 40),
            _buildMisViajesColumn(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: FloatingNavBar(
        index: 0,
        onSelect: _handleMobileNavSelect,
        onCreate: _createTrip,
      ),
    );
  }

  String _firstName(String name) => name.trim().split(' ').first;
}

// ════════════════════════════════════════════════════════════════════════════════
// WIDGETS PRIVADOS - TARJETAS DE ACCIÓN
// ════════════════════════════════════════════════════════════════════════════════

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
                Text('+ CREAR VIAJE', style: AppText.display(26, color: AppColors.paper)),
                const SizedBox(height: 4),
                Text(
                  'Organiza aventuras',
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
                Text('📍 VER MAPA', style: AppText.display(22)),
                const SizedBox(height: 4),
                Text('Descubre lugares', style: AppText.ui(12, color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GastoManualCard extends StatelessWidget {
  const _GastoManualCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                Text('GASTO MANUAL', style: AppText.label(10)),
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.ink,
                    size: 16,
                  ),
                ),
              ],
            ),
            Text(
              'Registra un gasto manual',
              style: AppText.display(24),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanReceiptCard extends StatelessWidget {
  const _ScanReceiptCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      onTap: onTap,
      color: AppColors.mint,
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
                color: AppColors.paper,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.receipt_long, color: AppColors.mint, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📸 Escanear',
                  style: AppText.display(22, color: AppColors.paper),
                ),
                const SizedBox(height: 4),
                Text(
                  'Recibos con IA',
                  style: AppText.ui(12, color: AppColors.paper.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesCard extends StatelessWidget {
  const _FavoritesCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.favorite_outline, color: AppColors.paper, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✨ Favoritos',
                  style: AppText.display(22),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lugares guardados',
                  style: AppText.ui(12, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SpendingAnalyticsCard extends StatelessWidget {
  const _SpendingAnalyticsCard({
    required this.trip,
    required this.onTap,
  });

  final Trip? trip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final spent = trip != null ? (trip!.getTotalSpent()) : 0.0;
    final budget = trip != null ? trip!.maxBudget : 0.0;
    final percentage = budget > 0 ? ((spent / budget) * 100).clamp(0, 100) : 0.0;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.bar_chart, size: 20, color: AppColors.ink),
                Container(
                  decoration: BoxDecoration(
                    color: percentage > 80 ? Colors.red[100] : AppColors.mint.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: AppText.label(
                      9,
                      weight: FontWeight.w700,
                      color: percentage > 80 ? Colors.red.shade700 : AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📊 Análisis',
                  style: AppText.display(22),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dónde gastas más',
                  style: AppText.ui(12, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetComparisonCard extends StatelessWidget {
  const _BudgetComparisonCard({
    required this.totalBudget,
    required this.totalSpent,
    required this.onTap,
  });

  final double totalBudget;
  final double totalSpent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final percentage = totalBudget > 0 ? ((totalSpent / totalBudget) * 100).clamp(0, 100) : 0.0;
    final isOverBudget = totalSpent > totalBudget;
    final color = isOverBudget ? Colors.red : AppColors.mint;

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
                Text('💰 Presupuesto', style: AppText.label(10, weight: FontWeight.w700)),
                Container(
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    isOverBudget ? '⚠️ Excedido' : '✓ Ok',
                    style: AppText.label(9, weight: FontWeight.w700, color: color),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.formatMoney(totalBudget),
                  style: AppText.display(24, color: AppColors.ink),
                ),
                const SizedBox(height: 4),
                Text(
                  '${percentage.toStringAsFixed(0)}% gastado de tu presupuesto total',
                  style: AppText.ui(11, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}