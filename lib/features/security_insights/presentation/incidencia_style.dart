import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../data/models/seguridad_stats.dart';

/// Colores del índice sobre el mapa oscuro (estilo petróleo). El nivel
/// siempre va acompañado de su nombre: no depende solo del color.
extension NivelIncidenciaStyle on NivelIncidencia {
  Color get color => switch (this) {
        NivelIncidencia.bajo => const Color(0xFF4CAF7A),
        NivelIncidencia.medio => const Color(0xFFF2C94C),
        NivelIncidencia.alto => const Color(0xFFF2994A),
        NivelIncidencia.muyAlto => const Color(0xFFE5534B),
      };

  String label(BuildContext context) => switch (this) {
        NivelIncidencia.bajo => context.l10n.securityLevelLow,
        NivelIncidencia.medio => context.l10n.securityLevelMedium,
        NivelIncidencia.alto => context.l10n.securityLevelHigh,
        NivelIncidencia.muyAlto => context.l10n.securityLevelVeryHigh,
      };
}

/// Rango "0–24", "25–49"… de cada nivel según los umbrales configurados.
String rangoNivel(NivelIncidencia nivel, SeguridadMetadatos m) =>
    switch (nivel) {
      NivelIncidencia.bajo => '0–${m.umbralMedio - 1}',
      NivelIncidencia.medio => '${m.umbralMedio}–${m.umbralAlto - 1}',
      NivelIncidencia.alto => '${m.umbralAlto}–${m.umbralMuyAlto - 1}',
      NivelIncidencia.muyAlto => '${m.umbralMuyAlto}–100',
    };

/// "ene 2021 – nov 2023" en el idioma de la app.
String periodoLabel(BuildContext context, SeguridadMetadatos m) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final f = DateFormat.yMMM(locale);
  return '${f.format(m.periodoInicio)} – ${f.format(m.periodoFin)}';
}

String formatoEntero(BuildContext context, num n) =>
    NumberFormat.decimalPattern(Localizations.localeOf(context).toLanguageTag())
        .format(n);
