import 'package:flutter/foundation.dart';

import '../data/models/comuna_geo.dart';
import '../data/models/seguridad_stats.dart';
import '../data/security_repository.dart';

/// Capa de incidencia delictiva del mapa de turista: polígonos, índice por
/// comuna y fuente. Los datos históricos no cambian mientras la app está
/// abierta, así que se piden una sola vez y quedan en memoria; volver al
/// mapa no repite las consultas.
class SecurityMapProvider extends ChangeNotifier {
  SecurityMapProvider({SecurityRepository? repository})
      : _repository = repository ?? SecurityRepository();

  final SecurityRepository _repository;

  bool _capaVisible = false;
  bool _isLoading = false;
  bool _loadFailed = false;
  Future<void>? _inFlight;

  SeguridadMetadatos? _metadatos;
  List<ComunaGeo> _comunas = const [];
  Map<String, ComunaIndice> _indices = const {};

  /// Para las consultas a demanda de la ficha de una comuna.
  SecurityRepository get repository => _repository;

  bool get capaVisible => _capaVisible;
  bool get isLoading => _isLoading;
  bool get loadFailed => _loadFailed;
  bool get hasLoaded => _metadatos != null;

  /// `null` hasta cargar; [SeguridadMetadatos.hayDatos] es `false` si aún
  /// no se ha corrido el importador.
  SeguridadMetadatos? get metadatos => _metadatos;
  List<ComunaGeo> get comunas => _comunas;
  ComunaIndice? indiceDe(String codigo) => _indices[codigo];

  /// Mostrar/ocultar la capa. La primera vez que se muestra, carga.
  void setCapaVisible(bool visible) {
    if (visible == _capaVisible) return;
    _capaVisible = visible;
    notifyListeners();
    if (visible) ensureLoaded();
  }

  Future<void> ensureLoaded() {
    if (hasLoaded) return Future.value();
    return _inFlight ??= _load().whenComplete(() => _inFlight = null);
  }

  Future<void> retry() {
    _loadFailed = false;
    return ensureLoaded();
  }

  Future<void> _load() async {
    _isLoading = true;
    _loadFailed = false;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.fetchMetadatos(),
        _repository.fetchComunasGeo(),
        _repository.fetchIndiceComunas(),
      ]);
      final metadatos = results[0] as SeguridadMetadatos?;
      if (metadatos == null) {
        throw StateError('seguridad_config no tiene fila');
      }
      _metadatos = metadatos;
      _comunas = results[1] as List<ComunaGeo>;
      _indices = {
        for (final i in results[2] as List<ComunaIndice>) i.codigo: i,
      };
    } catch (e, st) {
      debugPrint('SecurityMapProvider._load error: $e\n$st');
      _loadFailed = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
