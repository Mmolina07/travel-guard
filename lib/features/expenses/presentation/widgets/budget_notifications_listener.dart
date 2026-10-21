import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/notifications/app_notice_center.dart';
import '../../../../core/notifications/browser_notifications.dart';
import '../../../../core/settings/currency_provider.dart';
import '../../../subscriptions/providers/subscription_provider.dart';
import '../../../trips/presentation/pages/trip_model.dart';
import '../../providers/budget_alerts_provider.dart';
import '../../providers/notification_prefs_provider.dart';
import '../../utils/daily_budget_calculator.dart';
import '../../utils/reminder_planner.dart';

/// HU-11: convierte en notificaciones (dentro de la app y, si se
/// activó, del navegador) los umbrales del presupuesto de hoy que acaba
/// de cruzar un viaje (CA1/CA2/CA7, `pendingAlerts`) y los recordatorios
/// (CA5/CA6/CA8/CA9, `pendingReminders`). Solo para Premium (HU-24) y
/// si "Mostrar alertas" está activo (CA4).
class BudgetNotificationsListener extends StatefulWidget {
  const BudgetNotificationsListener({super.key, required this.child});

  final Widget child;

  @override
  State<BudgetNotificationsListener> createState() => _BudgetNotificationsListenerState();
}

class _BudgetNotificationsListenerState extends State<BudgetNotificationsListener> {
  BudgetAlertsProvider? _alerts;
  SubscriptionProvider? _subscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final alerts = context.read<BudgetAlertsProvider>();
    final subscription = context.read<SubscriptionProvider>();
    if (alerts != _alerts) {
      _alerts?.removeListener(_onChange);
      _alerts = alerts..addListener(_onChange);
    }
    if (subscription != _subscription) {
      _subscription?.removeListener(_onChange);
      _subscription = subscription..addListener(_onChange);
    }
  }

  @override
  void dispose() {
    _alerts?.removeListener(_onChange);
    _subscription?.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    final alerts = _alerts;
    final subscription = _subscription;
    if (alerts == null || subscription == null) return;
    if (alerts.pendingAlerts.isEmpty && alerts.pendingReminders.isEmpty) return;
    // Mientras no se sepa si es Premium, se esperan (no se descartan).
    if (subscription.isLoading) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _show());
  }

  void _show() {
    final alerts = _alerts;
    if (!mounted || alerts == null) return;
    final pending = alerts.pendingAlerts;
    final reminders = alerts.pendingReminders;
    if (pending.isEmpty && reminders.isEmpty) return;
    alerts.consumeAlerts();
    alerts.consumeReminders(reminders);

    final enabled = context.read<NotificationPrefsProvider>().alertsEnabled;
    if (!enabled || !(_subscription?.isPremium ?? false)) return;

    for (final alert in pending) {
      showAppNotice(context, buildBudgetNotice(context, alert.trip, alert.today));
    }
    for (final reminder in reminders) {
      showAppNotice(context, buildReminderNotice(context, reminder));
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Muestra [notice] dentro de la app y, si el turista activó las
/// notificaciones del navegador (y dio el permiso), también como
/// notificación del sistema.
void showAppNotice(BuildContext context, AppNotice notice) {
  final center = context.read<AppNoticeCenter>();
  center.push(notice);
  if (context.read<NotificationPrefsProvider>().browserNotifications) {
    BrowserNotifications.show(
      title: notice.title,
      body: notice.message,
      tag: notice.key,
      onClick: () => center.open(notice),
    );
  }
}

/// Aviso del presupuesto de un día (HU-11): amarillo desde el 75% (CA1),
/// el monto que queda al 85% (CA7) y rojo al llegar al límite (CA2).
AppNotice buildBudgetNotice(BuildContext context, Trip trip, DailyBudgetStatus day) {
  final l10n = context.l10n;
  final now = DateTime.now();
  final isToday = day.date.year == now.year && day.date.month == now.month && day.date.day == now.day;
  final dayLabel = isToday
      ? l10n.budgetNoticeToday
      : l10n.budgetNoticeOnDate(DateFormat.MMMd(Localizations.localeOf(context).toString()).format(day.date));
  final pct = day.percentage.round();
  final remaining = context.formatMoney(day.remaining < 0 ? 0 : day.remaining);

  final (tone, icon, title, message) = switch (day.level) {
    DailyBudgetLevel.exceeded => (
        AppNoticeTone.danger,
        Icons.error_outline_rounded,
        l10n.budgetNoticeExceededTitle,
        l10n.budgetNoticeExceededMessage(
          trip.name,
          pct,
          context.formatMoney(day.spent),
          context.formatMoney(day.dailyBudget),
          dayLabel,
        ),
      ),
    DailyBudgetLevel.nearLimit => (
        AppNoticeTone.nearLimit,
        Icons.savings_outlined,
        l10n.budgetNoticeNearLimitTitle(remaining, dayLabel),
        l10n.budgetNoticeNearLimitMessage(trip.name, pct, dayLabel),
      ),
    _ => (
        AppNoticeTone.warning,
        Icons.warning_amber_rounded,
        l10n.budgetNoticeWarningTitle(pct),
        l10n.budgetNoticeWarningMessage(trip.name, remaining, dayLabel),
      ),
  };
  return AppNotice(
    key: 'budget_${trip.id}',
    tone: tone,
    icon: icon,
    title: title,
    message: message,
    route: '/viajes/${trip.id}',
    routeExtra: trip,
    actionLabel: l10n.budgetNoticeOpenTrip,
  );
}

/// Justo después de registrar un gasto: si el día quedó en 75% o más,
/// avisa con el % alcanzado (cada vez que se registra, para la fecha que
/// sea). Premium (HU-24) y solo con "Mostrar alertas" activo (CA4).
void notifyExpenseBudget(BuildContext context, {required Trip trip, required DailyBudgetStatus day}) {
  if (day.level == DailyBudgetLevel.ok) return;
  if (!context.read<SubscriptionProvider>().isPremium) return;
  if (!context.read<NotificationPrefsProvider>().alertsEnabled) return;
  showAppNotice(context, buildBudgetNotice(context, trip, day));
  context.read<BudgetAlertsProvider>().markNotified(trip.id, day.date, day.level);
}

/// Recordatorios de HU-11 (CA5, CA6, CA8, CA9) como notificación.
AppNotice buildReminderNotice(BuildContext context, BudgetReminder r) {
  final l10n = context.l10n;
  final trip = r.trip;
  final locale = Localizations.localeOf(context).toString();
  final (IconData icon, String title, String message, String action) = switch (r.kind) {
    ReminderKind.noExpenses => (
        Icons.edit_note_rounded,
        l10n.reminderNoExpensesTitle,
        r.endOfDay
            ? l10n.reminderNoExpensesEndOfDay(trip.name)
            : l10n.reminderNoExpensesMessage(trip.name, r.hoursWithoutExpenses ?? 0),
        l10n.reminderRegisterExpense,
      ),
    ReminderKind.dailySummary => (
        Icons.receipt_long_outlined,
        l10n.reminderDailySummaryTitle(
          context.formatMoney(r.day!.spent),
          context.formatMoney(r.day!.remaining < 0 ? 0 : r.day!.remaining),
        ),
        l10n.reminderDailySummaryMessage(trip.name),
        l10n.budgetNoticeOpenTrip,
      ),
    ReminderKind.dayClosing => (
        Icons.nightlight_outlined,
        r.day!.remaining >= 0
            ? l10n.reminderDayClosingTitle(
                r.tripDayNumber ?? 1,
                context.formatMoney(r.day!.dailyBudget),
                context.formatMoney(r.day!.spent),
                context.formatMoney(r.day!.remaining),
              )
            : l10n.reminderDayClosingOverTitle(
                r.tripDayNumber ?? 1,
                context.formatMoney(r.day!.dailyBudget),
                context.formatMoney(r.day!.spent),
                context.formatMoney(-r.day!.remaining),
              ),
        l10n.reminderDayClosingMessage(trip.name, DateFormat.MMMd(locale).format(r.day!.date)),
        l10n.budgetNoticeOpenTrip,
      ),
    ReminderKind.upcomingTrip => (
        Icons.flight_takeoff_rounded,
        l10n.reminderUpcomingTripTitle(trip.destination, r.daysUntil ?? 1),
        l10n.reminderUpcomingTripMessage,
        l10n.reminderReviewBudget,
      ),
  };
  return AppNotice(
    // Un recordatorio de registro por viaje en pantalla: el nuevo
    // reemplaza al anterior.
    key: r.kind == ReminderKind.noExpenses ? 'nudge_${trip.id}' : 'reminder_${r.key}',
    tone: AppNoticeTone.info,
    icon: icon,
    title: title,
    message: message,
    route: '/viajes/${trip.id}',
    routeExtra: trip,
    actionLabel: action,
  );
}
