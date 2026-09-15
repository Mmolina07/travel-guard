import 'package:geolocator/geolocator.dart';

/// Resultado de intentar obtener la ubicación del turista (HU-07,
/// TG-145/146/147/155): distingue los tres motivos por los que puede
/// fallar para que la UI muestre el mensaje/acción correcta en cada caso.
enum LocationFailureReason { serviceDisabled, permissionDenied, permissionDeniedForever }

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

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    return LocationResult.success(position);
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
