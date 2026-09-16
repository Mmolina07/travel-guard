import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../theme/app_theme.dart';
import '../widgets/budget_bar.dart';
import '../widgets/pressable.dart';

/// Detalle: cabecera con gasto vs. tope + pestañas (sin tabla clave-valor).
class TripDetailScreen extends StatefulWidget {
  const TripDetailScreen({super.key, required this.trip});

  final Trip trip;

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 4, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.trip;
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(26, 26, 26, 30),
            decoration: const BoxDecoration(
              color: AppColors.ink,
              borderRadius:
                  BorderRadius.only(bottomRight: Radius.circular(44)),
            ),
            child: SafeArea(
              bottom: false,
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
                            border: Border.all(color: Colors.white24),
                            borderRadius:
                                BorderRadius.circular(AppRadius.control),
                          ),
                          child: const Icon(Icons.arrow_back,
                              size: 18, color: AppColors.paper),
                        ),
                      ),
                      Hero(
                        tag: 'trip-thumb-${t.id}',
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.inkSoft,
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Hero(
                    tag: 'trip-title-${t.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: RichText(
                        text: TextSpan(
                          style: AppText.display(40, color: AppColors.paper),
                          children: [
                            const TextSpan(text: 'Viaje a\n'),
                            TextSpan(
                              text: t.destination,
                              style: AppText.displayItalic(40,
                                  color: AppColors.mint),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(t.rangeLabel,
                      style: AppText.label(11, color: Color(0xFF9DB3B0))),
                  const SizedBox(height: 26),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('GASTADO',
                              style: AppText.label(10, color: Color(0xFF9DB3B0))),
                          Text(Trip.money(t.spent),
                              style: AppText.display(40, color: AppColors.paper)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('TOPE',
                              style: AppText.label(10, color: Color(0xFF9DB3B0))),
                          Text(Trip.money(t.budget),
                              style: AppText.ui(18, color: Color(0xFF9DB3B0))),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  BudgetBar(
                    progress: t.progress,
                    height: 8,
                    track: Colors.white24,
                    fill: AppColors.mint,
                  ),
                ],
              ),
            ),
          ),
          TabBar(
            controller: _tabs,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerColor: AppColors.line,
            indicatorColor: AppColors.ink,
            indicatorWeight: 2,
            labelColor: AppColors.ink,
            unselectedLabelColor: AppColors.textLabel,
            labelStyle: AppText.ui(14, weight: FontWeight.w700),
            unselectedLabelStyle: AppText.ui(14),
            tabs: const [
              Tab(text: 'Resumen'),
              Tab(text: 'Hospedaje'),
              Tab(text: 'Transporte'),
              Tab(text: 'Gastos'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: const [
                _SummaryTab(),
                _SummaryTab(),
                _SummaryTab(),
                _SummaryTab(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
            child: Row(
              children: [
                Expanded(
                  child: Pressable(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: AppShadow.inkButton,
                      ),
                      child: Text('Añadir gasto',
                          style: AppText.ui(15,
                              weight: FontWeight.w700, color: AppColors.paper)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Pressable(
                  onTap: () {},
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.hair),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(Icons.more_horiz, color: AppColors.ink),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTab extends StatelessWidget {
  const _SummaryTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppShadow.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Hospedaje', style: AppText.display(22)),
                  Text('\$600.000',
                      style: AppText.label(12, color: AppColors.inkSoft)),
                ],
              ),
              const SizedBox(height: 14),
              _Row(label: 'Tipo', value: 'Hotel'),
              const SizedBox(height: 10),
              _Row(label: 'Noches', value: '3'),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Tag(text: 'Desayuno', strong: true),
                  const SizedBox(width: 8),
                  _Tag(text: 'Wi-Fi'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MiniCard(
                label: 'IDA',
                title: 'Vuelo',
                detail: 'AV-8412 · 07:20',
                dark: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniCard(
                label: 'EN DESTINO',
                title: 'Metro',
                detail: 'Tarjeta Cívica',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppText.ui(14, color: AppColors.textMuted)),
        Text(value, style: AppText.ui(14, weight: FontWeight.w600)),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, this.strong = false});

  final String text;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: strong ? AppColors.wash : AppColors.paperDeep,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text,
          style: AppText.ui(12,
              weight: strong ? FontWeight.w600 : FontWeight.w500,
              color: strong ? AppColors.inkSoft : AppColors.textMuted)),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.label,
    required this.title,
    required this.detail,
    this.dark = false,
  });

  final String label;
  final String title;
  final String detail;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: dark ? AppColors.ink : AppColors.wash,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppText.label(10,
                  color: dark ? const Color(0xFF9DB3B0) : AppColors.textMuted)),
          const SizedBox(height: 8),
          Text(title,
              style: AppText.display(24,
                  color: dark ? AppColors.paper : AppColors.ink)),
          const SizedBox(height: 6),
          Text(detail,
              style: AppText.ui(12,
                  color: dark ? const Color(0xFF9DB3B0) : AppColors.textMuted)),
        ],
      ),
    );
  }
}
