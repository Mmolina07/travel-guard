import 'package:flutter/material.dart';
import '../data/models/trip_model.dart'; // Ajusta el import según la ruta de tu modelo

class TripProvider with ChangeNotifier {
  Trip? _activeTrip;

  // Obtener el viaje activo actual
  Trip? get activeTrip => _activeTrip;

  // Saber si hay un viaje seleccionado
  bool get hasActiveTrip => _activeTrip != null;

  // Guardar/Seleccionar viaje activo
  void setActiveTrip(Trip trip) {
    _activeTrip = trip;
    notifyListeners(); // Notifica a todas las pantallas para redibujar la UI
  }

  // Limpiar el viaje activo (por ejemplo, al cerrar sesión)
  void clearActiveTrip() {
    _activeTrip = null;
    notifyListeners();
  }
}