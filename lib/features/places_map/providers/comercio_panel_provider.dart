import 'package:flutter/foundation.dart';

import '../../auth/data/comercio_repository.dart';
import '../../auth/data/models/comercio_model.dart';
import '../../auth/providers/app_auth_provider.dart';
import '../data/menus_repository.dart';
import '../data/models/actividad_model.dart';
import '../data/places_map_repository.dart';
import '../presentation/menu_model.dart';

/// Filtro de estado de la vista "Actividades" del comercio.
enum ActividadFiltro { todas, borrador, publicada, pausada }

/// Datos del panel del comercio (perfil, menús y actividades) compartidos
/// entre `/comercio`, `/comercio/actividades` y `/comercio/menu` — antes
/// vivían en el `State` de `HomeScreenComercio` y cada vista los habría
/// tenido que volver a pedir. Las llamadas a Supabase son las mismas que
/// hacía esa pantalla; aquí solo se centralizan.
class ComercioPanelProvider extends ChangeNotifier {
  ComercioPanelProvider({
    ComercioRepository? comercioRepository,
    MenusRepository? menusRepository,
    PlacesMapRepository? placesMapRepository,
  }) : _comercioRepository = comercioRepository ?? ComercioRepository(),
       _menusRepository = menusRepository ?? MenusRepository(),
       _placesMapRepository = placesMapRepository ?? PlacesMapRepository();

  final ComercioRepository _comercioRepository;
  final MenusRepository _menusRepository;
  final PlacesMapRepository _placesMapRepository;

  int? _comercioId;
  int? _loadedFor;
  Future<bool>? _inFlight;

  bool _isLoading = false;
  bool _loadFailed = false;
  ComercioModel? _comercio;
  List<Menu> _menus = [];
  List<Actividad> _actividades = [];
  ActividadFiltro _filtro = ActividadFiltro.todas;
  ActividadFiltro _filtroPromos = ActividadFiltro.todas;
  String _busqueda = '';
  bool _disposed = false;

  bool get isLoading => _isLoading;
  bool get loadFailed => _loadFailed;

  /// Ya hay datos del comercio actual (aunque estén vacíos). Mientras sea
  /// `false` y no haya fallado, las vistas muestran "cargando" en vez del
  /// estado vacío.
  bool get hasLoaded => _comercioId != null && _loadedFor == _comercioId;
  ComercioModel? get comercio => _comercio;
  List<Menu> get menus => List.unmodifiable(_menus);

  /// Todo lo publicado por el comercio (actividades y promociones), más
  /// recientes primero (la nueva queda primera).
  List<Actividad> get actividades => List.unmodifiable(_actividades);

  /// Solo actividades (sin promociones): vista "Actividades".
  List<Actividad> get soloActividades =>
      _actividades.where((a) => !a.esPromocion).toList();

  /// Solo promociones (exclusivas Premium): vista "Promociones".
  List<Actividad> get promociones => _actividades.where((a) => a.esPromocion).toList();

  ActividadFiltro get filtro => _filtro;

  /// Filtro de estado de la vista de actividades o de la de promociones.
  ActividadFiltro filtroDe({required bool promociones}) =>
      promociones ? _filtroPromos : _filtro;

  void setFiltroDe(ActividadFiltro filtro, {required bool promociones}) {
    if (promociones) {
      if (filtro == _filtroPromos) return;
      _filtroPromos = filtro;
    } else {
      if (filtro == _filtro) return;
      _filtro = filtro;
    }
    notifyListeners();
  }

  /// Texto del buscador del topbar ("Buscar actividades o platos").
  String get busqueda => _busqueda;
  bool get buscando => _normalizar(_busqueda).isNotEmpty;

  void setBusqueda(String value) {
    if (value == _busqueda) return;
    _busqueda = value;
    notifyListeners();
  }

  /// Sin distinguir mayúsculas ni tildes ("cafe" encuentra "Café").
  static String _normalizar(String text) {
    const from = 'áàäâãéèëêíìïîóòöôõúùüûñç';
    const to = 'aaaaaeeeeiiiiooooouuuunc';
    final lower = text.toLowerCase().trim();
    final buffer = StringBuffer();
    for (final ch in lower.split('')) {
      final i = from.indexOf(ch);
      buffer.write(i == -1 ? ch : to[i]);
    }
    return buffer.toString();
  }

  bool _coincide(Iterable<String?> campos) {
    final q = _normalizar(_busqueda);
    if (q.isEmpty) return true;
    return campos.any((c) => c != null && _normalizar(c).contains(q));
  }

  /// La actividad coincide con la búsqueda (nombre, descripción o
  /// categoría). Sin búsqueda, todas coinciden.
  bool actividadCoincide(Actividad a) =>
      _coincide([a.nombre, a.descripcion, a.categoria]);

  /// El plato coincide por nombre o descripción.
  bool productoCoincide(MenuItem p) => _coincide([p.name, p.description]);

  /// El menú coincide por nombre o categoría (entonces se muestran todos
  /// sus platos).
  bool menuCoincide(Menu m) => _coincide([m.name, m.category]);

  /// Todos los productos de todos los menús, en orden de menú.
  List<MenuItem> get productos => [for (final m in _menus) ...m.products];

  /// Sigue la sesión: si cambia el comercio logueado (o se cierra
  /// sesión), descarta lo cargado para no mostrar datos de otra cuenta.
  void updateAuth(AppAuthProvider auth) {
    final id = auth.comercio != null ? auth.usuario?.id : null;
    if (id == _comercioId) return;
    _comercioId = id;
    _loadedFor = null;
    _inFlight = null;
    _comercio = null;
    _menus = [];
    _actividades = [];
    _filtro = ActividadFiltro.todas;
    _filtroPromos = ActividadFiltro.todas;
    _busqueda = '';
    _loadFailed = false;
    _isLoading = false;
    // Corre dentro del `update` del ProxyProvider (en pleno build):
    // notificar ahí mismo revienta, así que se difiere un microtask.
    Future.microtask(() {
      if (_disposed || id != _comercioId) return;
      if (id == null) {
        notifyListeners();
      } else {
        ensureLoaded();
      }
    });
  }

  /// Carga una vez por comercio. Devuelve `false` si falló la carga.
  Future<bool> ensureLoaded() {
    if (_comercioId == null) return Future.value(true);
    if (_loadedFor == _comercioId && !_loadFailed) return Future.value(true);
    return _inFlight ??= load();
  }

  /// Misma carga que hacía `HomeScreenComercio._loadData`.
  Future<bool> load() async {
    final comercioId = _comercioId;
    if (comercioId == null) return true;
    _isLoading = true;
    _loadFailed = false;
    notifyListeners();
    try {
      final results = await Future.wait([
        _comercioRepository.find(comercioId),
        _menusRepository.fetchMenus(comercioId),
        _placesMapRepository.fetchActividadesDelComercio(comercioId),
      ]);
      if (comercioId != _comercioId) return true;
      _comercio = results[0] as ComercioModel?;
      _menus = List<Menu>.from(results[1] as List<Menu>);
      // El repositorio las trae por `created_at` ascendente.
      _actividades = (results[2] as List<Actividad>).reversed.toList();
      _loadedFor = comercioId;
      return true;
    } catch (e, st) {
      debugPrint('ComercioPanelProvider.load error: $e\n$st');
      if (comercioId != _comercioId) return true;
      _loadFailed = true;
      return false;
    } finally {
      if (comercioId == _comercioId && !_disposed) {
        _isLoading = false;
        _inFlight = null;
        notifyListeners();
      }
    }
  }

  void setFiltro(ActividadFiltro filtro) {
    if (filtro == _filtro) return;
    _filtro = filtro;
    notifyListeners();
  }

  /// Tras crear una actividad: queda primera y el filtro vuelve a "Todas".
  void insertActividad(Actividad actividad) {
    _actividades.insert(0, actividad);
    _filtro = ActividadFiltro.todas;
    _filtroPromos = ActividadFiltro.todas;
    notifyListeners();
  }

  /// Tras editar una actividad: la reemplaza en su lugar.
  void replaceActividad(Actividad actividad) {
    final i = _actividades.indexWhere((a) => a.id == actividad.id);
    if (i == -1) return;
    _actividades[i] = actividad;
    notifyListeners();
  }

  /// Tras eliminar una actividad.
  void removeActividad(int id) {
    _actividades.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  void addMenu(Menu menu) {
    _menus.add(menu);
    notifyListeners();
  }

  void removeMenu(Menu menu) {
    _menus.remove(menu);
    notifyListeners();
  }

  void replaceMenu(Menu old, Menu updated) {
    final i = _menus.indexOf(old);
    if (i == -1) return;
    _menus[i] = updated;
    notifyListeners();
  }

  /// `MenuDetailScreen` edita `menu.products` en sitio; al volver de ahí
  /// basta con avisar a las vistas.
  void menusChanged() => notifyListeners();

  void setComercio(ComercioModel? comercio) {
    _comercio = comercio;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
