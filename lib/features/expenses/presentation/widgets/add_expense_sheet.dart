import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/settings/currency_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/categoria_gasto_model.dart';
import '../../utils/daily_budget_calculator.dart';

/// Resultado de [AddExpenseSheet]: datos ya validados, listos para
/// persistir en `gastos` (HU-13).
class NewExpenseData {
  final CategoriaGasto categoria;
  final double monto;
  final DateTime fecha;
  final String? descripcion;

  const NewExpenseData({
    required this.categoria,
    required this.monto,
    required this.fecha,
    this.descripcion,
  });
}

/// Formulario para registrar un gasto manual (HU-13), con categorías
/// reales (traídas de `categorias_gasto`, no una lista fija) y fecha
/// seleccionable (por defecto hoy).
class AddExpenseSheet extends StatefulWidget {
  final List<CategoriaGasto> categorias;
  final DateTime tripStartDate;
  final DateTime tripEndDate;

  /// HU-11 (TG-278): si viene, el formulario advierte en vivo cuando el
  /// monto haría pasar el presupuesto diario de la fecha elegida, y
  /// pide confirmación antes de registrarlo.
  final DailyBudgetCalculator? dailyBudget;

  const AddExpenseSheet({
    super.key,
    required this.categorias,
    required this.tripStartDate,
    required this.tripEndDate,
    this.dailyBudget,
  });

  static Future<NewExpenseData?> show(
    BuildContext context, {
    required List<CategoriaGasto> categorias,
    required DateTime tripStartDate,
    required DateTime tripEndDate,
    DailyBudgetCalculator? dailyBudget,
  }) {
    return showModalBottomSheet<NewExpenseData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddExpenseSheet(
        categorias: categorias,
        tripStartDate: tripStartDate,
        tripEndDate: tripEndDate,
        dailyBudget: dailyBudget,
      ),
    );
  }

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  static const Color _primary = Color(0xFF1A5F7A);

  late CategoriaGasto _selectedCategoria;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late DateTime _fecha;

  @override
  void initState() {
    super.initState();
    _selectedCategoria = widget.categorias.first;
    final today = DateTime.now();
    // Si "hoy" cae fuera del rango del viaje (viaje pasado/futuro),
    // arranca en la fecha de inicio para que quede dentro del rango.
    _fecha = (today.isBefore(widget.tripStartDate) ||
            today.isAfter(widget.tripEndDate))
        ? widget.tripStartDate
        : today;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: widget.tripStartDate,
      lastDate: widget.tripEndDate,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  /// Cómo quedaría el día elegido con el monto escrito (TG-278); `null`
  /// si no hay calculadora o el monto todavía no es válido.
  DailyBudgetStatus? get _projectedDay {
    final calc = widget.dailyBudget;
    final amount = double.tryParse(_amountController.text.trim());
    if (calc == null || amount == null || amount <= 0) return null;
    return calc.statusFor(_fecha).withExtra(amount);
  }

  Future<bool> _confirmOverBudget(DailyBudgetStatus projected) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 32),
        title: Text(ctx.l10n.addExpenseOverBudgetDialogTitle),
        content: Text(
          ctx.l10n.addExpenseOverBudgetDialogContent(
            ctx.formatMoney(projected.dailyBudget),
            ctx.formatMoney(projected.remaining.abs()),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.l10n.configCancelButton),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ctx.l10n.addExpenseOverBudgetConfirm),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _handleSubmit() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.addExpenseInvalidAmount),
          backgroundColor: const Color(0xFFD32F2F),
        ),
      );
      return;
    }

    final projected = _projectedDay;
    if (projected != null && projected.level == DailyBudgetLevel.exceeded) {
      if (!await _confirmOverBudget(projected) || !mounted) return;
    }

    Navigator.pop(
      context,
      NewExpenseData(
        categoria: _selectedCategoria,
        monto: amount,
        fecha: _fecha,
        descripcion: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: _primary),
      filled: true,
      fillColor: const Color(0xFFF5FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD7E8EF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
    );
  }

  /// Advertencia visual en vivo (TG-278): ámbar desde el 75% del
  /// presupuesto del día, roja si este gasto lo supera.
  Widget _buildDailyBudgetWarning() {
    final projected = _projectedDay;
    final level = projected?.level ?? DailyBudgetLevel.ok;
    final Widget content;
    if (projected == null || level == DailyBudgetLevel.ok) {
      content = const SizedBox(width: double.infinity);
    } else {
      final exceeded = level == DailyBudgetLevel.exceeded;
      final accent = exceeded ? AppColors.error : AppColors.warning;
      content = Container(
        key: ValueKey(level),
        width: double.infinity,
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: exceeded ? AppColors.errorWash : AppColors.warningWash,
          borderRadius: BorderRadius.circular(AppRadius.control),
          border: Border.all(color: accent),
        ),
        child: Row(
          children: [
            Icon(
              exceeded ? Icons.error_outline_rounded : Icons.warning_amber_rounded,
              color: accent,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                exceeded
                    ? context.l10n.addExpenseExceedsDailyBudget(
                        context.formatMoney(projected.remaining.abs()),
                        context.formatMoney(projected.dailyBudget),
                      )
                    : context.l10n.addExpenseNearDailyBudget(
                        projected.percentage.round(),
                        context.formatMoney(projected.remaining),
                      ),
                style: AppText.ui(12.5, weight: FontWeight.w600, color: accent),
              ),
            ),
          ],
        ),
      );
    }
    return AnimatedSwitcher(duration: AppMotion.toggle, child: content);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.addExpenseTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.addExpenseSubtitle,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),

          DropdownButtonFormField<CategoriaGasto>(
            initialValue: _selectedCategoria,
            decoration: _fieldDecoration(
              label: context.l10n.addExpenseCategoryLabel,
              icon: Icons.category_outlined,
            ),
            items: widget.categorias
                .map((c) => DropdownMenuItem(
                      value: c,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(c.icon, size: 18, color: c.color),
                          const SizedBox(width: 8),
                          Text(c.nombre),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedCategoria = value);
            },
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            decoration: _fieldDecoration(
              label: context.l10n.addExpenseAmountLabel,
              icon: Icons.attach_money,
              hint: context.l10n.addExpenseAmountHint,
            ),
          ),
          _buildDailyBudgetWarning(),
          const SizedBox(height: 16),

          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _pickDate,
            child: InputDecorator(
              decoration: _fieldDecoration(
                label: context.l10n.addExpenseDateLabel,
                icon: Icons.calendar_today_outlined,
              ),
              child: Text(DateFormat('dd/MM/yyyy').format(_fecha)),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _descriptionController,
            maxLines: 2,
            decoration: _fieldDecoration(
              label: context.l10n.addExpenseDescriptionLabel,
              icon: Icons.description_outlined,
              hint: context.l10n.addExpenseDescriptionHint,
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primary,
                    side: const BorderSide(color: _primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    context.l10n.configCancelButton,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    context.l10n.addExpenseAddButton,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
