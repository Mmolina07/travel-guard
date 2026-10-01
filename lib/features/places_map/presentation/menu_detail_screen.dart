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
  State<MenuDetailScreen> createState() =>
      _MenuDetailScreenState();
}

class _MenuDetailScreenState
    extends State<MenuDetailScreen> {
  late Menu menu;

  @override
  void initState() {
    super.initState();

    menu = widget.menu;
  }

  // ============================================================
  // PRODUCTOS
  // ============================================================

  Future<MenuItem?> _showProductDialog({
    MenuItem? product,
  }) async {
    final nameController =
        TextEditingController(
      text: product?.name ?? '',
    );

    final descriptionController =
        TextEditingController(
      text: product?.description ?? '',
    );

    final priceController =
        TextEditingController(
      text: product != null
          ? product.price.toStringAsFixed(0)
          : '',
    );

    final result =
        await showDialog<MenuItem>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              AppColors.surface,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(22),
          ),
          title: Text(
            product == null
                ? 'Agregar producto'
                : 'Editar producto',
            style:
                AppText.display(20),
          ),
          content:
              SingleChildScrollView(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                TextField(
                  controller:
                      nameController,
                  autofocus: true,
                  textInputAction:
                      TextInputAction.next,
                  decoration:
                      const InputDecoration(
                    labelText: 'Nombre',
                    hintText:
                        'Ej. Hamburguesa clásica',
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                TextField(
                  controller:
                      descriptionController,
                  maxLines: 3,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Descripción',
                    hintText:
                        'Describe el plato o bebida',
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                TextField(
                  controller:
                      priceController,
                  keyboardType:
                      const TextInputType
                          .numberWithOptions(
                    decimal: true,
                  ),
                  decoration:
                      const InputDecoration(
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
                Navigator.pop(
                  dialogContext,
                );
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
                final name =
                    nameController.text
                        .trim();

                final description =
                    descriptionController
                        .text
                        .trim();

                final price =
                    double.tryParse(
                  priceController.text
                      .trim()
                      .replaceAll('.', '')
                      .replaceAll(
                        ',',
                        '.',
                      ),
                );

                if (name.isEmpty ||
                    description.isEmpty ||
                    price == null ||
                    price < 0) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
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
                    description:
                        description,
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
    final product =
        await _showProductDialog();

    if (!mounted ||
        product == null) {
      return;
    }

    setState(() {
      menu = Menu(
        name: menu.name,
        description: menu.description,
        category: menu.category,
        isAvailable:
            menu.isAvailable,
        products: [
          ...menu.products,
          product,
        ],
      );
    });
  }

  // ============================================================
  // EDITAR PRODUCTO
  // ============================================================

  Future<void> _editProduct(
    int index,
  ) async {
    if (index < 0 ||
        index >= menu.products.length) {
      return;
    }

    final updatedProduct =
        await _showProductDialog(
      product: menu.products[index],
    );

    if (!mounted ||
        updatedProduct == null) {
      return;
    }

    final products =
        List<MenuItem>.from(
      menu.products,
    );

    products[index] = updatedProduct;

    setState(() {
      menu = Menu(
        name: menu.name,
        description: menu.description,
        category: menu.category,
        isAvailable:
            menu.isAvailable,
        products: products,
      );
    });
  }

  // ============================================================
  // ELIMINAR PRODUCTO
  // ============================================================

  Future<void> _deleteProduct(
    int index,
  ) async {
    if (index < 0 ||
        index >= menu.products.length) {
      return;
    }

    final product =
        menu.products[index];

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              AppColors.surface,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(22),
          ),
          title: Text(
            'Eliminar producto',
            style:
                AppText.display(20),
          ),
          content: Text(
            '¿Quieres eliminar "${product.name}" del menú?',
            style: AppText.ui(
              14,
              color:
                  AppColors.textMuted,
            ).copyWith(
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: Text(
                'Cancelar',
                style: AppText.ui(
                  14,
                  color:
                      AppColors.ink,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFFB54D4D,
                ),
                foregroundColor:
                    Colors.white,
              ),
              child:
                  const Text(
                'Eliminar',
              ),
            ),
          ],
        );
      },
    );

    if (!mounted ||
        confirmed != true) {
      return;
    }

    final products =
        List<MenuItem>.from(
      menu.products,
    );

    products.removeAt(index);

    setState(() {
      menu = Menu(
        name: menu.name,
        description: menu.description,
        category: menu.category,
        isAvailable:
            menu.isAvailable,
        products: products,
      );
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder:
          (context, constraints) {
        if (constraints.maxWidth <
            700) {
          return _buildMobile();
        }

        return _buildDesktop();
      },
    );
  }

  // ============================================================
  // DESKTOP
  // ============================================================

  Widget _buildDesktop() {
    return Scaffold(
      backgroundColor:
          AppColors.paper,
      body: Center(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 1050,
            ),
            child: Container(
              decoration:
                  BoxDecoration(
                color:
                    AppColors.surface,
                borderRadius:
                    BorderRadius.circular(
                  34,
                ),
                boxShadow:
                    AppShadow.raised,
              ),
              clipBehavior:
                  Clip.antiAlias,
              child: Column(
                children: [
                  _buildDesktopHeader(),
                  _buildContent(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopHeader() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        36,
        28,
        36,
        34,
      ),
      color: AppColors.ink,
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child:
                _buildHeaderInformation(),
          ),

          const SizedBox(width: 30),

          _buildHeaderActions(),
        ],
      ),
    );
  }

  Widget _buildHeaderInformation() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () =>
              Navigator.pop(context),
          child: Row(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Icon(
                Icons.arrow_back,
                size: 16,
                color:
                    AppColors.textOnInk,
              ),
              const SizedBox(width: 7),
              Text(
                'VOLVER',
                style: AppText.label(
                  10,
                  weight:
                      FontWeight.w600,
                  color:
                      AppColors.textOnInk,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        _buildAvailabilityBadge(),

        const SizedBox(height: 18),

        Text(
          menu.name,
          style: AppText.display(
            38,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            const Icon(
              Icons.category_outlined,
              size: 17,
              color:
                  AppColors.textOnInk,
            ),
            const SizedBox(width: 8),
            Text(
              menu.category,
              style: AppText.ui(
                14,
                color:
                    AppColors.textOnInk,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      children: [
        _buildIconButton(
          icon:
              Icons.add_circle_outline,
          tooltip: 'Agregar producto',
          onTap: _addProduct,
        ),

        const SizedBox(width: 10),

        _buildIconButton(
          icon:
              Icons.delete_outline,
          tooltip: 'Eliminar menú',
          onTap:
              _showDeleteDialog,
          danger: true,
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(13),
        child: Container(
          width: 44,
          height: 44,
          decoration:
              BoxDecoration(
            color: danger
                ? Colors.white
                    .withOpacity(.08)
                : Colors.white
                    .withOpacity(.10),
            borderRadius:
                BorderRadius.circular(
              13,
            ),
            border: Border.all(
              color: Colors.white
                  .withOpacity(.12),
            ),
          ),
          child: Icon(
            icon,
            size: 19,
            color: danger
                ? const Color(
                    0xFFFF8B8B,
                  )
                : Colors.white,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MOBILE
  // ============================================================

  Widget _buildMobile() {
    return Scaffold(
      backgroundColor:
          AppColors.paper,
      appBar: AppBar(
        backgroundColor:
            AppColors.ink,
        foregroundColor:
            Colors.white,
        elevation: 0,
        leading:
            IconButton(
          icon:
              const Icon(
            Icons.arrow_back,
          ),
          onPressed: () =>
              Navigator.pop(context),
        ),
        title: Text(
          'DETALLE DEL MENÚ',
          style: AppText.label(
            11,
            weight:
                FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            tooltip:
                'Agregar producto',
            onPressed: _addProduct,
            icon: const Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      body:
          SingleChildScrollView(
        child: Column(
          children: [
            _buildMobileHeader(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Container(
      width: double.infinity,
      color: AppColors.ink,
      padding:
          const EdgeInsets.fromLTRB(
        24,
        4,
        24,
        30,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildAvailabilityBadge(),

          const SizedBox(height: 18),

          Text(
            menu.name,
            style: AppText.display(
              32,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(
                Icons.category_outlined,
                size: 17,
                color:
                    AppColors.textOnInk,
              ),
              const SizedBox(width: 8),
              Text(
                menu.category,
                style: AppText.ui(
                  14,
                  color:
                      AppColors.textOnInk,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTENIDO
  // ============================================================

  Widget _buildContent() {
    return Padding(
      padding:
          const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildStatistics(),

          const SizedBox(height: 30),

          _buildDescription(),

          const SizedBox(height: 34),

          _buildProductsSection(),

          const SizedBox(height: 30),

          _buildAvailabilitySection(),

          const SizedBox(height: 28),

          _buildBottomActions(),
        ],
      ),
    );
  }

  // ============================================================
  // ESTADÍSTICAS
  // ============================================================

  Widget _buildStatistics() {
    return LayoutBuilder(
      builder:
          (context, constraints) {
        final isSmall =
            constraints.maxWidth < 520;

        if (isSmall) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child:
                        _buildStatCard(
                      icon: Icons
                          .restaurant_menu_outlined,
                      value: menu
                          .getProductCount()
                          .toString(),
                      label: 'Productos',
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child:
                        _buildStatCard(
                      icon: Icons
                          .attach_money_outlined,
                      value:
                          '\$${menu.getAveragePrice().toStringAsFixed(0)}',
                      label:
                          'Precio promedio',
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 12,
              ),

              _buildStatCard(
                icon: Icons
                    .receipt_long_outlined,
                value:
                    '\$${menu.getTotalPrice().toStringAsFixed(0)}',
                label: 'Valor total',
                fullWidth: true,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons
                    .restaurant_menu_outlined,
                value: menu
                    .getProductCount()
                    .toString(),
                label: 'Productos',
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: _buildStatCard(
                icon: Icons
                    .attach_money_outlined,
                value:
                    '\$${menu.getAveragePrice().toStringAsFixed(0)}',
                label:
                    'Precio promedio',
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: _buildStatCard(
                icon: Icons
                    .receipt_long_outlined,
                value:
                    '\$${menu.getTotalPrice().toStringAsFixed(0)}',
                label: 'Valor total',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    bool fullWidth = false,
  }) {
    return Container(
      width:
          fullWidth ? double.infinity : null,
      padding:
          const EdgeInsets.all(18),
      decoration:
          BoxDecoration(
        color: AppColors.paperDeep,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.line,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration:
                BoxDecoration(
              color: AppColors.wash,
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.ink,
              size: 21,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  value,
                  style: AppText.ui(
                    17,
                    weight:
                        FontWeight.w700,
                    color:
                        AppColors.ink,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  label,
                  style: AppText.ui(
                    11,
                    color: AppColors
                        .textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DESCRIPCIÓN
  // ============================================================

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          eyebrow: 'SOBRE ESTE MENÚ',
          title: 'Descripción',
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.all(20),
          decoration:
              BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.circular(
              18,
            ),
            border: Border.all(
              color: AppColors.line,
            ),
            boxShadow:
                AppShadow.card,
          ),
          child: Text(
            menu.description,
            style: AppText.ui(
              14,
              color:
                  AppColors.textMuted,
            ).copyWith(
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PRODUCTOS
  // ============================================================

  Widget _buildProductsSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Expanded(
              child:
                  _buildSectionTitle(
                eyebrow: 'CONTENIDO',
                title:
                    'Platos y bebidas',
              ),
            ),

            Text(
              '${menu.products.length} items',
              style: AppText.ui(
                12,
                color:
                    AppColors.textMuted,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        if (menu.products.isEmpty)
          _buildEmptyProducts()
        else
          ListView.separated(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            itemCount:
                menu.products.length,
            separatorBuilder:
                (_, __) =>
                    const SizedBox(
              height: 12,
            ),
            itemBuilder:
                (context, index) {
              return _buildProductCard(
                menu.products[index],
                index,
              );
            },
          ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addProduct,
            icon: const Icon(
              Icons.add,
            ),
            label: const Text(
              'Agregar plato o bebida',
            ),
            style:
                OutlinedButton.styleFrom(
              foregroundColor:
                  AppColors.ink,
              side:
                  const BorderSide(
                color: AppColors.ink,
              ),
              padding:
                  const EdgeInsets
                      .symmetric(
                vertical: 15,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
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
      padding:
          const EdgeInsets.all(30),
      decoration:
          BoxDecoration(
        color: AppColors.paperDeep,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.line,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration:
                BoxDecoration(
              color: AppColors.wash,
              borderRadius:
                  BorderRadius.circular(
                16,
              ),
            ),
            child: const Icon(
              Icons
                  .restaurant_menu_outlined,
              size: 27,
              color:
                  AppColors.textMuted,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          Text(
            'Sin productos',
            style:
                AppText.display(18),
          ),

          const SizedBox(height: 5),

          Text(
            'Este menú todavía no tiene platos o bebidas.',
            textAlign:
                TextAlign.center,
            style: AppText.ui(
              12,
              color:
                  AppColors.textMuted,
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
      padding:
          const EdgeInsets.all(16),
      decoration:
          BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.line,
        ),
        boxShadow:
            AppShadow.card,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration:
                BoxDecoration(
              color: AppColors.wash,
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
            child: Center(
              child: Text(
                '${index + 1}'
                    .padLeft(2, '0'),
                style: AppText.ui(
                  13,
                  weight:
                      FontWeight.w700,
                  color:
                      AppColors.ink,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  product.name,
                  style: AppText.ui(
                    15,
                    weight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  product.description,
                  maxLines: 3,
                  overflow:
                      TextOverflow.ellipsis,
                  style: AppText.ui(
                    12,
                    color:
                        AppColors
                            .textMuted,
                  ).copyWith(
                    height: 1.45,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration:
                      BoxDecoration(
                    color: AppColors
                        .paperDeep,
                    borderRadius:
                        BorderRadius
                            .circular(9),
                  ),
                  child: Text(
                    '\$${product.price.toStringAsFixed(0)}',
                    style:
                        AppText.ui(
                      13,
                      weight:
                          FontWeight.w700,
                      color: AppColors
                          .inkSoft,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Column(
            children: [
              IconButton(
                tooltip: 'Editar',
                onPressed: () =>
                    _editProduct(index),
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 19,
                ),
              ),

              IconButton(
                tooltip: 'Eliminar',
                onPressed: () =>
                    _deleteProduct(index),
                icon: const Icon(
                  Icons.delete_outline,
                  size: 19,
                  color:
                      Color(0xFFB54D4D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DISPONIBILIDAD
  // ============================================================

  Widget _buildAvailabilitySection() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(20),
      decoration:
          BoxDecoration(
        color: menu.isAvailable
            ? const Color(0xFFF0F8F1)
            : const Color(0xFFFFF1F1),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: menu.isAvailable
              ? const Color(
                  0xFFC9E5CD,
                )
              : const Color(
                  0xFFF0CACA,
                ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration:
                BoxDecoration(
              color: menu.isAvailable
                  ? const Color(
                      0xFFDCEFE0,
                    )
                  : const Color(
                      0xFFF9DADA,
                    ),
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
            ),
            child: Icon(
              menu.isAvailable
                  ? Icons
                      .check_circle_outline
                  : Icons
                      .pause_circle_outline,
              color:
                  menu.isAvailable
                      ? const Color(
                          0xFF3E7D47,
                        )
                      : const Color(
                          0xFFB54D4D,
                        ),
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  menu.isAvailable
                      ? 'Menú disponible'
                      : 'Menú no disponible',
                  style: AppText.ui(
                    14,
                    weight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  menu.isAvailable
                      ? 'Este menú está disponible para tus clientes.'
                      : 'Este menú está temporalmente deshabilitado.',
                  style: AppText.ui(
                    12,
                    color: AppColors
                        .textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityBadge() {
    final available =
        menu.isAvailable;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration:
          BoxDecoration(
        color: available
            ? const Color(
                0xFF3E7D47,
              ).withOpacity(.22)
            : const Color(
                0xFFB54D4D,
              ).withOpacity(.20),
        borderRadius:
            BorderRadius.circular(30),
        border: Border.all(
          color: available
              ? const Color(
                  0xFF78B982,
                ).withOpacity(.35)
              : const Color(
                  0xFFE58C8C,
                ).withOpacity(.35),
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration:
                BoxDecoration(
              shape: BoxShape.circle,
              color: available
                  ? const Color(
                      0xFF8FD497,
                    )
                  : const Color(
                      0xFFFF9999,
                    ),
            ),
          ),

          const SizedBox(width: 7),

          Text(
            available
                ? 'DISPONIBLE'
                : 'NO DISPONIBLE',
            style: AppText.label(
              9,
              weight:
                  FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TÍTULOS
  // ============================================================

  Widget _buildSectionTitle({
    required String eyebrow,
    required String title,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: AppText.label(
            9,
            weight:
                FontWeight.w700,
            color:
                AppColors.textMuted,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          title,
          style:
              AppText.display(23),
        ),
      ],
    );
  }

  // ============================================================
  // ACCIONES INFERIORES
  // ============================================================

  Widget _buildBottomActions() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _addProduct,
        icon: const Icon(
          Icons.add,
          size: 18,
        ),
        label: const Text(
          'Agregar plato o bebida',
        ),
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              AppColors.ink,
          foregroundColor:
              Colors.white,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              14,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ELIMINAR MENÚ
  // ============================================================

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              AppColors.surface,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(22),
          ),
          title: Text(
            'Eliminar menú',
            style:
                AppText.display(20),
          ),
          content: Text(
            '¿Estás seguro de que deseas eliminar "${menu.name}"? Esta acción no se puede deshacer.',
            style: AppText.ui(
              14,
              color:
                  AppColors.textMuted,
            ).copyWith(
              height: 1.5,
            ),
          ),
          actionsPadding:
              const EdgeInsets.fromLTRB(
            20,
            0,
            20,
            20,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: Text(
                'Cancelar',
                style: AppText.ui(
                  13,
                  weight:
                      FontWeight.w600,
                  color:
                      AppColors.ink,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );

                Navigator.pop(
                  context,
                  null,
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFFB54D4D,
                ),
                foregroundColor:
                    Colors.white,
              ),
              child:
                  const Text(
                'Eliminar',
              ),
            ),
          ],
        );
      },
    );
  }
}
