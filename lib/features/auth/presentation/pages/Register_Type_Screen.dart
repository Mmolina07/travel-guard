import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/widgets/auth_screen_shell.dart';
import "../widgets/Register_Type_Card.dart";
import "../pages/Comercio_Register_Screen.dart";
import "../pages/client_register_screen.dart";

class RegisterTypeScreen extends StatelessWidget {
  const RegisterTypeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthScreenShell(
      title: context.l10n.registerTypeTitle,
      subtitle: context.l10n.registerTypeSubtitle,
      content: (context) => Column(
        children: [
          RegisterTypeCard(
            icon: Icons.person,
            title: context.l10n.registerTypeTouristTitle,
            description: context.l10n.registerTypeTouristDescription,
            onTap: () => _handleTuristaSelection(context),
          ),
          const SizedBox(height: 16),
          RegisterTypeCard(
            icon: Icons.storefront,
            title: context.l10n.registerTypeCommerceTitle,
            description: context.l10n.registerTypeCommerceDescription,
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
