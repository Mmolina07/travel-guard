import 'package:intl/intl.dart' show NumberFormat;

class Trip {
  const Trip({
    required this.id,
    required this.name,
    required this.destination,
    required this.rangeLabel,
    required this.people,
    required this.spent,
    required this.budget,
  });

  final String id;
  final String name;
  final String destination;
  final String rangeLabel; // "18 SEP — 21 SEP · 2 PAX"
  final int people;
  final double spent;
  final double budget;

  double get progress => budget == 0 ? 0 : spent / budget;

  String get budgetLabel =>
      '${money(spent)} de ${money(budget)}';

  static String money(double v) =>
      NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0)
          .format(v);
}

const demoTrips = <Trip>[
  Trip(
    id: 'med',
    name: 'Viaje a Medellín',
    destination: 'Medellín',
    rangeLabel: '18 SEP — 21 SEP · 2 PAX',
    people: 2,
    spent: 1860000,
    budget: 3000000,
  ),
  Trip(
    id: 'ctg',
    name: 'Cartagena en pareja',
    destination: 'Cartagena',
    rangeLabel: '02 OCT — 07 OCT · 2 PAX',
    people: 2,
    spent: 960000,
    budget: 4000000,
  ),
];
