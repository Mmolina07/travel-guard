import 'package:flutter/material.dart';
import '../presentation/menu_model.dart';
import '../../../core/theme/app_theme.dart';

class MenuDetailScreen extends StatefulWidget {
  final Menu menu;

  const MenuDetailScreen({  
    Key? key,
    required this.menu,
  }) : super(key: key);

  @override
  State<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends State<MenuDetailScreen> {
  late Menu menu;

  @override
  void initState() {
    super.initState();
    menu = widget.menu;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalle del Menú',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: const DecoratedBox(decoration: BoxDecoration(color: AppColors.ink)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información del menú
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.ink,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Estado del menú
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: menu.isAvailable
                          ? const Color(0xFF4CAF50)
                          : AppColors.error,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      menu.isAvailable ? 'Disponible' : 'No disponible',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nombre del menú
                  Text(
                    menu.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Categoría
                  Row(
                    children: [
                      const Icon(
                        Icons.category_outlined,
                        color: Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        menu.category,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Descripción
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.paperDeep,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.hair,
                      ),
                    ),
                    child: Text(
                      menu.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Estadísticas
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.restaurant_menu_outlined,
                    label: 'Productos',
                    value: menu.getProductCount().toString(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.attach_money_outlined,
                    label: 'Promedio',
                    value: '\$${menu.getAveragePrice().toStringAsFixed(0)}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.receipt_long_outlined,  // ← CAMBIO AQUÍ
                    label: 'Total',
                    value: '\$${menu.getTotalPrice().toStringAsFixed(0)}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Productos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Productos (${menu.getProductCount()})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Lista de productos
            if (menu.products.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.paperDeep,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.hair,
                    ),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.fastfood_outlined,
                        size: 48,
                        color: AppColors.hair,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'No hay productos',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: menu.products.length,
                itemBuilder: (context, index) {
                  final product = menu.products[index];
                  return _buildProductCard(product, index);
                },
              ),

            const SizedBox(height: 24),

            // Botones de acción
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Editar menú
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Función en desarrollo'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Editar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.ink,
                        side: const BorderSide(
                          color: AppColors.ink,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Eliminar menú
                        _showDeleteDialog();
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Eliminar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.paperDeep,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.hair,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.ink,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(MenuItem product, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.hair,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono del producto
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.hair,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.fastfood_outlined,
              color: AppColors.ink,
              size: 32,
            ),
          ),

          const SizedBox(width: 14),

          // Información del producto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),

                const SizedBox(height: 6),

                // Descripción
                Text(
                  product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 10),

                // Precio
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.paperDeep,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '\$${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Número del producto
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Eliminar menú',
            style: TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '¿Estás seguro de que deseas eliminar el menú "${menu.name}"? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: AppColors.ink,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar diálogo
                Navigator.pop(context); // Volver a pantalla anterior
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Menú eliminado'),
                    backgroundColor: AppColors.error,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Eliminar',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}