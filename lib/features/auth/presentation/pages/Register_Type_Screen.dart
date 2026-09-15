import 'package:flutter/material.dart';

import '../../../../core/widgets/auth_screen_shell.dart';
import "../widgets/Register_Type_Card.dart";
import "../pages/Comercio_Register_Screen.dart";
import "../pages/client_register_screen.dart";

class RegisterTypeScreen extends StatelessWidget {
  const RegisterTypeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthScreenShell(
      title: '¿Cómo te quieres registrar?',
      subtitle: 'Selecciona cómo quieres registrarte en TravelGuard.',
      content: (context) => Column(
        children: [
          RegisterTypeCard(
            icon: Icons.person,
            title: 'Turista',
            description:
                'Accede a experiencias, mapas, recomendaciones y más.',
            onTap: () => _handleTuristaSelection(context),
          ),
          const SizedBox(height: 16),
          RegisterTypeCard(
            icon: Icons.storefront,
            title: 'Comercio',
            description: 'Registra tu negocio y llega a más visitantes.',
            onTap: () => _handleComercioSelection(context),
          ),
        ],
      ),
    );
  }

  //Navegacion a registro de Turista y Comercio
  void _handleTuristaSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ClienteRegisterScreen()),
    );
  }

  void _handleComercioSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ComercioRegisterScreen()),
    );
  }
}
