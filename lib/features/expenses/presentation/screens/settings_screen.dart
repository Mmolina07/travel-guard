import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes y Configuración'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Notificaciones y Alertas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: SwitchListTile(
              title: const Text('Mostrar alertas de presupuesto'),
              subtitle: const Text(
                'Recibir notificaciones cuando alcances el 75%, 100% o recordatorios diarios.',
              ),
              secondary: Icon(
                expenseProvider.notificationsEnabled
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                color: expenseProvider.notificationsEnabled
                    ? Colors.blue
                    : Colors.grey,
              ),
              value: expenseProvider.notificationsEnabled,
              onChanged: (bool value) {
                expenseProvider.toggleNotifications(value);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'Alertas de presupuesto activadas'
                          : 'Alertas de presupuesto silenciadas',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}