import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../trips/presentation/pages/trip_model.dart';
import '../../providers/budget_alerts_provider.dart';

/// TG-279: muestra el recordatorio de las 11:00 PM ("¿tuviste gastos
/// hoy que no registraste?") encima de cualquier pantalla. Vive en el
/// `builder` de `MaterialApp.router`, por encima del `Navigator`, así
/// que abre el diálogo con el contexto del navegador de [router].
class ExpenseReminderListener extends StatefulWidget {
  const ExpenseReminderListener({super.key, required this.router, required this.child});

  final GoRouter router;
  final Widget child;

  @override
  State<ExpenseReminderListener> createState() => _ExpenseReminderListenerState();
}

class _ExpenseReminderListenerState extends State<ExpenseReminderListener> {
  BudgetAlertsProvider? _provider;
  bool _showing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<BudgetAlertsProvider>();
    if (provider != _provider) {
      _provider?.removeListener(_onChange);
      _provider = provider..addListener(_onChange);
    }
  }

  @override
  void dispose() {
    _provider?.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    final trips = _provider?.pendingReminder ?? const [];
    if (trips.isEmpty || _showing) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _show());
  }

  Future<void> _show() async {
    final provider = _provider;
    final navContext = widget.router.routerDelegate.navigatorKey.currentContext;
    if (provider == null || navContext == null || _showing) return;
    final trips = provider.pendingReminder;
    if (trips.isEmpty) return;

    _showing = true;
    final l10n = navContext.l10n;
    final target = await showDialog<Trip>(
      context: navContext,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.notifications_active_outlined, color: AppColors.inkSoft, size: 32),
        title: Text(l10n.expenseReminderTitle, style: AppText.display(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.expenseReminderMessage, style: AppText.ui(14, color: AppColors.textMuted)),
            const SizedBox(height: 12),
            for (final trip in trips)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.luggage_outlined, color: AppColors.ink),
                title: Text(trip.name, style: AppText.ui(14, weight: FontWeight.w600)),
                subtitle: Text(trip.destination, style: AppText.ui(12, color: AppColors.textMuted)),
                trailing: const Icon(Icons.chevron_right, color: AppColors.inkSoft),
                onTap: () => Navigator.pop(ctx, trip),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.expenseReminderDismiss),
          ),
        ],
      ),
    );
    _showing = false;
    provider.dismissReminder();
    if (target != null) widget.router.go('/viajes/${target.id}', extra: target);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
