import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/settings/currency_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/route_pattern_background.dart';
import '../../../../shell/app_shell.dart';
import '../../../../widgets/budget_bar.dart';
import '../../../../widgets/ink_button.dart';
import '../../../../widgets/ink_header.dart';
import '../../../../widgets/pressable.dart';
import '../../../auth/providers/app_auth_provider.dart';
import '../../../expenses/data/expense_repository.dart';
import '../../../expenses/data/models/categoria_gasto_model.dart';
import '../../../expenses/data/models/gasto_model.dart';
import '../../../expenses/presentation/widgets/add_expense_sheet.dart';
import '../../../expenses/presentation/widgets/budget_alert_card.dart';
import '../../../expenses/presentation/widgets/budget_notifications_listener.dart';
import '../../../expenses/providers/budget_alerts_provider.dart';
import '../../../expenses/utils/daily_budget_calculator.dart';
import '../../../subscriptions/presentation/widgets/premium_gate.dart';
import '../../../subscriptions/providers/subscription_provider.dart';
import '../../data/models/trip_collaborator.dart';
import '../../data/models/trip_history_entry.dart';
import '../../data/trip_repository.dart';
import '../../presentation/pages/trip_model.dart';
import '../../utils/budget_calculator.dart';
import 'create_trip_screen.dart';
import 'edit_trip_budget_screen.dart';
import 'personal_pocket_screen.dart';
import '../../data/models/pocket_repository.dart';
import '../pages/spending_limits_screen.dart';
import '../../data/limits_repository.dart';

class TripDetailScreen extends StatefulWidget {
  final Trip trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen>
    with SingleTickerProviderStateMixin {
  late Trip trip;
  late final TabController _tabController;
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  final TripRepository _tripRepository = TripRepository();
  final PocketRepository _pocketRepository = PocketRepository();
  final LimitsRepository _limitsRepository = LimitsRepository();
  Map<int, double> _limites = {};

  List<Gasto> _gastos = [];
  List<CategoriaGasto> _categorias = [];
  bool _isLoadingGastos = true;
  String? _gastosError;

  /// Muestra/oculta la tarjeta de devolución de IVA — solo aplica a
  /// turistas extranjeros no residentes, así que no tiene sentido
  /// mostrarla siempre.
  bool _esExtranjero = false;

  // HU-16: gestión de viajes en grupo (colaboradores + historial).
  int? _currentUserId;
  TripCollaborator? _owner;
  List<TripCollaborator> _collaborators = [];
  List<TripHistoryEntry> _history = [];
  bool _isLoadingGrupo = true;
  String? _grupoError;

  /// Solo el dueño puede invitar/quitar colaboradores o eliminar el
  /// viaje — un colaborador puede editar todo lo demás igual que el
  /// dueño (ver docs/db/hu16_colaboradores_historial.sql).
  bool get _isOwner => _currentUserId != null && _currentUserId == trip.turistaId;

  @override
  void initState() {
    super.initState();
    trip = widget.trip;
    _tabController = TabController(length: 6, vsync: this)
      ..addListener(() => setState(() {}));
    _currentUserId = context.read<AppAuthProvider>().usuario?.id;
    _loadGastos();
    _loadGrupo();
    _loadLimites();
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// HU-13: trae los gastos reales del viaje (y las categorías reales
  /// para el formulario) desde Supabase. Sin `trip.id` (viaje no
  /// guardado) no hay dónde persistir gastos.
  Future<void> _loadGastos() async {
    if (trip.id == null) {
      setState(() => _isLoadingGastos = false);
      return;
    }
    setState(() {
      _isLoadingGastos = true;
      _gastosError = null;
    });
    try {
      final results = await Future.wait([
        _expenseRepository.fetchCategorias(),
        _expenseRepository.fetchGastosDelViaje(trip.id!),
      ]);
      if (!mounted) return;
      setState(() {
        _categorias = results[0] as List<CategoriaGasto>;
        _gastos = results[1] as List<Gasto>;
        _isLoadingGastos = false;
      });
    } catch (e, st) {
      debugPrint('TripDetailScreen._loadGastos error: $e\n$st');
      if (!mounted) return;
      setState(() {
        _gastosError = context.l10n.tripDetailLoadExpensesError;
        _isLoadingGastos = false;
      });
    }
  }

  /// Suma de los gastos reales registrados manualmente, que se recalcula
  /// solita cada vez que `_gastos` cambia (agregar/eliminar) — "se va
  /// actualizando constantemente".
  double get _gastosTotal => _gastos.fold(0.0, (sum, g) => sum + g.monto);

    /// Solo los gastos pagados con el dinero del viaje. Los pagados desde un
  /// bolsillo personal no restan del presupuesto compartido.
  double get _gastosDelViajeTotal =>
      _gastos.where((g) => g.pagadoConDineroViaje).fold(0.0, (sum, g) => sum + g.monto);

  /// HU-11: presupuesto diario calculado con los gastos ya cargados —
  /// se reconstruye en cada `build`, así refleja al instante cada gasto
  /// que se agrega o borra en esta pantalla.
    DailyBudgetCalculator get _dailyBudget => DailyBudgetCalculator(
        trip: trip,
        gastos: _gastos.where((g) => g.pagadoConDineroViaje).toList(),
      );

  /// Tarjeta del % del presupuesto de hoy — solo mientras el viaje está
  /// en curso y ya cargaron los gastos (si no, mostraría 0% falso).
  Widget _buildTodayBudgetAlert() {
    final calc = _dailyBudget;
    if (_isLoadingGastos || trip.id == null || !calc.isTripDay(DateTime.now())) {
      return const SizedBox.shrink();
    }
    // HU-24 / TG-298: las alertas del presupuesto diario son Premium; a
    // los demás se les muestra la invitación en el mismo lugar.
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: PremiumGate(
        compact: true,
        icon: Icons.notifications_active_outlined,
        title: context.l10n.dailyBudgetLockedTitle,
        description: context.l10n.dailyBudgetLockedDescription,
        child: BudgetAlertCard(status: calc.today),
      ),
    );
  }

  /// HU-16: dueño, colaboradores e historial del viaje, para el tab
  /// "Grupo". Igual que `_loadGastos`, sin `trip.id` no hay nada que
  /// consultar (viaje que no llegó a guardarse).
  Future<void> _loadGrupo() async {
    if (trip.id == null || trip.turistaId == null) {
      setState(() => _isLoadingGrupo = false);
      return;
    }
    setState(() {
      _isLoadingGrupo = true;
      _grupoError = null;
    });
    try {
      final results = await Future.wait([
        _tripRepository.fetchOwner(trip.turistaId!),
        _tripRepository.fetchCollaborators(trip.id!),
        _tripRepository.fetchHistory(trip.id!),
      ]);
      if (!mounted) return;
      setState(() {
        _owner = results[0] as TripCollaborator;
        _collaborators = results[1] as List<TripCollaborator>;
        _history = results[2] as List<TripHistoryEntry>;
        _isLoadingGrupo = false;
      });
    } catch (e, st) {
      debugPrint('TripDetailScreen._loadGrupo error: $e\n$st');
      if (!mounted) return;
      setState(() {
        _grupoError = context.l10n.tripDetailLoadGroupError;
        _isLoadingGrupo = false;
      });
    }
  }

  Future<void> _handleInvite() async {
    if (trip.id == null || trip.turistaId == null || _currentUserId == null) return;

    // El diálogo valida y llama al backend él mismo: si el correo está
    // vacío, mal escrito o no registrado, el error se muestra dentro y la
    // persona lo corrige sin volver a abrirlo.
    final collaborator = await showDialog<TripCollaborator>(
      context: context,
      builder: (ctx) => _InviteCollaboratorDialog(
        onInvite: (email) => _tripRepository.addCollaboratorByEmail(
          tripId: trip.id!,
          ownerId: trip.turistaId!,
          email: email,
          invitedBy: _currentUserId!,
        ),
      ),
    );
    if (collaborator == null || !mounted) return;
    setState(() => _collaborators = [..._collaborators, collaborator]);
    _showSnack(
      context.l10n.tripDetailCollaboratorAddedSnackbar(collaborator.nombreCompleto),
      color: AppColors.ink,
    );
  }

  Future<void> _handleRemoveCollaborator(TripCollaborator member) async {
    if (trip.id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.tripDetailRemoveCollaboratorDialogTitle),
        content: Text(
          context.l10n.tripDetailRemoveCollaboratorDialogContent(member.nombreCompleto),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.tripDetailCancelButton)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.tripDetailRemoveButton),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    try {
      await _tripRepository.removeCollaborator(tripId: trip.id!, usuarioId: member.usuarioId);
      if (!mounted) return;
      setState(() => _collaborators = _collaborators.where((c) => c.usuarioId != member.usuarioId).toList());
    } catch (e, st) {
      debugPrint('TripDetailScreen._handleRemoveCollaborator error: $e\n$st');
      if (!mounted) return;
      _showSnack(context.l10n.tripDetailRemoveCollaboratorErrorSnackbar);
    }
  }

  DateTime? _parseTripDate(String ddMmYyyy) {
    try {
      return DateFormat('dd/MM/yyyy').parseStrict(ddMmYyyy.trim());
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleAddExpense() async {
    // Un viaje terminado es de solo lectura (los botones ya no se
    // muestran; esto es por si se llega igual).
    if (trip.isFinished) {
      _showSnack(context.l10n.tripFinishedReadOnlyNotice);
      return;
    }
    if (trip.id == null) {
      _showSnack(context.l10n.tripDetailTripNotSavedSnackbar);
      return;
    }
    if (_categorias.isEmpty) {
      _showSnack(context.l10n.tripDetailCategoriesLoadErrorSnackbar);
      return;
    }

    final startDate = _parseTripDate(trip.startDate) ?? DateTime.now();
    final endDate = _parseTripDate(trip.endDate) ?? startDate;

    // NUEVO: saldo de MI bolsillo (null si aún no lo he creado)
    double? pocketBalance;
    try {
      if (_currentUserId != null) {
        final pocket = await _pocketRepository.fetchMyPocket(
          tripId: trip.id!,
          userId: _currentUserId!,
        );
        pocketBalance = pocket?.balance;
      }
    } catch (e, st) {
      debugPrint('TripDetailScreen: no se pudo leer el bolsillo: $e\n$st');
    }
    if (!mounted) return;

    // NUEVO: saldo del dinero del viaje (solo cuenta lo pagado con dinero del viaje)
    final tripBalance = trip.maxBudget - (trip.getTotalSpent() + _gastosDelViajeTotal);

    final result = await AddExpenseSheet.show(
      context,
      categorias: _categorias,
      tripStartDate: startDate,
      tripEndDate: endDate.isBefore(startDate) ? startDate : endDate,
      dailyBudget: context.read<SubscriptionProvider>().isPremium ? _dailyBudget : null,
      miembros: [if (_owner != null) _owner!, ..._collaborators],
      currentUserId: _currentUserId,
      tripBalance: tripBalance,      // NUEVO
      pocketBalance: pocketBalance,  // NUEVO
      categoryLimits: _limites,                      // NUEVO
      spentByCategory: _gastoPorCategoriaId(), 
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
      setState(() => _gastos = [gasto, ..._gastos]);
      // HU-11: aviso inmediato con el % al que llegó el día del gasto.
      notifyExpenseBudget(context, trip: trip, day: _dailyBudget.statusFor(result.fecha));
      context.read<BudgetAlertsProvider>().refresh();
      _showSnack(
        context.l10n.tripDetailExpenseAddedSnackbar(context.formatMoney(result.monto), result.categoria.nombre),
        color: AppColors.ink,
      );
    } catch (e, st) {
      debugPrint('TripDetailScreen._handleAddExpense error: $e\n$st');
      
      if (!mounted) return;
      _showSnack(context.l10n.tripDetailExpenseSaveErrorSnackbar);
    }
  }

  Future<void> _handleDeleteGasto(Gasto gasto) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.tripDetailDeleteExpenseDialogTitle),
        content: Text(
          context.l10n.tripDetailDeleteExpenseDialogContent(context.formatMoney(gasto.monto), gasto.categoriaNombre),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.tripDetailCancelButton),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.tripDetailDeleteButton),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _expenseRepository.deleteGasto(gasto.id);
      if (!mounted) return;
      setState(() => _gastos = _gastos.where((g) => g.id != gasto.id).toList());
      context.read<BudgetAlertsProvider>().refresh();
    } catch (e, st) {
      debugPrint('TripDetailScreen._handleDeleteGasto error: $e\n$st');
      if (!mounted) return;
      _showSnack(context.l10n.tripDetailDeleteExpenseErrorSnackbar);
    }
  }

  /// Mejora "gestor de presupuesto" (TG-166): antes el presupuesto solo
  /// se definía una vez al crear el viaje; ahora se puede reajustar
  /// (monto máximo, categorías, hospedaje, emergencias) en cualquier
  /// momento, sin tener que borrar y recrear el viaje.
  Future<void> _editBudget() async {
    if (trip.isFinished) {
      _showSnack(context.l10n.tripFinishedReadOnlyNotice);
      return;
    }
    final updated = await Navigator.push<Trip>(
      context,
      MaterialPageRoute(builder: (context) => EditTripBudgetScreen(trip: trip)),
    );
    if (updated != null && mounted) {
      setState(() => trip = updated);
    }
  }

  /// Bolsillo personal del usuario en este viaje (solo lo ve su dueño).
  Future<void> _openPocket() async {
    if (trip.id == null || _currentUserId == null) {
      _showSnack(context.l10n.tripDetailTripNotSavedSnackbar);
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonalPocketScreen(
          tripId: trip.id!,
          tripName: trip.name,
          userId: _currentUserId!,
        ),
      ),
    );
  }

  Future<void> _confirmDeleteTrip() async {
    // HU-16: eliminar el viaje es solo del dueño — la UI ya oculta este
    // botón para colaboradores, esto es un segundo seguro.
    if (!_isOwner) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.tripDetailDeleteTripDialogTitle),
        content: Text(
          context.l10n.tripDetailDeleteTripDialogContent(trip.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.tripDetailCancelButton),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.tripDetailDeleteButton),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    // Antes este botón solo navegaba a Inicio y mostraba el snackbar
    // sin borrar nada en el servidor — el viaje seguía apareciendo al
    // volver a entrar. `archiveTrip` es el soft delete real.
    if (trip.id == null) {
      context.go('/');
      return;
    }
    try {
      await _tripRepository.archiveTrip(trip.id!);
      if (!mounted) return;
      context.go('/');
      _showSnack(context.l10n.tripDetailTripDeletedSnackbar, color: AppColors.error);
    } catch (e, st) {
      debugPrint('TripDetailScreen._confirmDeleteTrip error: $e\n$st');
      if (!mounted) return;
      _showSnack(context.l10n.tripDetailDeleteTripErrorSnackbar);
    }
  }

  void _showSnack(String message, {Color color = AppColors.error}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> _createTripFromHere() async {
    await showCreateTripDialog(context);
  }

  void _handleSideNav(AppSection section) {
    switch (section) {
      case AppSection.inicio:
      case AppSection.misViajes:
        context.go('/');
        break;
      case AppSection.comercios:
        context.go('/comercios');
        break;
      case AppSection.mapa:
        context.go('/mapa');
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

  @override
  Widget build(BuildContext context) {
    context.watch<CurrencyProvider>();
    final totalSpent = trip.getTotalSpent() + _gastosDelViajeTotal;   
    final remaining = trip.maxBudget - totalSpent;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppBreakpoints.mobile) {
          return _buildMobile(context, totalSpent: totalSpent, remaining: remaining);
        }
        return AppShell(
          section: AppSection.misViajes,
          onNavigate: _handleSideNav,
          onCreateTrip: _createTripFromHere,
          activeTrip: trip,
          activeTripSpent: totalSpent,
          child: _buildDesktopContent(context, totalSpent: totalSpent, remaining: remaining),
        );
      },
    );
  }

  // ─── Escritorio / tablet ───

  Widget _buildDesktopContent(
    BuildContext context, {
    required double totalSpent,
    required double remaining,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderCard(totalSpent: totalSpent),
        const SizedBox(height: 24),
        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.ink,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.ink,
          dividerColor: AppColors.line,
          labelStyle: AppText.ui(14, weight: FontWeight.w700),
          unselectedLabelStyle: AppText.ui(14, weight: FontWeight.w500),
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(text: context.l10n.tripDetailTabResumen),
            Tab(text: context.l10n.tripDetailTabHospedaje),
            Tab(text: context.l10n.tripDetailTabGastos),
            Tab(text: context.l10n.tripDetailTabGrupo),
            Tab(text: context.l10n.tripDetailTabAnalisis),
            Tab(text: context.l10n.limitsTabTitle),
          ],
        ),
        const SizedBox(height: 24),
        switch (_tabController.index) {
          0 => _buildResumenTab(totalSpent: totalSpent, remaining: remaining),
          1 => _buildHospedajeTab(),
          2 => _buildGastosTab(totalSpent: totalSpent, remaining: remaining),
          3 => _buildGrupoTab(),
          4 => _buildAnalisisTab(),
          _ => _buildLimitesTab(),
        },
      ],
    );
  }

  Widget _buildHeaderCard({required double totalSpent}) {
    final progress = trip.maxBudget > 0 ? (totalSpent / trip.maxBudget).clamp(0.0, 1.0) : 0.0;
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(60),
        ),
      ),
      child: Stack(
        children: [
          const RoutePatternBackground(opacity: 0.10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => context.go('/'),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_back, size: 14, color: AppColors.textOnInk),
                            const SizedBox(width: 6),
                            Text(context.l10n.tripDetailBreadcrumbHome, style: AppText.label(11, color: AppColors.textOnInk)),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (trip.isFinished)
                          const _FinishedBadge()
                        else ...[
                          _HeaderButton(label: context.l10n.tripDetailEditButton, translucent: true, onTap: _editBudget),
                          const SizedBox(width: 10),
                          _HeaderButton(label: context.l10n.pocketButtonLabel, translucent: true, onTap: _openPocket),
                          const SizedBox(width: 10),
                          _HeaderButton(
                            label: context.l10n.tripDetailAddExpenseButton,
                            translucent: false,
                            onTap: _handleAddExpense,
                          ),
                        ],
                        if (_isOwner) ...[
                          const SizedBox(width: 10),
                          _HeaderIconButton(icon: Icons.more_horiz, onTap: _confirmDeleteTrip),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.inkSoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.luggage_outlined, color: AppColors.mint, size: 20),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(context.l10n.tripDetailHeaderTripToPrefix, style: AppText.display(40, color: Colors.white)),
                          Text(trip.destination, style: AppText.displayItalic(40)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  context.l10n.tripDetailHeaderSubtitle(
                    trip.startDate,
                    trip.endDate,
                    trip.persons,
                    trip.tripType.toUpperCase(),
                  ),
                  style: AppText.label(11, color: AppColors.textOnInk),
                ),
                const SizedBox(height: 30),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.l10n.tripDetailSpentLabel, style: AppText.label(10, color: AppColors.textOnInk)),
                          const SizedBox(height: 4),
                          Text(context.formatMoney(totalSpent), style: AppText.display(44, color: AppColors.paper)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(context.l10n.tripDetailCapLabel, style: AppText.label(10, color: AppColors.textOnInk)),
                        const SizedBox(height: 4),
                        Text(context.formatMoney(trip.maxBudget), style: AppText.ui(18, color: AppColors.textOnInk)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                BudgetBar(
                  progress: progress,
                  height: 8,
                  track: Colors.white.withValues(alpha: 0.24),
                  fill: AppColors.mint,
                ),
                const SizedBox(height: 8),
                _buildBudgetStatus(totalSpent: totalSpent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Línea corta de estado bajo la barra de presupuesto — sin esto, el
  /// usuario tenía que restar GASTADO - TOPE de cabeza para saber si
  /// va bien o ya se pasó.
  Widget _buildBudgetStatus({required double totalSpent}) {
    if (trip.maxBudget <= 0) return const SizedBox.shrink();
    final remaining = trip.maxBudget - totalSpent;
    final overBudget = remaining < 0;
    final pct = (totalSpent / trip.maxBudget * 100).round();
    final color = overBudget ? AppColors.error : AppColors.mint;
    final label = overBudget
        ? context.l10n.tripDetailOverBudgetLabel(context.formatMoney(remaining.abs()))
        : context.l10n.tripDetailOnTrackLabel(pct);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          overBudget ? Icons.error_outline : Icons.check_circle_outline,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(label, style: AppText.ui(12, weight: FontWeight.w600, color: color)),
      ],
    );
  }

  // ─── Tab: Resumen ───

  Widget _buildResumenTab({required double totalSpent, required double remaining}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTodayBudgetAlert(),
        LayoutBuilder(
          builder: (context, constraints) {
            final hospedaje = _buildHospedajeSummaryCard();
            final minis = _buildMiniCardsPair();
            final gastos = _buildUltimosGastosCard();
            if (constraints.maxWidth >= 760) {
              return Column(
                children: [
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: hospedaje),
                        const SizedBox(width: 16),
                        Expanded(child: minis),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  gastos,
                ],
              );
            }
            return Column(
              children: [hospedaje, const SizedBox(height: 16), minis, const SizedBox(height: 16), gastos],
            );
          },
        ),
        const SizedBox(height: 16),
        if (remaining > 0) ...[
          _buildDailyBudgetCard(remaining),
          const SizedBox(height: 16),
        ],
        _buildExpenseBreakdownCard(),
      ],
    );
  }

  Widget _buildHospedajeSummaryCard() {
    return _SectionCard(
      title: context.l10n.tripDetailLodgingTitle,
      trailing: context.formatMoney(trip.lodgingCost),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kv(context.l10n.tripDetailLodgingTypeLabel, trip.lodgingType.isNotEmpty ? trip.lodgingType : '—'),
          _kv(context.l10n.tripDetailCostLabel, context.formatMoney(trip.lodgingCost)),
          if (trip.includedServices.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final s in trip.includedServices) _tag(s)],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniCardsPair() {
    // `IntrinsicHeight` propio: sin esto, cuando el ancho disponible cae
    // por debajo de 760 (pasa justo en el rango típico de una ventana
    // de escritorio angosta: 1024px de ventana − 248px de sidebar − el
    // padding del contenido ya da ~708px), `_buildResumenTab` coloca
    // este `Row` sin envolver dentro de un `Column` que vive en el
    // `SingleChildScrollView` del `AppShell` — altura no acotada +
    // `stretch` revienta el layout (RenderFlex sin tamaño, pantalla en
    // blanco y "congelada" repitiendo la misma excepción cada frame).
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _MiniCard(
              color: AppColors.ink,
              labelColor: AppColors.textOnInk,
              titleColor: AppColors.paper,
              detailColor: AppColors.textOnInk,
              // Antes mostraba el transporte, que se quitó del viaje.
              label: context.l10n.tripDetailLodgingTitle,
              title: trip.lodgingType.isNotEmpty ? trip.lodgingType : '—',
              detail: trip.lodgingCost > 0 ? context.formatMoney(trip.lodgingCost) : '',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _MiniCard(
              color: AppColors.wash,
              labelColor: AppColors.inkSoft,
              titleColor: AppColors.ink,
              detailColor: AppColors.textMuted,
              label: context.l10n.tripDetailPersonsLabel,
              title: '${trip.persons}',
              detail: trip.tripType,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUltimosGastosCard() {
    final recent = _gastos.take(5).toList();
    return _SectionCard(
      title: context.l10n.tripDetailRecentExpensesTitle,
      child: _isLoadingGastos
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(color: AppColors.ink)),
            )
          : recent.isEmpty
          ? Text(
              context.l10n.tripDetailNoExpensesYetHint,
              style: AppText.ui(13, color: AppColors.textMuted),
            )
          : Column(
              children: [
                for (var i = 0; i < recent.length; i++) ...[
                  _gastoRow(recent[i]),
                  if (i != recent.length - 1) const Divider(height: 1, color: AppColors.line),
                ],
              ],
            ),
    );
  }

  Widget _gastoRow(Gasto gasto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gasto.descripcion?.isNotEmpty == true ? gasto.descripcion! : gasto.categoriaNombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.ui(14, weight: FontWeight.w600),
                ),
                Text(
                  '${gasto.categoriaNombre} · ${DateFormat('dd/MM/yyyy').format(gasto.fecha)}',
                  style: AppText.label(10),
                ),
              ],
            ),
          ),
          Text(context.formatMoney(gasto.monto), style: AppText.ui(14, weight: FontWeight.w700, color: AppColors.inkSoft)),
        ],
      ),
    );
  }

  /// Presupuesto que queda disponible, repartido por día y por persona
  /// (mejora "gestor de presupuesto"): sin esto, "disponible" era solo
  /// un número total que no ayudaba a decidir cuánto gastar hoy.
  Widget _buildDailyBudgetCard(double remaining) {
    final breakdown = calculateBudgetBreakdown(
      maxBudget: remaining,
      start: parseDdMmYyyy(trip.startDate),
      end: parseDdMmYyyy(trip.endDate),
      persons: trip.persons,
    );
    return _SectionCard(
      title: context.l10n.tripDetailAvailableBudgetTitle,
      trailing: context.formatMoney(remaining),
      child: Row(
        children: [
          Expanded(
            child: _buildDailyStat(
              icon: Icons.calendar_today,
              label: context.l10n.tripDetailPerDayLabel(breakdown.days),
              value: context.formatMoney(breakdown.perDay),
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.line),
          Expanded(
            child: _buildDailyStat(
              icon: Icons.groups_outlined,
              label: context.l10n.tripDetailPerPersonLabel(trip.persons),
              value: context.formatMoney(breakdown.perPerson),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyStat({required IconData icon, required String label, required String value}) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.inkSoft),
        const SizedBox(height: 4),
        Text(value, style: AppText.ui(15, weight: FontWeight.w700)),
        Text(label, style: AppText.label(10), textAlign: TextAlign.center),
      ],
    );
  }

  /// Desglose de gastos: presupuesto planeado del viaje (por categoría,
  /// pagos anticipados, hospedaje, emergencias) más los gastos reales
  /// de HU-13 agrupados por su propia categoría — cada monto se compara
  /// contra el presupuesto máximo del viaje.
  Widget _buildExpenseBreakdownCard() {
    final Map<String, double> gastosByCategory = {};
    for (final gasto in _gastos) {
      gastosByCategory[gasto.categoriaNombre] = (gastosByCategory[gasto.categoriaNombre] ?? 0) + gasto.monto;
    }

    final rows = <(String, double)>[
      (context.l10n.tripDetailAdvancePayments, trip.advancePayment),
      (context.l10n.tripDetailLodgingPlanned, trip.lodgingCost),
      for (final categoria in trip.categories) (categoria.nombre, categoria.monto),
      (context.l10n.tripDetailEmergencies, trip.emergencyMoney),
      ...gastosByCategory.entries.map((e) => (context.l10n.tripDetailCategoryRealSuffix(e.key), e.value)),
    ].where((e) => e.$2 > 0).toList();

    return _SectionCard(
      title: context.l10n.tripDetailExpenseBreakdownTitle,
      child: rows.isEmpty
          ? Text(context.l10n.tripDetailNoExpensesRegistered, style: AppText.ui(13, color: AppColors.textMuted))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [for (final row in rows) _buildSimpleExpenseRow(row.$1, row.$2)],
            ),
    );
  }

  Widget _buildSimpleExpenseRow(String label, double amount) {
    final percentage = trip.maxBudget > 0 ? (amount / trip.maxBudget).clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppText.ui(13, color: AppColors.textMuted)),
              Text(
                '${context.formatMoney(amount)} (${(percentage * 100).toStringAsFixed(1)}%)',
                style: AppText.ui(13, weight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          BudgetBar(progress: percentage, height: 6),
        ],
      ),
    );
  }

  // ─── Tab: Hospedaje ───

  Widget _buildHospedajeTab() {
    return _SectionCard(
      title: context.l10n.tripDetailLodgingTitle,
      trailing: context.formatMoney(trip.lodgingCost),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kv(context.l10n.tripDetailLodgingTypeFullLabel, trip.lodgingType.isNotEmpty ? trip.lodgingType : '—'),
          _kv(context.l10n.tripDetailCostLabel, context.formatMoney(trip.lodgingCost)),
          if (trip.includedServices.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(context.l10n.tripDetailIncludedServicesLabel, style: AppText.ui(13, weight: FontWeight.w600, color: AppColors.textMuted)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final s in trip.includedServices) _tag(s)],
            ),
          ],
        ],
      ),
    );
  }

  // ─── Tab: Gastos ───

  Widget _buildGastosTab({required double totalSpent, required double remaining}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTodayBudgetAlert(),
        _SectionCard(
          title: context.l10n.tripDetailExpensesRegisteredTitle,
          trailing: context.formatMoney(_gastosTotal),
          child: _buildGastosList(),
        ),
        const SizedBox(height: 16),
        _buildSpendingPaceCard(remaining, totalSpent),
        const SizedBox(height: 16),
        _buildTaxRefundCard(),
      ],
    );
  }

  Widget _buildGastosList() {
    if (_isLoadingGastos) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator(color: AppColors.ink)),
      );
    }
    if (trip.id == null) {
      return Text(
        context.l10n.tripDetailTripNotSavedExpensesHint,
        style: AppText.ui(13, color: AppColors.textMuted),
      );
    }
    if (_gastosError != null) {
      return Row(
        children: [
          Expanded(child: Text(_gastosError!, style: AppText.ui(13, color: AppColors.error))),
          TextButton(onPressed: _loadGastos, child: Text(context.l10n.tripDetailRetryButton)),
        ],
      );
    }
    if (_gastos.isEmpty) {
      return Text(
        context.l10n.tripDetailNoRealExpensesYet,
        style: AppText.ui(13, color: AppColors.textMuted),
      );
    }

    return Column(
      children: _gastos.map((gasto) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: gasto.categoria.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(gasto.categoria.icon, size: 18, color: gasto.categoria.color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gasto.descripcion?.isNotEmpty == true ? gasto.descripcion! : gasto.categoriaNombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.ui(13, weight: FontWeight.w600),
                    ),
                    Text(
                      '${gasto.categoriaNombre} · ${DateFormat('dd/MM/yyyy').format(gasto.fecha)}',
                      style: AppText.label(10),
                    ),
                  ],
                ),
              ),
              Text(context.formatMoney(gasto.monto), style: AppText.ui(13, weight: FontWeight.w700, color: AppColors.inkSoft)),
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                onPressed: () => _handleDeleteGasto(gasto),
                tooltip: context.l10n.tripDetailDeleteExpenseTooltip,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Ritmo de gasto recomendado — a diferencia de [_buildDailyBudgetCard]
  /// (que reparte el presupuesto total entre TODOS los días del viaje),
  /// esto usa la fecha de HOY: si el viaje ya empezó, dice cuánto queda
  /// por gastar por día y por persona en lo que resta, no en el total.
  /// También muestra lo que ya llevas gastado por persona, si hay algo.
  Widget _buildSpendingPaceCard(double remaining, double totalSpent) {
    final start = parseDdMmYyyy(trip.startDate);
    final end = parseDdMmYyyy(trip.endDate);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    String phaseLabel;
    int? remainingDays;
    if (start == null || end == null) {
      phaseLabel = context.l10n.tripDetailInvalidDatesHint;
    } else if (today.isBefore(start)) {
      final daysUntil = start.difference(today).inDays;
      phaseLabel = context.l10n.tripDetailTripStartsIn(daysUntil);
      remainingDays = end.difference(start).inDays + 1;
    } else if (today.isAfter(end)) {
      phaseLabel = context.l10n.tripDetailTripEnded;
    } else {
      remainingDays = end.difference(today).inDays + 1;
      phaseLabel = context.l10n.tripDetailDaysRemaining(remainingDays);
    }

    final safePersons = trip.persons < 1 ? 1 : trip.persons;
    // `totalSpent` = lo planeado al crear el viaje + los gastos
    // registrados. Se muestran por separado: antes salía todo junto como
    // "llevas gastado", y contradecía "Gastos registrados $0".
    final planned = trip.getTotalSpent();
    final registered = _gastosTotal;
    final l10n = context.l10n;

    final children = <Widget>[];
    if (remainingDays != null && remaining > 0) {
      final perDay = remaining / remainingDays;
      children.addAll([
        const SizedBox(height: 12),
        Text(
          l10n.tripDetailPaceRemaining(context.formatMoney(remaining)),
          style: AppText.ui(13, color: AppColors.textMuted),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildDailyStat(
                icon: safePersons > 1 ? Icons.groups_outlined : Icons.today_outlined,
                label: safePersons > 1 ? l10n.tripDetailPacePerDayGroup : l10n.tripDetailPacePerDaySolo,
                value: context.formatMoney(perDay),
              ),
            ),
            // Con una sola persona "grupo" y "por persona" son lo mismo.
            if (safePersons > 1) ...[
              Container(width: 1, height: 36, color: AppColors.line),
              Expanded(
                child: _buildDailyStat(
                  icon: Icons.person_outline,
                  label: l10n.tripDetailPacePerPersonDay,
                  value: context.formatMoney(perDay / safePersons),
                ),
              ),
            ],
          ],
        ),
      ]);
    } else if (remainingDays != null) {
      children.addAll([
        const SizedBox(height: 12),
        Text(
          l10n.tripDetailPaceNoBudgetLeft,
          style: AppText.ui(13, weight: FontWeight.w600, color: AppColors.error),
        ),
      ]);
    }

    Widget amountRow(String label, double value, {bool strong = false}) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppText.ui(12, color: AppColors.textMuted)),
              Text(
                context.formatMoney(value),
                style: AppText.ui(13, weight: strong ? FontWeight.w700 : FontWeight.w600,
                    color: strong ? AppColors.inkSoft : AppColors.ink),
              ),
            ],
          ),
        );

    if (planned > 0 || registered > 0) {
      children.addAll([
        const SizedBox(height: 14),
        const Divider(height: 1, color: AppColors.line),
        const SizedBox(height: 14),
        amountRow(l10n.tripDetailPacePlanned, planned),
        amountRow(l10n.tripDetailPaceRegistered, registered),
        if (safePersons > 1)
          amountRow(
            l10n.tripDetailPacePerPerson(safePersons),
            (planned + registered) / safePersons,
            strong: true,
          ),
      ]);
    }

    return _SectionCard(
      title: l10n.tripDetailSpendingPaceTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_outlined, size: 18, color: AppColors.inkSoft),
              const SizedBox(width: 8),
              Expanded(child: Text(phaseLabel, style: AppText.ui(13, weight: FontWeight.w600))),
            ],
          ),
          ...children,
        ],
      ),
    );
  }

  // Valor de referencia DIAN (devolución de IVA a turistas extranjeros
  // no residentes): 100% del IVA (19%) de compras elegibles con factura
  // electrónica, mínimo 3 UVT por factura, tope 200 UVT por solicitud.
  // UVT 2026 = $52.374 (Resolución DIAN 000238 de 2025) — esto es un
  // estimado educativo, no un cálculo oficial; el usuario debe verificar
  // el trámite vigente en dian.gov.co antes de viajar.
  static const double _ivaRate = 0.19;
  static const double _uvt2026 = 52374;
  static const double _minPurchaseUvt = 3;
  static const double _maxRefundUvt = 200;

  /// Estimador de devolución de IVA para turistas extranjeros: usa los
  /// gastos ya registrados en la categoría "Compras" (HU-13) para decir
  /// cuánto de eso fue impuesto, y por lo tanto cuánto se podría pedir
  /// de vuelta en el aeropuerto antes de salir del país.
  Widget _buildTaxRefundCard() {
    final comprasTotal =
        _gastos.where((g) => g.categoriaNombre == 'Compras').fold(0.0, (sum, g) => sum + g.monto);
    final ivaEstimado = comprasTotal * (_ivaRate / (1 + _ivaRate));
    final minPurchase = _minPurchaseUvt * _uvt2026;
    final maxRefund = _maxRefundUvt * _uvt2026;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(AppRadius.card + 2),
        border: Border.all(color: const Color(0xFFF3E0A3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flight_takeoff, size: 18, color: Color(0xFF8A6D1D)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.tripDetailForeignTouristQuestion,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF8A6D1D)),
                ),
              ),
              Switch(
                value: _esExtranjero,
                activeThumbColor: const Color(0xFF8A6D1D),
                onChanged: (value) => setState(() => _esExtranjero = value),
              ),
            ],
          ),
          if (_esExtranjero) ...[
            const SizedBox(height: 8),
            Text(
              comprasTotal > 0
                  ? context.l10n.tripDetailTaxRefundWithPurchases(
                      context.formatMoney(comprasTotal),
                      context.formatMoney(ivaEstimado),
                    )
                  : context.l10n.tripDetailTaxRefundNoPurchases,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B5416), height: 1.4),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.tripDetailTaxRefundRequirements(
                context.formatMoney(minPurchase),
                context.formatMoney(maxRefund),
              ),
              style: const TextStyle(fontSize: 10, color: Color(0xFF8A6D1D), height: 1.4),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Tab: Grupo (HU-16) ───

  Widget _buildGrupoTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildColaboradoresCard(),
        const SizedBox(height: 16),
        _buildHistorialCard(),
      ],
    );
  }

  Widget _buildColaboradoresCard() {
    return _SectionCard(
      title: context.l10n.tripDetailCollaboratorsTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  context.l10n.tripDetailCollaboratorsSubtitle,
                  style: AppText.ui(12, color: AppColors.textMuted),
                ),
              ),
              if (_isOwner) _addActionButton(context.l10n.tripDetailInviteButton, _handleInvite),
            ],
          ),
          const SizedBox(height: 14),
          if (_isLoadingGrupo)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(color: AppColors.ink)),
            )
          else if (_grupoError != null)
            Row(
              children: [
                Expanded(child: Text(_grupoError!, style: AppText.ui(13, color: AppColors.error))),
                TextButton(onPressed: _loadGrupo, child: Text(context.l10n.tripDetailRetryButton)),
              ],
            )
          else ...[
            if (_owner != null) _memberRow(_owner!, isOwnerRow: true),
            for (final collaborator in _collaborators) _memberRow(collaborator, isOwnerRow: false),
          ],
        ],
      ),
    );
  }

  Widget _memberRow(TripCollaborator member, {required bool isOwnerRow}) {
    final isMe = member.usuarioId == _currentUserId;
    final initial = member.nombreCompleto.isNotEmpty ? member.nombreCompleto[0].toUpperCase() : '?';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.wash,
            child: Text(initial, style: AppText.ui(14, weight: FontWeight.w700, color: AppColors.inkSoft)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.nombreCompleto, style: AppText.ui(14, weight: FontWeight.w600)),
                Text(member.email, style: AppText.label(10)),
              ],
            ),
          ),
          if (isOwnerRow)
            _tag(context.l10n.tripDetailOwnerTag)
          else ...[
            if (isMe) _tag(context.l10n.tripDetailYouTag),
            if (_isOwner) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                onPressed: () => _handleRemoveCollaborator(member),
                tooltip: context.l10n.tripDetailRemoveCollaboratorTooltip,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _addActionButton(String label, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_add_alt, size: 14, color: AppColors.inkSoft),
            const SizedBox(width: 4),
            Text(label, style: AppText.ui(12, weight: FontWeight.w600, color: AppColors.inkSoft)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorialCard() {
    return _SectionCard(
      title: context.l10n.tripDetailHistoryTitle,
      child: _isLoadingGrupo
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(color: AppColors.ink)),
            )
          : _history.isEmpty
          ? Text(
              context.l10n.tripDetailNoHistoryYet,
              style: AppText.ui(13, color: AppColors.textMuted),
            )
          : Column(
              children: [
                for (var i = 0; i < _history.length; i++) ...[
                  _historyRow(_history[i]),
                  if (i != _history.length - 1) const Divider(height: 1, color: AppColors.line),
                ],
              ],
            ),
    );
  }

  Widget _historyRow(TripHistoryEntry entry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.wash, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.history, size: 15, color: AppColors.inkSoft),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    style: AppText.ui(13, color: AppColors.ink),
                    children: [
                      TextSpan(text: entry.editorNombre, style: const TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(text: context.l10n.tripDetailHistoryChangedText),
                      TextSpan(
                        text: tripHistoryFieldLabel(context, entry.campo),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.valorAnterior ?? '—'} → ${entry.valorNuevo ?? '—'}',
                  style: AppText.ui(13, weight: FontWeight.w600, color: AppColors.inkSoft),
                ),
                const SizedBox(height: 2),
                Text(_relativeTime(entry.createdAt), style: AppText.label(10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final diff = DateTime.now().difference(local);
    if (diff.inMinutes < 1) return context.l10n.tripDetailJustNow;
    if (diff.inMinutes < 60) return context.l10n.tripDetailMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return context.l10n.tripDetailHoursAgo(diff.inHours);
    if (diff.inDays == 1) return context.l10n.tripDetailYesterday;
    if (diff.inDays < 7) return context.l10n.tripDetailDaysAgo(diff.inDays);
    return DateFormat('dd/MM/yyyy').format(local);
  }

  // ─── Tab: Análisis ───

  static const Color _budgetBlue = Color(0xFF3B82F6);
  static const Color _realRed = Color(0xFFEF4444);
  static const Color _savingGreen = Color(0xFF16A34A);

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  Widget _hBar(double fraction, Color color, {double height = 8}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: Stack(
        children: [
          Container(height: height, color: AppColors.wash),
          FractionallySizedBox(
            widthFactor: fraction.clamp(0.0, 1.0),
            child: Container(height: height, color: color),
          ),
        ],
      ),
    );
  }

  Widget _subTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 4),
        child: Text(text, style: AppText.ui(13, weight: FontWeight.w700, color: AppColors.textMuted)),
      );

  /// Gasto real por día (clave = fecha sin hora).
  Map<DateTime, double> _gastoPorDia() {
    final map = <DateTime, double>{};
    for (final g in _gastos) {
      final k = _dayOnly(g.fecha);
      map[k] = (map[k] ?? 0) + g.monto;
    }
    return map;
  }

  /// Presupuestado vs real por categoría (une las categorías planeadas
  /// del viaje con las categorías donde hubo gastos reales).
  List<({String nombre, double presupuestado, double real})> _filasCategoria() {
    final presupuestado = <String, double>{
      for (final c in trip.categories) c.nombre: c.monto,
    };
    final real = <String, double>{};
    for (final g in _gastos) {
      real[g.categoriaNombre] = (real[g.categoriaNombre] ?? 0) + g.monto;
    }
    final nombres = {...presupuestado.keys, ...real.keys};
    final filas = [
      for (final n in nombres)
        (nombre: n, presupuestado: presupuestado[n] ?? 0.0, real: real[n] ?? 0.0),
    ]..sort((a, b) => b.real.compareTo(a.real));
    return filas;
  }

  Widget _buildAnalisisTab() {
  if (_isLoadingGastos) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(child: CircularProgressIndicator(color: AppColors.ink)),
    );
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildComparativaDiariaCard(),
      const SizedBox(height: 16),
      _buildPorCategoriaCard(),
      const SizedBox(height: 16),
      _buildCategoriaMasGastoCard(),
      const SizedBox(height: 16),
      _buildTopEstablecimientosCard(),
      const SizedBox(height: 16),
      _buildHorariosCard(),
      const SizedBox(height: 16),
      _buildComparativaEntreDiasCard(),
      const SizedBox(height: 16),
      _buildGastoPorPersonaCard(),
    ],
  );
}

  // 1. Comparativa diaria
  Widget _buildComparativaDiariaCard() {
    final start = parseDdMmYyyy(trip.startDate);
    final end = parseDdMmYyyy(trip.endDate);
    if (start == null || end == null || end.isBefore(start)) {
      return _SectionCard(
        title: context.l10n.analysisDailyTitle,
        child: Text(context.l10n.analysisInvalidTripDates,
            style: AppText.ui(13, color: AppColors.textMuted)),
      );
    }
    final breakdown = calculateBudgetBreakdown(
      maxBudget: trip.maxBudget,
      start: start,
      end: end,
      persons: trip.persons,
    );
    final presupuestoDiario = breakdown.perDay;
    final porDia = _gastoPorDia();
    final totalDias = end.difference(start).inDays + 1;

    TableRow header() => TableRow(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.line))),
          children: [
            for (final h in [
              context.l10n.analysisColDay,
              context.l10n.analysisColDailyBudget,
              context.l10n.analysisColActual,
              context.l10n.analysisColDifference,
              context.l10n.analysisColPctSpent,
            ])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Text(h, style: AppText.label(10, color: AppColors.textLabel)),
              ),
          ],
        );

    Widget cell(String text, {Color color = AppColors.ink, FontWeight weight = FontWeight.w500}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Text(text, style: AppText.ui(13, weight: weight, color: color)),
        );

    final rows = <TableRow>[header()];
    for (var i = 0; i < totalDias; i++) {
      final dia = start.add(Duration(days: i));
      final real = porDia[_dayOnly(dia)] ?? 0.0;
      final diff = presupuestoDiario - real;
      final pct = presupuestoDiario > 0 ? real / presupuestoDiario * 100 : 0.0;
      final diffColor = diff >= 0 ? _savingGreen : AppColors.error;
      rows.add(TableRow(
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.line, width: 0.5))),
        children: [
          cell(context.l10n.analysisDayLabelDate(i + 1, DateFormat('dd/MM').format(dia)),
              weight: FontWeight.w600),
          cell(context.formatMoney(presupuestoDiario)),
          cell(context.formatMoney(real), weight: FontWeight.w600),
          cell('${diff >= 0 ? '+' : '-'}${context.formatMoney(diff.abs())}',
              color: diffColor, weight: FontWeight.w700),
          cell('${pct.toStringAsFixed(1)}%',
              color: pct > 100 ? AppColors.error : AppColors.ink, weight: FontWeight.w600),
        ],
      ));
    }

    return _SectionCard(
      title: context.l10n.analysisDailyTitle,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 620),
          child: Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            children: rows,
          ),
        ),
      ),
    );
  }

  // 2. Por categoría
  Widget _buildPorCategoriaCard() {
    final filas = _filasCategoria();
    if (filas.isEmpty) {
      return _SectionCard(
        title: context.l10n.analysisByCategoryTitle,
        child: Text(context.l10n.analysisNoCategoriesYet,
            style: AppText.ui(13, color: AppColors.textMuted)),
      );
    }
    final maxValor = filas
        .map((f) => f.presupuestado > f.real ? f.presupuestado : f.real)
        .fold(0.0, (a, b) => b > a ? b : a);

    Widget h(String t) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Text(t, style: AppText.label(10, color: AppColors.textLabel)),
        );
    Widget c(String t, {Color color = AppColors.ink, FontWeight w = FontWeight.w500}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Text(t, style: AppText.ui(13, weight: w, color: color)),
        );

    final tableRows = <TableRow>[
      TableRow(
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.line))),
        children: [
          h(context.l10n.analysisColCategory),
          h(context.l10n.analysisColBudgeted),
          h(context.l10n.analysisColActual),
          h(context.l10n.analysisColDifference),
        ],
      ),
      for (final f in filas)
        TableRow(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.line, width: 0.5))),
          children: [
            c(f.nombre, w: FontWeight.w600),
            c(context.formatMoney(f.presupuestado)),
            c(context.formatMoney(f.real), w: FontWeight.w600),
            c(
              '${f.presupuestado - f.real >= 0 ? '+' : '-'}${context.formatMoney((f.presupuestado - f.real).abs())}',
              color: f.presupuestado - f.real >= 0 ? _savingGreen : AppColors.error,
              w: FontWeight.w700,
            ),
          ],
        ),
    ];

    return _SectionCard(
      title: context.l10n.analysisByCategoryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 520),
              child: Table(defaultColumnWidth: const IntrinsicColumnWidth(), children: tableRows),
            ),
          ),
          const SizedBox(height: 22),
          _subTitle(context.l10n.analysisBudgetedVsActual),
          Row(
            children: [
              _legendDot(_budgetBlue, context.l10n.analysisLegendBudgeted),
              const SizedBox(width: 16),
              _legendDot(_realRed, context.l10n.analysisLegendActual),
            ],
          ),
          const SizedBox(height: 12),
          for (final f in filas)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(f.nombre, style: AppText.ui(13, weight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  _hBar(maxValor > 0 ? f.presupuestado / maxValor : 0, _budgetBlue, height: 10),
                  const SizedBox(height: 4),
                  _hBar(maxValor > 0 ? f.real / maxValor : 0, _realRed, height: 10),
                ],
              ),
            ),
          const Divider(height: 24, color: AppColors.line),
          for (final f in filas)
            if (f.presupuestado > 0 || f.real > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _mensajeCategoria(f.nombre, f.presupuestado - f.real),
              ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: AppText.ui(12, color: AppColors.textMuted)),
        ],
      );

  Widget _mensajeCategoria(String nombre, double diff) {
    final ahorro = diff >= 0;
    final color = ahorro ? _savingGreen : AppColors.error;
    final texto = ahorro
        ? context.l10n.analysisCategorySaved(nombre, context.formatMoney(diff))
        : context.l10n.analysisCategoryExceeded(nombre, context.formatMoney(diff.abs()));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(ahorro ? Icons.check_circle_outline : Icons.error_outline, size: 15, color: color),
        const SizedBox(width: 6),
        Expanded(child: Text(texto, style: AppText.ui(12, weight: FontWeight.w600, color: color))),
      ],
    );
  }

  // 3a. Categorías con más gasto (%)
  Widget _buildCategoriaMasGastoCard() {
    final filas = _filasCategoria().where((f) => f.real > 0).toList();
    final total = filas.fold(0.0, (s, f) => s + f.real);
    if (total <= 0) {
      return _SectionCard(
        title: context.l10n.analysisTopCategoryTitle,
        child: Text(context.l10n.analysisTopCategoryEmpty,
            style: AppText.ui(13, color: AppColors.textMuted)),
      );
    }
    final top = filas.take(3).toList();
    final resumen = top.map((f) => '${f.nombre} (${(f.real / total * 100).round()}%)').join(', ');
    return _SectionCard(
      title: context.l10n.analysisTopCategoryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.analysisTopCategorySummary(resumen),
              style: AppText.ui(14, weight: FontWeight.w600)),
          const SizedBox(height: 14),
          for (final f in top)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(f.nombre, style: AppText.ui(13, color: AppColors.textMuted)),
                      Text('${(f.real / total * 100).toStringAsFixed(1)}%',
                          style: AppText.ui(13, weight: FontWeight.w700, color: AppColors.inkSoft)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _hBar(f.real / total, AppColors.mint),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // 3b. Top 3 establecimientos
  Widget _buildTopEstablecimientosCard() {
    final map = <String, double>{};
    final nombres = <String, String>{};
    for (final g in _gastos) {
      final nombre = (g.establecimiento ?? g.descripcion ?? '').trim();
      if (nombre.isEmpty) continue;
      final key = nombre.toLowerCase();
      nombres[key] = nombre;
      map[key] = (map[key] ?? 0) + g.monto;
    }
    final top = (map.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).take(3).toList();

    return _SectionCard(
      title: context.l10n.analysisTopPlacesTitle,
      child: top.isEmpty
          ? Text(context.l10n.analysisTopPlacesEmpty,
              style: AppText.ui(13, color: AppColors.textMuted))
          : Column(
              children: [
                for (var i = 0; i < top.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(10)),
                          child: Text('${i + 1}', style: AppText.label(11, color: AppColors.ink)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(nombres[top[i].key]!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.ui(14, weight: FontWeight.w600)),
                        ),
                        Text(context.formatMoney(top[i].value),
                            style: AppText.ui(14, weight: FontWeight.w700, color: AppColors.inkSoft)),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  // 3c. Horarios de mayor gasto (bloques de 2 horas)
  Widget _buildHorariosCard() {
    final bloques = List<double>.filled(12, 0);
    for (final g in _gastos) {
      bloques[g.fecha.hour ~/ 2] += g.monto;
    }
    final maxV = bloques.fold(0.0, (a, b) => b > a ? b : a);

    String etiqueta(int i) {
      String h(int x) => x == 0 ? '12a' : x < 12 ? '${x}a' : x == 12 ? '12p' : '${x - 12}p';
      return '${h(i * 2)}-${h(i * 2 + 2 == 24 ? 0 : i * 2 + 2)}';
    }

    final ordenados = List.generate(12, (i) => i)..sort((a, b) => bloques[b].compareTo(bloques[a]));
    final picos = ordenados.take(2).where((i) => bloques[i] > 0).toSet();

    return _SectionCard(
      title: context.l10n.analysisPeakHoursTitle,
      child: maxV <= 0
          ? Text(context.l10n.analysisPeakHoursEmpty,
              style: AppText.ui(13, color: AppColors.textMuted))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 140,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < 12; i++)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: (bloques[i] / maxV * 100).clamp(bloques[i] > 0 ? 4 : 0, 100).toDouble(),
                                  decoration: BoxDecoration(
                                    color: picos.contains(i) ? AppColors.ink : AppColors.mint,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(etiqueta(i),
                                    style: AppText.label(8), textAlign: TextAlign.center, maxLines: 1),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  context.l10n.analysisPeakHoursSummary(
                    picos.map(etiqueta).join(context.l10n.analysisAnd),
                  ),
                  style: AppText.ui(12, weight: FontWeight.w600, color: AppColors.inkSoft),
                ),
              ],
            ),
    );
  }

  // 3d. Comparativa entre días + promedio
  Widget _buildComparativaEntreDiasCard() {
    final start = parseDdMmYyyy(trip.startDate);
    final end = parseDdMmYyyy(trip.endDate);
    if (start == null || end == null || end.isBefore(start)) return const SizedBox.shrink();

    final porDia = _gastoPorDia();
    final dias = end.difference(start).inDays + 1;
    final valores = [
      for (var i = 0; i < dias; i++) porDia[_dayOnly(start.add(Duration(days: i)))] ?? 0.0,
    ];
    final promedio = valores.fold(0.0, (s, v) => s + v) / dias;
    final maxV = [...valores, promedio].fold(0.0, (a, b) => b > a ? b : a);

    return _SectionCard(
      title: context.l10n.analysisBetweenDaysTitle,
      trailing: context.l10n.analysisAverageTrailing(context.formatMoney(promedio)),
      child: maxV <= 0
          ? Text(context.l10n.analysisNoExpensesYet,
              style: AppText.ui(13, color: AppColors.textMuted))
          : Column(
              children: [
                for (var i = 0; i < dias; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 56,
                          child: Text(context.l10n.analysisDayLabel(i + 1),
                              style: AppText.ui(13, weight: FontWeight.w600)),
                        ),
                        Expanded(
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              _hBar(valores[i] / maxV,
                                  valores[i] > promedio ? _realRed : AppColors.inkSoft,
                                  height: 12),
                              // Línea del promedio
                              Positioned.fill(
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: (promedio / maxV).clamp(0.0, 1.0),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(width: 2, color: AppColors.ink),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 90,
                          child: Text(context.formatMoney(valores[i]),
                              textAlign: TextAlign.right,
                              style: AppText.ui(12, weight: FontWeight.w700, color: AppColors.inkSoft)),
                        ),
                      ],
                    ),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 2, height: 12, color: AppColors.ink),
                      const SizedBox(width: 6),
                      Text(context.l10n.analysisDailyAverageLegend,
                          style: AppText.ui(11, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // 3e. Gasto por persona (fondo del viaje vs bolsillo personal)
  Widget _buildGastoPorPersonaCard() {
    final miembros = <TripCollaborator>[if (_owner != null) _owner!, ..._collaborators];
    if (miembros.isEmpty) {
      return _SectionCard(
        title: context.l10n.analysisPerPersonTitle,
        child: Text(context.l10n.analysisNoParticipants,
            style: AppText.ui(13, color: AppColors.textMuted)),
      );
    }

    Widget fila({
      required String nombre,
      required double delViaje,
      required double bolsillo,
    }) {
      final total = delViaje + bolsillo;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.wash,
                  child: Text(
                    nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                    style: AppText.ui(13, weight: FontWeight.w700, color: AppColors.inkSoft),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(nombre, style: AppText.ui(14, weight: FontWeight.w600))),
                Text(context.formatMoney(total),
                    style: AppText.ui(14, weight: FontWeight.w700, color: AppColors.inkSoft)),
              ],
            ),
            const SizedBox(height: 8),
            _hBar(total > 0 ? delViaje / total : 0, AppColors.ink, height: 8),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.l10n.analysisTripMoneyAmount(context.formatMoney(delViaje)),
                    style: AppText.ui(11, color: AppColors.textMuted)),
                Text(context.l10n.analysisPocketAmount(context.formatMoney(bolsillo)),
                    style: AppText.ui(11, color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
      );
    }

    double suma(Iterable<Gasto> gs) => gs.fold(0.0, (s, g) => s + g.monto);

    final idsMiembros = miembros.map((m) => m.usuarioId).toSet();
    final sinAsignar =
        _gastos.where((g) => g.pagadoPorId == null || !idsMiembros.contains(g.pagadoPorId));

    return _SectionCard(
      title: context.l10n.analysisPerPersonTitle,
      child: Column(
        children: [
          for (final m in miembros)
            fila(
              nombre: m.nombreCompleto,
              delViaje: suma(_gastos.where((g) => g.pagadoPorId == m.usuarioId && g.pagadoConDineroViaje)),
              bolsillo: suma(_gastos.where((g) => g.pagadoPorId == m.usuarioId && !g.pagadoConDineroViaje)),
            ),
          if (sinAsignar.isNotEmpty) ...[
            const Divider(height: 1, color: AppColors.line),
            fila(
              nombre: context.l10n.analysisUnassigned,
              delViaje: suma(sinAsignar.where((g) => g.pagadoConDineroViaje)),
              bolsillo: suma(sinAsignar.where((g) => !g.pagadoConDineroViaje)),
            ),
          ],
        ],
      ),
    );
  }

    // ─── Tab: Límites ───

  Future<void> _loadLimites() async {
    if (trip.id == null) return;
    try {
      final data = await _limitsRepository.fetchLimits(trip.id!);
      if (!mounted) return;
      setState(() => _limites = data);
    } catch (e, st) {
      debugPrint('TripDetailScreen._loadLimites error: $e\n$st');
    }
  }

  Map<int, double> _gastoPorCategoriaId() {
    final map = <int, double>{};
    for (final g in _gastos) {
      final id = g.categoria.id;
      map[id] = (map[id] ?? 0) + g.monto;
    }
    return map;
  }

  Future<void> _openLimitsConfig() async {
    if (trip.id == null) {
      _showSnack(context.l10n.tripDetailTripNotSavedSnackbar);
      return;
    }
    if (_categorias.isEmpty) {
      _showSnack(context.l10n.tripDetailCategoriesLoadErrorSnackbar);
      return;
    }
    final result = await Navigator.push<Map<int, double>>(
      context,
      MaterialPageRoute(
        builder: (_) => SpendingLimitsScreen(
          tripId: trip.id!,
          tripName: trip.name,
          categorias: _categorias,
          initialLimits: _limites,
          spentByCategory: _gastoPorCategoriaId(),
        ),
      ),
    );
    if (result != null && mounted) setState(() => _limites = result);
  }

  Widget _buildLimitesTab() {
    if (_isLoadingGastos) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator(color: AppColors.ink)),
      );
    }
    final withLimit = _categorias.where((c) => (_limites[c.id] ?? 0) > 0).toList();
    final spent = _gastoPorCategoriaId();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: _openLimitsConfig,
            icon: const Icon(Icons.tune, size: 18),
            label: Text(context.l10n.limitsConfigureButton),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.ink,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLimitProgressCard(withLimit, spent),
        if (withLimit.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildLimitReportCard(withLimit, spent),
        ],
      ],
    );
  }

  Widget _buildLimitProgressCard(List<CategoriaGasto> cats, Map<int, double> spent) {
    final l = context.l10n;
    if (cats.isEmpty) {
      return _SectionCard(
        title: l.limitsEmptyTitle,
        child: Text(l.limitsEmptyDescription, style: AppText.ui(13, color: AppColors.textMuted)),
      );
    }
    return _SectionCard(
      title: l.limitsProgressTitle,
      child: Column(
        children: [
          for (final c in cats)
            Builder(builder: (_) {
              final limit = _limites[c.id]!;
              final s = spent[c.id] ?? 0.0;
              final over = s > limit;
              final color = over ? AppColors.error : _savingGreen;
              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: c.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(c.icon, size: 18, color: c.color),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(c.nombre, style: AppText.ui(14, weight: FontWeight.w600)),
                        ),
                        Text(
                          l.limitsProgressAmount(context.formatMoney(s), context.formatMoney(limit)),
                          style: AppText.ui(13, weight: FontWeight.w700, color: color),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    BudgetBar(progress: (s / limit).clamp(0.0, 1.0), height: 8, fill: color),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(over ? Icons.error_outline : Icons.check_circle_outline, size: 14, color: color),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            over
                                ? l.limitsOverBy(context.formatMoney(s - limit))
                                : l.limitsLeft(context.formatMoney(limit - s)),
                            style: AppText.ui(12, weight: FontWeight.w600, color: color),
                          ),
                        ),
                        Text('${(s / limit * 100).round()}%', style: AppText.label(10)),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildLimitReportCard(List<CategoriaGasto> cats, Map<int, double> spent) {
    final l = context.l10n;

    Widget h(String t, {TextAlign align = TextAlign.left}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Text(t, textAlign: align, style: AppText.label(10, color: AppColors.textLabel)),
        );
    Widget c(String t,
            {Color color = AppColors.ink, FontWeight w = FontWeight.w500, TextAlign align = TextAlign.left}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Text(t, textAlign: align, style: AppText.ui(13, weight: w, color: color)),
        );

    var totalLimit = 0.0;
    var totalSpent = 0.0;
    final rows = <TableRow>[
      TableRow(
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.line))),
        children: [
          h(l.limitsColCategory),
          h(l.limitsColLimit, align: TextAlign.right),
          h(l.limitsColSpent, align: TextAlign.right),
          h(l.limitsColCompliance, align: TextAlign.right),
        ],
      ),
    ];
    for (final cat in cats) {
      final limit = _limites[cat.id]!;
      final s = spent[cat.id] ?? 0.0;
      totalLimit += limit;
      totalSpent += s;
      final pct = s / limit * 100;
      final over = s > limit;
      rows.add(TableRow(
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.line, width: 0.5))),
        children: [
          c(cat.nombre, w: FontWeight.w600),
          c(context.formatMoney(limit), align: TextAlign.right),
          c(context.formatMoney(s), w: FontWeight.w600, align: TextAlign.right),
          c('${pct.toStringAsFixed(1)}%',
              color: over ? AppColors.error : _savingGreen, w: FontWeight.w700, align: TextAlign.right),
        ],
      ));
    }
    final totalPct = totalLimit > 0 ? totalSpent / totalLimit * 100 : 0.0;
    rows.add(TableRow(
      children: [
        c(l.limitsTotalRow, w: FontWeight.w700),
        c(context.formatMoney(totalLimit), w: FontWeight.w700, align: TextAlign.right),
        c(context.formatMoney(totalSpent), w: FontWeight.w700, align: TextAlign.right),
        c('${totalPct.toStringAsFixed(1)}%',
            color: totalSpent > totalLimit ? AppColors.error : _savingGreen,
            w: FontWeight.w700,
            align: TextAlign.right),
      ],
    ));

    return _SectionCard(
      title: l.limitsReportTitle,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 520),
          child: Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            children: rows,
          ),
        ),
      ),
    );
  }

  Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.ui(14, color: AppColors.textMuted)),
          Text(value, style: AppText.ui(14, weight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _tag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: AppColors.wash, borderRadius: BorderRadius.circular(AppRadius.chip)),
      child: Text(label, style: AppText.ui(12, weight: FontWeight.w600, color: AppColors.inkSoft)),
    );
  }

  // ─── Móvil ───
  // No forma parte del alcance de esta pasada de escritorio; mantiene
  // la estructura anterior (info plana + botones fijos) funcionando.

  // ─── Móvil ───
  // Anatomía móvil del handoff (› Detalle del viaje): cabecera `ink`
  // con `bottomRight: 44` y el presupuesto, pestañas con el mismo
  // contenido que escritorio y pie fijo con "Añadir gasto" + `⋯`.

  Widget _buildMobile(BuildContext context, {required double totalSpent, required double remaining}) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _buildMobileHeader(totalSpent: totalSpent),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: AppColors.ink,
                  unselectedLabelColor: AppColors.textMuted,
                  indicatorColor: AppColors.ink,
                  dividerColor: AppColors.line,
                  labelStyle: AppText.ui(14, weight: FontWeight.w700),
                  unselectedLabelStyle: AppText.ui(14, weight: FontWeight.w500),
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    Tab(text: context.l10n.tripDetailTabResumen),
                    Tab(text: context.l10n.tripDetailTabHospedaje),
                    Tab(text: context.l10n.tripDetailTabGastos),
                    Tab(text: context.l10n.tripDetailTabGrupo),
                    Tab(text: context.l10n.tripDetailTabAnalisis),
                    Tab(text: context.l10n.limitsTabTitle),
                  ],
                ),
                const SizedBox(height: 20),
                switch (_tabController.index) {
                  0 => _buildResumenTab(totalSpent: totalSpent, remaining: remaining),
                  1 => _buildHospedajeTab(),
                  2 => _buildGastosTab(totalSpent: totalSpent, remaining: remaining),
                  3 => _buildGrupoTab(),
                  4 => _buildAnalisisTab(),
                  _ => _buildLimitesTab(),
                },
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          // Alto fijo: `bottomNavigationBar` no acota la altura y el botón
          // se estiraba a toda la pantalla.
          child: SizedBox(
            height: 58,
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: trip.isFinished
                    // Terminado: en vez de "Añadir gasto", por qué no se puede.
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.wash,
                          borderRadius: BorderRadius.circular(AppRadius.button),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock_outline, size: 18, color: AppColors.inkSoft),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                context.l10n.tripFinishedReadOnlyNotice,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.ui(12, weight: FontWeight.w600, color: AppColors.inkSoft),
                              ),
                            ),
                          ],
                        ),
                      )
                    : InkButton(
                        label: context.l10n.tripDetailAddExpenseButton,
                        icon: Icons.add,
                        expand: true,
                        onPressed: _handleAddExpense,
                      ),
              ),
              if (_isOwner) ...[
                const SizedBox(width: 12),
                Pressable(
                  onTap: _confirmDeleteTrip,
                  semanticLabel: context.l10n.tripDetailMoreTooltip,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.button),
                      border: Border.all(color: AppColors.hair),
                    ),
                    child: const Icon(Icons.more_horiz, color: AppColors.ink),
                  ),
                ),
              ],
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileHeader({required double totalSpent}) {
    final progress = trip.maxBudget > 0 ? (totalSpent / trip.maxBudget).clamp(0.0, 1.0) : 0.0;
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(color: AppColors.ink, borderRadius: AppRadius.headerDetail),
      child: Stack(
        children: [
          const Positioned.fill(child: RoutePatternBackground(opacity: 0.10)),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(26, 18, 26, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GhostIconButton(icon: Icons.arrow_back, onTap: () => context.go('/')),
                      const SizedBox(width: 12),
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.inkSoft,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.luggage_outlined, color: AppColors.mint, size: 20),
                      ),
                      const Spacer(),
                      if (trip.isFinished)
                        const _FinishedBadge()
                      else ...[
                        GhostIconButton(
                          icon: Icons.account_balance_wallet_outlined,
                          tooltip: context.l10n.pocketButtonLabel,
                          onTap: _openPocket,
                        ),
                        const SizedBox(width: 8),
                        GhostIconButton(
                          icon: Icons.edit_outlined,
                          tooltip: context.l10n.tripDetailEditBudgetTooltip,
                          onTap: _editBudget,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(context.l10n.tripDetailHeaderTripToPrefix.trim(), style: AppText.display(40, color: AppColors.paper)),
                  Text(trip.destination, style: AppText.displayItalic(40, color: AppColors.mint)),
                  const SizedBox(height: 10),
                  Text(
                    context.l10n.tripDetailHeaderSubtitle(
                      trip.startDate,
                      trip.endDate,
                      trip.persons,
                      trip.tripType.toUpperCase(),
                    ),
                    style: AppText.label(11, color: AppColors.textOnInk),
                  ),
                  const SizedBox(height: 26),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(context.l10n.tripDetailSpentLabel, style: AppText.label(10, color: AppColors.textOnInk)),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                context.formatMoney(totalSpent),
                                style: AppText.display(40, color: AppColors.paper),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(context.l10n.tripDetailCapLabel, style: AppText.label(10, color: AppColors.textOnInk)),
                          const SizedBox(height: 4),
                          Text(context.formatMoney(trip.maxBudget), style: AppText.ui(18, color: AppColors.textOnInk)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  BudgetBar(
                    progress: progress,
                    height: 8,
                    track: Colors.white.withValues(alpha: 0.24),
                    fill: AppColors.mint,
                  ),
                  const SizedBox(height: 8),
                  _buildBudgetStatus(totalSpent: totalSpent),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Etiqueta "Viaje terminado" sobre `ink`, donde iban Editar / Añadir
/// gasto en un viaje que ya acabó.
class _FinishedBadge extends StatelessWidget {
  const _FinishedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 14, color: AppColors.mint),
          const SizedBox(width: 6),
          Text(
            context.l10n.tripFinishedBadge.toUpperCase(),
            style: AppText.label(10, color: AppColors.mint),
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.label, required this.translucent, required this.onTap});

  final String label;
  final bool translucent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: translucent ? Colors.white.withValues(alpha: 0.14) : AppColors.mint,
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          child: Text(
            label,
            style: AppText.ui(13, weight: FontWeight.w700, color: translucent ? Colors.white : AppColors.ink),
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, this.trailing, required this.child});

  final String title;
  final String? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card + 2),
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppText.display(22)),
              if (trailing != null) Text(trailing!, style: AppText.label(12, color: AppColors.inkSoft)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.color,
    required this.labelColor,
    required this.titleColor,
    required this.detailColor,
    required this.label,
    required this.title,
    required this.detail,
  });

  final Color color;
  final Color labelColor;
  final Color titleColor;
  final Color detailColor;
  final String label;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppRadius.card + 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.label(10, color: labelColor)),
          const SizedBox(height: 8),
          Text(title, style: AppText.display(24, color: titleColor)),
          if (detail.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(detail, style: AppText.ui(12, color: detailColor)),
          ],
        ],
      ),
    );
  }
}


/// Diálogo "Invitar al viaje": valida el correo (vacío, formato) antes de
/// buscarlo, muestra bajo el campo por qué no se pudo invitar (no
/// registrado, no es turista, ya está en el viaje...) y bloquea el botón
/// mientras responde el servidor.
class _InviteCollaboratorDialog extends StatefulWidget {
  const _InviteCollaboratorDialog({required this.onInvite});

  final Future<TripCollaborator> Function(String email) onInvite;

  @override
  State<_InviteCollaboratorDialog> createState() => _InviteCollaboratorDialogState();
}

class _InviteCollaboratorDialogState extends State<_InviteCollaboratorDialog> {
  final _controller = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    final email = _controller.text.trim();
    if (email.isEmpty) {
      setState(() => _error = context.l10n.valInviteEmailRequired);
      return;
    }
    if (!Validators.isEmail(email)) {
      setState(() => _error = context.l10n.valEmail);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final collaborator = await widget.onInvite(email);
      if (!mounted) return;
      Navigator.pop(context, collaborator);
    } on TripInviteException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (e, st) {
      debugPrint('_InviteCollaboratorDialog error: $e\n$st');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = context.l10n.tripDetailInviteErrorSnackbar;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.tripDetailInviteDialogTitle),
      content: SizedBox(
        width: 380,
        child: TextField(
          controller: _controller,
          autofocus: true,
          enabled: !_loading,
          keyboardType: TextInputType.emailAddress,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'\s')),
            LengthLimitingTextInputFormatter(150),
          ],
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            hintText: l10n.tripDetailInviteEmailHint,
            helperText: l10n.tripDetailInviteEmailHelper,
            helperMaxLines: 2,
            errorText: _error,
            errorMaxLines: 3,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: Text(l10n.tripDetailCancelButton),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.mint),
                )
              : Text(l10n.tripDetailInviteButton),
        ),
      ],
    );
  }
}
