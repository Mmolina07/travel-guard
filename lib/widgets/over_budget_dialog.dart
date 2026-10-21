import 'package:flutter/material.dart';

import '../core/l10n/l10n_extension.dart';
import '../core/settings/currency_provider.dart';
import '../core/theme/app_theme.dart';
import 'ink_button.dart';

/// "Lo planeado supera el presupuesto": avisa por cuánto y deja guardar
/// igual o volver a revisar. `true` = guardar igual.
Future<bool> confirmOverBudget(BuildContext context, double excess) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 32),
      title: Text(ctx.l10n.valOverBudgetTitle, style: AppText.display(24)),
      content: Text(
        ctx.l10n.valOverBudgetContent(ctx.formatMoney(excess)),
        style: AppText.ui(14, color: AppColors.textMuted),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
      actions: [
        InkButton(
          label: ctx.l10n.valOverBudgetCancel,
          variant: InkButtonVariant.secondary,
          onPressed: () => Navigator.pop(ctx, false),
        ),
        InkButton(
          label: ctx.l10n.valOverBudgetConfirm,
          onPressed: () => Navigator.pop(ctx, true),
        ),
      ],
    ),
  );
  return confirmed == true;
}
