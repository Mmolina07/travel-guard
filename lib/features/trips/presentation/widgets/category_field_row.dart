import 'package:flutter/material.dart';

import '../../data/models/trip_budget_category.dart';

/// Fila editable de categoría de presupuesto (nombre + monto +
/// vínculo opcional a una categoría de gasto real), usada tanto al
/// crear un viaje (`CreateTripScreen`) como al editar su presupuesto
/// después (`EditTripBudgetScreen`) — reemplaza los 5 campos fijos que
/// había antes (Tours/Restaurantes/Discotecas/Souvenirs/Actividades
/// pagas), que no se podían renombrar ni quitar.
class CategoryFieldRow {
  CategoryFieldRow({
    String nombre = '',
    String monto = '',
    this.categoriaGastoId,
  })  : nombreController = TextEditingController(text: nombre),
        montoController = TextEditingController(text: monto);

  factory CategoryFieldRow.fromCategory(TripBudgetCategory category) {
    return CategoryFieldRow(
      nombre: category.nombre,
      monto: category.monto > 0 ? category.monto.toStringAsFixed(0) : '',
      categoriaGastoId: category.categoriaGastoId,
    );
  }

  final TextEditingController nombreController;
  final TextEditingController montoController;

  /// Vínculo opcional a `categorias_gasto` (HU-13): sin esto, el
  /// desglose no sabría qué gastos reales le corresponden a esta
  /// categoría planeada (los nombres son libres, no coinciden por
  /// texto con la lista fija de categorías de gasto).
  int? categoriaGastoId;

  double get monto => double.tryParse(montoController.text.trim()) ?? 0;

  TripBudgetCategory? toCategory() {
    final nombre = nombreController.text.trim();
    if (nombre.isEmpty) return null;
    return TripBudgetCategory(
      nombre: nombre,
      monto: monto,
      categoriaGastoId: categoriaGastoId,
    );
  }

  void dispose() {
    nombreController.dispose();
    montoController.dispose();
  }
}
