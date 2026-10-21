import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../../widgets/pressable.dart';
import 'app_notice_center.dart';

/// Pinta las [AppNotice] de [AppNoticeCenter] encima de la app (vive en
/// el `builder` de `MaterialApp.router`, por encima del `Navigator`):
/// arriba a la derecha en escritorio, arriba a todo el ancho en móvil.
class AppNoticeOverlay extends StatefulWidget {
  const AppNoticeOverlay({super.key, required this.router, required this.child});

  final GoRouter router;
  final Widget child;

  @override
  State<AppNoticeOverlay> createState() => _AppNoticeOverlayState();
}

class _AppNoticeOverlayState extends State<AppNoticeOverlay> {
  @override
  void initState() {
    super.initState();
    context.read<AppNoticeCenter>().navigate =
        (route, extra) => widget.router.go(route, extra: extra);
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child;
    final notices = context.watch<AppNoticeCenter>().notices;
    final isMobile = MediaQuery.sizeOf(context).width < AppBreakpoints.mobile;
    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          right: isMobile ? 16 : 22,
          left: isMobile ? 16 : null,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: isMobile ? 8 : 22),
              child: SizedBox(
                width: isMobile ? null : 380,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final notice in notices)
                      _NoticeCard(
                        key: ValueKey(notice.key),
                        notice: notice,
                        onOpen: notice.route == null
                            ? null
                            : () => context.read<AppNoticeCenter>().open(notice),
                        onDismiss: () => context.read<AppNoticeCenter>().dismiss(notice.key),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NoticeCard extends StatefulWidget {
  const _NoticeCard({super.key, required this.notice, required this.onDismiss, this.onOpen});

  final AppNotice notice;
  final VoidCallback onDismiss;
  final VoidCallback? onOpen;

  @override
  State<_NoticeCard> createState() => _NoticeCardState();
}

class _NoticeCardState extends State<_NoticeCard> {
  static const _visibleFor = Duration(seconds: 10);
  Timer? _timer;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _restartTimer();
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = Timer(_visibleFor, () {
      if (mounted && !_hovered) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notice = widget.notice;
    final (Color accent, Color background) = switch (notice.tone) {
      AppNoticeTone.info => (AppColors.inkSoft, AppColors.surface),
      AppNoticeTone.warning => (AppColors.warning, AppColors.warningWash),
      AppNoticeTone.nearLimit => (AppColors.warning, AppColors.warningWash),
      AppNoticeTone.danger => (AppColors.error, AppColors.errorWash),
    };

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.listItem,
      curve: AppMotion.enter,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.translate(offset: Offset(0, (1 - t) * -16), child: child),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) {
            setState(() => _hovered = false);
            _restartTimer();
          },
          child: Pressable(
            onTap: widget.onOpen,
            semanticLabel: notice.title,
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: accent, width: 1.2),
                  boxShadow: AppShadow.raised,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(notice.icon, color: accent, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notice.title, style: AppText.ui(14, weight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(notice.message, style: AppText.ui(13, color: AppColors.textMuted)),
                          if (notice.actionLabel != null && widget.onOpen != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              notice.actionLabel!.toUpperCase(),
                              style: AppText.label(10, color: accent, weight: FontWeight.w700),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Sin `Tooltip`: aquí (encima del `Navigator`) no hay
                    // `Overlay` donde mostrarlo.
                    Semantics(
                      button: true,
                      label: MaterialLocalizations.of(context).closeButtonTooltip,
                      child: Pressable(
                        onTap: widget.onDismiss,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.close, size: 18, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
