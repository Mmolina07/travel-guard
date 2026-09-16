import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/route_pattern_background.dart';
import '../../../../shell/app_shell.dart';
import '../../../../widgets/budget_bar.dart';
import '../../../expenses/data/expense_repository.dart';
import '../../../expenses/data/models/categoria_gasto_model.dart';
import '../../../expenses/data/models/gasto_model.dart';
import '../../../expenses/presentation/widgets/add_expense_sheet.dart';
import '../../presentation/pages/trip_model.dart';
import '../../utils/budget_calculator.dart';
import 'create_trip_screen.dart';
import 'edit_trip_budget_screen.dart';

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

  List<Gasto> _gastos = [];
  List<CategoriaGasto> _categorias = [];
  bool _isLoadingGastos = true;
  String? _gastosError;

  /// Muestra/oculta la tarjeta de devolución de IVA — solo aplica a
  /// turistas extranjeros no residentes, así que no tiene sentido
  /// mostrarla siempre.
  bool _esExtranjero = false;

  @override
  void initState() {
    super.initState();
    trip = widget.trip;
    _tabController = TabController(length: 4, vsync: this)
      ..addListener(() => setState(() {}));
    _loadGastos();
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
        _gastosError = 'No se pudieron cargar los gastos.';
        _isLoadingGastos = false;
      });
    }
  }

  /// Suma de los gastos reales registrados manualmente, que se recalcula
  /// solita cada vez que `_gastos` cambia (agregar/eliminar) — "se va
  /// actualizando constantemente".
  double get _gastosTotal => _gastos.fold(0.0, (sum, g) => sum + g.monto);

  DateTime? _parseTripDate(String ddMmYyyy) {
    try {
      return DateFormat('dd/MM/yyyy').parseStrict(ddMmYyyy.trim());
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleAddExpense() async {
    if (trip.id == null) {
      _showSnack('Este viaje no quedó guardado en el servidor; no se pueden registrar gastos.');
      return;
    }
    if (_categorias.isEmpty) {
      _showSnack('No se pudieron cargar las categorías de gasto.');
      return;
    }

    final startDate = _parseTripDate(trip.startDate) ?? DateTime.now();
    final endDate = _parseTripDate(trip.endDate) ?? startDate;

    final result = await AddExpenseSheet.show(
      context,
      categorias: _categorias,
      tripStartDate: startDate,
      tripEndDate: endDate.isBefore(startDate) ? startDate : endDate,
    );
    if (result == null || !mounted) return;

    try {
      final gasto = await _expenseRepository.createGasto(
        viajeId: trip.id!,
        categoriaId: result.categoria.id,
        monto: result.monto,
        fecha: result.fecha,
        descripcion: result.descripcion,
      );
      if (!mounted) return;
      setState(() => _gastos = [gasto, ..._gastos]);
      _showSnack(
        'Gasto de ${formatCOP(result.monto)} en ${result.categoria.nombre} agregado',
        color: AppColors.ink,
      );
    } catch (e, st) {
      debugPrint('TripDetailScreen._handleAddExpense error: $e\n$st');
      if (!mounted) return;
      _showSnack('No se pudo guardar el gasto. Intenta de nuevo.');
    }
  }

  Future<void> _handleDeleteGasto(Gasto gasto) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar gasto'),
        content: Text(
          '¿Eliminar el gasto de ${formatCOP(gasto.monto)} en ${gasto.categoriaNombre}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _expenseRepository.deleteGasto(gasto.id);
      if (!mounted) return;
      setState(() => _gastos = _gastos.where((g) => g.id != gasto.id).toList());
    } catch (e, st) {
      debugPrint('TripDetailScreen._handleDeleteGasto error: $e\n$st');
      if (!mounted) return;
      _showSnack('No se pudo eliminar el gasto.');
    }
  }

  /// Mejora "gestor de presupuesto" (TG-166): antes el presupuesto solo
  /// se definía una vez al crear el viaje; ahora se puede reajustar
  /// (monto máximo, categorías, hospedaje, emergencias) en cualquier
  /// momento, sin tener que borrar y recrear el viaje.
  Future<void> _editBudget() async {
    final updated = await Navigator.push<Trip>(
      context,
      MaterialPageRoute(builder: (context) => EditTripBudgetScreen(trip: trip)),
    );
    if (updated != null && mounted) {
      setState(() => trip = updated);
    }
  }

  Future<void> _confirmDeleteTrip() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar viaje'),
        content: Text(
          '¿Estás seguro de que deseas eliminar el viaje "${trip.name}"? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.go('/');
      _showSnack('Viaje eliminado', color: AppColors.error);
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSpent = trip.getTotalSpent() + _gastosTotal;
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
          tabs: const [
            Tab(text: 'Resumen'),
            Tab(text: 'Hospedaje'),
            Tab(text: 'Transporte'),
            Tab(text: 'Gastos'),
          ],
        ),
        const SizedBox(height: 24),
        switch (_tabController.index) {
          0 => _buildResumenTab(totalSpent: totalSpent, remaining: remaining),
          1 => _buildHospedajeTab(),
          2 => _buildTransporteTab(),
          _ => _buildGastosTab(totalSpent: totalSpent, remaining: remaining),
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
                            Text('INICIO / MIS VIAJES', style: AppText.label(11, color: AppColors.textOnInk)),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        _HeaderButton(label: 'Editar', translucent: true, onTap: _editBudget),
                        const SizedBox(width: 10),
                        _HeaderButton(
                          label: 'Añadir gasto',
                          translucent: false,
                          onTap: _handleAddExpense,
                        ),
                        const SizedBox(width: 10),
                        _HeaderIconButton(icon: Icons.more_horiz, onTap: _confirmDeleteTrip),
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
                          Text('Viaje a ', style: AppText.display(40, color: Colors.white)),
                          Text(trip.destination, style: AppText.displayItalic(40)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${trip.startDate} – ${trip.endDate} · ${trip.persons} '
                  '${trip.persons == 1 ? 'PERSONA' : 'PERSONAS'} · ${trip.tripType.toUpperCase()}',
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
                          Text('GASTADO', style: AppText.label(10, color: AppColors.textOnInk)),
                          const SizedBox(height: 4),
                          Text(formatCOP(totalSpent), style: AppText.display(44, color: AppColors.paper)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('TOPE', style: AppText.label(10, color: AppColors.textOnInk)),
                        const SizedBox(height: 4),
                        Text(formatCOP(trip.maxBudget), style: AppText.ui(18, color: AppColors.textOnInk)),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tab: Resumen ───

  Widget _buildResumenTab({required double totalSpent, required double remaining}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      title: 'Hospedaje',
      trailing: formatCOP(trip.lodgingCost),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kv('Tipo', trip.lodgingType.isNotEmpty ? trip.lodgingType : '—'),
          _kv('Costo', formatCOP(trip.lodgingCost)),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _MiniCard(
            color: AppColors.ink,
            labelColor: AppColors.textOnInk,
            titleColor: AppColors.paper,
            detailColor: AppColors.textOnInk,
            label: 'TRANSPORTE',
            title: trip.startTransport.isNotEmpty ? trip.startTransport : '—',
            detail: trip.duringTransport.isNotEmpty ? 'Durante: ${trip.duringTransport}' : '',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _MiniCard(
            color: AppColors.wash,
            labelColor: AppColors.inkSoft,
            titleColor: AppColors.ink,
            detailColor: AppColors.textMuted,
            label: 'PERSONAS',
            title: '${trip.persons}',
            detail: trip.tripType,
          ),
        ),
      ],
    );
  }

  Widget _buildUltimosGastosCard() {
    final recent = _gastos.take(5).toList();
    return _SectionCard(
      title: 'Últimos gastos',
      child: _isLoadingGastos
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(color: AppColors.ink)),
            )
          : recent.isEmpty
          ? Text('Aún no has registrado gastos.', style: AppText.ui(13, color: AppColors.textMuted))
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
          Text(formatCOP(gasto.monto), style: AppText.ui(14, weight: FontWeight.w700, color: AppColors.inkSoft)),
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
      title: 'Presupuesto disponible',
      trailing: formatCOP(remaining),
      child: Row(
        children: [
          Expanded(
            child: _buildDailyStat(
              icon: Icons.calendar_today,
              label: 'Por día (${breakdown.days} días)',
              value: formatCOP(breakdown.perDay),
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.line),
          Expanded(
            child: _buildDailyStat(
              icon: Icons.groups_outlined,
              label: 'Por persona (${trip.persons})',
              value: formatCOP(breakdown.perPerson),
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
      ('Pagos anticipados', trip.advancePayment),
      ('Hospedaje (planeado)', trip.lodgingCost),
      for (final categoria in trip.categories) (categoria.nombre, categoria.monto),
      ('Emergencias', trip.emergencyMoney),
      ...gastosByCategory.entries.map((e) => ('${e.key} (real)', e.value)),
    ].where((e) => e.$2 > 0).toList();

    return _SectionCard(
      title: 'Desglose de gastos',
      child: rows.isEmpty
          ? Text('No hay gastos registrados aún.', style: AppText.ui(13, color: AppColors.textMuted))
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
                '${formatCOP(amount)} (${(percentage * 100).toStringAsFixed(1)}%)',
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
      title: 'Hospedaje',
      trailing: formatCOP(trip.lodgingCost),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kv('Tipo de hospedaje', trip.lodgingType.isNotEmpty ? trip.lodgingType : '—'),
          _kv('Costo', formatCOP(trip.lodgingCost)),
          if (trip.includedServices.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Servicios incluidos', style: AppText.ui(13, weight: FontWeight.w600, color: AppColors.textMuted)),
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

  // ─── Tab: Transporte ───

  Widget _buildTransporteTab() {
    return _SectionCard(
      title: 'Transporte',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kv('Transporte de inicio', trip.startTransport.isNotEmpty ? trip.startTransport : '—'),
          _kv('Transporte durante el viaje', trip.duringTransport.isNotEmpty ? trip.duringTransport : '—'),
        ],
      ),
    );
  }

  // ─── Tab: Gastos ───

  Widget _buildGastosTab({required double totalSpent, required double remaining}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          title: 'Gastos registrados',
          trailing: formatCOP(_gastosTotal),
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
        'Este viaje no quedó guardado en el servidor, así que no se pueden registrar gastos reales.',
        style: AppText.ui(13, color: AppColors.textMuted),
      );
    }
    if (_gastosError != null) {
      return Row(
        children: [
          Expanded(child: Text(_gastosError!, style: AppText.ui(13, color: AppColors.error))),
          TextButton(onPressed: _loadGastos, child: const Text('Reintentar')),
        ],
      );
    }
    if (_gastos.isEmpty) {
      return Text(
        'Aún no has registrado gastos reales para este viaje.',
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
              Text(formatCOP(gasto.monto), style: AppText.ui(13, weight: FontWeight.w700, color: AppColors.inkSoft)),
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                onPressed: () => _handleDeleteGasto(gasto),
                tooltip: 'Eliminar gasto',
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
      phaseLabel = 'Agrega fechas válidas para ver tu ritmo de gasto.';
    } else if (today.isBefore(start)) {
      final daysUntil = start.difference(today).inDays;
      phaseLabel = 'Tu viaje empieza en $daysUntil día${daysUntil == 1 ? '' : 's'}.';
      remainingDays = end.difference(start).inDays + 1;
    } else if (today.isAfter(end)) {
      phaseLabel = 'Este viaje ya terminó.';
    } else {
      remainingDays = end.difference(today).inDays + 1;
      phaseLabel = 'Quedan $remainingDays día${remainingDays == 1 ? '' : 's'} de viaje.';
    }

    final safePersons = trip.persons < 1 ? 1 : trip.persons;
    final perPersonSpent = totalSpent / safePersons;

    Widget? paceRow;
    if (remainingDays != null && remaining > 0) {
      final dailyForGroup = remaining / remainingDays;
      final dailyPerPerson = dailyForGroup / safePersons;
      paceRow = Row(
        children: [
          Expanded(
            child: _buildDailyStat(
              icon: Icons.groups_outlined,
              label: 'Grupo debería gastar/día',
              value: formatCOP(dailyForGroup),
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.line),
          Expanded(
            child: _buildDailyStat(
              icon: Icons.person_outline,
              label: 'Por persona/día',
              value: formatCOP(dailyPerPerson),
            ),
          ),
        ],
      );
    }

    return _SectionCard(
      title: 'Ritmo de gasto',
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
          if (paceRow != null) ...[const SizedBox(height: 14), paceRow],
          if (totalSpent > 0) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.line),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Llevas gastado por persona', style: AppText.ui(12, color: AppColors.textMuted)),
                Text(formatCOP(perPersonSpent), style: AppText.ui(13, weight: FontWeight.w700, color: AppColors.inkSoft)),
              ],
            ),
          ],
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
              const Expanded(
                child: Text(
                  '¿Eres turista extranjero?',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF8A6D1D)),
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
                  ? 'De lo que llevas en "Compras" (${formatCOP(comprasTotal)}), aprox. '
                        '${formatCOP(ivaEstimado)} fue IVA — en Colombia los turistas '
                        'extranjeros no residentes pueden pedirlo de vuelta completo '
                        'antes de salir del país.'
                  : 'Cuando registres compras (ropa, calzado, artesanías, joyería, '
                        'electrodomésticos, etc.) con factura electrónica, aquí verás '
                        'cuánto IVA podrías recuperar antes de salir del país.',
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B5416), height: 1.4),
            ),
            const SizedBox(height: 8),
            Text(
              'Requisitos: factura electrónica de mínimo ${formatCOP(minPurchase)} por '
              'compra, pasaporte o Tarjeta Andina Migratoria, y solicitarlo en la DIAN '
              'del aeropuerto antes de viajar. Tope: ${formatCOP(maxRefund)} por '
              'solicitud. Verifica el trámite vigente en dian.gov.co.',
              style: const TextStyle(fontSize: 10, color: Color(0xFF8A6D1D), height: 1.4),
            ),
          ],
        ],
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

  Widget _buildMobile(BuildContext context, {required double totalSpent, required double remaining}) {
    final percentage = trip.maxBudget > 0 ? (totalSpent / trip.maxBudget) * 100 : 0.0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Viaje', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), tooltip: 'Editar presupuesto', onPressed: _editBudget),
          IconButton(icon: const Icon(Icons.more_vert), tooltip: 'Más', onPressed: _confirmDeleteTrip),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(trip.name, style: AppText.display(24)),
            const SizedBox(height: 4),
            Text(trip.destination, style: AppText.ui(14, color: AppColors.textMuted)),
            const SizedBox(height: 20),
            _SectionCard(
              title: 'Presupuesto',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _kv('Gastado', formatCOP(totalSpent)),
                  _kv('Disponible', formatCOP(remaining)),
                  const SizedBox(height: 10),
                  BudgetBar(progress: (percentage / 100).clamp(0, 1)),
                  const SizedBox(height: 6),
                  Text('${percentage.toStringAsFixed(1)}% del presupuesto utilizado', style: AppText.label(10)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildHospedajeTab(),
            const SizedBox(height: 16),
            _buildTransporteTab(),
            const SizedBox(height: 16),
            _SectionCard(title: 'Gastos registrados', trailing: formatCOP(_gastosTotal), child: _buildGastosList()),
          ],
        ),
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
