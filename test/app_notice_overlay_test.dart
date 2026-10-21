import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:travelguard/core/notifications/app_notice_center.dart';
import 'package:travelguard/core/notifications/app_notice_overlay.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('muestra la notificación encima de la app y se puede cerrar', (tester) async {
    final center = AppNoticeCenter();
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, _) => const Scaffold(body: Text('inicio'))),
      GoRoute(path: '/viajes/1', builder: (_, _) => const Scaffold(body: Text('detalle'))),
    ]);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: center,
        child: MaterialApp.router(
          routerConfig: router,
          builder: (context, child) => AppNoticeOverlay(router: router, child: child!),
        ),
      ),
    );

    center.push(AppNotice(
      key: 'budget_1',
      tone: AppNoticeTone.warning,
      icon: Icons.warning_amber_rounded,
      title: 'Has gastado el 75% de tu presupuesto diario',
      message: 'Cartagena: te quedan \$25.000 para hoy.',
      route: '/viajes/1',
    ));
    await tester.pumpAndSettle();
    expect(find.text('Has gastado el 75% de tu presupuesto diario'), findsOneWidget);

    // Un aviso con la misma clave reemplaza al anterior (no se apilan).
    center.push(AppNotice(
      key: 'budget_1',
      tone: AppNoticeTone.danger,
      icon: Icons.error_outline_rounded,
      title: 'Has alcanzado tu límite diario',
      message: 'Cartagena',
      route: '/viajes/1',
    ));
    await tester.pumpAndSettle();
    expect(find.text('Has gastado el 75% de tu presupuesto diario'), findsNothing);
    expect(find.text('Has alcanzado tu límite diario'), findsOneWidget);

    // Tocarla lleva al viaje y la cierra.
    await tester.tap(find.text('Has alcanzado tu límite diario'));
    await tester.pumpAndSettle();
    expect(find.text('detalle'), findsOneWidget);
    expect(center.notices, isEmpty);

    // Se cierra sola a los 10 s.
    center.push(AppNotice(
      key: 'x',
      tone: AppNoticeTone.info,
      icon: Icons.info_outline,
      title: 'Recordatorio',
      message: '...',
    ));
    await tester.pumpAndSettle();
    expect(find.text('Recordatorio'), findsOneWidget);
    await tester.pump(const Duration(seconds: 11));
    await tester.pumpAndSettle();
    expect(find.text('Recordatorio'), findsNothing);
  });
}
