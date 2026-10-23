import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/models/comuna_geo.dart';
import '../providers/security_map_provider.dart';
import 'incidencia_style.dart';

/// Guarda el último juego de polígonos: el mapa se reconstruye con cada
/// actualización del GPS y rehacer los miles de puntos de las 21 comunas
/// cada vez no hace falta si la capa no cambió.
class ComunaPolygonsCache {
  Object? _clave;
  Set<Polygon> _polygons = const {};

  Set<Polygon> get(
    SecurityMapProvider provider, {
    required ValueChanged<ComunaGeo> onTap,
    String? seleccionada,
  }) {
    // `List ==` es identidad: la clave cambia solo si el provider recargó.
    final clave = (
      provider.capaVisible,
      provider.comunas,
      provider.metadatos,
      seleccionada,
    );
    if (clave == _clave) return _polygons;
    _clave = clave;
    return _polygons = buildComunaPolygons(
      provider,
      onTap: onTap,
      seleccionada: seleccionada,
    );
  }
}

/// Polígonos de la capa de incidencia: un color por nivel del índice. Las
/// comunas sin índice (o sin geometría importada) no se dibujan.
Set<Polygon> buildComunaPolygons(
  SecurityMapProvider provider, {
  required ValueChanged<ComunaGeo> onTap,
  String? seleccionada,
}) {
  if (!provider.capaVisible || !provider.hasLoaded) return const {};
  final polygons = <Polygon>{};
  for (final comuna in provider.comunas) {
    final indice = provider.indiceDe(comuna.codigo);
    if (indice == null) continue;
    final color = indice.nivel.color;
    final activa = comuna.codigo == seleccionada;
    for (var i = 0; i < comuna.poligonos.length; i++) {
      final p = comuna.poligonos[i];
      if (p.exterior.length < 3) continue;
      polygons.add(
        Polygon(
          polygonId: PolygonId('comuna_${comuna.codigo}_$i'),
          points: [for (final pt in p.exterior) LatLng(pt.lat, pt.lng)],
          holes: [
            for (final h in p.huecos) [for (final pt in h) LatLng(pt.lat, pt.lng)],
          ],
          fillColor: color.withValues(alpha: activa ? 0.5 : 0.32),
          strokeColor: activa ? Colors.white : color.withValues(alpha: 0.9),
          strokeWidth: activa ? 3 : 1,
          consumeTapEvents: true,
          onTap: () => onTap(comuna),
        ),
      );
    }
  }
  return polygons;
}
