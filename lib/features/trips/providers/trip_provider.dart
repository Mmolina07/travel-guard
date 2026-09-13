import 'package:flutter/material.dart';
import '../data/models/trip_model.dart';

class TripProvider with ChangeNotifier {
  Trip? _activeTrip;

  Trip? get activeTrip => _activeTrip;
  bool get hasActiveTrip => _activeTrip != null;

  void setActiveTrip(Trip trip) {
    if (_activeTrip?.id != trip.id) {
      _activeTrip = trip;
      notifyListeners(); // Notifica a los listeners/widgets que el viaje activo cambió
    }
  }

  void clearActiveTrip() {
    _activeTrip = null;
    notifyListeners();
  }
}