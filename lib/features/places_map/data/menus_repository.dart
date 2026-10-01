import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import '../presentation/menu_model.dart';

/// Persistencia de "Mis menús" del comercio (`menus` + `menu_productos`,
/// ver docs/db/hu_comercio_menus_actividades.sql). Antes de esto,
/// `create_menu_screen.dart`/`menu_detail_screen.dart`/
/// `home_screen_comercio.dart` solo guardaban los menús en memoria
/// (`State` local) y se perdían al salir de la pantalla.
class MenusRepository {
  MenusRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  final SupabaseClient _client;
  static const String _menusTable = 'menus';
  static const String _productosTable = 'menu_productos';

  /// Todos los menús de [comercioId], con sus productos ya embebidos
  /// (una sola consulta vía el embed de PostgREST).
  Future<List<Menu>> fetchMenus(int comercioId) async {
    final rows = await _client
        .from(_menusTable)
        .select('*, menu_productos(*)')
        .eq('comercio_id', comercioId)
        .order('created_at');

    return (rows as List).map((row) {
      final map = row as Map<String, dynamic>;
      final rawProductos = map['menu_productos'] as List?;
      final productos = (rawProductos ?? const [])
          .map((p) => MenuItem.fromRow(p as Map<String, dynamic>))
          .toList();
      return Menu.fromRow(map, products: productos);
    }).toList();
  }

  /// Crea el menú y, si trae productos, los inserta todos en un solo
  /// `insert` masivo. Devuelve el [Menu] con el `id` real (del menú y
  /// de cada producto) ya asignado por Supabase.
  Future<Menu> createMenu({
    required int comercioId,
    required Menu menu,
  }) async {
    final menuRow = await _client
        .from(_menusTable)
        .insert(menu.toInsertMap(comercioId))
        .select()
        .single();
    final menuId = menuRow['id'] as int;

    List<MenuItem> productos = const [];
    if (menu.products.isNotEmpty) {
      final rows = await _client
          .from(_productosTable)
          .insert(menu.products.map((p) => p.toInsertMap(menuId)).toList())
          .select();
      productos = (rows as List)
          .map((row) => MenuItem.fromRow(row as Map<String, dynamic>))
          .toList();
    }

    return Menu.fromRow(menuRow, products: productos);
  }

  /// Edita datos propios del menú (no sus productos, ver
  /// [addProducto]/[updateProducto]/[deleteProducto]).
  Future<void> updateMenu(Menu menu) async {
    final id = menu.id;
    if (id == null) {
      throw ArgumentError('No se puede editar un menú sin id (sin guardar aún)');
    }
    await _client.from(_menusTable).update({
      'nombre': menu.name,
      'descripcion': menu.description,
      'categoria': menu.category,
      'disponible': menu.isAvailable,
    }).eq('id', id);
  }

  /// Borra el menú y, en cascada (FK `ON DELETE CASCADE`), todos sus
  /// productos.
  Future<void> deleteMenu(int menuId) async {
    await _client.from(_menusTable).delete().eq('id', menuId);
  }

  Future<MenuItem> addProducto({
    required int menuId,
    required MenuItem producto,
  }) async {
    final row = await _client
        .from(_productosTable)
        .insert(producto.toInsertMap(menuId))
        .select()
        .single();
    return MenuItem.fromRow(row);
  }

  Future<void> updateProducto({
    required int menuId,
    required MenuItem producto,
  }) async {
    final id = producto.id;
    if (id == null) {
      throw ArgumentError('No se puede editar un producto sin id (sin guardar aún)');
    }
    await _client.from(_productosTable).update({
      'nombre': producto.name,
      'descripcion': producto.description,
      'precio': producto.price,
    }).eq('id', id);
  }

  Future<void> deleteProducto(int productoId) async {
    await _client.from(_productosTable).delete().eq('id', productoId);
  }
}
