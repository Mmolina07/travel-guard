import 'package:flutter/material.dart';

/// Categoría de la tabla `categorias_gasto` (HU-13).
class CategoriaGasto {
  final int id;
  final String nombre;

  const CategoriaGasto({required this.id, required this.nombre});

  factory CategoriaGasto.fromMap(Map<String, dynamic> map) {
    return CategoriaGasto(
      id: map['id'] as int,
      nombre: map['nombre'] as String,
    );
  }

  /// Ícono/color por categoría, para que el desglose y la lista de
  /// gastos se vean distintos según el tipo de gasto (no solo texto).
  IconData get icon {
    switch (nombre.trim().toLowerCase()) {
      case 'comida':
        return Icons.restaurant;
      case 'movilidad':
        return Icons.directions_car;
      case 'actividades':
        return Icons.local_activity;
      case 'compras':
        return Icons.shopping_bag;
      case 'hospedaje':
        return Icons.hotel;
      default:
        return Icons.category;
    }
  }

  Color get color {
    switch (nombre.trim().toLowerCase()) {
      case 'comida':
        return const Color(0xFFE67E22);
      case 'movilidad':
        return const Color(0xFF2980B9);
      case 'actividades':
        return const Color(0xFF9B59B6);
      case 'compras':
        return const Color(0xFF16A085);
      case 'hospedaje':
        return const Color(0xFF8E44AD);
      default:
        return const Color(0xFF1A5F7A);
    }
  }
}
