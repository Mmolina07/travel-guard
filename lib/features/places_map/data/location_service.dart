import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Resultado de intentar obtener la ubicación del turista (HU-07,
/// TG-145/146/147/155): distingue los motivos por los que puede fallar
/// para que la UI muestre el mensaje/acción correcta en cada caso.
///
/// [unavailable]: hay permiso pero el dispositivo no entregó una posición
/// a tiempo (p.ej. Chrome en Mac sin acceso a Localización en los ajustes
/// del sistema: la petición del navegador nunca responde).
enum LocationFailureReason {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  unavailable,
}

class LocationResult {
  final Position? position;
  final LocationFailureReason? failure;

  const LocationResult.success(Position position)
      : position = position,
        failure = null;

  const LocationResult.failure(LocationFailureReason reason)
      : position = null,
        failure = reason;

  bool get isSuccess => position != null;
}

class LocationService {
  /// Verifica que el GPS/servicio de ubicación esté encendido, pide el
  /// permiso si falta, y devuelve la posición actual del turista.
  Future<LocationResult> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationResult.failure(
        LocationFailureReason.serviceDisabled,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return const LocationResult.failure(
        LocationFailureReason.permissionDenied,
      );
    }
    if (permission == LocationPermission.deniedForever) {
      return const LocationResult.failure(
        LocationFailureReason.permissionDeniedForever,
      );
    }

    try {
      final position = await _firstFix();
      return position == null
          ? const LocationResult.failure(LocationFailureReason.unavailable)
          : LocationResult.success(position);
    } on PermissionDeniedException {
      return const LocationResult.failure(
        LocationFailureReason.permissionDenied,
      );
    } on LocationServiceDisabledException {
      return const LocationResult.failure(
        LocationFailureReason.serviceDisabled,
      );
    }
  }

  /// Sin `timeLimit` la petición de alta precisión puede no responder
  /// nunca (en el navegador sobre todo) y el mapa se quedaba cargando.
  /// Se intenta precisa, luego aproximada (WiFi/red, más rápida), y en
  /// móvil la última posición conocida.
  Future<Position?> _firstFix() async {
    for (final (accuracy, limit) in const [
      (LocationAccuracy.high, Duration(seconds: 10)),
      (LocationAccuracy.low, Duration(seconds: 10)),
    ]) {
      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: accuracy,
            timeLimit: limit,
          ),
        );
      } on PermissionDeniedException {
        rethrow;
      } on LocationServiceDisabledException {
        rethrow;
      } catch (e) {
        // TimeoutException o posición no disponible: siguiente intento.
        debugPrint('LocationService: sin posición ($accuracy): $e');
      }
    }
    if (kIsWeb) return null; // el navegador no tiene "última conocida".
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      debugPrint('LocationService.getLastKnownPosition error: $e');
      return null;
    }
  }

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  /// Ubicación del turista en tiempo real: emite una nueva posición cada
  /// vez que el dispositivo se mueve lo suficiente (no es una sola foto
  /// como [getCurrentPosition]). Se asume que el permiso ya se concedió
  /// (llamar después de un [getCurrentPosition] exitoso).
  Stream<Position> watchPosition() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // metros: evita actualizar por micro-ruido GPS.
      ),
    );
  }
}
