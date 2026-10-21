import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/settings/currency_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shell/app_shell.dart';
import '../../../widgets/hover_card.dart';
import '../../../widgets/ink_button.dart';
import '../../../widgets/stagger_in.dart';
import '../data/menus_repository.dart';
import '../providers/comercio_panel_provider.dart';
import 'menu_detail_screen.dart';
import 'menu_model.dart';
import 'widgets/comercio_scaffold.dart';
import 'widgets/comercio_ui.dart';
import 'widgets/product_form_dialog.dart';

/// "Tu menú" (`/comercio/menu`): todos los menús del comercio con sus
/// productos agrupados por tipo. Crear/editar/eliminar productos y
/// eliminar menús usa las mismas llamadas que `MenuDetailScreen`, que
/// sigue disponible desde "Ver detalle".
class ComercioMenuScreen extends StatelessWidget {
  const ComercioMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<CurrencyProvider>();
    final l10n = context.l10n;
    final panel = context.watch<ComercioPanelProvider>();
    final menus = panel.menus;
    // Con búsqueda: un menú que coincide por nombre/categoría muestra
    // todos sus platos; si no, solo los platos que coinciden.
    final visible = <(Menu, List<MenuItem>)>[
      for (final m in menus)
        if (!panel.buscando || panel.menuCoincide(m))
          (m, m.products)
        else if (m.products.any(panel.productoCoincide))
          (m, m.products.where(panel.productoCoincide).toList()),
    ];
    final width = MediaQuery.sizeOf(context).width;
    final titleSize = (width * 0.032).clamp(32.0, 44.0);

    return ComercioScaffold(
      section: ComercioSection.menu,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 20,
            runSpacing: 18,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.comercioMenuProductsCount(panel.productos.length),
                    style: AppText.label(11, color: AppColors.inkSoft),
                  ),
                  const SizedBox(height: 10),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: l10n.comercioMenuTitle1),
                        TextSpan(
                          text: l10n.comercioMenuTitle2,
                          style: AppText.displayItalic(titleSize),
                        ),
                      ],
                    ),
                    style: AppText.display(titleSize).copyWith(height: 1.04),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.comercioMenuSubtitle,
                    style: AppText.ui(14, color: AppColors.textMuted),
                  ),
                ],
              ),
              if (context.isMobile)
                // Móvil: el principal primero y ambos del mismo ancho.
                Row(
                  children: [
                    Expanded(
                      child: SmallInkButton(
                        label: l10n.comercioAddProductButton,
                        onTap: () => _addProductAnywhere(context, menus),
                        radius: 18,
                        fontSize: 14,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SmallInkButton(
                        label: l10n.homeComercioAddMenuButton,
                        outlined: true,
                        onTap: () => openCreateMenu(context),
                        radius: 18,
                        fontSize: 14,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                )
              else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SmallInkButton(
                    label: l10n.homeComercioAddMenuButton,
                    outlined: true,
                    onTap: () => openCreateMenu(context),
                    radius: 18,
                    fontSize: 14,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  SmallInkButton(
                    label: l10n.comercioAddProductButton,
                    onTap: () => _addProductAnywhere(context, menus),
                    radius: 18,
                    fontSize: 14,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shadow: AppShadow.inkButton,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 26),
          if (!panel.hasLoaded && !panel.loadFailed)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.ink),
              ),
            )
          else if (menus.isEmpty)
            DashedBox(
              child: Text(
                l10n.comercioMenuEmpty,
                style: AppText.ui(14, color: AppColors.textMuted),
              ),
            )
          else if (visible.isEmpty)
            Text(
              l10n.comercioSearchNoResults(panel.busqueda.trim()),
              style: AppText.ui(14, color: AppColors.textMuted),
            )
          else
            for (var i = 0; i < visible.length; i++) ...[
              if (i > 0) const SizedBox(height: 34),
              _MenuBlock(menu: visible[i].$1, products: visible[i].$2),
            ],
        ],
      ),
    );
  }

  /// "+ Agregar producto" del encabezado: sin menús abre "Nuevo menú"
  /// (un producto siempre pertenece a un menú); con uno, lo agrega ahí;
  /// con varios, pregunta a cuál.
  Future<void> _addProductAnywhere(
    BuildContext context,
    List<Menu> menus,
  ) async {
    if (menus.isEmpty) {
      openCreateMenu(context);
      return;
    }
    var target = menus.first;
    if (menus.length > 1) {
      final picked = await showDialog<Menu>(
        context: context,
        builder: (dialogContext) => SimpleDialog(
          title: Text(
            context.l10n.comercioPickMenuTitle,
            style: AppText.display(24),
          ),
          children: [
            for (final menu in menus)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(dialogContext, menu),
                child: Text(menu.name, style: AppText.ui(15)),
              ),
          ],
        ),
      );
      if (picked == null) return;
      target = picked;
    }
    if (!context.mounted) return;
    await _MenuActions.addProduct(context, target);
  }
}

/// Acciones sobre un menú (mismas llamadas que `MenuDetailScreen`).
abstract final class _MenuActions {
  static final _repository = MenusRepository();

  static Future<void> addProduct(BuildContext context, Menu menu) async {
    final panel = context.read<ComercioPanelProvider>();
    await ProductFormDialog.show(
      context,
      takenNames: [for (final p in menu.products) p.name],
      onSave: (product) async {
        final created = await _repository.addProducto(
          menuId: menu.id!,
          producto: product,
        );
        menu.products.add(created);
        panel.menusChanged();
      },
    );
  }

  static Future<void> editProduct(
    BuildContext context,
    Menu menu,
    MenuItem product,
  ) async {
    final panel = context.read<ComercioPanelProvider>();
    await ProductFormDialog.show(
      context,
      takenNames: [for (final p in menu.products) p.name],
      existing: product,
      onSave: (updated) async {
        await _repository.updateProducto(menuId: menu.id!, producto: updated);
        final index = menu.products.indexOf(product);
        if (index != -1) menu.products[index] = updated;
        panel.menusChanged();
      },
    );
  }

  static Future<void> deleteProduct(
    BuildContext context,
    Menu menu,
    MenuItem product,
  ) async {
    final panel = context.read<ComercioPanelProvider>();
    final id = product.id;
    if (id == null) return;
    try {
      await _repository.deleteProducto(id);
      menu.products.remove(product);
      panel.menusChanged();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.menuDetailSaveErrorSnackbar)),
      );
    }
  }

  static Future<void> openDetail(BuildContext context, Menu menu) async {
    final panel = context.read<ComercioPanelProvider>();
    final deleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => MenuDetailScreen(menu: menu)),
    );
    // `MenuDetailScreen` edita `menu.products` en sitio.
    if (deleted == true) {
      panel.removeMenu(menu);
    } else {
      panel.menusChanged();
    }
  }

  static void confirmDelete(BuildContext context, Menu menu) {
    final panel = context.read<ComercioPanelProvider>();
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
                Navigator.pop(dialogContext);
                final id = menu.id;
                if (id == null) return;
                try {
                  await _repository.deleteMenu(id);
                  panel.removeMenu(menu);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.menuDetailMenuDeletedSnackbar),
                    ),
                  );
                } catch (_) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.menuDetailSaveErrorSnackbar),
                    ),
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

/// Un menú: encabezado (nombre, categoría, disponibilidad y acciones) y
/// sus productos agrupados por tipo en `auto-fill minmax(260, 1fr)`.
class _MenuBlock extends StatelessWidget {
  const _MenuBlock({required this.menu, required this.products});

  final Menu menu;

  /// Platos a mostrar (todos, o los que coinciden con la búsqueda).
  final List<MenuItem> products;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status = menu.isAvailable
        ? l10n.menuDetailStatusAvailable
        : l10n.menuDetailStatusUnavailable;
    final mobile = context.isMobile;
    final block = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 16,
          runSpacing: 10,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(menu.name, style: AppText.display(26)),
                const SizedBox(height: 4),
                Text(
                  '${menu.category} · $status'.toUpperCase(),
                  style: AppText.label(
                    10,
                    color: menu.isAvailable
                        ? AppColors.inkSoft
                        : AppColors.textLabel,
                  ),
                ),
                if (menu.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Text(
                      menu.description,
                      style: AppText.ui(13, color: AppColors.textMuted),
                    ),
                  ),
                ],
              ],
            ),
            if (mobile)
              Row(
                children: [
                  TextLink(
                    label: l10n.comercioAddProductShort,
                    onTap: () => _MenuActions.addProduct(context, menu),
                  ),
                  const SizedBox(width: 18),
                  TextLink(
                    label: l10n.comercioMenuDetailLink,
                    onTap: () => _MenuActions.openDetail(context, menu),
                  ),
                  const Spacer(),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: l10n.menuDetailDeleteButton,
                    icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                    onPressed: () => _MenuActions.confirmDelete(context, menu),
                  ),
                ],
              )
            else
            Wrap(
              spacing: 18,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TextLink(
                  label: l10n.comercioAddProductShort,
                  onTap: () => _MenuActions.addProduct(context, menu),
                ),
                TextLink(
                  label: l10n.comercioMenuDetailLink,
                  onTap: () => _MenuActions.openDetail(context, menu),
                ),
                IconButton(
                  tooltip: l10n.menuDetailDeleteButton,
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: AppColors.error,
                  ),
                  onPressed: () => _MenuActions.confirmDelete(context, menu),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (products.isEmpty)
          Text(
            l10n.menuDetailNoProductsTitle,
            style: AppText.ui(14, color: AppColors.textMuted),
          )
        else
          for (final entry
              in menu
                  .copyWith(products: products)
                  .productsByCategory
                  .entries) ...[
            Text(
              productCategoryLabel(
                context,
                entry.key,
                plural: true,
              ).toUpperCase(),
              style: AppText.label(11).copyWith(letterSpacing: 11 * 0.16),
            ),
            const SizedBox(height: 12),
            _ProductGrid(menu: menu, products: entry.value),
            const SizedBox(height: 22),
          ],
      ],
    );
    if (!mobile) return block;
    // Móvil: cada menú en su bloque `paperDeep` para que las acciones y
    // los productos se lean como parte de ese menú.
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
      decoration: BoxDecoration(
        color: AppColors.paperDeep,
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
      ),
      child: block,
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.menu, required this.products});

  final Menu menu;
  final List<MenuItem> products;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 14.0;
        final columns = ((constraints.maxWidth + gap) / (260 + gap))
            .floor()
            .clamp(1, 99);
        final itemWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var i = 0; i < products.length; i++)
              SizedBox(
                width: itemWidth,
                child: StaggerIn(
                  index: i,
                  child: _ProductCard(menu: menu, product: products[i]),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Tarjeta blanca: nombre display 22, precio mono y descripción. Toda la
/// tarjeta edita el producto; el icono elimina.
class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.menu, required this.product});

  final Menu menu;
  final MenuItem product;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (context.isMobile) return _buildCompact(context);
    return HoverCard(
      onTap: () => _MenuActions.editProduct(context, menu, product),
      radius: AppRadius.card,
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: AppText.display(22).copyWith(height: 1.1),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  context.formatMoney(product.price),
                  style: AppText.label(
                    13,
                    color: AppColors.inkSoft,
                  ).copyWith(letterSpacing: 0),
                ),
              ],
            ),
          ),
          if (product.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                product.description,
                style: AppText.ui(13, color: AppColors.textMuted, height: 1.5),
              ),
            ),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: l10n.menuDetailEditButton,
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppColors.textLabel,
                  ),
                  onPressed: () =>
                      _MenuActions.editProduct(context, menu, product),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: l10n.menuDetailDeleteButton,
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: AppColors.textLabel,
                  ),
                  onPressed: () =>
                      _MenuActions.deleteProduct(context, menu, product),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Móvil: precio y acciones a la derecha en la misma fila (antes iban
  /// en una fila aparte y cada tarjeta medía el doble).
  Widget _buildCompact(BuildContext context) {
    final l10n = context.l10n;
    return HoverCard(
      onTap: () => _MenuActions.editProduct(context, menu, product),
      radius: AppRadius.card,
      padding: const EdgeInsets.fromLTRB(18, 14, 6, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: AppText.display(20).copyWith(height: 1.1)),
                if (product.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.ui(13, color: AppColors.textMuted),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 2),
                child: Text(
                  context.formatMoney(product.price),
                  style: AppText.label(13, color: AppColors.inkSoft).copyWith(letterSpacing: 0),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: l10n.menuDetailEditButton,
                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textLabel),
                    onPressed: () => _MenuActions.editProduct(context, menu, product),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: l10n.menuDetailDeleteButton,
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textLabel),
                    onPressed: () => _MenuActions.deleteProduct(context, menu, product),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
