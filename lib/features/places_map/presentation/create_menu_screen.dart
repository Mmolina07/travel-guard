import 'package:flutter/material.dart';
import '../presentation/menu_model.dart';

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
          title: const Text(
            'Agregar producto',
            style: TextStyle(
              color: Color(0xFF1A5F7A),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: productNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del producto',
                    hintText: 'Ej. Hamburguesa clásica',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: productDescriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Describe el producto',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: productPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Precio',
                    hintText: 'Ej. 18000',
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
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFF1A5F7A)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A5F7A),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final String name = productNameController.text.trim();
                final String description = productDescriptionController.text.trim();
                final double? price = double.tryParse(productPriceController.text.trim());

                if (name.isEmpty || description.isEmpty || price == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Completa correctamente todos los campos.'),
                    ),
                  );
                  return;
                }

                if (price < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('El precio no puede ser negativo.'),
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
              child: const Text('Agregar'),
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
        const SnackBar(
          content: Text('Agrega al menos un producto al menú.'),
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
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF1A5F7A),
        ),
        filled: true,
        fillColor: const Color(0xFFF5FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFD7E8EF),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF1A5F7A),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FF),
      appBar: AppBar(
        title: const Text(
          'Crear menú',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A5F7A),
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
                const Text(
                  'Nuevo menú',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A5F7A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Crea un menú para mostrar tus productos a los turistas.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),

                // Nombre del menú
                _buildTextField(
                  controller: _nameController,
                  label: 'Nombre del menú',
                  hint: 'Ej. Menú de comidas rápidas',
                  icon: Icons.restaurant_menu_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el nombre del menú';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Descripción del menú
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Descripción',
                  hint: 'Describe de qué trata este menú',
                  icon: Icons.description_outlined,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa una descripción';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Categoría
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Categoría',
                    prefixIcon: const Icon(
                      Icons.category_outlined,
                      color: Color(0xFF1A5F7A),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFFD7E8EF),
                      ),
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
                    const Text(
                      'Productos del menú',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A5F7A),
                      ),
                    ),
                    Text(
                      '${_products.length} productos',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
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
                      color: const Color(0xFFF5FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFD7E8EF),
                      ),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.fastfood_outlined,
                          size: 48,
                          color: Color(0xFFB0D9E8),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Todavía no hay productos',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A5F7A),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Agrega los productos que formarán parte de este menú.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFD7E8EF),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD9EAF2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.fastfood_outlined,
                                color: Color(0xFF1A5F7A),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A5F7A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product['description'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '\$${product['price'].toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A5F7A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
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
                    label: const Text('Agregar producto'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A5F7A),
                      side: const BorderSide(
                        color: Color(0xFF1A5F7A),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Estado del menú
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Menú disponible',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    _isAvailable ? 'Los turistas podrán verlo.' : 'El menú estará oculto.',
                  ),
                  value: _isAvailable,
                  activeColor: const Color(0xFF1A5F7A),
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
                          foregroundColor: const Color(0xFF1A5F7A),
                          side: const BorderSide(
                            color: Color(0xFF1A5F7A),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleCreateMenu,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A5F7A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Crear menú',
                                style: TextStyle(fontWeight: FontWeight.bold),
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