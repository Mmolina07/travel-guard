import 'package:flutter/material.dart';

import '../presentation/menu_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/step_progress.dart';

class CreateMenuScreen extends StatefulWidget {
  const CreateMenuScreen({Key? key}) : super(key: key);

  @override
  State<CreateMenuScreen> createState() => _CreateMenuScreenState();
}

class _CreateMenuScreenState extends State<CreateMenuScreen> {
  static const int _stepCount = 3;

  static const List<(String, String)> _stepTitles = [
    ('¿Cuál es', 'tu menú?'),
    ('¿Qué', 'ofreces?'),
    ('Resumen y', 'publicar'),
  ];

  static const List<String> _stepNames = [
    'Información',
    'Productos',
    'Detalles',
  ];

  int _step = 0;
  bool _isLoading = false;

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  String? _selectedCategory = 'Comidas rápidas';
  bool _isAvailable = true;

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

  final List<MenuItem> _products = [];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ============================================================
  // VALIDACIONES
  // ============================================================

  String? _validateStep0() {
    if (_nameController.text.trim().isEmpty) {
      return 'Ingresa el nombre del menú';
    }

    if (_descriptionController.text.trim().isEmpty) {
      return 'Ingresa una descripción';
    }

    if (_selectedCategory == null ||
        _selectedCategory!.trim().isEmpty) {
      return 'Selecciona una categoría';
    }

    return null;
  }

  String? _validateStep1() {
    if (_products.isEmpty) {
      return 'Agrega al menos un plato o bebida';
    }

    return null;
  }

  // ============================================================
  // NAVEGACIÓN DE PASOS
  // ============================================================

  void _goNext() {
    if (_isLoading) return;

    if (_step == 0) {
      final error = _validateStep0();

      if (error != null) {
        _showSnack(error);
        return;
      }
    }

    if (_step == 1) {
      final error = _validateStep1();

      if (error != null) {
        _showSnack(error);
        return;
      }
    }

    if (_step < _stepCount - 1) {
      setState(() {
        _step++;
      });
    } else {
      _handleCreateMenu();
    }
  }

  void _goBack() {
    if (_isLoading) return;

    if (_step > 0) {
      setState(() {
        _step--;
      });
    }
  }

  void _goToStep(int index) {
    if (_isLoading) return;

    if (index <= _step) {
      setState(() {
        _step = index;
      });
    }
  }

  // ============================================================
  // AGREGAR / EDITAR PRODUCTO
  // ============================================================

  Future<MenuItem?> _showProductDialog({
    MenuItem? product,
  }) async {
    final nameController = TextEditingController(
      text: product?.name ?? '',
    );

    final descriptionController = TextEditingController(
      text: product?.description ?? '',
    );

    final priceController = TextEditingController(
      text: product != null
          ? product.price.toStringAsFixed(0)
          : '',
    );

    final result = await showDialog<MenuItem>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            product == null
                ? 'Agregar producto'
                : 'Editar producto',
            style: AppText.display(20),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    hintText: 'Ej. Hamburguesa clásica',
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Describe el plato o bebida',
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: priceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Precio',
                    prefixText: '\$ ',
                    hintText: '18000',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'Cancelar',
                style: AppText.ui(
                  14,
                  color: AppColors.ink,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();

                final description =
                    descriptionController.text.trim();

                final price = double.tryParse(
                  priceController.text
                      .trim()
                      .replaceAll('.', '')
                      .replaceAll(',', '.'),
                );

                if (name.isEmpty ||
                    description.isEmpty ||
                    price == null ||
                    price < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Completa correctamente todos los campos',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(
                  dialogContext,
                  MenuItem(
                    name: name,
                    description: description,
                    price: price,
                  ),
                );
              },
              child: Text(
                product == null
                    ? 'Agregar'
                    : 'Guardar',
              ),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();

    return result;
  }

  // ============================================================
  // AGREGAR PRODUCTO
  // ============================================================

  Future<void> _addProduct() async {
    final product = await _showProductDialog();

    if (!mounted || product == null) {
      return;
    }

    setState(() {
      _products.add(product);
    });
  }

  // ============================================================
  // EDITAR PRODUCTO
  // ============================================================

  Future<void> _editProduct(int index) async {
    if (index < 0 || index >= _products.length) {
      return;
    }

    final updatedProduct = await _showProductDialog(
      product: _products[index],
    );

    if (!mounted || updatedProduct == null) {
      return;
    }

    setState(() {
      _products[index] = updatedProduct;
    });
  }

  // ============================================================
  // ELIMINAR PRODUCTO
  // ============================================================

  Future<void> _removeProduct(int index) async {
    if (index < 0 || index >= _products.length) {
      return;
    }

    final product = _products[index];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            'Eliminar producto',
            style: AppText.display(20),
          ),
          content: Text(
            '¿Quieres eliminar "${product.name}" del menú?',
            style: AppText.ui(
              14,
              color: AppColors.textMuted,
            ).copyWith(
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                'Cancelar',
                style: AppText.ui(
                  14,
                  color: AppColors.ink,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB54D4D),
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    setState(() {
      _products.removeAt(index);
    });
  }

  // ============================================================
  // CREAR MENÚ
  // ============================================================

  Future<void> _handleCreateMenu() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    if (!mounted) return;

    final menu = Menu(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory ?? 'Otro',
      isAvailable: _isAvailable,
      products: List<MenuItem>.from(_products),
    );

    setState(() {
      _isLoading = false;
    });

    Navigator.pop(context, menu);
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showSnack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return _buildMobileScaffold();
        }

        return _buildDialogDesktop();
      },
    );
  }

  // ============================================================
  // DESKTOP
  // ============================================================

  Widget _buildDialogDesktop() {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 880,
              maxHeight: 680,
            ),
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(34),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    boxShadow: AppShadow.raised,
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 260,
                        child: _buildLeftColumn(),
                      ),
                      Expanded(
                        child: _buildRightColumn(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftColumn() {
    final title = _stepTitles[_step];

    return Container(
      color: AppColors.ink,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'PASO ${_step + 1} DE $_stepCount',
            style: AppText.label(
              10,
              weight: FontWeight.w600,
              color: AppColors.textOnInk,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            title.$1,
            style: AppText.display(
              34,
              color: Colors.white,
            ),
          ),

          Text(
            title.$2,
            style: AppText.displayItalic(34),
          ),

          const SizedBox(height: 26),

          StepProgress(
            step: _step,
            total: _stepCount,
          ),

          const Spacer(),

          for (var i = 0;
              i < _stepNames.length;
              i++)
            Padding(
              padding:
                  const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _goToStep(i),
                child: Text(
                  _stepNames[i],
                  style: AppText.ui(
                    14,
                    weight: i == _step
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: i == _step
                        ? AppColors.paper
                        : AppColors.textOnInk,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRightColumn() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            28,
            24,
            24,
            0,
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: _isLoading
                    ? null
                    : () => Navigator.pop(context),
                child: Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.paperDeep,
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              28,
              8,
              28,
              24,
            ),
            child: _buildStepContent(),
          ),
        ),

        _buildFooter(),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 18,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.line,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          if (_step > 0)
            GestureDetector(
              onTap:
                  _isLoading ? null : _goBack,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.arrow_back,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Atrás',
                    style: AppText.ui(
                      13,
                      weight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox(),

          Row(
            children: [
              if (_step < _stepCount - 1) ...[
                Text(
                  'SIGUIENTE · ${_stepNames[_step + 1]}',
                  style: AppText.label(
                    10,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
              ],

              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : _goNext,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<
                                    Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          _step <
                                  _stepCount - 1
                              ? 'Continuar →'
                              : 'Crear menú',
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOBILE
  // ============================================================

  Widget _buildMobileScaffold() {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading
              ? null
              : (_step > 0
                  ? _goBack
                  : () => Navigator.pop(context)),
        ),
        title: Text(
          'PASO ${_step + 1} DE $_stepCount',
          style: AppText.label(
            11,
            weight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                20,
                24,
                12,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    _stepTitles[_step].$1,
                    style: AppText.display(30),
                  ),
                  Text(
                    _stepTitles[_step].$2,
                    style:
                        AppText.displayItalic(30),
                  ),
                  const SizedBox(height: 16),
                  StepProgress(
                    step: _step,
                    total: _stepCount,
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 24,
                ),
                child: _buildStepContent(),
              ),
            ),

            Container(
              margin: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                22,
              ),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.circular(
                  AppRadius.nav,
                ),
                boxShadow: AppShadow.raised,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _step <
                              _stepCount - 1
                          ? 'SIGUIENTE · ${_stepNames[_step + 1]}'
                          : 'Listo para crear',
                      style: AppText.label(
                        10,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),

                  ElevatedButton(
                    onPressed:
                        _isLoading ? null : _goNext,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<
                                      Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            _step <
                                    _stepCount - 1
                                ? 'Continuar →'
                                : 'Crear',
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CONTENIDO DEL PASO
  // ============================================================

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _buildStep0();

      case 1:
        return _buildStep1();

      case 2:
        return _buildStep2();

      default:
        return const SizedBox();
    }
  }

  // ============================================================
  // PASO 1
  // ============================================================

  Widget _buildStep0() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Nombre del menú',
          style: AppText.ui(
            13,
            weight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: _nameController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            hintText:
                'Ej. Menú de comidas rápidas',
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'Descripción',
          style: AppText.ui(
            13,
            weight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText:
                'Describe de qué trata este menú',
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'CATEGORÍA',
          style: AppText.label(
            10,
            weight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 10),

        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.paperDeep,
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          items: _categories
              .map(
                (category) =>
                    DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
        ),
      ],
    );
  }

  // ============================================================
  // PASO 2 - PRODUCTOS
  // ============================================================

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Platos y bebidas',
              style: AppText.display(22),
            ),
            Text(
              '${_products.length} items',
              style: AppText.ui(
                13,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        if (_products.isEmpty)
          _buildEmptyProducts()
        else
          ListView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            itemCount: _products.length,
            itemBuilder: (context, index) {
              return _buildProductCard(
                _products[index],
                index,
              );
            },
          ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addProduct,
            icon: const Icon(Icons.add),
            label: const Text(
              'Agregar plato o bebida',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.ink,
              side: const BorderSide(
                color: AppColors.ink,
              ),
              padding:
                  const EdgeInsets.symmetric(
                vertical: 15,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyProducts() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.paperDeep,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.hair,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.restaurant_menu_outlined,
            size: 48,
            color: AppColors.textMuted,
          ),

          const SizedBox(height: 10),

          Text(
            'Sin productos',
            style: AppText.display(18),
          ),

          const SizedBox(height: 6),

          Text(
            'Agrega platos o bebidas a tu menú',
            textAlign: TextAlign.center,
            style: AppText.ui(
              12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
    MenuItem product,
    int index,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.hair,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.wash,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.fastfood_outlined,
              color: AppColors.ink,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppText.ui(
                    15,
                    weight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  product.description,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: AppText.ui(
                    12,
                    color:
                        AppColors.textMuted,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '\$${product.price.toStringAsFixed(0)}',
                  style: AppText.ui(
                    13,
                    weight: FontWeight.w700,
                    color:
                        AppColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            tooltip: 'Editar',
            icon: const Icon(
              Icons.edit_outlined,
              size: 20,
            ),
            onPressed: () =>
                _editProduct(index),
          ),

          IconButton(
            tooltip: 'Eliminar',
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: 20,
            ),
            onPressed: () =>
                _removeProduct(index),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PASO 3 - RESUMEN
  // ============================================================

  Widget _buildStep2() {
    final totalPrice = _products.fold<double>(
      0,
      (sum, product) =>
          sum + product.price,
    );

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen del menú',
          style: AppText.display(22),
        ),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.circular(
              AppRadius.card + 2,
            ),
            boxShadow: AppShadow.card,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _summaryRow(
                'Nombre',
                _nameController.text,
              ),

              const SizedBox(height: 12),

              _summaryRow(
                'Categoría',
                _selectedCategory ?? '—',
              ),

              const SizedBox(height: 12),

              _summaryRow(
                'Productos',
                '${_products.length}',
              ),

              const SizedBox(height: 12),

              _summaryRow(
                'Precio total',
                '\$${totalPrice.toStringAsFixed(0)}',
                color: AppColors.inkSoft,
              ),

              const Divider(
                height: 24,
                color: AppColors.line,
              ),

              SwitchListTile(
                contentPadding:
                    EdgeInsets.zero,
                title: Text(
                  'Disponible',
                  style: AppText.ui(
                    14,
                    weight:
                        FontWeight.w600,
                  ),
                ),
                value: _isAvailable,
                activeColor:
                    AppColors.ink,
                onChanged: (value) {
                  setState(() {
                    _isAvailable = value;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    Color? color,
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppText.ui(
            12,
            color: AppColors.textMuted,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppText.ui(
              13,
              weight: FontWeight.w700,
              color:
                  color ?? AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}
