import 'package:flutter/material.dart';

class ExpenseAlertView extends StatelessWidget {
  final double spentPercentage;
  final double remainingBudget;
  final bool hasNoExpensesToday;
  final bool notificationsEnabled; // Propiedad añadida

  const ExpenseAlertView({
    super.key,
    required this.spentPercentage,
    required this.remainingBudget,
    required this.notificationsEnabled,
    this.hasNoExpensesToday = false,
  });

  @override
  Widget build(BuildContext context) {
    // Si el usuario desactivó las notificaciones en ajustes, no se muestra ninguna alerta
    if (!notificationsEnabled) {
      return const SizedBox.shrink();
    }

    if (spentPercentage < 75 && !hasNoExpensesToday) {
      return const SizedBox.shrink();
    }

    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData icon;
    String title;
    String message;

    if (hasNoExpensesToday) {
      backgroundColor = Colors.blue.shade50;
      borderColor = Colors.blue.shade700;
      textColor = Colors.blue.shade900;
      icon = Icons.notifications_active_rounded;
      title = "Recordatorio de Gastos";
      message = "¿Tuviste gastos hoy que no hayas registrado? Recuerda mantener tu presupuesto al día.";
    } else if (spentPercentage >= 100) {
      backgroundColor = Colors.red.shade50;
      borderColor = Colors.red.shade700;
      textColor = Colors.red.shade900;
      icon = Icons.error_outline_rounded;
      title = "¡Límite Alcanzado!";
      message = "Has alcanzado o superado tu presupuesto diario. Saldo disponible: \$${remainingBudget.toStringAsFixed(0)} COP.";
    } else {
      backgroundColor = Colors.amber.shade50;
      borderColor = Colors.amber.shade700;
      textColor = Colors.amber.shade900;
      icon = Icons.warning_amber_rounded;
      title = "Advertencia de Presupuesto";
      message = "Has gastado el ${spentPercentage.toStringAsFixed(0)}% de tu presupuesto diario. Te quedan \$${remainingBudget.toStringAsFixed(0)} COP.";
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: borderColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(fontSize: 14, color: textColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}