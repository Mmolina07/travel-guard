class PocketDeposit {
  final int id;
  final double monto;
  final String? nota;
  final DateTime createdAt;

  const PocketDeposit({
    required this.id,
    required this.monto,
    required this.createdAt,
    this.nota,
  });

  factory PocketDeposit.fromMap(Map<String, dynamic> map) => PocketDeposit(
        id: (map['id'] as num).toInt(),
        monto: (map['monto'] as num).toDouble(),
        nota: map['nota'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}

/// Bolsillo de un participante en un viaje: aportes, lo gastado desde él y saldo.
class PocketSummary {
  final int id;
  final List<PocketDeposit> deposits;
  final double spent;

  const PocketSummary({
    required this.id,
    required this.deposits,
    required this.spent,
  });

  double get added => deposits.fold(0.0, (s, d) => s + d.monto);
  double get balance => added - spent;
}