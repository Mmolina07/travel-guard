import 'package:flutter/material.dart';

class ExpenseAlertView extends StatelessWidget {
  const ExpenseAlertView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.amber.shade700),
      ),
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Alerta de Presupuesto Diario",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text("Has alcanzado el límite o estás cerca de tu presupuesto diario."),
        ],
      ),
    );
  }
}