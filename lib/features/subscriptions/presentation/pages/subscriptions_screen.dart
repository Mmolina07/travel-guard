import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/providers/app_auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../trips/presentation/pages/home_screen_client.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  late bool _isAnnual;
  late String _selectedPlan;

  @override
  void initState() {
    super.initState();
    _isAnnual = false;
    _selectedPlan = 'turista'; // Plan seleccionado por defecto
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreenClient()),
            );
          },
        ),
        title: Text(
          'Planes y suscripciones premium',
          style: AppText.ui(18, weight: FontWeight.w600),
        ),
        backgroundColor: AppColors.paper,
        elevation: 0,
        foregroundColor: AppColors.ink,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ========== HEADER ==========
                Text(
                  'Elige tu plan perfecto para mejorar tu experiencia en la aplicación',
                  style: AppText.display(28),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Acceso a todas las características de viajes y experiencias',
                  style: AppText.ui(15, color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // ========== TOGGLE: MENSUAL / ANUAL ==========
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.wash,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _BillingToggle(
                        label: 'Mensual',
                        isSelected: !_isAnnual,
                        onTap: () {
                          setState(() {
                            _isAnnual = false;
                          });
                        },
                      ),
                      _BillingToggle(
                        label: 'Anual (-20%)',
                        isSelected: _isAnnual,
                        onTap: () {
                          setState(() {
                            _isAnnual = true;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // ========== PLANES ==========
                isMobile
                    ? Column(
                        children: [
                          _PlanCard(
                            name: 'Turista',
                            subtitle: 'Perfecto para exploradores',
                            price: _isAnnual ? '29.990' : '3.990',
                            period: _isAnnual ? '/año' : '/mes',
                            color: AppColors.mint,
                            features: [
                              'Busca viajes y experiencias',
                              'Califica y comenta',
                              'Guarda favoritos',
                              'Acceso móvil completo',
                              'Soporte por email',
                            ],
                            isSelected: _selectedPlan == 'turista',
                            onTap: () {
                              setState(() {
                                _selectedPlan = 'turista';
                              });
                              _showSubscriptionDialog(context, 'Turista', '${_isAnnual ? '29.990' : '3.990'} COP');
                            },
                          ),
                      
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _PlanCard(
                              name: 'Turista',
                              subtitle: 'Perfecto para exploradores',
                              price: _isAnnual ? '29.990' : '3.990',
                              period: _isAnnual ? '/año' : '/mes',
                              color: AppColors.mint,
                              features: [
                                'Guarda tus lugares favoritos',
                                'Conoce en qué gastas más',
                                'Compara tu presupuesto y tus gastos',
                                'Escanea tus recibos automáticamente',
                              ],
                              isSelected: _selectedPlan == 'turista',
                              onTap: () {
                                setState(() {
                                  _selectedPlan = 'turista';
                                });
                                _showSubscriptionDialog(context, 'Turista', '${_isAnnual ? '29.990' : '3.990'} COP');
                              },
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 48),

                // ========== FAQ ==========
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preguntas frecuentes',
                      style: AppText.display(20),
                    ),
                    const SizedBox(height: 20),
                    _FAQItem(
                      question: '¿Puedo cambiar de plan en cualquier momento?',
                      answer: 'Sí, puedes cambiar o cancelar tu suscripción en cualquier momento desde tu configuración.',
                    ),
                    const SizedBox(height: 12),
                    _FAQItem(
                      question: '¿Hay período de prueba gratuita?',
                      answer: 'No, actualmente no ofrecemos un período de prueba gratuita. Sin embargo, puedes cancelar tu suscripción en cualquier momento.',
                    ),
                    const SizedBox(height: 12),
                    _FAQItem(
                      question: '¿Qué métodos de pago aceptan?',
                      answer: 'Aceptamos tarjetas de crédito, débito, transferencia bancaria y billeteras digitales.',
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // ========== FOOTER ==========
                Center(
                  child: Text(
                    'Cambiar de plan en cualquier momento sin penalización',
                    style: AppText.label(
                      10,
                      weight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSubscriptionDialog(BuildContext context, String planName, String price) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        title: Text(
          'Plan $planName',
          style: AppText.display(18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Precio: $price',
              style: AppText.ui(16, weight: FontWeight.w600, color: AppColors.inkSoft),
            ),
            const SizedBox(height: 16),
            Text(
              'Al hacer clic en "Continuar", serás redirigido a la pasarela de pago para completar tu suscripción.',
              style: AppText.ui(13, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: AppText.ui(14, color: AppColors.ink),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Redirigiendo a pasarela de pago...',
                    style: AppText.ui(13, color: AppColors.paper),
                  ),
                  backgroundColor: Colors.green[600],
                  duration: const Duration(seconds: 2),
                ),
              );
              // TODO: Redirigir a pasarela de pago
            },
            child: Text(
              'Continuar',
              style: AppText.ui(14, color: AppColors.inkSoft, weight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ========== WIDGET: TOGGLE DE FACTURACIÓN ==========
class _BillingToggle extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BillingToggle({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.control),
          boxShadow: isSelected ? AppShadow.card : [],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(
          label,
          style: AppText.ui(
            13,
            weight: FontWeight.w600,
            color: isSelected ? AppColors.inkSoft : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

// ========== WIDGET: TARJETA DE PLAN ==========
class _PlanCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String price;
  final String period;
  final Color color;
  final List<String> features;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.name,
    required this.subtitle,
    required this.price,
    required this.period,
    required this.color,
    required this.features,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: isSelected ? color : AppColors.line,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppShadow.raised : AppShadow.card,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppText.display(22, color: color),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppText.ui(12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.surface,
                      size: 16,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Precio
            Row(
              textBaseline: TextBaseline.alphabetic,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              children: [
                Text(
                  price,
                  style: AppText.display(32, color: color),
                ),
                const SizedBox(width: 8),
                Text(
                  period,
                  style: AppText.ui(14, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Botón
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? color : AppColors.wash,
                  foregroundColor: isSelected ? AppColors.surface : color,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.control),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isSelected ? 'Plan seleccionado' : 'Seleccionar',
                  style: AppText.ui(13, weight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Características
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: features.map((feature) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: color, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: AppText.ui(13),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== WIDGET: ITEM FAQ ==========
class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQItem({
    required this.question,
    required this.answer,
  });

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.line),
      ),
      child: ExpansionTile(
        title: Text(
          widget.question,
          style: AppText.ui(14, weight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.answer,
              style: AppText.ui(13, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}