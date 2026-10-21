import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/settings/currency_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../widgets/pressable.dart';
import '../../data/models/actividad_model.dart';
import '../../providers/comercio_panel_provider.dart';

// Piezas compartidas del panel del comercio (`PROMPT_COMERCIO.md`):
// formato de actividades, badge de estado, interruptor 30×18, caja de
// borde discontinuo y el marco de los modales (vista previa `ink` +
// formulario).

/// Valores de `actividades.estado` en Supabase — NO traducir.
abstract final class EstadoActividad {
  static const activa = 'activa';
  static const pausada = 'pausada';
  static const borrador = 'borrador';

  /// Orden del `SegmentedPill` del modal (Borrador / Publicada / Pausada).
  static const ordenados = [borrador, activa, pausada];

  /// Filas antiguas sin `estado` se tratan como borrador.
  static String normalizar(String? estado) =>
      ordenados.contains(estado) ? estado! : borrador;
}

String estadoActividadLabel(BuildContext context, String? estado) {
  final l10n = context.l10n;
  return switch (EstadoActividad.normalizar(estado)) {
    EstadoActividad.activa => l10n.comercioStatusPublished,
    EstadoActividad.pausada => l10n.comercioStatusPaused,
    _ => l10n.comercioStatusDraft,
  };
}

(Color, Color) estadoActividadColors(String? estado) =>
    switch (EstadoActividad.normalizar(estado)) {
      EstadoActividad.activa => (
        AppColors.statusPublished,
        AppColors.statusPublishedText,
      ),
      EstadoActividad.pausada => (
        AppColors.statusPaused,
        AppColors.statusPausedText,
      ),
      _ => (AppColors.statusDraft, AppColors.statusDraftText),
    };

/// `null` = todas.
String? estadoDeFiltro(ActividadFiltro filtro) => switch (filtro) {
  ActividadFiltro.todas => null,
  ActividadFiltro.borrador => EstadoActividad.borrador,
  ActividadFiltro.publicada => EstadoActividad.activa,
  ActividadFiltro.pausada => EstadoActividad.pausada,
};

String actividadFiltroLabel(BuildContext context, ActividadFiltro filtro) {
  final l10n = context.l10n;
  return switch (filtro) {
    ActividadFiltro.todas => l10n.comercioFilterAll,
    ActividadFiltro.borrador => l10n.comercioStatusDraft,
    ActividadFiltro.publicada => l10n.comercioStatusPublished,
    ActividadFiltro.pausada => l10n.comercioStatusPaused,
  };
}

/// "12 OCT" con los meses ya localizados del shell.
String formatDiaMes(BuildContext context, DateTime date) {
  final l10n = context.l10n;
  final months = [
    l10n.appShellMonthJan,
    l10n.appShellMonthFeb,
    l10n.appShellMonthMar,
    l10n.appShellMonthApr,
    l10n.appShellMonthMay,
    l10n.appShellMonthJun,
    l10n.appShellMonthJul,
    l10n.appShellMonthAug,
    l10n.appShellMonthSep,
    l10n.appShellMonthOct,
    l10n.appShellMonthNov,
    l10n.appShellMonthDec,
  ];
  final day = date.day.toString().padLeft(2, '0');
  return '$day ${months[date.month - 1].toUpperCase()}';
}

/// "01 OCT — 31 OCT", "Desde 12 OCT" (sin fecha de fin) o "Sin fecha".
String formatActividadFechas(
  BuildContext context, {
  required DateTime? inicio,
  required DateTime? fin,
}) {
  if (inicio == null) return context.l10n.comercioDatesNone;
  final a = formatDiaMes(context, inicio);
  if (fin == null) return context.l10n.comercioDatesFrom(a);
  return '$a — ${formatDiaMes(context, fin)}';
}

/// Precio en la moneda elegida, o "Gratis" si no tiene.
String formatActividadPrecio(BuildContext context, Actividad actividad) {
  final precio = actividad.precio;
  if (precio == null || precio <= 0) return context.l10n.comercioFree;
  return context.formatMoney(precio);
}

IconData activityCategoryIcon(String? category) {
  switch (category) {
    case 'Fiesta':
      return Icons.celebration_outlined;
    case 'Tour':
      return Icons.tour_outlined;
    case 'Promoción':
      return Icons.local_offer_outlined;
    case 'Clase':
      return Icons.school_outlined;
    case 'Evento':
      return Icons.event_outlined;
    default:
      return Icons.event_note_outlined;
  }
}

/// Badge de estado (Publicada / Borrador / Pausada).
class EstadoBadge extends StatelessWidget {
  const EstadoBadge({super.key, required this.estado});

  final String? estado;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = estadoActividadColors(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        estadoActividadLabel(context, estado),
        style: AppText.ui(12, weight: FontWeight.w600, color: fg),
      ),
    );
  }
}

/// Etiqueta "PREMIUM": actividad o promoción exclusiva para turistas
/// con suscripción.
class PremiumTag extends StatelessWidget {
  const PremiumTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspace_premium_outlined, size: 11, color: AppColors.mint),
          const SizedBox(width: 3),
          Text(
            context.l10n.comercioPremiumBadge,
            style: AppText.label(9, color: AppColors.mint),
          ),
        ],
      ),
    );
  }
}

/// Interruptor 30×18: pista `hair`/`inkSoft` y knob blanco con
/// `easeOutBack`.
class MiniSwitch extends StatelessWidget {
  const MiniSwitch({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final bool value;
  final String label;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: label,
      child: MouseRegion(
        cursor: onChanged == null
            ? MouseCursor.defer
            : SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onChanged == null ? null : () => onChanged!(!value),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label.isNotEmpty) ...[
                Text(label, style: AppText.ui(12, color: AppColors.textMuted)),
                const SizedBox(width: 6),
              ],
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: AppMotion.press,
                width: 30,
                height: 18,
                decoration: BoxDecoration(
                  color: value ? AppColors.inkSoft : AppColors.hair,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: AppMotion.enter,
                      top: 2,
                      left: value ? 14 : 2,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botón compacto de las tarjetas de acción ("+ Actividad" / "+ Menú"):
/// relleno `ink` o con borde `ink`.
class SmallInkButton extends StatelessWidget {
  const SmallInkButton({
    super.key,
    required this.label,
    required this.onTap,
    this.outlined = false,
    this.radius = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    this.fontSize = 13,
    this.shadow,
  });

  final String label;
  final VoidCallback? onTap;
  final bool outlined;
  final double radius;
  final EdgeInsets padding;
  final double fontSize;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: AppMotion.pressIn,
        opacity: onTap == null ? 0.45 : 1,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: outlined ? Colors.transparent : AppColors.ink,
            border: outlined ? Border.all(color: AppColors.ink) : null,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: outlined ? null : shadow,
          ),
          // Centrado cuando se estira (p.ej. dentro de un `Expanded`); con
          // los factores en 1 sigue midiendo lo que su texto si no.
          child: Align(
            widthFactor: 1,
            heightFactor: 1,
            child: Text(
              label,
              style: AppText.ui(
                fontSize,
                weight: FontWeight.w700,
                color: outlined ? AppColors.ink : AppColors.paper,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Enlace de texto (`inkSoft` w600) o etiqueta mono ("VER TODAS").
class TextLink extends StatelessWidget {
  const TextLink({
    super.key,
    required this.label,
    required this.onTap,
    this.mono = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          mono ? label.toUpperCase() : label,
          style: mono
              ? AppText.label(
                  11,
                  color: AppColors.inkSoft,
                ).copyWith(letterSpacing: 11 * 0.12)
              : AppText.ui(
                  14,
                  weight: FontWeight.w600,
                  color: AppColors.inkSoft,
                ),
        ),
      ),
    );
  }
}

/// Caja con borde discontinuo de 1.5 px `hair`, radio 24 (estados
/// vacíos).
class DashedBox extends StatelessWidget {
  const DashedBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 34),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  static const _radius = 24.0;
  static const _dash = 6.0;
  static const _gap = 5.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.hair
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(0.75),
      const Radius.circular(_radius),
    );
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + _dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Etiqueta mono 10 `textLabel` de los campos del modal.
class FieldCaption extends StatelessWidget {
  const FieldCaption(this.text, {super.key, this.color = AppColors.textLabel});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppText.label(10, color: color).copyWith(letterSpacing: 10 * 0.16),
    );
  }
}

/// Texto de error de campo: #B4413A 12/w500.
class FieldError extends StatelessWidget {
  const FieldError(this.message, {super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final message = this.message;
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        message,
        style: AppText.ui(12, weight: FontWeight.w500, color: AppColors.error),
      ),
    );
  }
}

/// Marco de los modales del comercio ("Crear actividad", "Nuevo menú"):
///
/// * Escritorio/tablet ([asDialog]): overlay `ink` al 55 % con blur 3 y
///   caja `paper` radio 34, `maxWidth` 980, en dos columnas 320 : resto
///   (columna izquierda `ink` = [preview]). Si la ventana es más baja que
///   la caja, scrollea desde arriba sin cortarse (`SingleChildScrollView`
///   + `ConstrainedBox(minHeight)` + `Center`). Con poco ancho, la vista
///   previa pasa arriba del formulario.
/// * Móvil: pantalla completa con la vista previa arriba.
class ComercioModalFrame extends StatelessWidget {
  const ComercioModalFrame({
    super.key,
    required this.asDialog,
    required this.preview,
    required this.form,
    required this.onDismiss,
  });

  final bool asDialog;
  final Widget preview;
  final Widget form;

  /// Tocar el overlay (fuera de la caja). `null` mientras guarda.
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    if (!asDialog) {
      return Scaffold(
        backgroundColor: AppColors.paper,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: AppColors.ink,
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 26),
                  child: preview,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                  child: form,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: ColoredBox(color: AppColors.ink.withValues(alpha: 0.55)),
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - 56).clamp(
                    0,
                    double.infinity,
                  ),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: GestureDetector(
                      onTap:
                          () {}, // Absorbe el tap: no cierra al tocar dentro.
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(34),
                          boxShadow: AppShadow.modal,
                        ),
                        child: Material(
                          color: AppColors.paper,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(34),
                          ),
                          child: LayoutBuilder(
                            builder: (context, box) {
                              if (box.maxWidth < 760) {
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      color: AppColors.ink,
                                      padding: const EdgeInsets.fromLTRB(
                                        26,
                                        30,
                                        26,
                                        26,
                                      ),
                                      child: preview,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        28,
                                        28,
                                        28,
                                        28,
                                      ),
                                      child: form,
                                    ),
                                  ],
                                );
                              }
                              // La columna `ink` se pinta como fondo
                              // posicionado para que ocupe todo el alto
                              // sin `IntrinsicHeight` (el formulario
                              // tiene `LayoutBuilder`s que no lo admiten).
                              return Stack(
                                children: [
                                  const Positioned(
                                    left: 0,
                                    top: 0,
                                    bottom: 0,
                                    width: 320,
                                    child: ColoredBox(color: AppColors.ink),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 320,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            26,
                                            30,
                                            26,
                                            30,
                                          ),
                                          child: preview,
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            32,
                                            28,
                                            32,
                                            28,
                                          ),
                                          child: form,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Título de la vista previa: "Así la verán / *los turistas*".
class PreviewHeading extends StatelessWidget {
  const PreviewHeading({
    super.key,
    required this.eyebrow,
    required this.line1,
    required this.line2,
  });

  final String eyebrow;
  final String line1;
  final String line2;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldCaption(eyebrow, color: AppColors.textOnInk),
        const SizedBox(height: 14),
        Text(line1, style: AppText.display(32, color: AppColors.paper)),
        Text(line2, style: AppText.displayItalic(32, color: AppColors.mint)),
      ],
    );
  }
}

/// Punto de color + nota al pie de la vista previa.
class PreviewStatusNote extends StatelessWidget {
  const PreviewStatusNote({super.key, required this.color, required this.note});

  final Color color;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: AppMotion.toggle,
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(note, style: AppText.ui(13, color: AppColors.textOnInk)),
        ),
      ],
    );
  }
}

/// Pie de los modales: borde superior 1 px `line`, "Cancelar" con borde
/// y el botón primario (al 45 % y deshabilitado si [onSubmit] es `null`).
class ModalFooter extends StatelessWidget {
  const ModalFooter({
    super.key,
    required this.cancelLabel,
    required this.submitLabel,
    required this.onCancel,
    required this.onSubmit,
    required this.loading,
  });

  final String cancelLabel;
  final String submitLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onSubmit;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final enabled = onSubmit != null && !loading;
    return Container(
      padding: const EdgeInsets.only(top: 18),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 10,
        runSpacing: 10,
        children: [
          Pressable(
            onTap: onCancel,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.hair),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                cancelLabel,
                style: AppText.ui(15, weight: FontWeight.w600),
              ),
            ),
          ),
          Pressable(
            onTap: enabled ? onSubmit : null,
            child: AnimatedOpacity(
              duration: AppMotion.pressIn,
              opacity: onSubmit == null ? 0.45 : 1,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: AppShadow.inkButton,
                ),
                child: loading
                    ? const SizedBox(
                        width: 18,
                        height: 21,
                        child: Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.mint,
                            ),
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            submitLabel,
                            style: AppText.ui(
                              15,
                              weight: FontWeight.w700,
                              color: AppColors.paper,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '→',
                            style: AppText.ui(15, color: AppColors.mint),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón cerrar 34×34 radio 12 con borde `hair`.
class ModalCloseButton extends StatelessWidget {
  const ModalCloseButton({
    super.key,
    required this.onTap,
    required this.tooltip,
  });

  final VoidCallback? onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Pressable(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.hair),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.close, size: 16, color: AppColors.ink),
        ),
      ),
    );
  }
}
