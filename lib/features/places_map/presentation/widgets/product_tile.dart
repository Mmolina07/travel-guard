import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/settings/currency_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../menu_model.dart';
import 'product_form_dialog.dart';

/// Fila de producto del menú (HU-20): icono del tipo, nombre,
/// descripción opcional y precio en mono `inkSoft`; editar/eliminar a
/// la derecha si se pasan los callbacks.
class ProductTile extends StatelessWidget {
  const ProductTile({super.key, required this.product, this.onEdit, this.onDelete});

  final MenuItem product;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadow.card,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.wash,
              borderRadius: BorderRadius.circular(AppRadius.control),
            ),
            child: Icon(productCategoryIcon(product.category), color: AppColors.ink, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: AppText.ui(16, weight: FontWeight.w600)),
                if (product.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.ui(13, color: AppColors.textMuted),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  context.formatMoney(product.price),
                  style: AppText.label(12, color: AppColors.inkSoft, weight: FontWeight.w700),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              tooltip: context.l10n.menuDetailEditButton,
              icon: const Icon(Icons.edit_outlined, color: AppColors.ink, size: 20),
              onPressed: onEdit,
            ),
          if (onDelete != null)
            IconButton(
              tooltip: context.l10n.menuDetailDeleteButton,
              icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}

/// Encabezado de sección de productos (PLATOS · 3), mono `inkSoft`.
class ProductCategoryHeading extends StatelessWidget {
  const ProductCategoryHeading({super.key, required this.category, required this.count});

  final ProductCategory category;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 12),
      child: Row(
        children: [
          Icon(productCategoryIcon(category), size: 16, color: AppColors.inkSoft),
          const SizedBox(width: 8),
          Text(
            '${productCategoryLabel(context, category, plural: true).toUpperCase()} · $count',
            style: AppText.label(11, color: AppColors.inkSoft, weight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
