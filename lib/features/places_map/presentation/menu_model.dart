// lib/models/menu_model.dart
//
// `fromRow`/`toInsertMap` mapean contra las tablas `menus`/`menu_productos`
// (ver docs/db/hu_comercio_menus_actividades.sql) vía [MenusRepository].
// Los nombres de campo en Dart se dejan en inglés (name/description/price)
// porque ya los usan `create_menu_screen.dart`, `menu_detail_screen.dart` y
// `home_screen_comercio.dart` — solo cambia cómo se serializan hacia/desde
// Supabase, no los nombres que ve el resto de la app.

class MenuItem {
  final int? id;
  final String name;
  final String description;
  final double price;

  const MenuItem({
    this.id,
    required this.name,
    required this.description,
    required this.price,
  });

  factory MenuItem.fromRow(Map<String, dynamic> row) {
    return MenuItem(
      id: row['id'] as int?,
      name: row['nombre']?.toString() ?? '',
      description: row['descripcion']?.toString() ?? '',
      price: _parsePrice(row['precio']),
    );
  }

  /// Fila lista para `menu_productos` (insert o update) de este producto
  /// dentro de [menuId].
  Map<String, dynamic> toInsertMap(int menuId) {
    return {
      'menu_id': menuId,
      'nombre': name,
      'descripcion': description,
      'precio': price,
    };
  }

  static double _parsePrice(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(
            value.replaceAll(',', '.'),
          ) ??
          0.0;
    }

    return 0.0;
  }

  MenuItem copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
    );
  }
}

class Menu {
  final int? id;
  final String name;
  final String description;
  final String category;
  final bool isAvailable;
  final List<MenuItem> products;

  Menu({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.isAvailable,
    required List<MenuItem> products,
  }) : products = List<MenuItem>.from(products);

  double getTotalPrice() {
    return products.fold(
      0.0,
      (sum, item) => sum + item.price,
    );
  }

  double getAveragePrice() {
    if (products.isEmpty) return 0.0;

    return getTotalPrice() / products.length;
  }

  int getProductCount() {
    return products.length;
  }

  Menu copyWith({
    int? id,
    String? name,
    String? description,
    String? category,
    bool? isAvailable,
    List<MenuItem>? products,
  }) {
    return Menu(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      products: products ?? this.products,
    );
  }

  /// Fila lista para `menus` (insert o update), sin productos — los
  /// productos se manejan aparte en `menu_productos` vía
  /// [MenusRepository].
  Map<String, dynamic> toInsertMap(int comercioId) {
    return {
      'comercio_id': comercioId,
      'nombre': name,
      'descripcion': description,
      'categoria': category,
      'disponible': isAvailable,
    };
  }

  factory Menu.fromRow(Map<String, dynamic> row, {List<MenuItem> products = const []}) {
    return Menu(
      id: row['id'] as int?,
      name: row['nombre']?.toString() ?? '',
      description: row['descripcion']?.toString() ?? '',
      category: row['categoria']?.toString() ?? 'Otro',
      isAvailable: row['disponible'] == true,
      products: products,
    );
  }
}
