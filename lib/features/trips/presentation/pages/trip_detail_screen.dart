import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/money_formatter.dart';
import '../../../expenses/data/expense_repository.dart';
import '../../../expenses/data/models/categoria_gasto_model.dart';
import '../../../expenses/data/models/gasto_model.dart';
import '../../../expenses/presentation/widgets/add_expense_sheet.dart';
import '../../presentation/pages/trip_model.dart';
import '../../utils/budget_calculator.dart';
import 'edit_trip_budget_screen.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../../core/widgets/route_pattern_background.dart';
import '../../../../core/widgets/travel_guard_badge.dart';

class TripDetailScreen extends StatefulWidget {
  final Trip trip;

  const TripDetailScreen({Key? key, required this.trip}) : super(key: key);

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  static const Color _primary = Color(0xFF1A5F7A);

  late Trip trip;
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
    _loadGastos();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Este viaje no quedó guardado en el servidor; no se pueden registrar gastos.',
          ),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
      return;
    }
    if (_categorias.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudieron cargar las categorías de gasto.'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gasto de ${formatCOP(result.monto)} en '
            '${result.categoria.nombre} agregado',
          ),
          backgroundColor: _primary,
        ),
      );
    } catch (e, st) {
      debugPrint('TripDetailScreen._handleAddExpense error: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar el gasto. Intenta de nuevo.'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
    }
  }

  Future<void> _handleDeleteGasto(Gasto gasto) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Eliminar gasto',
          style: TextStyle(color: _primary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Eliminar el gasto de ${formatCOP(gasto.monto)} '
          'en ${gasto.categoriaNombre}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: _primary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo eliminar el gasto.'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    final double totalSpent = trip.getTotalSpent() + _gastosTotal;
    final double remaining = trip.maxBudget - totalSpent;
    final double percentage = trip.maxBudget > 0
        ? (totalSpent / trip.maxBudget) * 100
        : 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalle del Viaje',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A5F7A),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A5F7A), Color(0xFF0F4C5F)],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar presupuesto',
            onPressed: _editBudget,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header azul
            FadeSlideIn(
              child: Container(
                width: double.infinity,
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.primaryLight, Color(0xFF0F4C5F)],
                  ),
                ),
                child: Stack(
                  children: [
                    const RoutePatternBackground(opacity: 0.10),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            trip.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const TravelGuardBadge(size: 40, animate: false),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.white70,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          trip.destination,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.white70,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${trip.startDate} - ${trip.endDate}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            FadeSlideIn(
              delay: const Duration(milliseconds: 100),
              child: ResponsiveCenter(
                maxWidth: 720,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SECCIÓN 1: INFORMACIÓN BÁSICA
                    _buildSectionTitle('Información del Viaje'),
                    const SizedBox(height: 12),
                    _buildInfoRow('Destino', trip.destination),
                    _buildInfoRow('Tipo de Viaje', trip.tripType),
                    _buildInfoRow('Número de Personas', '${trip.persons}'),
                    _buildInfoRow(
                      'Fechas',
                      '${trip.startDate} - ${trip.endDate}',
                    ),
                    const SizedBox(height: 24),

                    // SECCIÓN 2: HOSPEDAJE
                    _buildSectionTitle('Hospedaje'),
                    const SizedBox(height: 12),
                    _buildInfoRow('Tipo de Hospedaje', trip.lodgingType),
                    _buildInfoRow(
                      'Costo Hospedaje',
                      '${formatCOP(trip.lodgingCost)}',
                      isAmount: true,
                    ),
                    if (trip.includedServices.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildSectionSubtitle('Servicios Incluidos'),
                      const SizedBox(height: 8),
                      ...trip.includedServices.map(
                        (service) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outlined,
                                color: AppColors.accentLight,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                service,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // SECCIÓN 3: TRANSPORTE
                    _buildSectionTitle('Transporte'),
                    const SizedBox(height: 12),
                    _buildInfoRow('Transporte Inicio', trip.startTransport),
                    _buildInfoRow('Transporte Durante', trip.duringTransport),
                    const SizedBox(height: 24),

                    // SECCIÓN 4: PRESUPUESTO PLANEADO
                    _buildSectionTitle('Presupuesto Planeado'),
                    const SizedBox(height: 12),
                    for (final categoria in trip.categories)
                      if (categoria.monto > 0)
                        _buildInfoRow(
                          categoria.nombre,
                          formatCOP(categoria.monto),
                          isAmount: true,
                        ),
                    if (trip.emergencyMoney > 0)
                      _buildInfoRow(
                        'Dinero Emergencias',
                        '${formatCOP(trip.emergencyMoney)}',
                        isAmount: true,
                      ),
                    const SizedBox(height: 24),

                    // SECCIÓN 5: GASTOS REALES (HU-13)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('Gastos Registrados'),
                        TextButton.icon(
                          onPressed: _handleAddExpense,
                          icon: const Icon(Icons.add_circle, size: 20),
                          label: const Text('Agregar'),
                          style: TextButton.styleFrom(
                            foregroundColor: _primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildGastosList(),
                    const SizedBox(height: 24),

                    // SECCIÓN 6: RESUMEN PRESUPUESTARIO
                    _buildSectionTitle('Resumen Presupuestario'),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F7FC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD7E8EF)),
                      ),
                      child: Column(
                        children: [
                          _buildBudgetRow(
                            'Presupuesto Máximo',
                            '${formatCOP(trip.maxBudget)}',
                          ),
                          const SizedBox(height: 12),
                          _buildBudgetRow(
                            'Total Gastado',
                            '${formatCOP(totalSpent)}',
                            isSpent: true,
                          ),
                          const SizedBox(height: 12),
                          _buildBudgetRow(
                            'Presupuesto Disponible',
                            '${formatCOP(remaining)}',
                            isAvailable: true,
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: (percentage / 100).clamp(0.0, 1.0),
                              minHeight: 10,
                              backgroundColor: const Color(0xFFE0EEF7),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                remaining > 0
                                    ? AppColors.accentLight
                                    : const Color(0xFFD32F2F),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${percentage.toStringAsFixed(1)}% del presupuesto utilizado',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (remaining > 0) ...[
                      const SizedBox(height: 16),
                      _buildDailyBudgetCard(remaining),
                    ],
                    const SizedBox(height: 24),

                    // SECCIÓN "PARA TI": recomendaciones personalizadas
                    _buildSectionTitle('Para ti'),
                    const SizedBox(height: 16),
                    _buildSpendingPaceCard(remaining, totalSpent),
                    const SizedBox(height: 16),
                    _buildTaxRefundCard(),
                    const SizedBox(height: 24),

                    // SECCIÓN 7: DESGLOSE DETALLADO
                    _buildSectionTitle('Desglose de Gastos'),
                    const SizedBox(height: 16),
                    _buildExpenseBreakdown(),
                    const SizedBox(height: 24),

                    // BOTONES DE ACCIÓN
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Función en desarrollo'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Editar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1A5F7A),
                              side: const BorderSide(color: Color(0xFF1A5F7A)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showDeleteDialog();
                            },
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Eliminar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGastosList() {
    if (_isLoadingGastos) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator(color: _primary)),
      );
    }
    if (trip.id == null) {
      return const Text(
        'Este viaje no quedó guardado en el servidor, así que no se '
        'pueden registrar gastos reales.',
        style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
      );
    }
    if (_gastosError != null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              _gastosError!,
              style: const TextStyle(fontSize: 13, color: Color(0xFFD32F2F)),
            ),
          ),
          TextButton(onPressed: _loadGastos, child: const Text('Reintentar')),
        ],
      );
    }
    if (_gastos.isEmpty) {
      return const Text(
        'Aún no has registrado gastos reales para este viaje.',
        style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
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
                  color: gasto.categoria.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  gasto.categoria.icon,
                  size: 18,
                  color: gasto.categoria.color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gasto.descripcion?.isNotEmpty == true
                          ? gasto.descripcion!
                          : gasto.categoriaNombre,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A5F7A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${gasto.categoriaNombre} · '
                      '${DateFormat('dd/MM/yyyy').format(gasto.fecha)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${formatCOP(gasto.monto)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A5F7A),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.textSecondaryLight,
                ),
                onPressed: () => _handleDeleteGasto(gasto),
                tooltip: 'Eliminar gasto',
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A5F7A),
      ),
    );
  }

  Widget _buildSectionSubtitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A5F7A),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isAmount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryLight,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isAmount
                  ? const Color(0xFF1A5F7A)
                  : const Color(0xFF1A5F7A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetRow(
    String label,
    String value, {
    bool isSpent = false,
    bool isAvailable = false,
  }) {
    Color textColor = AppColors.textSecondaryLight;
    if (isSpent) textColor = const Color(0xFFD32F2F);
    if (isAvailable) textColor = AppColors.accentLight;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD7E8EF)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDailyStat(
              icon: Icons.calendar_today,
              label: 'Por día (${breakdown.days} días)',
              value: formatCOP(breakdown.perDay),
            ),
          ),
          Container(width: 1, height: 36, color: const Color(0xFFE0EEF7)),
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

  Widget _buildDailyStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF4A90A4)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: _primary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
      phaseLabel =
          'Tu viaje empieza en $daysUntil día${daysUntil == 1 ? '' : 's'}.';
      remainingDays = end.difference(start).inDays + 1;
    } else if (today.isAfter(end)) {
      phaseLabel = 'Este viaje ya terminó.';
    } else {
      remainingDays = end.difference(today).inDays + 1;
      phaseLabel =
          'Quedan $remainingDays día${remainingDays == 1 ? '' : 's'} de viaje.';
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
          Container(width: 1, height: 36, color: const Color(0xFFE0EEF7)),
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD7E8EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_outlined, size: 18, color: _primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  phaseLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                  ),
                ),
              ),
            ],
          ),
          if (paceRow != null) ...[const SizedBox(height: 12), paceRow],
          if (totalSpent > 0) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFE0EEF7)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Llevas gastado por persona',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                Text(
                  formatCOP(perPersonSpent),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _primary,
                  ),
                ),
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
    final comprasTotal = _gastos
        .where((g) => g.categoriaNombre == 'Compras')
        .fold(0.0, (sum, g) => sum + g.monto);
    final ivaEstimado = comprasTotal * (_ivaRate / (1 + _ivaRate));
    final minPurchase = _minPurchaseUvt * _uvt2026;
    final maxRefund = _maxRefundUvt * _uvt2026;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3E0A3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.flight_takeoff,
                size: 18,
                color: Color(0xFF8A6D1D),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '¿Eres turista extranjero?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8A6D1D),
                  ),
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
                  ? 'De lo que llevas en "Compras" (${formatCOP(comprasTotal)}), '
                        'aprox. ${formatCOP(ivaEstimado)} fue IVA — en Colombia '
                        'los turistas extranjeros no residentes pueden pedirlo '
                        'de vuelta completo antes de salir del país.'
                  : 'Cuando registres compras (ropa, calzado, artesanías, '
                        'joyería, electrodomésticos, etc.) con factura '
                        'electrónica, aquí verás cuánto IVA podrías recuperar '
                        'antes de salir del país.',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B5416),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Requisitos: factura electrónica de mínimo '
              '${formatCOP(minPurchase)} por compra, pasaporte o Tarjeta '
              'Andina Migratoria, y solicitarlo en la DIAN del aeropuerto '
              'antes de viajar. Tope: ${formatCOP(maxRefund)} por solicitud. '
              'Verifica el trámite vigente en dian.gov.co.',
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF8A6D1D),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Desglose de gastos: presupuesto planeado del viaje (por categoría,
  /// pagos anticipados, hospedaje, emergencias) más los gastos reales
  /// de HU-13 agrupados por su propia categoría — cada monto se compara
  /// contra el presupuesto máximo del viaje.
  Widget _buildExpenseBreakdown() {
    final Map<String, double> gastosByCategory = {};
    for (final gasto in _gastos) {
      gastosByCategory[gasto.categoriaNombre] =
          (gastosByCategory[gasto.categoriaNombre] ?? 0) + gasto.monto;
    }

    final rows = <(String, double)>[
      ('Pagos Anticipados', trip.advancePayment),
      ('Hospedaje (planeado)', trip.lodgingCost),
      for (final categoria in trip.categories)
        (categoria.nombre, categoria.monto),
      ('Emergencias', trip.emergencyMoney),
      ...gastosByCategory.entries.map((e) => ('${e.key} (real)', e.value)),
    ].where((e) => e.$2 > 0).toList();

    if (rows.isEmpty) {
      return const Text(
        'No hay gastos registrados aún.',
        style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final row in rows) _buildSimpleExpenseRow(row.$1, row.$2),
      ],
    );
  }

  Widget _buildSimpleExpenseRow(String label, double amount) {
    final percentage = trip.maxBudget > 0
        ? (amount / trip.maxBudget) * 100
        : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              Text(
                '${formatCOP(amount)} (${percentage.toStringAsFixed(1)}%)',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A5F7A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: const Color(0xFFE0EEF7),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF1A5F7A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Eliminar viaje',
            style: TextStyle(
              color: Color(0xFF1A5F7A),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '¿Estás seguro de que deseas eliminar el viaje "${trip.name}"? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFF1A5F7A)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Viaje eliminado'),
                    backgroundColor: Color(0xFFF44336),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
