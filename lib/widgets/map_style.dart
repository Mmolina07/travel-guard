/// Estilo oscuro personalizado (JSON de Google Maps) recoloreado hacia
/// la paleta ink/petróleo — geometría en tonos ink/inkSoft, agua casi
/// negra, POIs en mint. Compartido por [MapPanel] y la pantalla de
/// mapa (`MapScreen`) para que cualquier Google Map de la app se vea
/// igual, en vez del skin genérico de Google.
const String mapInkStyle = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#0f2d30"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#0b3438"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#9db3b0"}]},
  {"featureType": "administrative", "elementType": "geometry", "stylers": [{"color": "#4c6461"}]},
  {"featureType": "poi", "elementType": "geometry", "stylers": [{"color": "#1c3a3d"}]},
  {"featureType": "poi", "elementType": "labels.text.fill", "stylers": [{"color": "#7fd1b9"}]},
  {"featureType": "poi.park", "elementType": "geometry", "stylers": [{"color": "#1c7a6b"}]},
  {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#1a4145"}]},
  {"featureType": "road", "elementType": "geometry.stroke", "stylers": [{"color": "#0b3438"}]},
  {"featureType": "road", "elementType": "labels.text.fill", "stylers": [{"color": "#8a8272"}]},
  {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#234f52"}]},
  {"featureType": "road.highway", "elementType": "geometry.stroke", "stylers": [{"color": "#0b3438"}]},
  {"featureType": "transit", "elementType": "geometry", "stylers": [{"color": "#1a4145"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#082226"}]},
  {"featureType": "water", "elementType": "labels.text.fill", "stylers": [{"color": "#4c6461"}]}
]
''';
