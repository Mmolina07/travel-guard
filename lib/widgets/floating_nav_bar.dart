import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'pressable.dart';

/// Nav flotante — **solo móvil** (`< AppBreakpoints.mobile`). En
/// tablet/escritorio la navegación vive en el `SideNav` de `AppShell`.
/// 3 destinos + un único FAB central que abre "Crear viaje" mediante
/// `Hero` (ver `HeroScaleRoute`).
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.index,
    required this.onSelect,
    required this.onCreate,
    this.fabHeroTag = 'create-trip',
  });

  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onCreate;
  final Object fabHeroTag;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(22, 0, 22, 22),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppRadius.nav),
        boxShadow: AppShadow.raised,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavItem(
            label: 'Inicio',
            active: index == 0,
            onTap: () => onSelect(0),
          ),
          _NavItem(label: 'Mapa', active: index == 1, onTap: () => onSelect(1)),
          Pressable(
            onTap: onCreate,
            semanticLabel: 'Crear viaje',
            child: Hero(
              tag: fabHeroTag,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: AppShadow.inkButton,
                ),
                child: const Icon(Icons.add, color: AppColors.mint, size: 24),
              ),
            ),
          ),
          _NavItem(
            label: 'Comercios',
            active: index == 2,
            onTap: () => onSelect(2),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.toggle,
          curve: AppMotion.enter,
          padding:
              EdgeInsets.symmetric(horizontal: active ? 16 : 12, vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.wash : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: AnimatedDefaultTextStyle(
            duration: AppMotion.toggle,
            style: AppText.ui(
              13,
              weight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? AppColors.ink : AppColors.textMuted,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
