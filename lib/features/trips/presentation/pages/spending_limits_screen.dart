import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/settings/currency_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../expenses/data/models/categoria_gasto_model.dart';
import '../../../../shell/app_shell.dart';
import '../../../../shell/shell_page.dart';
import '../../../../widgets/ink_button.dart';
import '../../../../widgets/ink_header.dart';
import '../../data/limits_repository.dart';
import 'trip_model.dart';

class SpendingLimitsScreen extends StatefulWidget {
  final int tripId;
  final String tripName;
  final List<CategoriaGasto> categorias;
  final Map<int, double> initialLimits;
  final Map<int, double> spentByCategory;

  /// Viaje del resumen de presupuesto del sidebar (escritorio).
  final Trip? trip;

  const SpendingLimitsScreen({
    super.key,
    this.trip,
    required this.tripId,
    required this.tripName,
    required this.categorias,
    required this.initialLimits,
    required this.spentByCategory,
  });

  @override
  State<SpendingLimitsScreen> createState() => _SpendingLimitsScreenState();
}

class _SpendingLimitsScreenState extends State<SpendingLimitsScreen> {
  final LimitsRepository _repository = LimitsRepository();
  late final Map<int, TextEditingController> _controllers;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final c in widget.categorias)
        c.id: TextEditingController(
          text: (widget.initialLimits[c.id] ?? 0) > 0
              ? widget.initialLimits[c.id]!.round().toString()
              : '',
        ),
    };
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final limits = <int, double>{};
    for (final c in widget.categorias) {
      final value = double.tryParse(_controllers[c.id]!.text.trim());
      if (value != null && value > 0) limits[c.id] = value;
    }
    setState(() => _saving = true);
    try {
      await _repository.saveLimits(widget.tripId, limits);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.limitsSavedSnackbar), backgroundColor: AppColors.ink),
      );
      Navigator.pop(context, limits);
    } catch (e, st) {
      debugPrint('SpendingLimitsScreen._save error: $e\n$st');
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.limitsSaveError), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ShellPage(
      section: AppSection.misViajes,
      activeTrip: widget.trip,
      header: (asCard) => InkHeader(
        eyebrow: '${l.limitsTripLabel} · ${widget.tripName}',
        title: l.limitsHeaderTitle,
        titleAccent: l.limitsHeaderAccent,
        subtitle: l.limitsScreenSubtitle,
        asCard: asCard,
        onBack: () => Navigator.maybePop(context),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card + 2),
          boxShadow: AppShadow.card,
        ),
        child: Column(
          children: [
            for (var i = 0; i < widget.categorias.length; i++) ...[
              _row(widget.categorias[i]),
              if (i != widget.categorias.length - 1) const Divider(height: 1, color: AppColors.line),
            ],
          ],
        ),
      ),
      action: InkButton(
        label: l.limitsSaveButton,
        loading: _saving,
        expand: true,
        trailingArrow: true,
        onPressed: _saving ? null : _save,
      ),
    );
  }

  Widget _row(CategoriaGasto c) {
    final spent = widget.spentByCategory[c.id] ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: c.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(c.icon, size: 20, color: c.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.nombre, style: AppText.ui(14, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  context.l10n.limitsSpentSoFar(context.formatMoney(spent)).toUpperCase(),
                  style: AppText.label(10, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 150,
            child: TextField(
              controller: _controllers[c.id],
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.right,
              style: AppText.ui(15, weight: FontWeight.w600),
              decoration: InputDecoration(
                prefixText: r'$ ',
                hintText: context.l10n.limitsFieldHint,
                hintStyle: AppText.ui(13, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.paperDeep,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.dateField),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.dateField),
                  borderSide: const BorderSide(color: AppColors.ink, width: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}