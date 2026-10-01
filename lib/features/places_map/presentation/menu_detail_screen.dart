import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/menu_model.dart';
import '../../../core/settings/currency_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/l10n_extension.dart';

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
    context.watch<CurrencyProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.menuDetailAppBarTitle,
          style: AppText.ui(18, weight: FontWeight.w700, color: Colors.white),
        ),
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        elevation: 0,
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
                borderRadius: AppRadius.headerDetail,
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
                          ? AppColors.mint
                          : AppColors.error,
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                    child: Text(
                      menu.isAvailable
                          ? context.l10n.menuDetailStatusAvailable
                          : context.l10n.menuDetailStatusUnavailable,
                      style: AppText.label(
                        11,
                        weight: FontWeight.w700,
                        color: menu.isAvailable ? AppColors.ink : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nombre del menú
                  Text(
                    menu.name,
                    style: AppText.display(32, color: Colors.white),
                  ),
                  const SizedBox(height: 8),

                  // Categoría
                  Row(
                    children: [
                      const Icon(
                        Icons.category_outlined,
                        color: AppColors.textOnInk,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        menu.category,
                        style: AppText.ui(14, color: AppColors.textOnInk),
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
                  Text(
                    context.l10n.menuDetailDescriptionLabel,
                    style: AppText.display(20),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.paperDeep,
                      borderRadius: BorderRadius.circular(AppRadius.control),
                      border: Border.all(
                        color: AppColors.hair,
                      ),
                    ),
                    child: Text(
                      menu.description,
                      style: AppText.ui(14, color: AppColors.textMuted, height: 1.6),
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
                    label: context.l10n.menuDetailStatProductsLabel,
                    value: menu.getProductCount().toString(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.attach_money_outlined,
                    label: context.l10n.menuDetailStatAverageLabel,
                    value: context.formatMoney(menu.getAveragePrice()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.receipt_long_outlined,  // ← CAMBIO AQUÍ
                    label: context.l10n.menuDetailStatTotalLabel,
                    value: context.formatMoney(menu.getTotalPrice()),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Productos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.menuDetailProductsCount(menu.getProductCount()),
                    style: AppText.display(20),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _addProduct(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(
                      context.l10n.createMenuAddProductLabel,
                      style: AppText.ui(13, weight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button),
                      ),
                    ),
                  ),
                ],
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
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(
                      color: AppColors.hair,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.fastfood_outlined,
                        size: 48,
                        color: AppColors.hair,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        context.l10n.menuDetailNoProductsTitle,
                        style: AppText.ui(15, weight: FontWeight.w700),
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
                  return _buildProductCard(context, product, index);
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
                      onPressed: () => _addProduct(context),
                      icon: const Icon(Icons.add),
                      label: Text(
                        context.l10n.createMenuAddProductLabel,
                        style: AppText.ui(14, weight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.button),
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
                      label: Text(
                        context.l10n.menuDetailDeleteButton,
                        style: AppText.ui(14, weight: FontWeight.w700, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.button),
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
        borderRadius: BorderRadius.circular(AppRadius.control),
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
            style: AppText.ui(15, weight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppText.label(10, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, MenuItem product, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: AppColors.hair,
        ),
        boxShadow: AppShadow.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono del producto
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.wash,
              borderRadius: BorderRadius.circular(AppRadius.control),
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
                  style: AppText.ui(16, weight: FontWeight.w700),
                ),

                const SizedBox(height: 6),

                // Descripción
                Text(
                  product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.ui(13, color: AppColors.textMuted, height: 1.4),
                ),

                const SizedBox(height: 10),

                // Precio
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.wash,
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                  ),
                  child: Text(
                    context.formatMoney(product.price),
                    style: AppText.ui(14, weight: FontWeight.w700, color: AppColors.inkSoft),
                  ),
                ),
              ],
            ),
          ),

          // Acciones del producto
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.ink, size: 20),
                onPressed: () => _addProduct(context, index: index),
                tooltip: context.l10n.menuDetailEditButton,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                onPressed: () => _removeProduct(index),
                tooltip: context.l10n.menuDetailDeleteButton,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _removeProduct(int index) {
    setState(() {
      menu.products.removeAt(index);
    });
  }

  Future<void> _addProduct(BuildContext context, {int? index}) async {
    final existing = index != null ? menu.products[index] : null;
    final nameController = TextEditingController(text: existing?.name ?? '');
    final descriptionController =
        TextEditingController(text: existing?.description ?? '');
    final priceController = TextEditingController(
      text: existing != null ? existing.price.toStringAsFixed(0) : '',
    );

    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            existing == null
                ? context.l10n.createMenuAddProductDialogTitle
                : context.l10n.menuDetailEditButton,
            style: AppText.display(20),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: AppText.ui(15),
                  decoration: InputDecoration(
                    labelText: context.l10n.createMenuProductNameLabel,
                    hintText: context.l10n.createMenuProductNameHint,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  style: AppText.ui(15),
                  decoration: InputDecoration(
                    labelText: context.l10n.createMenuProductDescriptionLabel,
                    hintText: context.l10n.createMenuProductDescriptionHint,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  style: AppText.ui(15),
                  decoration: InputDecoration(
                    labelText: context.l10n.createMenuProductPriceLabel,
                    hintText: context.l10n.createMenuProductPriceHint,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                context.l10n.createMenuCancelButton,
                style: AppText.ui(14, color: AppColors.ink),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final description = descriptionController.text.trim();
                final price = double.tryParse(priceController.text.trim());

                if (name.isEmpty || description.isEmpty || price == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.createMenuFieldsInvalidSnackbar),
                    ),
                  );
                  return;
                }

                if (price < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.createMenuNegativePriceSnackbar),
                    ),
                  );
                  return;
                }

                setState(() {
                  final item = MenuItem(
                    name: name,
                    description: description,
                    price: price,
                  );
                  if (index != null) {
                    menu.products[index] = item;
                  } else {
                    menu.products.add(item);
                  }
                });

                Navigator.pop(dialogContext, true);
              },
              child: Text(
                existing == null
                    ? context.l10n.createMenuAddProductButton
                    : context.l10n.menuDetailEditButton,
              ),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            context.l10n.menuDetailDeleteDialogTitle,
            style: AppText.display(20),
          ),
          content: Text(
            context.l10n.menuDetailDeleteDialogContent(menu.name),
            style: AppText.ui(14, color: AppColors.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.l10n.menuDetailCancelButton,
                style: AppText.ui(14, color: AppColors.ink),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar diálogo
                Navigator.pop(context); // Volver a pantalla anterior
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.menuDetailMenuDeletedSnackbar),
                    backgroundColor: AppColors.error,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: Text(
                context.l10n.menuDetailDeleteButton,
                style: AppText.ui(14, weight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}