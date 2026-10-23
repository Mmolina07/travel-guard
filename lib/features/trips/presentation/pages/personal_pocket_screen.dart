import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/settings/currency_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/pocket_models.dart';
import '../../data/models/pocket_repository.dart';

class PersonalPocketScreen extends StatefulWidget {
  final int tripId;
  final String tripName;
  final int userId;

  const PersonalPocketScreen({
    super.key,
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
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: Text(context.l10n.pocketScreenTitle,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.ink));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: AppText.ui(13, color: AppColors.error)),
            TextButton(onPressed: _load, child: Text(context.l10n.tripDetailRetryButton)),
          ],
        ),
      );
    }
    final pocket = _pocket;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(widget.tripName, style: AppText.display(26)),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.lock_outline, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 6),
            Expanded(
              child: Text(context.l10n.pocketPrivateNote,
                  style: AppText.ui(12, color: AppColors.textMuted)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (pocket == null) _buildEmptyCard() else ..._buildPocket(pocket),
      ],
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.account_balance_wallet_outlined, size: 32, color: AppColors.inkSoft),
          const SizedBox(height: 12),
          Text(context.l10n.pocketEmptyTitle, style: AppText.display(22)),
          const SizedBox(height: 6),
          Text(context.l10n.pocketEmptyDescription,
              style: AppText.ui(13, color: AppColors.textMuted)),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _createPocket,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.ink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            child: Text(context.l10n.pocketCreateButton),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPocket(PocketSummary pocket) {
    Widget stat(String label, double value) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppText.label(10, color: AppColors.textOnInk)),
              const SizedBox(height: 4),
              Text(context.formatMoney(value),
                  style: AppText.ui(16, weight: FontWeight.w600, color: AppColors.textOnInk)),
            ],
          ),
        );

    return [
      Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(AppRadius.cardLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.pocketBalanceLabel,
                style: AppText.label(10, color: AppColors.textOnInk)),
            const SizedBox(height: 4),
            Text(context.formatMoney(pocket.balance),
                style: AppText.display(44, color: AppColors.paper)),
            const SizedBox(height: 20),
            Row(
              children: [
                stat(context.l10n.pocketAddedLabel, pocket.added),
                stat(context.l10n.pocketSpentLabel, pocket.spent),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      ElevatedButton.icon(
        onPressed: _addMoney,
        icon: const Icon(Icons.add, size: 18),
        label: Text(context.l10n.pocketAddMoneyButton),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mint,
          foregroundColor: AppColors.ink,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.control)),
        ),
      ),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppShadow.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.pocketMovementsTitle, style: AppText.display(22)),
            const SizedBox(height: 12),
            if (pocket.deposits.isEmpty)
              Text(context.l10n.pocketNoMovements,
                  style: AppText.ui(13, color: AppColors.textMuted))
            else
              for (var i = 0; i < pocket.deposits.length; i++) ...[
                _depositRow(pocket.deposits[i]),
                if (i != pocket.deposits.length - 1)
                  const Divider(height: 1, color: AppColors.line),
              ],
          ],
        ),
      ),
    ];
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
              color: AppColors.mint.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_downward, size: 18, color: AppColors.ink),
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
                Text(DateFormat('dd/MM/yyyy HH:mm').format(d.createdAt.toLocal()),
                    style: AppText.label(10)),
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
    return AlertDialog(
      title: Text(context.l10n.pocketAddMoneyTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _amount,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: context.l10n.pocketAmountLabel,
              errorText: _error,
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            decoration: InputDecoration(
              labelText: context.l10n.pocketNoteLabel,
              hintText: context.l10n.pocketNoteHint,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.tripDetailCancelButton),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(context.l10n.pocketAddConfirmButton),
        ),
      ],
    );
  }
}