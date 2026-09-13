import 'package:flutter/material.dart';

class TripDataLoader {
  // Carga dinámica de datos según el ID del viaje seleccionado
  static Future<void> cargarDatosDelViaje(BuildContext context, int viajeId) async {
    // 1. Cargar Gastos y Presupuesto del viaje seleccionado
    // Provider.of<ExpenseProvider>(context, listen: false).fetchGastosPorViaje(viajeId);

    // 2. Cargar Actividades/Lugares del viaje seleccionado
    // Provider.of<ActivityProvider>(context, listen: false).fetchActividadesPorViaje(viajeId);

    print('Cargando dinámicamente presupuesto, gastos y actividades para el viaje ID: $viajeId');
  }
}