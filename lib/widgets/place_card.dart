import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'hover_card.dart';

enum PlaceCardVariant { featured, compact }

/// Una etiqueta de la tarjeta destacada — `emphasis: true` para
/// afirmativos tipo "Verificado" (fondo `wash`/texto `inkSoft`),
/// `false` para neutros tipo "Abierto ahora" (fondo `paperDeep`).
class PlaceCardTag {
  const PlaceCardTag(this.label, {this.emphasis = false});

  final String label;
  final bool emphasis;
}

/// Tarjeta de comercio/lugar de interés — sin botón "Ver detalles": la
/// tarjeta completa es el objetivo táctil. `featured` es la anatomía
/// grande (imagen 150, badges, tags); `compact` es la fila angosta
/// (imagen 116 a la izquierda) usada en listas más densas.
class PlaceCard extends StatelessWidget {
  const PlaceCard({
    super.key,
    required this.variant,
    required this.name,
    this.imageUrl,
    this.categoryLabel,
    this.distanceLabel,
    this.address,
    this.description,
    this.tags = const [],
    this.typeLabel,
    this.onTap,
  });

  final PlaceCardVariant variant;
  final String name;
  final String? imageUrl;
  final String? categoryLabel;
  final String? distanceLabel;
  final String? address;
  final String? description;
  final List<PlaceCardTag> tags;
  final String? typeLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return variant == PlaceCardVariant.featured
        ? _buildFeatured(context)
        : _buildCompact(context);
  }

  Widget _buildFeatured(BuildContext context) {
    return HoverCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      radius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
            child: Stack(
              children: [
                _image(width: double.infinity, height: 150),
                if (categoryLabel != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _Badge(
                      text: categoryLabel!,
                      background: AppColors.ink,
                      foreground: AppColors.mint,
                    ),
                  ),
                if (distanceLabel != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _Badge(
                      text: distanceLabel!,
                      background: AppColors.paper.withValues(alpha: 0.92),
                      foreground: AppColors.ink,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.display(26),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward,
                      color: AppColors.inkSoft,
                      size: 20,
                    ),
                  ],
                ),
                if (address != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    address!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.ui(13, color: AppColors.textMuted),
                  ),
                ],
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [for (final t in tags) _Tag(t)],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompact(BuildContext context) {
    final labelParts = [?typeLabel, ?distanceLabel];
    return HoverCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      radius: AppRadius.card,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _image(width: 116, height: 96),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (labelParts.isNotEmpty)
                  Text(labelParts.join(' · '), style: AppText.label(10)),
                const SizedBox(height: 4),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.display(22),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.ui(12, color: AppColors.textMuted),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _image({double? width, double? height}) {
    final placeholder = Container(
      width: width,
      height: height,
      color: AppColors.wash,
      alignment: Alignment.center,
      child: Text('FOTO', style: AppText.label(10)),
    );
    if (imageUrl == null || imageUrl!.isEmpty) return placeholder;
    return Image.network(
      imageUrl!,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => placeholder,
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.tag);

  final PlaceCardTag tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tag.emphasis ? AppColors.wash : AppColors.paperDeep,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Text(
        tag.label,
        style: AppText.ui(
          12,
          weight: FontWeight.w600,
          color: tag.emphasis ? AppColors.inkSoft : AppColors.textMuted,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.text,
    required this.background,
    required this.foreground,
  });

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: AppText.label(10, color: foreground)),
    );
  }
}
