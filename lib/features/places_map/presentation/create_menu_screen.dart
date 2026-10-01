import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/menu_model.dart';

import '../../../core/settings/currency_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/l10n_extension.dart';

class CreateMenuScreen extends StatefulWidget {
  const CreateMenuScreen({Key? key}) : super(key: key);

  @override
  State<CreateMenuScreen> createState() => _CreateMenuScreenState();
}

class _CreateMenuScreenState extends State<CreateMenuScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedCategory = 'Comidas rápidas';

  bool _isAvailable = true;
  bool _isLoading = false;

  final List<String> _categories = [
    'Comidas rápidas',
    'Bebidas',
    'Desayunos',
    'Almuerzos',
    'Cenas',
    'Postres',
    'Menú turístico',
    'Otro',
  ];

  final List<Map<String, dynamic>> _products = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Permite agregar un producto al menú.
  Future<void> _addProduct() async {
    final TextEditingController productNameController = TextEditingController();
    final TextEditingController productDescriptionController = TextEditingController();
    final TextEditingController productPriceController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            context.l10n.createMenuAddProductDialogTitle,
            style: AppText.display(20),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: productNameController,
                  decoration: InputDecoration(
                    labelText: context.l10n.createMenuProductNameLabel,
                    hintText: context.l10n.createMenuProductNameHint,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: productDescriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: context.l10n.createMenuProductDescriptionLabel,
                    hintText: context.l10n.createMenuProductDescriptionHint,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: productPriceController,
                  keyboardType: TextInputType.number,
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
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                context.l10n.createMenuCancelButton,
                style: AppText.ui(14, color: AppColors.ink),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final String name = productNameController.text.trim();
                final String description = productDescriptionController.text.trim();
                final double? price = double.tryParse(productPriceController.text.trim());

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

                _products.add({
                  'name': name,
                  'description': description,
                  'price': price,
                });

                Navigator.pop(dialogContext, true);
              },
              child: Text(context.l10n.createMenuAddProductButton),
            ),
          ],
        );
      },
    );

    productNameController.dispose();
    productDescriptionController.dispose();
    productPriceController.dispose();

    if (result == true) {
      setState(() {});
    }
  }

  // Elimina un producto de la lista.
  void _removeProduct(int index) {
    setState(() {
      _products.removeAt(index);
    });
  }

  // Valida y crea el menú.
  void _handleCreateMenu() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.createMenuNoProductsSnackbar),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      // Convertir Map a MenuItem
      final List<MenuItem> menuItems = _products
          .map((p) => MenuItem(
                name: p['name'],
                description: p['description'],
                price: p['price'],
              ))
          .toList();

      // Crear objeto Menu
      final Menu menu = Menu(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory ?? 'Otro',
        isAvailable: _isAvailable,
        products: menuItems,
      );

      setState(() {
        _isLoading = false;
      });

      // Regresa a la pantalla anterior enviando el menú creado
      Navigator.pop(context, menu);
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: AppText.ui(15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.ink),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<CurrencyProvider>();
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: Text(
          context.l10n.createMenuAppBarTitle,
          style: AppText.ui(18, weight: FontWeight.w700, color: Colors.white),
        ),
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.createMenuHeading,
                  style: AppText.display(26),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.createMenuSubtitle,
                  style: AppText.ui(14, color: AppColors.textMuted),
                ),
                const SizedBox(height: 24),

                // Nombre del menú
                _buildTextField(
                  controller: _nameController,
                  label: context.l10n.createMenuNameLabel,
                  hint: context.l10n.createMenuNameHint,
                  icon: Icons.restaurant_menu_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.l10n.createMenuNameRequired;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Descripción del menú
                _buildTextField(
                  controller: _descriptionController,
                  label: context.l10n.createMenuDescriptionLabel,
                  hint: context.l10n.createMenuDescriptionHint,
                  icon: Icons.description_outlined,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.l10n.createMenuDescriptionRequired;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Categoría
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  style: AppText.ui(15),
                  decoration: InputDecoration(
                    labelText: context.l10n.createMenuCategoryLabel,
                    prefixIcon: const Icon(
                      Icons.category_outlined,
                      color: AppColors.ink,
                    ),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),

                const SizedBox(height: 28),

                // Título de productos
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.createMenuProductsHeading,
                      style: AppText.display(20),
                    ),
                    Text(
                      context.l10n.createMenuProductsCount(_products.length),
                      style: AppText.label(10, color: AppColors.textMuted, weight: FontWeight.w600),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Lista de productos
                if (_products.isEmpty)
                  Container(
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
                          context.l10n.createMenuEmptyProductsTitle,
                          style: AppText.ui(15, weight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.l10n.createMenuEmptyProductsSubtitle,
                          textAlign: TextAlign.center,
                          style: AppText.ui(13, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          border: Border.all(
                            color: AppColors.hair,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.wash,
                                borderRadius: BorderRadius.circular(AppRadius.control),
                              ),
                              child: const Icon(
                                Icons.fastfood_outlined,
                                color: AppColors.ink,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'] as String,
                                    style: AppText.ui(16, weight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product['description'] as String,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppText.ui(13, color: AppColors.textMuted),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    context.formatMoney(product['price'] as num),
                                    style: AppText.ui(14, weight: FontWeight.w700, color: AppColors.inkSoft),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                              ),
                              onPressed: () {
                                _removeProduct(index);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 12),

                // Botón para agregar productos
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _addProduct,
                    icon: const Icon(Icons.add),
                    label: Text(
                      context.l10n.createMenuAddProductLabel,
                      style: AppText.ui(14, weight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Estado del menú
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    context.l10n.createMenuAvailableTitle,
                    style: AppText.ui(15, weight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    _isAvailable
                        ? context.l10n.createMenuAvailableSubtitleOn
                        : context.l10n.createMenuAvailableSubtitleOff,
                    style: AppText.ui(13, color: AppColors.textMuted),
                  ),
                  value: _isAvailable,
                  activeColor: AppColors.ink,
                  onChanged: (value) {
                    setState(() {
                      _isAvailable = value;
                    });
                  },
                ),

                const SizedBox(height: 24),

                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.button),
                          ),
                        ),
                        child: Text(
                          context.l10n.createMenuCancelButton,
                          style: AppText.ui(15, weight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleCreateMenu,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.button),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: AppColors.mint,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                context.l10n.createMenuCreateButton,
                                style: AppText.ui(15, weight: FontWeight.w700, color: AppColors.paper),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}