import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../widgets/load_error_box.dart';
import '../../data/models/seguridad_stats.dart';
import '../../providers/security_map_provider.dart';
import '../incidencia_style.dart';

/// Botón para mostrar/ocultar la capa y, con la capa activa, la leyenda
/// (o el error / "sin datos"). Va en una esquina del mapa.
class SecurityLayerControls extends StatelessWidget {
  const SecurityLayerControls({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SecurityMapProvider>();
    final metadatos = provider.metadatos;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 260),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.capaVisible) ...[
            if (provider.loadFailed)
              LoadErrorBox(
                message: context.l10n.securityLoadError,
                onRetry: provider.retry,
              )
            else if (metadatos != null && !metadatos.hayDatos)
              _Card(
                child: Text(
                  context.l10n.securityNoData,
                  style: AppText.ui(12, color: AppColors.textMuted),
                ),
              )
            else if (metadatos != null)
              _Legend(metadatos: metadatos),
            const SizedBox(height: 10),
          ],
          _ToggleButton(
            active: provider.capaVisible,
            loading: provider.isLoading,
            onTap: () => provider.setCapaVisible(!provider.capaVisible),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.active,
    required this.loading,
    required this.onTap,
  });

  final bool active;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = active ? AppColors.mint : AppColors.ink;
    return Semantics(
      button: true,
      toggled: active,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: AppMotion.toggle,
            curve: AppMotion.press,
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: active ? AppColors.ink : AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: active ? null : Border.all(color: AppColors.line),
              boxShadow: AppShadow.raised,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (loading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                  )
                else
                  Icon(Icons.shield_outlined, size: 18, color: fg),
                const SizedBox(width: 8),
                Text(
                  context.l10n.securityLayerToggle,
                  style: AppText.ui(13, weight: FontWeight.w600, color: fg),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.metadatos});

  final SeguridadMetadatos metadatos;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.securityIndexTitle,
            style: AppText.ui(12, weight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            context.l10n.securityLegendSubtitle(periodoLabel(context, metadatos)),
            style: AppText.ui(11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          for (final nivel in NivelIncidencia.values.reversed)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: nivel.color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      nivel.label(context),
                      style: AppText.ui(12),
                    ),
                  ),
                  Text(
                    rangoNivel(nivel, metadatos),
                    style: AppText.label(10),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Text(
            '${context.l10n.securitySourceLabel}: Alcaldía de Medellín (SISC)',
            style: AppText.ui(10, color: AppColors.textLabel),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadow.raised,
      ),
      child: child,
    );
  }
}
