import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/providers/app_auth_provider.dart';
import '../../../places_map/presentation/widgets/comercio_ui.dart';
import '../../../trips/data/trip_repository.dart';
import '../../../trips/presentation/pages/trip_model.dart';
import '../../utils/daily_budget_calculator.dart';
import '../../utils/reminder_planner.dart';
import 'budget_notifications_listener.dart';

/// "Probar notificaciones" (Configuración): muestra al instante cada
/// aviso de HU-11 con un viaje real del turista, sin esperar a que se
/// cumpla su condición (75/85/100 % del día, 4 h sin gastos, 11 PM,
/// 11:59 PM, 3 días antes del viaje). Sirve para pruebas y demos: no
/// guarda nada ni cambia el estado de los avisos reales. Sale también
/// como notificación del navegador si esa opción está activa.
class NotificationsDemoPanel extends StatefulWidget {
  const NotificationsDemoPanel({super.key});

  @override
  State<NotificationsDemoPanel> createState() => _NotificationsDemoPanelState();
}

enum _Demo { warning, nearLimit, exceeded, noExpenses, summary, closing, upcoming }

class _NotificationsDemoPanelState extends State<NotificationsDemoPanel> {
  Trip? _trip;
  bool _loading = false;

  /// El viaje más reciente del turista (los avisos llevan su nombre y
  /// el botón "Ver viaje" abre de verdad ese viaje).
  Future<Trip?> _demoTrip() async {
    if (_trip != null) return _trip;
    final id = context.read<AppAuthProvider>().usuario?.id;
    if (id == null) return null;
    setState(() => _loading = true);
    try {
      final trips = await TripRepository().fetchTripsByTurista(id);
      _trip = trips.isEmpty ? null : trips.first;
    } catch (e) {
      debugPrint('NotificationsDemoPanel error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
    return _trip;
  }

  Future<void> _fire(_Demo demo) async {
    final messenger = ScaffoldMessenger.of(context);
    final noTrip = context.l10n.configDemoNoTrip;
    final trip = await _demoTrip();
    if (!mounted) return;
    if (trip == null) {
      messenger.showSnackBar(SnackBar(content: Text(noTrip)));
      return;
    }
    final now = DateTime.now();
    // Presupuesto de ejemplo para el día: lo que da el viaje repartido
    // entre sus días, o $100.000 si no se puede calcular.
    final daily = trip.maxBudget > 0 ? (trip.maxBudget / 5).roundToDouble() : 100000.0;
    DailyBudgetStatus day(double pct) =>
        DailyBudgetStatus(date: now, dailyBudget: daily, spent: (daily * pct).roundToDouble());

    final notice = switch (demo) {
      _Demo.warning => buildBudgetNotice(context, trip, day(0.76)),
      _Demo.nearLimit => buildBudgetNotice(context, trip, day(0.86)),
      _Demo.exceeded => buildBudgetNotice(context, trip, day(1.08)),
      _Demo.noExpenses => buildReminderNotice(
          context,
          BudgetReminder(kind: ReminderKind.noExpenses, key: 'demo_nudge', trip: trip, hoursWithoutExpenses: 4),
        ),
      _Demo.summary => buildReminderNotice(
          context,
          BudgetReminder(kind: ReminderKind.dailySummary, key: 'demo_summary', trip: trip, day: day(0.6)),
        ),
      _Demo.closing => buildReminderNotice(
          context,
          BudgetReminder(
            kind: ReminderKind.dayClosing,
            key: 'demo_closing',
            trip: trip,
            day: day(0.9),
            tripDayNumber: 2,
          ),
        ),
      _Demo.upcoming => buildReminderNotice(
          context,
          BudgetReminder(kind: ReminderKind.upcomingTrip, key: 'demo_upcoming', trip: trip, daysUntil: 3),
        ),
    };
    showAppNotice(context, notice);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final buttons = [
      (_Demo.warning, l10n.configDemoWarning),
      (_Demo.nearLimit, l10n.configDemoNearLimit),
      (_Demo.exceeded, l10n.configDemoExceeded),
      (_Demo.noExpenses, l10n.configDemoNoExpenses),
      (_Demo.summary, l10n.configDemoSummary),
      (_Demo.closing, l10n.configDemoClosing),
      (_Demo.upcoming, l10n.configDemoUpcoming),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.line),
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science_outlined, size: 18, color: AppColors.inkSoft),
              const SizedBox(width: 8),
              Expanded(child: Text(l10n.configDemoTitle, style: AppText.ui(15, weight: FontWeight.w600))),
              if (_loading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(l10n.configDemoSubtitle, style: AppText.ui(12, color: AppColors.textMuted)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (demo, label) in buttons)
                SmallInkButton(
                  label: label,
                  outlined: true,
                  onTap: _loading ? null : () => _fire(demo),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
