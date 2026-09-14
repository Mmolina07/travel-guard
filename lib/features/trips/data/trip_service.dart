import 'http' as http;

class TripService {
  static const String baseUrl = 'http://localhost:8080/viajes'; // Ajustar la URL de tu backend

  static Future<bool> archivarViaje(int viajeId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$viajeId/archivar'),
    );

    return response.statusCode == 200;
  }
}