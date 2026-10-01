// lib/models/menu_model.dart

class MenuItem {
  final String name;
  final String description;
  final double price;

  const MenuItem({
    required this.name,
    required this.description,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
    };
  }

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      price: _parsePrice(map['price']),
    );
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
    String? name,
    String? description,
    double? price,
  }) {
    return MenuItem(
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
    );
  }
}

class Menu {
  final String name;
  final String description;
  final String category;
  final bool isAvailable;
  final List<MenuItem> products;

  Menu({
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
    String? name,
    String? description,
    String? category,
    bool? isAvailable,
    List<MenuItem>? products,
  }) {
    return Menu(
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      products: products ?? this.products,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'isAvailable': isAvailable,
      'products': products
          .map((product) => product.toMap())
          .toList(),
    };
  }

  factory Menu.fromMap(Map<String, dynamic> map) {
    final rawProducts = map['products'];

    final List<MenuItem> products = [];

    if (rawProducts is List) {
      for (final item in rawProducts) {
        if (item is Map<String, dynamic>) {
          products.add(MenuItem.fromMap(item));
        }
      }
    }

    return Menu(
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      category: map['category']?.toString() ?? 'Otro',
      isAvailable: map['isAvailable'] == true,
      products: products,
    );
  }
}
