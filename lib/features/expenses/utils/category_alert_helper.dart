import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/notifications/app_notice_center.dart';
import '../../core/settings/currency_provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/notification_prefs_provider.dart';
import 'category_budget_calculator.dart';

/// Dispara la alerta visual cuando se alcanza el 50%, 75% o 100% del límite de la categoría (HU-19)
void checkAndNotifyCategoryBudget(
  BuildContext context, {
  required int tripId,
  required String tripName,
  required String categoriaNombre,
  required CategoryBudgetStatus status,
}) {
  final prefs = context.read<NotificationPrefsProvider>();
  if (!prefs.alertsEnabled) return;

  final level = status.level;
  if (level == CategoryBudgetLevel.ok) return;

  final pct = status.porcentaje.round();
  final (AppNoticeTone tone, IconData icon, String title, String message) = switch (level) {
    CategoryBudgetLevel.exceeded100 => (
        AppNoticeTone.danger,
        Icons.error_outline_rounded,
        '¡Límite de categoría excedido!',
        'Has gastado el $pct% del límite en "$categoriaNombre" para el viaje "$tripName".',
      ),
    CategoryBudgetLevel.warning75 => (
        AppNoticeTone.nearLimit,
        Icons.warning_amber_rounded,
        'Alerta de presupuesto (75%)',
        'Has alcanzado el 75% del límite establecido en "$categoriaNombre".',
      ),
    CategoryBudgetLevel.warning50 => (
        AppNoticeTone.warning,
        Icons.info_outline,
        'Aviso de presupuesto (50%)',
        'Has consumido la mitad ($pct%) del presupuesto para "$categoriaNombre".',
      ),
    _ => (AppNoticeTone.info, Icons.notifications, '', ''),
  };

  final notice = AppNotice(
    key: 'category_limit_${tripId}_$categoriaNombre',
    tone: tone,
    icon: icon,
    title: title,
    message: message,
    route: '/viajes/$tripId',
  );

  context.read<AppNoticeCenter>().push(notice);
}