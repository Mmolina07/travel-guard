import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../presentation/menu_model.dart';

import '../../auth/providers/app_auth_provider.dart';
import '../data/menus_repository.dart';
import '../providers/comercio_panel_provider.dart';
import '../../../core/settings/currency_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../widgets/filter_chips_row.dart';
import '../../../widgets/ink_button.dart';
import 'widgets/comercio_scaffold.dart';
import 'widgets/comercio_ui.dart';
import 'widgets/product_form_dialog.dart';
import 'widgets/product_tile.dart';

/// `Page` de `/comercio/menu/nuevo`: mismo patrón de diálogo que "Crear
/// actividad" (overlay `ink` + fade/scale); pantalla completa en móvil.
Page<void> buildCreateMenuPage(BuildContext context, GoRouterState state) {
  if (context.isMobile) {
    return MaterialPage<void>(
      key: state.pageKey,
      fullscreenDialog: true,
      child: const CreateMenuScreen(),
    );
  }
  return CustomTransitionPage<void>(
    key: state.pageKey,
    opaque: false,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 240),
    child: const CreateMenuScreen(asDialog: true),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// "Nuevo menú" (antes una pantalla completa): vista previa `ink` + el
/// mismo formulario (nombre, descripción, categoría, disponibilidad y
/// productos) con las mismas validaciones y el mismo guardado.
class CreateMenuScreen extends StatefulWidget {
  const CreateMenuScreen({Key? key, this.asDialog = false}) : super(key: key);

  final bool asDialog;

  @override
  State<CreateMenuScreen> createState() => _CreateMenuScreenState();
}

class _CreateMenuScreenState extends State<CreateMenuScreen> {
  final _menusRepository = MenusRepository();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedCategory = 'Comidas rápidas';

  bool _isAvailable = true;
  bool _isLoading = false;
  Map<String, String> _errors = const {};

  // ⚠️ Se guardan tal cual en `menus.categoria` — NO traducir.
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
    _nameController.addListener(_onTyping);
    _descriptionController.addListener(_onTyping);
  }

  void _onTyping() => setState(() {});

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Permite agregar un producto al menú (se guarda junto con el menú).
  Future<void> _addProduct() async {
    final product = await ProductFormDialog.show(
      context,
      takenNames: [for (final p in _products) p.name],
    );
    if (product != null) {
      setState(() {
        _products.add(product);
        _errors = Map.of(_errors)..remove('products');
      });
    }
  }

  // Elimina un producto de la lista.
  void _removeProduct(int index) {
    setState(() {
      _products.removeAt(index);
    });
  }

  bool _validate() {
    final l10n = context.l10n;
    final errors = <String, String>{};
    if (_nameController.text.trim().isEmpty) {
      errors['name'] = l10n.createMenuNameRequired;
    } else {
      final nameError = Validators.title(context, _nameController.text, max: 150);
      if (nameError != null) errors['name'] = nameError;
    }
    if (_descriptionController.text.trim().isEmpty) {
      errors['description'] = l10n.createMenuDescriptionRequired;
    } else {
      final descError = Validators.freeText(
        context,
        _descriptionController.text,
        min: 10,
        max: 500,
      );
      if (descError != null) errors['description'] = descError;
    }
    if (_products.isEmpty) {
      errors['products'] = l10n.createMenuNoProductsSnackbar;
    }
    setState(() => _errors = errors);
    return errors.isEmpty;
  }

  // Valida y crea el menú.
  Future<void> _handleCreateMenu() async {
    if (_isLoading || !_validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final draft = Menu(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory ?? 'Otro',
        isAvailable: _isAvailable,
        products: _products,
      );

      final comercioId = context.read<AppAuthProvider>().usuario!.id;
      final menu = await _menusRepository.createMenu(
        comercioId: comercioId,
        menu: draft,
      );

      if (!mounted) return;
      context.read<ComercioPanelProvider>().addMenu(menu);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.homeComercioMenuCreatedSnackbar(menu.name),
          ),
          backgroundColor: AppColors.ink,
        ),
      );
      context.go(ComercioRoutes.menu);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.createMenuSaveErrorSnackbar)),
      );
    }
  }

  void _close() {
    if (_isLoading) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(ComercioRoutes.menu);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<CurrencyProvider>();
    return ComercioModalFrame(
      asDialog: widget.asDialog,
      onDismiss: _isLoading ? null : _close,
      preview: _buildPreview(context),
      form: _buildForm(context),
    );
  }

  Widget _buildPreview(BuildContext context) {
    final l10n = context.l10n;
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final grouped = Menu(
      name: '',
      description: '',
      category: '',
      isAvailable: true,
      products: _products,
    ).productsByCategory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PreviewHeading(
          eyebrow: l10n.comercioNewMenuEyebrow,
          line1: l10n.comercioMenuPreviewTitle1,
          line2: l10n.comercioPreviewTitle2,
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (_selectedCategory ?? '').toUpperCase(),
                style: AppText.label(10, color: AppColors.inkSoft),
              ),
              const SizedBox(height: 6),
              Text(
                name.isEmpty ? l10n.createMenuNameLabel : name,
                style: AppText.display(
                  22,
                  color: name.isEmpty ? AppColors.textLabel : AppColors.ink,
                ).copyWith(height: 1.12),
              ),
              const SizedBox(height: 6),
              Text(
                description.isEmpty
                    ? l10n.comercioPreviewDescPlaceholder
                    : description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppText.ui(12, color: AppColors.textMuted, height: 1.45),
              ),
              const SizedBox(height: 8),
              if (_products.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    l10n.comercioMenuPreviewEmpty,
                    style: AppText.ui(12, color: AppColors.textLabel),
                  ),
                )
              else
                for (final entry in grouped.entries) ...[
                  const SizedBox(height: 8),
                  Text(
                    productCategoryLabel(
                      context,
                      entry.key,
                      plural: true,
                    ).toUpperCase(),
                    style: AppText.label(9),
                  ),
                  for (final p in entry.value)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.line),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              p.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.ui(13, weight: FontWeight.w400),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.formatMoney(p.price),
                            style: AppText.label(
                              11,
                              color: AppColors.inkSoft,
                            ).copyWith(letterSpacing: 0),
                          ),
                        ],
                      ),
                    ),
                ],
            ],
          ),
        ),
        const SizedBox(height: 22),
        PreviewStatusNote(
          color: _isAvailable ? AppColors.mint : AppColors.textOnInk,
          note: _isAvailable
              ? l10n.createMenuAvailableSubtitleOn
              : l10n.createMenuAvailableSubtitleOff,
        ),
      ],
    );
  }

  /// Productos agrupados por tipo (HU-20 CA2), con su índice real en
  /// [_products] para poder borrarlos.
  List<Widget> _buildProductList() {
    final grouped = Menu(
      name: '',
      description: '',
      category: '',
      isAvailable: true,
      products: _products,
    ).productsByCategory;
    return [
      for (final entry in grouped.entries) ...[
        ProductCategoryHeading(category: entry.key, count: entry.value.length),
        for (final product in entry.value)
          ProductTile(
            product: product,
            onDelete: () => _removeProduct(_products.indexOf(product)),
          ),
      ],
    ];
  }

  Widget _buildForm(BuildContext context) {
    final l10n = context.l10n;
    final categoryIndex = _selectedCategory == null
        ? -1
        : _categories.indexOf(_selectedCategory!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.createMenuHeading, style: AppText.display(30)),
                  const SizedBox(height: 6),
                  Text(
                    l10n.createMenuSubtitle,
                    style: AppText.ui(14, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ModalCloseButton(
              onTap: _isLoading ? null : _close,
              tooltip: l10n.createMenuCancelButton,
            ),
          ],
        ),
        const SizedBox(height: 22),
        AnimatedOpacity(
          opacity: _isLoading ? 0.5 : 1,
          duration: AppMotion.pressIn,
          child: IgnorePointer(
            ignoring: _isLoading,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FieldCaption(l10n.createMenuNameLabel),
                TextField(
                  controller: _nameController,
                  autofocus: widget.asDialog,
                  inputFormatters: [
                    AppInputFormatters.safeText,
                    AppInputFormatters.maxLength(150),
                  ],
                  style: AppText.ui(19, weight: FontWeight.w400),
                  cursorColor: AppColors.inkSoft,
                  decoration: InputDecoration(
                    hintText: l10n.createMenuNameHint,
                    hintStyle: AppText.ui(
                      19,
                      weight: FontWeight.w400,
                      color: AppColors.textLabel,
                    ),
                    filled: false,
                    isDense: true,
                    contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.ink, width: 2),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.ink, width: 2),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.ink, width: 2),
                    ),
                  ),
                ),
                FieldError(_errors['name']),
                const SizedBox(height: 22),
                FieldCaption(l10n.createMenuDescriptionLabel),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  minLines: 3,
                  inputFormatters: [
                    AppInputFormatters.safeText,
                    AppInputFormatters.maxLength(500),
                  ],
                  maxLines: 8,
                  style: AppText.ui(15, weight: FontWeight.w400, height: 1.5),
                  cursorColor: AppColors.inkSoft,
                  decoration: InputDecoration(
                    hintText: l10n.createMenuDescriptionHint,
                    hintStyle: AppText.ui(
                      15,
                      weight: FontWeight.w400,
                      color: AppColors.textLabel,
                    ),
                    filled: true,
                    fillColor: AppColors.paperDeep,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                FieldError(_errors['description']),
                const SizedBox(height: 22),
                FieldCaption(l10n.createMenuCategoryLabel),
                const SizedBox(height: 10),
                FilterChipsRow(
                  items: _categories,
                  selected: categoryIndex,
                  fontSize: 14,
                  duration: const Duration(milliseconds: 300),
                  curve: AppMotion.enter,
                  onSelect: (i) =>
                      setState(() => _selectedCategory = _categories[i]),
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: BoxDecoration(
                    color: AppColors.paperDeep,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.createMenuAvailableTitle,
                              style: AppText.ui(15, weight: FontWeight.w600),
                            ),
                            Text(
                              _isAvailable
                                  ? l10n.createMenuAvailableSubtitleOn
                                  : l10n.createMenuAvailableSubtitleOff,
                              style: AppText.ui(13, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      MiniSwitch(
                        value: _isAvailable,
                        label: '',
                        onChanged: (v) => setState(() => _isAvailable = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.createMenuProductsHeading,
                        style: AppText.display(22),
                      ),
                    ),
                    Text(
                      l10n
                          .createMenuProductsCount(_products.length)
                          .toUpperCase(),
                      style: AppText.label(11, color: AppColors.inkSoft),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (_products.isEmpty)
                  DashedBox(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 22,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.createMenuEmptyProductsTitle,
                          style: AppText.display(20),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.createMenuEmptyProductsSubtitle,
                          style: AppText.ui(13, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 14),
                        InkButton(
                          label: l10n.createMenuAddProductLabel,
                          icon: Icons.add,
                          onPressed: _addProduct,
                        ),
                      ],
                    ),
                  )
                else ...[
                  ..._buildProductList(),
                  const SizedBox(height: 4),
                  InkButton(
                    label: l10n.createMenuAddProductLabel,
                    icon: Icons.add,
                    variant: InkButtonVariant.secondary,
                    expand: true,
                    onPressed: _addProduct,
                  ),
                ],
                FieldError(_errors['products']),
              ],
            ),
          ),
        ),
        const SizedBox(height: 26),
        ModalFooter(
          cancelLabel: l10n.createMenuCancelButton,
          submitLabel: l10n.createMenuCreateButton,
          loading: _isLoading,
          onCancel: _isLoading ? null : _close,
          onSubmit: _nameController.text.trim().isEmpty
              ? null
              : _handleCreateMenu,
        ),
      ],
    );
  }
}
