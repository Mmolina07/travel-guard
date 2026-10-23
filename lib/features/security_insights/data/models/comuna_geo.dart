/// Un punto del polígono de una comuna (EPSG:4326).
typedef GeoPunto = ({double lat, double lng});

/// Un polígono simple: contorno exterior y, si los hay, huecos.
class ComunaPoligono {
  final List<GeoPunto> exterior;
  final List<List<GeoPunto>> huecos;

  const ComunaPoligono({required this.exterior, this.huecos = const []});
}

/// Comuna o corregimiento de Medellín con su geometría, tal como la deja el
/// importador en `seguridad_comunas.geometria` (GeoJSON de la capa
/// LimiteComunaCorregimiento de la Alcaldía).
class ComunaGeo {
  /// '01'…'16' comunas, '50'…'90' corregimientos.
  final String codigo;
  final String nombre;
  final bool esCorregimiento;
  final List<ComunaPoligono> poligonos;

  const ComunaGeo({
    required this.codigo,
    required this.nombre,
    required this.esCorregimiento,
    required this.poligonos,
  });

  factory ComunaGeo.fromRow(Map<String, dynamic> row) {
    return ComunaGeo(
      codigo: row['codigo'] as String,
      nombre: row['nombre'] as String,
      esCorregimiento: row['tipo'] == 'corregimiento',
      poligonos: _parseGeometria(row['geometria'] as Map<String, dynamic>?),
    );
  }

  /// Polygon → un polígono; MultiPolygon → varios. Si todavía no se ha
  /// importado la geometría (NULL) la comuna queda sin polígonos y
  /// simplemente no se dibuja.
  static List<ComunaPoligono> _parseGeometria(Map<String, dynamic>? geo) {
    if (geo == null) return const [];
    final coords = geo['coordinates'] as List?;
    if (coords == null) return const [];
    return switch (geo['type']) {
      'Polygon' => [_poligono(coords)],
      'MultiPolygon' => [for (final p in coords) _poligono(p as List)],
      _ => const [],
    };
  }

  static ComunaPoligono _poligono(List anillos) {
    final parsed = [for (final a in anillos) _anillo(a as List)];
    return ComunaPoligono(
      exterior: parsed.isEmpty ? const [] : parsed.first,
      huecos: parsed.length > 1 ? parsed.sublist(1) : const [],
    );
  }

  // GeoJSON guarda [lng, lat].
  static List<GeoPunto> _anillo(List puntos) => [
        for (final p in puntos)
          (lat: (p[1] as num).toDouble(), lng: (p[0] as num).toDouble()),
      ];
}
