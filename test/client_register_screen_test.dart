import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travelguard/features/auth/presentation/pages/client_register_screen.dart';

void main() {
  testWidgets(
    'ClienteRegisterScreen muestra el formulario de registro de turista',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ClienteRegisterScreen()),
      );

      expect(find.text('Registro de turista'), findsOneWidget);
      expect(find.text('Nombre completo'), findsOneWidget);
      expect(find.text('Correo electrónico'), findsOneWidget);
      expect(find.text('Registrarse'), findsOneWidget);
      expect(find.text('Registrarse con Google'), findsOneWidget);
    },
  );

  testWidgets(
    'Muestra errores de validación al enviar el formulario vacío',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ClienteRegisterScreen()),
      );

      // No toca AppAuthProvider/Firebase: el formulario vacío nunca pasa
      // de _formKey.currentState!.validate().
      final registrarseButton = find.text('Registrarse');
      await tester.ensureVisible(registrarseButton);
      await tester.tap(registrarseButton);
      await tester.pump();

      expect(find.text('Por favor ingresa tu nombre'), findsOneWidget);
    },
  );
}
