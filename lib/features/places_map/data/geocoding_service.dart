import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

/// Geocodificación de direcciones (HU-02 + HU-07): convierte el texto
/// que el comercio escribe en "Dirección" a coordenadas reales, para
/// que el mapa de ubicación pueda centrarse ahí solo, sin que el
/// usuario tenga que buscar manualmente el punto exacto.
///
/// Usa Nominatim (OpenStreetMap) en vez de la Geocoding API de Google:
/// es gratis, no requiere API key, y funciona directo desde el
/// navegador (CORS habilitado) — la Geocoding API de Google, en
/// cambio, rechaza llamadas desde el cliente con una key restringida
/// por dominio (la misma que usa `google_maps_flutter` en este
/// proyecto), porque está pensada para uso desde servidor.
class GeocodingService {
  GeocodingService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _baseUrl = 'https://nominatim.openstreetmap.org/search';

  /// Retorna la primera coincidencia para [address], o `null` si no se
  /// encontró nada o falló la consulta. `countrycodes=co` acota la
  /// búsqueda a Colombia para evitar resultados de otros países con
  /// nombres de calle parecidos.
  Future<LatLng?> geocodeAddress(String address) async {
    final query = address.trim();
    if (query.isEmpty) return null;

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'q': query,
      'format': 'json',
      'limit': '1',
      'countrycodes': 'co',
    });

    try {
      final response = await _client.get(
        uri,
        // Nominatim exige un User-Agent identificable (política de uso
        // del servicio público); sin esto puede rechazar la solicitud.
        headers: const {'User-Agent': 'TravelGuardApp/1.0'},
      );
      if (response.statusCode != 200) return null;

      final results = jsonDecode(response.body) as List<dynamic>;
      if (results.isEmpty) return null;

      final first = results.first as Map<String, dynamic>;
      final lat = double.tryParse(first['lat'] as String? ?? '');
      final lon = double.tryParse(first['lon'] as String? ?? '');
      if (lat == null || lon == null) return null;

      return LatLng(lat, lon);
    } catch (_) {
      return null;
    }
  }
}
