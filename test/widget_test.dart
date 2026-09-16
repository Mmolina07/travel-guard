import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travelguard/features/auth/presentation/pages/login_screen.dart';

void main() {
  testWidgets('LoginScreen muestra el nombre de la app y los accesos de auth',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('TRAVELGUARD'), findsOneWidget);
    expect(find.text('Turista'), findsOneWidget);
    expect(find.text('Continuar con Google'), findsOneWidget);
  });
}
