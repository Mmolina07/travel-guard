import 'package:flutter_test/flutter_test.dart';
import 'package:travelguard/features/places_map/presentation/menu_model.dart';
import 'package:travelguard/features/places_map/presentation/widgets/product_form_dialog.dart';

void main() {
  group('parseProductPrice (HU-20 CA3)', () {
    test('acepta enteros, miles con punto y decimales', () {
      expect(parseProductPrice('18000'), 18000);
      expect(parseProductPrice('18.000'), 18000);
      expect(parseProductPrice('1.250.000'), 1250000);
      expect(parseProductPrice('18,50'), 18.5);
      expect(parseProductPrice(' 9.5 '), 9.5);
    });

    test('devuelve null si no es un número', () {
      expect(parseProductPrice(''), isNull);
      expect(parseProductPrice('abc'), isNull);
      expect(parseProductPrice('12a'), isNull);
    });
  });

  group('Menu.productsByCategory (HU-20 CA2)', () {
    test('agrupa en el orden de ProductCategory y omite vacías', () {
      final menu = Menu(
        name: 'Carta',
        description: '',
        category: 'Otro',
        isAvailable: true,
        products: const [
          MenuItem(name: 'Limonada', description: '', price: 5000, category: ProductCategory.bebida),
          MenuItem(name: 'Bandeja', description: '', price: 30000),
          MenuItem(name: 'Jugo', description: '', price: 6000, category: ProductCategory.bebida),
        ],
      );
      final grouped = menu.productsByCategory;
      expect(grouped.keys, [ProductCategory.plato, ProductCategory.bebida]);
      expect(grouped[ProductCategory.bebida]!.map((p) => p.name), ['Limonada', 'Jugo']);
    });

    test('categoría desconocida en BD cae en plato', () {
      expect(ProductCategory.fromDb(null), ProductCategory.plato);
      expect(ProductCategory.fromDb('postre'), ProductCategory.postre);
      expect(ProductCategory.fromDb('xyz'), ProductCategory.plato);
    });
  });
}
