//pantalla principal del turista, crear viaje
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../pages/create_trip_screen.dart';
import '../pages/trip_model.dart';
import '../../../auth/providers/app_auth_provider.dart';
import '../../../expenses/data/expense_repository.dart';
import '../../../expenses/data/models/categoria_gasto_model.dart';
import '../../../expenses/presentation/widgets/add_expense_sheet.dart';
import '../../../expenses/presentation/widgets/budget_alert_card.dart';
import '../../../expenses/presentation/widgets/budget_notifications_listener.dart';
import '../../../expenses/providers/budget_alerts_provider.dart';
import '../../../expenses/providers/notification_prefs_provider.dart';
import '../../../expenses/utils/daily_budget_calculator.dart';
import '../../../subscriptions/providers/subscription_provider.dart';
import '../../../places_map/data/models/map_place.dart';
import '../../../places_map/data/places_map_repository.dart';
import '../../data/models/pocket_repository.dart';
import '../../data/trip_repository.dart';
import '../../utils/budget_calculator.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/settings/currency_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shell/app_shell.dart';
import '../../../../widgets/load_error_box.dart';
import '../../../../widgets/floating_nav_bar.dart';
import '../../../../widgets/hover_card.dart';
import '../../../../widgets/place_card.dart';
import '../../../../widgets/stagger_in.dart';
import '../../../../widgets/trip_card.dart';
import '../../data/limits_repository.dart';

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
  // Errores de carga: se muestran en vez del estado vacío, para que una
  // falla del servidor no parezca "no tienes viajes".
  bool _tripsError = false;
  bool _placesError = false;
  bool _gastosError = false;

  /// Gastos reales (tabla `gastos`, HU-13) por `trip.id` — sin esto,
  /// las tarjetas de viaje y el resumen del sidebar solo contaban lo
  /// planeado al crear el viaje, no lo que en verdad se ha gastado.
  Map<int, double> _gastosPorViaje = {};

  final PlacesMapRepository _placesRepository = PlacesMapRepository();
  List<MapPlace> _nearbyPlaces = [];
  bool _isLoadingPlaces = true;

  String get userName => context.watch<AppAuthProvider>().displayName;

  /// Viaje más próximo por `startDate`; si ninguno tiene fecha futura
  /// parseable, cae al primero con fecha válida y luego al primero de
  /// la lista — nunca deja el saludo/estadísticas vacíos teniendo datos.
  Trip? get _nextTrip {
    if (_trips.isEmpty) return null;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final withDates =
        _trips
            .map((t) => MapEntry(t, parseDdMmYyyy(t.startDate)))
            .where((e) => e.value != null)
            .toList()
          ..sort((a, b) => a.value!.compareTo(b.value!));
    final upcoming = withDates
        .where((e) => !e.value!.isBefore(todayDate))
        .toList();
    if (upcoming.isNotEmpty) return upcoming.first.key;
    if (withDates.isNotEmpty) return withDates.first.key;
    return _trips.first;
  }

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
    // Reintento: vuelve a "cargando" (en `initState` ya lo está y ahí
    // `setState` no se puede llamar).
    if (_tripsError) {
      setState(() {
        _isLoadingTrips = true;
        _tripsError = false;
      });
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
      setState(() {
        _isLoadingTrips = false;
        _tripsError = true;
      });
    }
  }

  /// Gastos reales por viaje, para que las tarjetas y el sidebar no se
  /// queden solo con lo planeado — si falla, las tarjetas simplemente
  /// caen a `trip.getTotalSpent()` (comportamiento anterior), no vale
  /// la pena bloquear la pantalla por esto.
  Future<void> _loadGastosPorViaje(List<Trip> trips) async {
    final ids = [
      for (final t in trips)
        if (t.id != null) t.id!,
    ];
    if (ids.isEmpty) return;
    try {
      final totals = await _expenseRepository.fetchTotalGastosPorViaje(ids);
      if (!mounted) return;
      setState(() {
        _gastosPorViaje = totals;
        _gastosError = false;
      });
    } catch (e, st) {
      debugPrint('HomeScreenClient._loadGastosPorViaje error: $e\n$st');
      if (mounted) setState(() => _gastosError = true);
    }
  }

  /// Para la tarjeta "Cerca de ti" — mismos datos reales de HU-07 que
  /// usa Comercios, no un lugar de relleno.
  Future<void> _loadNearbyPlaces() async {
    if (_placesError) {
      setState(() {
        _isLoadingPlaces = true;
        _placesError = false;
      });
    }
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
      setState(() {
        _isLoadingPlaces = false;
        _placesError = true;
      });
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(context.l10n.homeClientSignOutDialogTitle),
        content: Text(context.l10n.homeClientSignOutDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.homeClientCancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.homeClientSignOutConfirmButton),
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

  Future<void> _openBudgetEstimator() async {
    final trip = await context.push<Trip>('/estimar');
    if (!mounted) return;
    if (trip != null) setState(() => _trips.add(trip));
  }

  void _openTripDetail(Trip trip) {
    context.go('/viajes/${trip.id}', extra: trip);
  }

  /// Acceso rápido a "añadir gasto" desde Inicio, sin pasar por el
  /// detalle del viaje: el enfoque de la app es justo registrar gastos
  /// seguido, así que si solo hay un viaje abierto no tiene sentido
  /// pedir que se elija — se abre directo el formulario. Los viajes ya
  /// terminados no se ofrecen (son de solo lectura).
  Future<void> _quickAddExpense() async {
    if (_trips.isEmpty) {
      _showSnack(context.l10n.homeClientCreateTripFirstSnackbar);
      return;
    }
    final open = _trips.where((t) => !t.isFinished).toList();
    if (open.isEmpty) {
      _showSnack(context.l10n.homeClientNoOpenTripsSnackbar);
      return;
    }
    final trip = open.length == 1 ? open.first : await _pickTripForExpense(open);
    if (trip == null || !mounted) return;
    await _addExpenseToTrip(trip);
  }

  Future<Trip?> _pickTripForExpense(List<Trip> trips) {
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
              Text(
                context.l10n.homeClientPickTripTitle,
                style: AppText.display(22),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.homeClientPickTripSubtitle,
                style: AppText.ui(13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (var i = 0; i < trips.length; i++) ...[
                        TripCard(
                          trip: trips[i],
                          spent: _spentFor(trips[i]),
                          thumbWidth: 56,
                          thumbHeight: 64,
                          onTap: () => Navigator.pop(sheetContext, trips[i]),
                        ),
                        if (i != trips.length - 1) const SizedBox(height: 10),
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
    if (trip.isFinished) {
      _showSnack(context.l10n.tripFinishedReadOnlyNotice);
      return;
    }
    if (trip.id == null) {
      _showSnack(context.l10n.homeClientTripNotSavedSnackbar);
      return;
    }

    List<CategoriaGasto> categorias;
    try {
      categorias = await _expenseRepository.fetchCategorias();
    } catch (e, st) {
      debugPrint(
        'HomeScreenClient._addExpenseToTrip fetchCategorias error: $e\n$st',
      );
      if (!mounted) return;
      _showSnack(context.l10n.homeClientCategoriesLoadErrorSnackbar);
      return;
    }
    if (categorias.isEmpty) {
      if (!mounted) return;
      _showSnack(context.l10n.homeClientCategoriesLoadErrorSnackbar);
      return;
    }
    if (!mounted) return;

    // HU-11 (TG-278): con los gastos del viaje el formulario puede
    // advertir si este gasto pasa el presupuesto del día (solo Premium,
    // HU-24). Si falla, se registra igual, solo que sin la advertencia.
    DailyBudgetCalculator? dailyBudget;
    if (context.read<SubscriptionProvider>().isPremium) {
      try {
        final gastos = await _expenseRepository.fetchGastosDelViaje(trip.id!);
        dailyBudget = DailyBudgetCalculator(trip: trip, gastos: gastos);
      } catch (e, st) {
        debugPrint(
          'HomeScreenClient._addExpenseToTrip fetchGastosDelViaje error: $e\n$st',
        );
      }
    }
    if (!mounted) return;

    final startDate = parseDdMmYyyy(trip.startDate) ?? DateTime.now();
    final endDateRaw = parseDdMmYyyy(trip.endDate) ?? startDate;

    // Saldo de MI bolsillo (null si aún no lo he creado), igual que en el
    // detalle del viaje.
    final userId = context.read<AppAuthProvider>().usuario?.id;
    double? pocketBalance;
    if (userId != null) {
      try {
        final pocket = await PocketRepository().fetchMyPocket(tripId: trip.id!, userId: userId);
        pocketBalance = pocket?.balance;
      } catch (e, st) {
        debugPrint('HomeScreenClient._addExpenseToTrip fetchMyPocket error: $e\n$st');
      }
    }
    if (!mounted) return;

    // HU-19 CA3: límites del viaje y lo ya gastado por categoría, para el
    // aviso al registrar. Si falla, se registra igual, solo sin el aviso.
    Map<int, double> limits = {};
    final spentByCat = <int, double>{};
    try {
      limits = await LimitsRepository().fetchLimits(trip.id!);
      if (limits.isNotEmpty) {
        final gastos = await _expenseRepository.fetchGastosDelViaje(trip.id!);
        for (final g in gastos) {
          spentByCat[g.categoria.id] = (spentByCat[g.categoria.id] ?? 0) + g.monto;
        }
      }
    } catch (e, st) {
      debugPrint('HomeScreenClient._addExpenseToTrip limites error: $e\n$st');
    }
    if (!mounted) return;

    final result = await AddExpenseSheet.show(
      context,
      categorias: categorias,
      tripStartDate: startDate,
      tripEndDate: endDateRaw.isBefore(startDate) ? startDate : endDateRaw,
      dailyBudget: dailyBudget,
      currentUserId: userId,
      tripBalance: trip.maxBudget - (trip.getTotalSpent() + (_gastosPorViaje[trip.id!] ?? 0)),
      pocketBalance: pocketBalance,
      categoryLimits: limits,          // NUEVO
      spentByCategory: spentByCat,     // NUEVO
    );
    if (result == null || !mounted) return;

    try {
      final gasto = await _expenseRepository.createGasto(
        viajeId: trip.id!,
        categoriaId: result.categoria.id,
        monto: result.monto,
        fecha: result.fecha,
        descripcion: result.descripcion,
        establecimiento: result.establecimiento,
        pagadoPorId: result.pagadoPorId,
        pagadoConDineroViaje: result.pagadoConDineroViaje,
      );
      if (!mounted) return;
      setState(() {
        _gastosPorViaje[trip.id!] =
            (_gastosPorViaje[trip.id!] ?? 0) + result.monto;
      });
      // HU-11: aviso inmediato con el % al que llegó el día del gasto.
      final calc = dailyBudget;
      if (calc != null) {
        notifyExpenseBudget(
          context,
          trip: trip,
          day: DailyBudgetCalculator(
            trip: trip,
            gastos: [...calc.gastos, gasto],
          ).statusFor(result.fecha),
        );
      }
      context.read<BudgetAlertsProvider>().refresh();
      _showSnack(
        context.l10n.homeClientExpenseAddedSnackbar(
          context.formatMoney(result.monto),
          result.categoria.nombre,
          trip.name,
        ),
        color: AppColors.ink,
      );
    } catch (e, st) {
      debugPrint(
        'HomeScreenClient._addExpenseToTrip createGasto error: $e\n$st',
      );
      if (!mounted) return;
      _showSnack(context.l10n.homeClientExpenseSaveErrorSnackbar);
    }
  }

  void _showSnack(String message, {Color color = AppColors.error}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
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
      case AppSection.actividades:
        context.go('/actividades');
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

  @override
  Widget build(BuildContext context) {
    context.watch<CurrencyProvider>();
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

  /// HU-11: advertencias del presupuesto de hoy de los viajes en curso
  /// (las calcula `BudgetAlertsProvider` en segundo plano). Solo
  /// aparecen desde el 75% — si todo va bien, no ocupan espacio.
  Widget _buildDailyBudgetAlerts() {
    // Premium (HU-24): a los demás no se les insiste aquí en Inicio; la
    // invitación sale en el detalle del viaje.
    if (!context.watch<SubscriptionProvider>().isPremium)
      return const SizedBox.shrink();
    // HU-11 CA4: con "Mostrar alertas" apagado, Inicio no advierte nada.
    if (!context.watch<NotificationPrefsProvider>().alertsEnabled)
      return const SizedBox.shrink();
    final alerts = context
        .watch<BudgetAlertsProvider>()
        .activeTrips
        .where((t) => t.today.level != DailyBudgetLevel.ok)
        .toList();
    if (alerts.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        for (final alert in alerts)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () =>
                    context.go('/viajes/${alert.trip.id}', extra: alert.trip),
                child: BudgetAlertCard(
                  status: alert.today,
                  tripName: alert.trip.name,
                  compact: true,
                ),
              ),
            ),
          ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDesktopContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGreetingRow(),
        const SizedBox(height: 26),
        _buildDailyBudgetAlerts(),
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
                child: StaggerIn(index: 1, child: _MapaCard(onTap: _openMap, placesCount: _nearbyPlaces.length)),
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
                  child: _ProximoGastoCard(
                    trip: _nextTrip,
                    onTap: _quickAddExpense,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: mapaFlex,
                child: StaggerIn(index: 3, child: _EstimarCard(onTap: _openBudgetEstimator)),
              ),
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
                  style: AppText.label(11, color: AppColors.inkSoft),
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
        else if (_tripsError)
          LoadErrorBox(
            message: context.l10n.valLoadTripsError,
            onRetry: _loadTrips,
          )
        else if (_trips.isEmpty)
          _buildEmptyTrips()
        else
          Column(
            children: [
              if (_gastosError) ...[
                LoadErrorBox(
                  message: context.l10n.valLoadGastosError,
                  onRetry: () => _loadGastosPorViaje(_trips),
                ),
                const SizedBox(height: 12),
              ],
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
          Text(context.l10n.homeClientNoTripsTitle, style: AppText.display(22)),
          const SizedBox(height: 6),
          Text(
            context.l10n.homeClientNoTripsSubtitle,
            style: AppText.ui(13, color: AppColors.textMuted),
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

  Widget _buildCercaDeTiColumn() {
    final featured = _nearbyPlaces.isNotEmpty ? _nearbyPlaces.first : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.homeClientNearbyTitle, style: AppText.display(26)),
        const SizedBox(height: 16),
        if (_isLoadingPlaces)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.ink),
            ),
          )
        else if (_placesError)
          LoadErrorBox(
            message: context.l10n.valLoadPlacesError,
            onRetry: _loadNearbyPlaces,
          )
        else if (featured == null)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.wash,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Text(
              context.l10n.homeClientNoNearbyPlaces,
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
            tags: [
              PlaceCardTag(context.l10n.homeClientVerifiedTag, emphasis: true),
            ],
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
            child: Text(
              context.l10n.homeClientViewPlacesButton(_nearbyPlaces.length),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.go('/actividades'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.line),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
            child: Text(context.l10n.homeClientViewActivitiesButton),
          ),
        ),
      ],
    );
  }

  String _firstName(String name) => name.trim().split(' ').first;

  String _contextLine(Trip? next) {
    if (next == null) return context.l10n.homeClientExploreTagline;
    final pct = next.getBudgetPercentage().clamp(0, 999).round();
    final start = parseDdMmYyyy(next.startDate);
    if (start != null) {
      final days = start.difference(DateTime.now()).inDays;
      if (days > 0) {
        return context.l10n.homeClientContextLineDays(
          next.destination,
          days,
          pct,
        );
      }
    }
    return context.l10n.homeClientContextLineNoDays(next.destination, pct);
  }

  // ─── Móvil ───
  // Anatomía móvil del handoff ("Papel Petróleo" › Home): saludo
  // editorial, retícula asimétrica Mapa / Crear viaje, lista de
  // `TripCard` y nav flotante. Reusa los mismos bloques que escritorio.

  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
          children: [
            _buildMobileGreeting(),
            _buildDailyBudgetAlerts(),
            _buildMobileActionGrid(),
            const SizedBox(height: 12),
            StaggerIn(index: 2, child: _EstimarCard(onTap: _openBudgetEstimator)),
            const SizedBox(height: 12),
            StaggerIn(
              index: 3,
              child: _ProximoGastoCard(trip: _nextTrip, onTap: _quickAddExpense),
            ),
            const SizedBox(height: 34),
            _buildMisViajesColumn(),
            const SizedBox(height: 34),
            _buildCercaDeTiColumn(),
          ],
        ),
      ),
      // El "+" central registra un gasto (el formulario ofrece "Escanear
      // recibo" en Android); crear viaje está en la tarjeta "Crear un viaje".
      bottomNavigationBar: FloatingNavBar(
        index: 0,
        onSelect: _handleMobileNavSelect,
        onCreate: _quickAddExpense,
        fabHeroTag: 'add-expense',
        fabSemanticLabel: context.l10n.floatingNavBarAddExpenseSemanticLabel,
      ),
    );
  }

  /// Fecha en mono + avatar `ink` (menú de cuenta) y título display 42
  /// con la segunda línea en itálica `inkSoft`.
  Widget _buildMobileGreeting() {
    final locale = Localizations.localeOf(context).toString();
    final today = DateFormat('EEEE d · MMM', locale).format(DateTime.now());
    final name = _firstName(userName);
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 26, 6, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(today.toUpperCase(), style: AppText.label(11)),
              PopupMenuButton<String>(
                tooltip: context.l10n.configScreenTitle,
                position: PopupMenuPosition.under,
                onSelected: (value) {
                  if (value == 'config') {
                    context.go('/configuracion');
                  } else {
                    _confirmSignOut(context);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'config', child: Text(context.l10n.configScreenTitle)),
                  PopupMenuItem(value: 'logout', child: Text(context.l10n.homeClientSignOutButton)),
                ],
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    name.isEmpty ? '·' : name[0].toUpperCase(),
                    style: AppText.ui(14, weight: FontWeight.w700, color: AppColors.mint),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Text(context.l10n.homeClientGreeting(name), style: AppText.display(42)),
          Text(
            context.l10n.homeClientActiveTripsCount(_trips.length),
            style: AppText.displayItalic(42),
          ),
        ],
      ),
    );
  }

  /// Retícula asimétrica 100 : 135 del handoff (Mapa `wash` / Crear `ink`).
  Widget _buildMobileActionGrid() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 100,
            child: StaggerIn(index: 0, child: _MapaCard(onTap: _openMap, placesCount: _nearbyPlaces.length, compact: true)),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 135,
            child: StaggerIn(index: 1, child: _CrearViajeCard(onTap: _createTrip, compact: true)),
          ),
        ],
      ),
    );
  }
}

class _CrearViajeCard extends StatelessWidget {
  const _CrearViajeCard({required this.onTap, this.compact = false});

  final VoidCallback onTap;

  /// Móvil: alto total 150 con padding 18 (retícula del handoff).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      onTap: onTap,
      color: AppColors.ink,
      radius: 28,
      baseShadow: AppShadow.raised,
      hoverShadow: AppShadow.raised,
      padding: EdgeInsets.all(compact ? 18 : 24),
      // Móvil: alto mínimo en vez de fijo — con la letra del sistema un
      // poco más grande, "Crear un viaje" se desbordaba 9 px.
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: compact ? 114 : 116, maxHeight: compact ? double.infinity : 116),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
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
            if (compact) const SizedBox(height: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.homeClientCreateTripCardTitle,
                  style: AppText.display(26, color: AppColors.paper),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.homeClientCreateTripCardSubtitle,
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
  const _MapaCard({required this.onTap, required this.placesCount, this.compact = false});

  final VoidCallback onTap;

  /// Lugares cargados para "Cerca de ti" (antes el texto decía "14" fijo).
  final int placesCount;

  /// Móvil: alto total 150 con padding 18 (retícula del handoff).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      onTap: onTap,
      color: AppColors.wash,
      radius: 28,
      padding: EdgeInsets.all(compact ? 18 : 24),
      // Móvil: alto mínimo en vez de fijo — con la letra del sistema un
      // poco más grande, "Crear un viaje" se desbordaba 9 px.
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: compact ? 114 : 116, maxHeight: compact ? double.infinity : 116),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.ink, width: 2),
              ),
              child: const Icon(
                Icons.location_on_outlined,
                color: AppColors.ink,
                size: 18,
              ),
            ),
            if (compact) const SizedBox(height: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.homeClientMapCardTitle,
                  style: AppText.display(22),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.homeClientMapCardPlacesCount(placesCount),
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

class _EstimarCard extends StatelessWidget {
  const _EstimarCard({required this.onTap});

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
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.calculate_outlined, color: AppColors.mint, size: 18),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.estimateScreenTitle, style: AppText.display(22, color: AppColors.ink)),
                const SizedBox(height: 4),
                Text(
                  context.l10n.estimateCardSubtitle,
                  style: AppText.ui(12, color: AppColors.ink),
                ),
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
                Text(
                  context.l10n.homeClientNextExpenseLabel,
                  style: AppText.label(10),
                ),
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
                    trip!.lodgingType.isNotEmpty
                        ? trip!.lodgingType
                        : context.l10n.homeClientLodgingFallback,
                    style: AppText.display(24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.homeClientLodgingPaymentDue(
                      trip!.startDate,
                      context.formatMoney(trip!.lodgingCost),
                    ),
                    style: AppText.ui(12, color: AppColors.textMuted),
                  ),
                ],
              )
            else
              Text(
                context.l10n.homeClientRegisterExpenseHint,
                style: AppText.ui(13, color: AppColors.textMuted),
              ),
          ],
        ),
      ),
    );
  }
}

