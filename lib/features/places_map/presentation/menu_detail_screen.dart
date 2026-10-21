import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/menu_model.dart';
import '../data/menus_repository.dart';
import '../../../core/settings/currency_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../widgets/form_section_card.dart';
import '../../../widgets/ink_button.dart';
import '../../../widgets/ink_header.dart';
import 'widgets/product_form_dialog.dart';
import 'widgets/product_tile.dart';

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
  final _menusRepository = MenusRepository();

  @override
  void initState() {
    super.initState();
    menu = widget.menu;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<CurrencyProvider>();
    final l10n = context.l10n;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            InkHeader(
              eyebrow: '${l10n.menuDetailAppBarTitle} · ${menu.category}',
              title: menu.name,
              onBack: () => Navigator.pop(context),
              bottom: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusChip(available: menu.isAvailable),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 34,
                    runSpacing: 14,
                    children: [
                      _HeaderStat(
                        label: l10n.menuDetailStatProductsLabel,
                        value: menu.getProductCount().toString(),
                      ),
                      _HeaderStat(
                        label: l10n.menuDetailStatAverageLabel,
                        value: context.formatMoney(menu.getAveragePrice()),
                      ),
                      _HeaderStat(
                        label: l10n.menuDetailStatTotalLabel,
                        value: context.formatMoney(menu.getTotalPrice()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 44),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (menu.description.isNotEmpty) ...[
                        FormSectionCard(
                          title: l10n.menuDetailDescriptionLabel,
                          children: [
                            Text(
                              menu.description,
                              style: AppText.ui(14, color: AppColors.textMuted, height: 1.6),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                      ],
                      FormSectionCard(
                        title: l10n.menuDetailProductsCount(menu.getProductCount()),
                        children: [
                          if (menu.products.isEmpty)
                            EmptyStateCard(
                              icon: Icons.restaurant_outlined,
                              title: l10n.menuDetailNoProductsTitle,
                              action: InkButton(
                                label: l10n.createMenuAddProductLabel,
                                icon: Icons.add,
                                onPressed: () => _addProduct(context),
                              ),
                            )
                          else ...[
                            // HU-20 CA2: organizados por tipo (platos, bebidas, ...).
                            for (final entry in menu.productsByCategory.entries) ...[
                              ProductCategoryHeading(category: entry.key, count: entry.value.length),
                              for (final product in entry.value)
                                ProductTile(
                                  product: product,
                                  onEdit: () => _addProduct(
                                    context,
                                    index: menu.products.indexOf(product),
                                  ),
                                  onDelete: () => _removeProduct(menu.products.indexOf(product)),
                                ),
                            ],
                            const SizedBox(height: 4),
                            InkButton(
                              label: l10n.createMenuAddProductLabel,
                              icon: Icons.add,
                              variant: InkButtonVariant.secondary,
                              expand: true,
                              onPressed: () => _addProduct(context),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 26),
                      InkButton(
                        label: l10n.menuDetailDeleteButton,
                        icon: Icons.delete_outline,
                        variant: InkButtonVariant.danger,
                        expand: true,
                        onPressed: _showDeleteDialog,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeProduct(int index) async {
    final productId = menu.products[index].id;
    if (productId == null) return;

    try {
      await _menusRepository.deleteProducto(productId);
      if (!mounted) return;
      setState(() => menu.products.removeAt(index));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.menuDetailSaveErrorSnackbar)),
      );
    }
  }

  /// Crea un producto o, con [index], edita ese (HU-20 CA1, CA5). Se
  /// guarda en Supabase desde el diálogo: si falla, sigue abierto.
  Future<void> _addProduct(BuildContext context, {int? index}) async {
    final existing = index != null ? menu.products[index] : null;
    await ProductFormDialog.show(
      context,
      existing: existing,
      takenNames: [for (final p in menu.products) p.name],
      onSave: (product) async {
        if (existing != null) {
          await _menusRepository.updateProducto(menuId: menu.id!, producto: product);
          if (!mounted) return;
          setState(() => menu.products[index!] = product);
        } else {
          final created = await _menusRepository.addProducto(menuId: menu.id!, producto: product);
          if (!mounted) return;
          setState(() => menu.products.add(created));
        }
      },
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            context.l10n.menuDetailDeleteDialogTitle,
            style: AppText.display(20),
          ),
          content: Text(
            context.l10n.menuDetailDeleteDialogContent(menu.name),
            style: AppText.ui(14, color: AppColors.textMuted),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
          actions: [
            InkButton(
              label: context.l10n.menuDetailCancelButton,
              variant: InkButtonVariant.secondary,
              onPressed: () => Navigator.pop(dialogContext),
            ),
            InkButton(
              label: context.l10n.menuDetailDeleteButton,
              icon: Icons.delete_outline,
              variant: InkButtonVariant.danger,
              onPressed: () async {
                Navigator.pop(dialogContext); // Cerrar diálogo

                final id = menu.id;
                if (id == null) return;

                try {
                  await _menusRepository.deleteMenu(id);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.menuDetailMenuDeletedSnackbar)),
                  );
                  // Avisa al home de comercio que lo quite de su lista.
                  Navigator.pop(context, true);
                } catch (_) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.menuDetailSaveErrorSnackbar)),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}

/// Chip de estado sobre `ink`: disponible en `mint`, oculto translúcido.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.available});

  final bool available;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: available ? AppColors.mint : AppColors.paper.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Text(
        (available
                ? context.l10n.menuDetailStatusAvailable
                : context.l10n.menuDetailStatusUnavailable)
            .toUpperCase(),
        style: AppText.label(10,
            weight: FontWeight.w700, color: available ? AppColors.ink : AppColors.textOnInk),
      ),
    );
  }
}

/// Cifra de la cabecera: etiqueta mono + valor display `paper`.
class _HeaderStat extends StatelessWidget {
  const _HeaderStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppText.label(10, color: AppColors.textOnInk)),
        const SizedBox(height: 4),
        Text(value, style: AppText.display(28, color: AppColors.paper)),
      ],
    );
  }
}
