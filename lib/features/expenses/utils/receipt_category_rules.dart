import 'receipt_parser.dart' show removeAccents;

/// Sugerencia de categoría para un recibo por palabras clave, sin IA.
///
/// Las llaves son los nombres de `categorias_gasto` (ver schema.sql). Para
/// ampliar: agrega palabras en minúscula y sin tildes a la lista de la
/// categoría; se comparan como palabras completas.
abstract final class ReceiptCategoryRules {
  static const Map<String, List<String>> keywords = {
    'Comida': [
      'restaurante', 'restaurant', 'cafe', 'cafeteria', 'panaderia', 'pasteleria',
      'pizzeria', 'pizza', 'hamburguesa', 'burger', 'asadero', 'parrilla', 'pollo',
      'sushi', 'heladeria', 'helado', 'comida', 'comidas', 'food', 'bar', 'gastrobar',
      'almuerzo', 'desayuno', 'cena', 'menu', 'bebida', 'gaseosa', 'cerveza',
      'frisby', 'mcdonalds', 'kfc', 'subway', 'crepes', 'juan valdez', 'starbucks',
      'tostao', 'oma', 'el corral', 'presto',
    ],
    'Compras': [
      'supermercado', 'supermercados', 'minimercado', 'tienda', 'almacen', 'almacenes',
      'mercado', 'drogueria', 'farmacia', 'boutique', 'souvenir', 'souvenirs',
      'artesanias', 'artesania', 'exito', 'carulla', 'olimpica', 'd1', 'ara', 'jumbo',
      'makro', 'metro supermercado', 'falabella', 'centro comercial', 'libreria',
    ],
    'Hospedaje': [
      'hotel', 'hostal', 'hostel', 'airbnb', 'alojamiento', 'hospedaje', 'posada',
      'motel', 'glamping', 'apartahotel', 'booking',
    ],
    'Actividades': [
      'museo', 'cine', 'cinema', 'cinemas', 'cinecolombia', 'procinal', 'cinemark',
      'teatro', 'concierto', 'tour', 'tours', 'entrada', 'boleta', 'boleteria',
      'discoteca', 'parque', 'zoologico', 'acuario', 'teleferico', 'excursion',
      'spa', 'gimnasio',
    ],
    'Movilidad': [
      'taxi', 'taxis', 'uber', 'didi', 'cabify', 'indriver', 'bus', 'buses', 'metro', 'peaje',
      'gasolina', 'combustible', 'estacion de servicio', 'terpel', 'primax', 'texaco',
      'parqueadero', 'parking', 'transporte', 'aerolinea', 'vuelo', 'avianca',
      'latam', 'wingo', 'terminal',
    ],
  };

  /// Categoría con más coincidencias (las del nombre del establecimiento
  /// pesan triple), o `null` si ninguna palabra coincide.
  static String? suggest(String text, {String? establishment}) {
    final body = removeAccents(text.toLowerCase());
    final name = removeAccents((establishment ?? '').toLowerCase());
    String? best;
    var bestScore = 0;
    keywords.forEach((category, words) {
      var score = 0;
      for (final w in words) {
        final re = RegExp('(^|[^a-z0-9])${RegExp.escape(w)}(\$|[^a-z0-9])');
        if (re.hasMatch(name)) score += 3;
        if (re.hasMatch(body)) score += 1;
      }
      if (score > bestScore) {
        best = category;
        bestScore = score;
      }
    });
    return best;
  }
}
