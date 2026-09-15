import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../data/trip_repository.dart';
import '../../utils/budget_calculator.dart';
import '../widgets/category_field_row.dart';
import 'trip_model.dart';

/// Mejora "gestor de presupuesto" (TG-166): antes el presupuesto de un
/// viaje solo se definía una vez, al crearlo — para cambiarlo había
/// que borrar el viaje y crear otro. Esta pantalla deja reajustar el
/// presupuesto máximo, los pagos anticipados, el hospedaje, el dinero
/// de emergencias y las categorías de gasto en cualquier momento.
class EditTripBudgetScreen extends StatefulWidget {
  final Trip trip;

  const EditTripBudgetScreen({super.key, required this.trip});

  @override
  State<EditTripBudgetScreen> createState() => _EditTripBudgetScreenState();
}

class _EditTripBudgetScreenState extends State<EditTripBudgetScreen> {
  static const Color _primary = Color(0xFF1A5F7A);

  late final TextEditingController _maxBudgetController;
  late final TextEditingController _advancePaymentController;
  late final TextEditingController _lodgingCostController;
  late final TextEditingController _emergencyMoneyController;
  final List<CategoryFieldRow> _categoryRows = [];

  final TripRepository _tripRepository = TripRepository();
  bool _isSaving = false;

  static final List<TextInputFormatter> _moneyFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
  ];

  @override
  void initState() {
    super.initState();
    final trip = widget.trip;
    _maxBudgetController = TextEditingController(
      text: trip.maxBudget.toStringAsFixed(0),
    );
    _advancePaymentController = TextEditingController(
      text: trip.advancePayment > 0
          ? trip.advancePayment.toStringAsFixed(0)
          : '',
    );
    _lodgingCostController = TextEditingController(
      text: trip.lodgingCost > 0 ? trip.lodgingCost.toStringAsFixed(0) : '',
    );
    _emergencyMoneyController = TextEditingController(
      text: trip.emergencyMoney > 0
          ? trip.emergencyMoney.toStringAsFixed(0)
          : '',
    );
    _categoryRows.addAll(
      trip.categories.isEmpty
          ? [CategoryFieldRow()]
          : trip.categories.map(CategoryFieldRow.fromCategory),
    );
  }

  @override
  void dispose() {
    _maxBudgetController.dispose();
    _advancePaymentController.dispose();
    _lodgingCostController.dispose();
    _emergencyMoneyController.dispose();
    for (final row in _categoryRows) {
      row.dispose();
    }
    super.dispose();
  }

  void _addCategoryRow() =>
      setState(() => _categoryRows.add(CategoryFieldRow()));

  void _removeCategoryRow(CategoryFieldRow row) {
    setState(() {
      _categoryRows.remove(row);
      row.dispose();
    });
  }

  double get _maxBudget =>
      double.tryParse(_maxBudgetController.text.trim()) ?? 0;
  double get _advancePayment =>
      double.tryParse(_advancePaymentController.text.trim()) ?? 0;
  double get _lodgingCost =>
      double.tryParse(_lodgingCostController.text.trim()) ?? 0;
  double get _emergencyMoney =>
      double.tryParse(_emergencyMoneyController.text.trim()) ?? 0;
  double get _categoriesTotal =>
      _categoryRows.fold(0.0, (sum, row) => sum + row.monto);
  double get _estimatedSpent =>
      _advancePayment + _lodgingCost + _categoriesTotal + _emergencyMoney;

  Future<void> _save() async {
    if (_maxBudget <= 0) {
      _showError('El presupuesto máximo debe ser mayor a 0');
      return;
    }
    setState(() => _isSaving = true);

    final updatedDraft = widget.trip.copyWith(
      maxBudget: _maxBudget,
      advancePayment: _advancePayment,
      lodgingCost: _lodgingCost,
      emergencyMoney: _emergencyMoney,
      categories: [
        for (final row in _categoryRows)
          if (row.toCategory() != null) row.toCategory()!,
      ],
    );

    try {
      final saved = await _tripRepository.updateTripBudget(trip: updatedDraft);
      if (!mounted) return;
      Navigator.pop(context, saved);
    } catch (e) {
      if (!mounted) return;
      _showError('No se pudo guardar el presupuesto. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFD32F2F),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _maxBudget - _estimatedSpent;
    final overBudget = remaining < 0;
    final breakdown = remaining > 0
        ? calculateBudgetBreakdown(
            maxBudget: remaining,
            start: parseDdMmYyyy(widget.trip.startDate),
            end: parseDdMmYyyy(widget.trip.endDate),
            persons: widget.trip.persons,
          )
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Editar presupuesto',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _primary,
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.trip.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.trip.destination,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),

            _field(
              controller: _maxBudgetController,
              label: 'Presupuesto máximo',
              icon: Icons.account_balance_wallet_outlined,
            ),
            const SizedBox(height: 16),
            _field(
              controller: _advancePaymentController,
              label: 'Pagos anticipados',
              icon: Icons.credit_card,
            ),
            const SizedBox(height: 16),
            _field(
              controller: _lodgingCostController,
              label: 'Costo hospedaje',
              icon: Icons.hotel_outlined,
            ),
            const SizedBox(height: 16),
            _field(
              controller: _emergencyMoneyController,
              label: 'Dinero emergencias',
              icon: Icons.health_and_safety_outlined,
            ),
            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categorías de gasto',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _primary,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addCategoryRow,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final row in _categoryRows) ...[
              _categoryRow(row),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _summaryRow('Estimado', formatCOP(_estimatedSpent)),
                    const SizedBox(height: 6),
                    _summaryRow(
                      overBudget ? 'Te excedes por' : 'Disponible',
                      formatCOP(remaining.abs()),
                      valueColor: overBudget
                          ? const Color(0xFFD32F2F)
                          : AppColors.accentLight,
                    ),
                    if (breakdown != null) ...[
                      const Divider(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _stat(
                              'Por día (${breakdown.days}d)',
                              formatCOP(breakdown.perDay),
                            ),
                          ),
                          Expanded(
                            child: _stat(
                              'Por persona (${widget.trip.persons})',
                              formatCOP(breakdown.perPerson),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(backgroundColor: _primary),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Guardar cambios',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Row(
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
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor ?? _primary,
          ),
        ),
      ],
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, color: _primary),
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

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: _moneyFormatters,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }

  Widget _categoryRow(CategoryFieldRow row) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: TextField(
            controller: row.nombreController,
            decoration: const InputDecoration(labelText: 'Categoría'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 4,
          child: TextField(
            controller: row.montoController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: _moneyFormatters,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Monto'),
          ),
        ),
        IconButton(
          onPressed: _categoryRows.length > 1
              ? () => _removeCategoryRow(row)
              : null,
          icon: const Icon(Icons.delete_outline),
          color: const Color(0xFFD32F2F),
          tooltip: 'Quitar categoría',
        ),
      ],
    );
  }
}
