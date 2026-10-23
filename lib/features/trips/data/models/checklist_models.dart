import 'package:flutter/material.dart';

/// Categoría de un pendiente (HU-26) — `viaje_pendientes.categoria`.
/// El orden del enum es el orden en que se muestran los grupos.
enum ChecklistCategory {
  documentos(Icons.badge_outlined),
  dinero(Icons.payments_outlined),
  equipaje(Icons.luggage_outlined),
  salud(Icons.medical_services_outlined),
  tecnologia(Icons.power_outlined),
  reservas(Icons.confirmation_number_outlined),
  casa(Icons.home_outlined),
  otro(Icons.checklist_rounded);

  const ChecklistCategory(this.icon);

  final IconData icon;

  static ChecklistCategory fromDb(String? value) =>
      ChecklistCategory.values.firstWhere((c) => c.name == value, orElse: () => ChecklistCategory.otro);
}

/// Un pendiente de la lista del viaje (fila de `viaje_pendientes`).
class ChecklistItem {
  final int id;
  final int tripId;
  final int userId;
  final String title;
  final ChecklistCategory category;
  final bool done;

  /// Clave de la sugerencia de la que salió (null = pendiente propio).
  final String? suggestionKey;

  /// Sugerencia descartada ("no aplica"): no se muestra en la lista.
  final bool dismissed;
  final DateTime? createdAt;

  const ChecklistItem({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.title,
    required this.category,
    this.done = false,
    this.suggestionKey,
    this.dismissed = false,
    this.createdAt,
  });

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      id: (map['id'] as num).toInt(),
      tripId: (map['viaje_id'] as num).toInt(),
      userId: (map['usuario_id'] as num).toInt(),
      title: map['titulo'] as String,
      category: ChecklistCategory.fromDb(map['categoria'] as String?),
      done: map['completado'] as bool? ?? false,
      suggestionKey: map['sugerencia_clave'] as String?,
      dismissed: map['descartado'] as bool? ?? false,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
    );
  }

  ChecklistItem copyWith({String? title, ChecklistCategory? category, bool? done}) {
    return ChecklistItem(
      id: id,
      tripId: tripId,
      userId: userId,
      title: title ?? this.title,
      category: category ?? this.category,
      done: done ?? this.done,
      suggestionKey: suggestionKey,
      dismissed: dismissed,
      createdAt: createdAt,
    );
  }
}

/// Pendiente que la app sugiere según el viaje (HU-26). El texto se
/// traduce en la UI a partir de [key] (`checklistSuggestionTitle`).
class ChecklistSuggestion {
  final String key;
  final ChecklistCategory category;

  const ChecklistSuggestion(this.key, this.category);
}
