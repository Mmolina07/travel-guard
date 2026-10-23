import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/settings/currency_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/pocket_models.dart';
import '../../data/models/pocket_repository.dart';
import '../../../../core/widgets/underline_field.dart';
import '../../../../shell/app_shell.dart';
import '../../../../shell/shell_page.dart';
import '../../../../widgets/ink_button.dart';
import '../../../../widgets/ink_header.dart';
import '../../../../widgets/load_error_box.dart';
import 'trip_model.dart';

class PersonalPocketScreen extends StatefulWidget {
  final int tripId;
  final String tripName;
  final int userId;

  /// Viaje del resumen de presupuesto del sidebar (escritorio).
  final Trip? trip;

  const PersonalPocketScreen({
    super.key,
    this.trip,
    required this.tripId,
    required this.tripName,
    required this.userId,
  });

  @override
  State<PersonalPocketScreen> createState() => _PersonalPocketScreenState();
}

class _PersonalPocketScreenState extends State<PersonalPocketScreen> {
  final PocketRepository _repository = PocketRepository();
  PocketSummary? _pocket;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final pocket = await _repository.fetchMyPocket(
        tripId: widget.tripId,
        userId: widget.userId,
      );
      if (!mounted) return;
      setState(() {
        _pocket = pocket;
        _isLoading = false;
      });
    } catch (e, st) {
      debugPrint('PersonalPocketScreen._load error: $e\n$st');
      if (!mounted) return;
      setState(() {
        _error = context.l10n.pocketLoadError;
        _isLoading = false;
      });
    }
  }

  void _showSnack(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.ink,
      ),
    );
  }

  Future<void> _createPocket() async {
    try {
      await _repository.createPocket(tripId: widget.tripId, userId: widget.userId);
      await _load();
      if (!mounted) return;
      _showSnack(context.l10n.pocketCreatedSnackbar, isError: false);
    } catch (e, st) {
      debugPrint('PersonalPocketScreen._createPocket error: $e\n$st');
      if (!mounted) return;
      _showSnack(context.l10n.pocketSaveError);
    }
  }

  Future<void> _addMoney() async {
    final pocket = _pocket;
    if (pocket == null) return;
    final result = await showDialog<({double monto, String? nota})>(
      context: context,
      builder: (_) => const _AddMoneyDialog(),
    );
    if (result == null || !mounted) return;
    try {
      await _repository.addDeposit(
        pocketId: pocket.id,
        monto: result.monto,
        nota: result.nota,
      );
      await _load();
      if (!mounted) return;
      _showSnack(
        context.l10n.pocketDepositAddedSnackbar(context.formatMoney(result.monto)),
        isError: false,
      );
    } catch (e, st) {
      debugPrint('PersonalPocketScreen._addMoney error: $e\n$st');
      if (!mounted) return;
      _showSnack(context.l10n.pocketSaveError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final pocket = _pocket;
    return ShellPage(
      section: AppSection.misViajes,
      activeTrip: widget.trip,
      header: (asCard) => InkHeader(
        eyebrow: widget.tripName,
        title: l.pocketHeaderTitle,
        titleAccent: l.pocketHeaderAccent,
        subtitle: l.pocketPrivateNote,
        asCard: asCard,
        onBack: () => Navigator.maybePop(context),
        bottom: pocket == null ? null : _balance(pocket),
      ),
      body: _buildBody(),
      action: pocket == null
          ? null
          : InkButton(
              label: l.pocketAddMoneyButton,
              icon: Icons.add,
              expand: true,
              onPressed: _addMoney,
            ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Center(child: CircularProgressIndicator(color: AppColors.ink)),
      );
    }
    if (_error != null) {
      return LoadErrorBox(message: _error!, onRetry: _load);
    }
    final pocket = _pocket;
    return pocket == null ? _buildEmptyCard() : _movements(pocket);
  }

  /// Estado vacío del sistema: tarjeta `wash` con título display y CTA.
  Widget _buildEmptyCard() {
    final l = context.l10n;
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.wash,
        borderRadius: BorderRadius.circular(AppRadius.card + 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.pocketEmptyTitle, style: AppText.display(30)),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(l.pocketEmptyDescription, style: AppText.ui(14, color: AppColors.textMuted)),
          ),
          const SizedBox(height: 22),
          InkButton(label: l.pocketCreateButton, icon: Icons.add, onPressed: _createPocket),
        ],
      ),
    );
  }

  /// Cifras del bolsillo dentro de la cabecera `ink`.
  Widget _balance(PocketSummary pocket) {
    final l = context.l10n;
    Widget stat(String label, double value) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: AppText.label(10, color: AppColors.textOnInk)),
            const SizedBox(height: 4),
            Text(context.formatMoney(value), style: AppText.ui(16, weight: FontWeight.w600, color: AppColors.paper)),
          ],
        );
    return Wrap(
      spacing: 34,
      runSpacing: 14,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.pocketBalanceLabel.toUpperCase(), style: AppText.label(10, color: AppColors.mint)),
            const SizedBox(height: 4),
            Text(context.formatMoney(pocket.balance), style: AppText.display(44, color: AppColors.paper)),
          ],
        ),
        stat(l.pocketAddedLabel, pocket.added),
        stat(l.pocketSpentLabel, pocket.spent),
      ],
    );
  }

  Widget _movements(PocketSummary pocket) {
    final l = context.l10n;
    return Container(
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
            children: [
              Expanded(child: Text(l.pocketMovementsTitle, style: AppText.display(26))),
              Text('${pocket.deposits.length}', style: AppText.label(11, color: AppColors.inkSoft)),
            ],
          ),
          const SizedBox(height: 12),
          if (pocket.deposits.isEmpty)
            Text(l.pocketNoMovements, style: AppText.ui(13, color: AppColors.textMuted))
          else
            for (var i = 0; i < pocket.deposits.length; i++) ...[
              _depositRow(pocket.deposits[i]),
              if (i != pocket.deposits.length - 1) const Divider(height: 1, color: AppColors.line),
            ],
        ],
      ),
    );
  }

  Widget _depositRow(PocketDeposit d) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.wash,
              borderRadius: BorderRadius.circular(AppRadius.control),
            ),
            child: const Icon(Icons.add, size: 18, color: AppColors.inkSoft),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (d.nota != null && d.nota!.isNotEmpty) ? d.nota! : context.l10n.pocketAddMoneyButton,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.ui(14, weight: FontWeight.w600),
                ),
                Text(
                  DateFormat('d MMM · HH:mm', Localizations.localeOf(context).toString())
                      .format(d.createdAt.toLocal())
                      .toUpperCase(),
                  style: AppText.label(10),
                ),
              ],
            ),
          ),
          Text('+${context.formatMoney(d.monto)}',
              style: AppText.ui(14, weight: FontWeight.w700, color: AppColors.inkSoft)),
        ],
      ),
    );
  }
}

/// Diálogo para agregar dinero: monto + nota opcional.
class _AddMoneyDialog extends StatefulWidget {
  const _AddMoneyDialog();

  @override
  State<_AddMoneyDialog> createState() => _AddMoneyDialogState();
}

class _AddMoneyDialogState extends State<_AddMoneyDialog> {
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _note = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = double.tryParse(_amount.text.trim().replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      setState(() => _error = context.l10n.addExpenseInvalidAmount);
      return;
    }
    final note = _note.text.trim();
    Navigator.pop(context, (monto: amount, nota: note.isEmpty ? null : note));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(34)),
      titlePadding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
      contentPadding: const EdgeInsets.fromLTRB(28, 18, 28, 8),
      actionsPadding: const EdgeInsets.fromLTRB(28, 12, 28, 26),
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '${l.pocketHeaderTitle}\n', style: AppText.display(30)),
            TextSpan(text: l.pocketAddMoneyTitle, style: AppText.displayItalic(30)),
          ],
        ),
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UnderlineField(
              label: l.pocketAmountLabel,
              hint: '0',
              controller: _amount,
              autofocus: true,
              emphasized: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onFieldSubmitted: (_) => _submit(),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(_error!, style: AppText.ui(12, color: AppColors.error)),
              ),
            const SizedBox(height: 18),
            UnderlineField(
              label: l.pocketNoteLabel,
              hint: l.pocketNoteHint,
              controller: _note,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
      actions: [
        InkButton(
          label: l.tripDetailCancelButton,
          variant: InkButtonVariant.secondary,
          onPressed: () => Navigator.pop(context),
        ),
        InkButton(label: l.pocketAddConfirmButton, onPressed: _submit),
      ],
    );
  }
}
