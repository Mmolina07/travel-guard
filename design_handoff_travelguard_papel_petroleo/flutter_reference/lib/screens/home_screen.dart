import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../routes/hero_scale_route.dart';
import '../theme/app_theme.dart';
import '../widgets/floating_nav_bar.dart';
import '../widgets/pressable.dart';
import '../widgets/stagger_in.dart';
import '../widgets/trip_card.dart';
import 'create_trip_screen.dart';
import 'trip_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  void _openCreate() => Navigator.of(context).push(
        HeroScaleRoute(builder: (_) => const CreateTripScreen()),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const _Greeting(),
                  const SizedBox(height: 6),
                  const _ActionGrid(),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Mis viajes', style: AppText.display(24)),
                        Text('VER TODOS',
                            style: AppText.label(11, color: AppColors.inkSoft)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  for (var i = 0; i < demoTrips.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 26, right: 26, bottom: 12),
                      child: StaggerIn(
                        index: i,
                        child: TripCard(
                          trip: demoTrips[i],
                          onTap: () => Navigator.of(context).push(
                            TripDetailRoute(
                              builder: (_) =>
                                  TripDetailScreen(trip: demoTrips[i]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            FloatingNavBar(
              index: _tab,
              onSelect: (i) => setState(() => _tab = i),
              onCreate: _openCreate,
            ),
          ],
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 26, 26, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('MARTES 15 · SEP', style: AppText.label(11)),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text('M',
                    style: AppText.ui(14,
                        weight: FontWeight.w700, color: AppColors.mint)),
              ),
            ],
          ),
          const SizedBox(height: 26),
          RichText(
            text: TextSpan(
              style: AppText.display(42),
              children: [
                const TextSpan(text: 'Hola, Mateo.\n'),
                TextSpan(
                    text: '2 viajes activos',
                    style: AppText.displayItalic(42)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Retícula asimétrica 1 : 1.35 — sustituye a los botones sueltos.
class _ActionGrid extends StatelessWidget {
  const _ActionGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 150,
        child: Row(
          children: [
            Expanded(
              flex: 100,
              child: PressableCard(
                color: AppColors.wash,
                shadow: const [],
                padding: const EdgeInsets.all(18),
                onTap: () {},
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.ink, width: 2),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mapa', style: AppText.display(22)),
                        const SizedBox(height: 6),
                        Text('14 lugares cerca',
                            style: AppText.ui(12, color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 135,
              child: PressableCard(
                color: AppColors.ink,
                shadow: AppShadow.raised,
                onTap: () {},
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.mint,
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Crear\nun viaje',
                            style: AppText.display(26, color: AppColors.paper)),
                        const SizedBox(height: 8),
                        Text('Presupuesto e itinerario',
                            style: AppText.ui(12, color: Color(0xFF9DB3B0))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
