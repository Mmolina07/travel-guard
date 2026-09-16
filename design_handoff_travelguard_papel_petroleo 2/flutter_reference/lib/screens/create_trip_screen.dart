import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/filter_chips.dart';
import '../widgets/pressable.dart';
import '../widgets/step_progress.dart';

/// "Crear viaje" en 3 pasos con CTA fija. PageView + SlideTransition por paso.
class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _pages = PageController();
  int _step = 0;
  int _type = 0;
  double _budget = 3000000;

  static const _titles = ['¿A dónde\nvamos?', '¿Dónde\ndormimos?', '¿Cómo nos\nmovemos?'];
  static const _next = ['Hospedaje', 'Transporte', 'Guardar viaje'];

  void _advance() {
    if (_step == 2) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _step++);
    _pages.animateToPage(_step,
        duration: AppMotion.step, curve: AppMotion.enter);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 26, 26, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Pressable(
                        onTap: () => Navigator.maybePop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.hair),
                            borderRadius:
                                BorderRadius.circular(AppRadius.control),
                          ),
                          child: const Icon(Icons.arrow_back,
                              size: 18, color: AppColors.ink),
                        ),
                      ),
                      Hero(
                        tag: 'create-trip',
                        child: Text('PASO ${_step + 1} DE 3',
                            style: AppText.label(11, color: AppColors.textMuted)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  StepTitle(
                    child: Text(_titles[_step],
                        key: ValueKey(_step), style: AppText.display(38)),
                  ),
                  const SizedBox(height: 18),
                  StepProgress(step: _step),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _BasicsStep(
                    type: _type,
                    budget: _budget,
                    onType: (v) => setState(() => _type = v),
                    onBudget: (v) => setState(() => _budget = v),
                  ),
                  const _PlaceholderStep(label: 'Hospedaje'),
                  const _PlaceholderStep(label: 'Transporte'),
                ],
              ),
            ),
            _StickyCta(nextLabel: _next[_step], onTap: _advance),
          ],
        ),
      ),
    );
  }
}

/// Fade + slide corto al cambiar de título: el Tween se reinicia con la key.
class StepTitle extends StatelessWidget {
  const StepTitle({super.key, required this.child, this.duration = AppMotion.step});

  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: child.key,
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: AppMotion.enter,
      builder: (context, t, _) => Opacity(
        opacity: t.clamp(0, 1),
        child: Transform.translate(offset: Offset(0, 12 * (1 - t)), child: child),
      ),
    );
  }
}

class _BasicsStep extends StatelessWidget {
  const _BasicsStep({
    required this.type,
    required this.budget,
    required this.onType,
    required this.onBudget,
  });

  final int type;
  final double budget;
  final ValueChanged<int> onType;
  final ValueChanged<double> onBudget;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.cardLg),
            boxShadow: AppShadow.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NOMBRE DEL VIAJE', style: AppText.label(10)),
              const SizedBox(height: 8),
              Text('Viaje a Medellín',
                  style: AppText.ui(19, weight: FontWeight.w500)),
              const Divider(color: AppColors.ink, thickness: 2, height: 22),
              Text('DESTINO', style: AppText.label(10)),
              const SizedBox(height: 8),
              Text('Ciudad o región',
                  style: AppText.ui(19, color: AppColors.textMuted)),
              const Divider(color: AppColors.hair, height: 22),
              Row(
                children: [
                  Expanded(child: _DateBox(label: 'INICIO', value: '18 SEP')),
                  const SizedBox(width: 12),
                  Expanded(child: _DateBox(label: 'FIN', value: '21 SEP')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Padding(
          padding: const EdgeInsets.only(left: 26),
          child: Text('TIPO DE VIAJE', style: AppText.label(10)),
        ),
        const SizedBox(height: 12),
        FilterChipsRow(
          items: const ['Vacaciones', 'Trabajo', 'Mochilero', 'Familia'],
          selected: type,
          onSelect: onType,
        ),
        const SizedBox(height: 22),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('PRESUPUESTO MÁXIMO', style: AppText.label(10)),
                  Text('\$${budget ~/ 1000000} M',
                      style: AppText.display(32, color: AppColors.inkSoft)),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6,
                  activeTrackColor: AppColors.ink,
                  inactiveTrackColor: AppColors.hair,
                  thumbColor: AppColors.mint,
                  overlayColor: const Color(0x1A0B3438),
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 12),
                ),
                child: Slider(
                  value: budget,
                  min: 500000,
                  max: 10000000,
                  divisions: 19,
                  onChanged: onBudget,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _DateBox extends StatelessWidget {
  const _DateBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.paperDeep,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.label(10)),
          const SizedBox(height: 6),
          Text(value, style: AppText.display(26)),
        ],
      ),
    );
  }
}

class _PlaceholderStep extends StatelessWidget {
  const _PlaceholderStep({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(label, style: AppText.display(28, color: AppColors.textMuted)),
    );
  }
}

class _StickyCta extends StatelessWidget {
  const _StickyCta({required this.nextLabel, required this.onTap});

  final String nextLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 22),
      padding: const EdgeInsets.fromLTRB(22, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: AppShadow.raised,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SIGUIENTE', style: AppText.label(10)),
              Text(nextLabel, style: AppText.ui(15, weight: FontWeight.w600)),
            ],
          ),
          Pressable(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppShadow.inkButton,
              ),
              child: Row(
                children: [
                  Text('Continuar',
                      style: AppText.ui(15,
                          weight: FontWeight.w700, color: AppColors.paper)),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward,
                      size: 18, color: AppColors.mint),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
