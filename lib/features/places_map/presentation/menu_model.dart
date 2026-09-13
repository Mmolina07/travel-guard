// lib/models/menu_model.dart

class MenuItem {
  final String name;
  final String description;
  final double price;

  MenuItem({
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
      name: map['name'] as String,
      description: map['description'] as String,
      price: map['price'] as double,
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
    required this.products,
  });

  // Calcular precio total del menú
  double getTotalPrice() {
    return products.fold(0, (sum, item) => sum + item.price);
  }

  // Calcular precio promedio
  double getAveragePrice() {
    if (products.isEmpty) return 0;
    return getTotalPrice() / products.length;
  }

  // Contar productos
  int getProductCount() {
    return products.length;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'isAvailable': isAvailable,
      'products': products.map((p) => p.toMap()).toList(),
    };
  }

  factory Menu.fromMap(Map<String, dynamic> map) {
    return Menu(
      name: map['name'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      isAvailable: map['isAvailable'] as bool,
      products: (map['products'] as List)
          .map((p) => MenuItem.fromMap(p as Map<String, dynamic>))
          .toList(),
    );
  }
}