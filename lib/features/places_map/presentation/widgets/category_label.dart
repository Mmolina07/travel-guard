import 'package:flutter/widgets.dart';

import '../../../../core/l10n/l10n_extension.dart';

/// Traduce una categoría de `categorias_lugar`/`categorias_comercio` (tal
/// como viene de Supabase, ej. `place.categoria`) a su etiqueta visible en
/// el idioma actual — sin tocar el valor guardado/comparado en ningún
/// lado: `place.categoria`, `_selectedCategory`, etc. siguen siendo el
/// string original en español.
///
/// Si aparece una categoría nueva en la BD que no está en este mapa, se
/// muestra tal cual llegó (nunca queda en blanco ni rompe la pantalla).
String localizedCategoryLabel(BuildContext context, String categoria) {
  switch (categoria.trim().toLowerCase()) {
    case 'comercio':
      return context.l10n.placeCategoryComercio;
    case 'discoteca':
      return context.l10n.placeCategoryDiscoteca;
    case 'mirador':
      return context.l10n.placeCategoryMirador;
    case 'museo':
      return context.l10n.placeCategoryMuseo;
    case 'parque':
      return context.l10n.placeCategoryParque;
    case 'restaurante':
      return context.l10n.placeCategoryRestaurante;
    case 'tour':
      return context.l10n.placeCategoryTour;
    case 'hotel':
      return context.l10n.placeCategoryHotel;
    case 'tienda':
      return context.l10n.placeCategoryTienda;
    case 'transporte':
      return context.l10n.placeCategoryTransporte;
    case 'otro':
      return context.l10n.placeCategoryOtro;
    default:
      return categoria;
  }
}

/// Traduce la opción especial "Todos" del filtro de categorías (no es una
/// categoría real de la BD, es un valor centinela del cliente).
String localizedCategoryOrAll(BuildContext context, String categoria) {
  return categoria == 'Todos'
      ? context.l10n.categoryFilterAll
      : localizedCategoryLabel(context, categoria);
}
