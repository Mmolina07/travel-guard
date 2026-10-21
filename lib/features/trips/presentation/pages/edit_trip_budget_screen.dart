import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/settings/currency_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../widgets/over_budget_dialog.dart';
import '../../../auth/providers/app_auth_provider.dart';
import '../../data/trip_repository.dart';
import '../../utils/budget_calculator.dart';
import '../widgets/category_field_row.dart';
import 'trip_model.dart';
import '../../../../widgets/ink_button.dart';
import '../../../../widgets/paper_top_bar.dart';

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

  late final TextEditingController _maxBudgetController;
  late final TextEditingController _advancePaymentController;
  late final TextEditingController _lodgingCostController;
  late final TextEditingController _emergencyMoneyController;
  final List<CategoryFieldRow> _categoryRows = [];

  final TripRepository _tripRepository = TripRepository();
  bool _isSaving = false;

  /// Montos con punto de miles (`1.500.000`), igual que al crear el
  /// viaje: antes `1.500` se leía como 1,5.
  static final List<TextInputFormatter> _moneyFormatters = [
    ThousandsInputFormatter(),
  ];

  @override
  void initState() {
    super.initState();
    final trip = widget.trip;
    _maxBudgetController = TextEditingController(
      text: groupThousands(trip.maxBudget.round()),
    );
    _advancePaymentController = TextEditingController(
      text: trip.advancePayment > 0
          ? groupThousands(trip.advancePayment.round())
          : '',
    );
    _lodgingCostController = TextEditingController(
      text: trip.lodgingCost > 0 ? groupThousands(trip.lodgingCost.round()) : '',
    );
    _emergencyMoneyController = TextEditingController(
      text: trip.emergencyMoney > 0
          ? groupThousands(trip.emergencyMoney.round())
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

  static double _amount(TextEditingController c) => (parseThousands(c.text) ?? 0).toDouble();
  double get _maxBudget => _amount(_maxBudgetController);
  double get _advancePayment => _amount(_advancePaymentController);
  double get _lodgingCost => _amount(_lodgingCostController);
  double get _emergencyMoney => _amount(_emergencyMoneyController);
  double get _categoriesTotal =>
      _categoryRows.fold(0.0, (sum, row) => sum + row.monto);
  double get _estimatedSpent =>
      _advancePayment + _lodgingCost + _categoriesTotal + _emergencyMoney;

  Future<void> _save() async {
    if (_maxBudget <= 0) {
      _showError(context.l10n.editTripBudgetErrorMaxBudgetPositive);
      return;
    }
    if (_advancePayment > _maxBudget) {
      _showError(context.l10n.valAdvanceOverBudget);
      return;
    }
    for (final row in _categoryRows) {
      final error = Validators.title(context, row.nombreController.text, isRequired: false, max: 80);
      if (error != null) {
        _showError('${context.l10n.editTripBudgetCategoryLabel}: $error');
        return;
      }
    }
    if (_estimatedSpent > _maxBudget) {
      final confirmed = await confirmOverBudget(context, _estimatedSpent - _maxBudget);
      if (!confirmed || !mounted) return;
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

    final editorUsuarioId = context.read<AppAuthProvider>().usuario?.id;
    if (editorUsuarioId == null) {
      setState(() => _isSaving = false);
      _showError(context.l10n.editTripBudgetErrorMustBeLoggedIn);
      return;
    }

    try {
      final saved = await _tripRepository.updateTripBudget(
        previous: widget.trip,
        trip: updatedDraft,
        editorUsuarioId: editorUsuarioId,
      );
      if (!mounted) return;
      Navigator.pop(context, saved);
    } catch (e) {
      if (!mounted) return;
      _showError(context.l10n.editTripBudgetErrorSaveGeneric);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<CurrencyProvider>();
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
      backgroundColor: AppColors.paper,
      appBar: PaperTopBar(
        eyebrow: context.l10n.editTripBudgetTitle,
        onBack: () => Navigator.maybePop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.trip.name, style: AppText.display(34)),
            Text(widget.trip.destination, style: AppText.displayItalic(34)),
            const SizedBox(height: 24),

            _field(
              controller: _maxBudgetController,
              label: context.l10n.editTripBudgetMaxBudgetLabel,
              icon: Icons.account_balance_wallet_outlined,
            ),
            const SizedBox(height: 16),
            _field(
              controller: _advancePaymentController,
              label: context.l10n.editTripBudgetAdvancePaymentLabel,
              icon: Icons.credit_card,
            ),
            const SizedBox(height: 16),
            _field(
              controller: _lodgingCostController,
              label: context.l10n.editTripBudgetLodgingCostLabel,
              icon: Icons.hotel_outlined,
            ),
            const SizedBox(height: 16),
            _field(
              controller: _emergencyMoneyController,
              label: context.l10n.editTripBudgetEmergencyMoneyLabel,
              icon: Icons.health_and_safety_outlined,
            ),
            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.l10n.editTripBudgetCategoriesTitle, style: AppText.display(22)),
                TextButton.icon(
                  onPressed: _addCategoryRow,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(context.l10n.editTripBudgetAddButton),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final row in _categoryRows) ...[
              _categoryRow(row),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                boxShadow: AppShadow.card,
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _summaryRow(context.l10n.editTripBudgetEstimatedLabel, context.formatMoney(_estimatedSpent)),
                    const SizedBox(height: 6),
                    _summaryRow(
                      overBudget ? context.l10n.editTripBudgetOverBudgetLabel : context.l10n.editTripBudgetAvailableLabel,
                      context.formatMoney(remaining.abs()),
                      valueColor: overBudget
                          ? AppColors.error
                          : AppColors.inkSoft,
                    ),
                    if (breakdown != null) ...[
                      const Divider(height: 24, color: AppColors.line),
                      Row(
                        children: [
                          Expanded(
                            child: _stat(
                              context.l10n.editTripBudgetPerDayLabel(breakdown.days),
                              context.formatMoney(breakdown.perDay),
                            ),
                          ),
                          Expanded(
                            child: _stat(
                              context.l10n.editTripBudgetPerPersonLabel(widget.trip.persons),
                              context.formatMoney(breakdown.perPerson),
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

            InkButton(
              label: context.l10n.editTripBudgetSaveButton,
              onPressed: _save,
              loading: _isSaving,
              trailingArrow: true,
              expand: true,
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
        Text(label, style: AppText.ui(14, color: AppColors.textMuted)),
        Text(value, style: AppText.ui(14, weight: FontWeight.w700, color: valueColor ?? AppColors.ink)),
      ],
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppText.display(22)),
        Text(label, style: AppText.label(10), textAlign: TextAlign.center),
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
      keyboardType: TextInputType.number,
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
            inputFormatters: [AppInputFormatters.safeText, AppInputFormatters.maxLength(80)],
            decoration: InputDecoration(labelText: context.l10n.editTripBudgetCategoryLabel),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 4,
          child: TextField(
            controller: row.montoController,
            keyboardType: TextInputType.number,
            inputFormatters: _moneyFormatters,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(labelText: context.l10n.editTripBudgetAmountLabel),
          ),
        ),
        IconButton(
          onPressed: _categoryRows.length > 1
              ? () => _removeCategoryRow(row)
              : null,
          icon: const Icon(Icons.delete_outline),
          color: AppColors.error,
          tooltip: context.l10n.editTripBudgetRemoveCategoryTooltip,
        ),
      ],
    );
  }
}
