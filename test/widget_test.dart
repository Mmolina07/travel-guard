import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travelguard/features/auth/presentation/Pages/welcome_home.dart';

void main() {
  testWidgets('WelcomeHome muestra el nombre de la app y los accesos de auth',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: WelcomeHome()));

    expect(find.text('TravelGuard'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsOneWidget);
  });
}
