import '../data/models/checklist_models.dart';
import '../presentation/pages/trip_model.dart';
import 'budget_calculator.dart';

/// Ciudades para las sugerencias por clima (sin tildes, en minúscula).
const _coastCities = [
  'cartagena', 'barranquilla', 'santa marta', 'san andres', 'providencia',
  'covenas', 'tolu', 'riohacha', 'capurgana', 'nuqui', 'bahia solano',
];
const _coldCities = [
  'bogota', 'tunja', 'pasto', 'manizales', 'zipaquira', 'villa de leyva',
  'paipa', 'ipiales', 'sogamoso',
];
const _rainyCities = ['medellin', 'cali', 'pereira', 'armenia', 'manizales', 'quibdo'];

/// Sugerencias de la lista de pendientes según los datos del viaje
/// (HU-26, tabla de reglas en `docs/hu/hu-26.md`). Función pura: sin IA
/// ni red. Devuelve cada clave una sola vez, en el orden de las
/// categorías.
List<ChecklistSuggestion> suggestChecklist(Trip trip) {
  final destination = _normalize(trip.destination);
  bool inAny(List<String> cities) => cities.any(destination.contains);

  final transports = {trip.startTransport, trip.duringTransport};
  final flies = transports.contains('Vuelo');
  final drives = transports.contains('Carro');
  final takesBus = trip.startTransport == 'Transporte público';

  final start = parseDdMmYyyy(trip.startDate);
  final end = parseDdMmYyyy(trip.endDate);
  final days = start != null && end != null ? end.difference(start).inDays + 1 : 1;

  final coast = inAny(_coastCities);
  final cold = inAny(_coldCities);
  final rainy = cold || inAny(_rainyCities);

  final out = <ChecklistSuggestion>[
    // Documentos
    const ChecklistSuggestion('doc_id', ChecklistCategory.documentos),
    if (drives) ...const [
      ChecklistSuggestion('doc_license', ChecklistCategory.documentos),
      ChecklistSuggestion('doc_soat', ChecklistCategory.documentos),
    ],
    if (trip.tripType == 'Trabajo') const ChecklistSuggestion('doc_work', ChecklistCategory.documentos),

    // Dinero
    const ChecklistSuggestion('money_cash', ChecklistCategory.dinero),
    const ChecklistSuggestion('money_cards', ChecklistCategory.dinero),
    const ChecklistSuggestion('money_bank_notice', ChecklistCategory.dinero),
    if (drives) const ChecklistSuggestion('money_tolls', ChecklistCategory.dinero),

    // Equipaje
    const ChecklistSuggestion('bag_pack', ChecklistCategory.equipaje),
    if (days > 5) const ChecklistSuggestion('bag_extra_clothes', ChecklistCategory.equipaje),
    if (flies) const ChecklistSuggestion('bag_liquids', ChecklistCategory.equipaje),
    if (coast) ...const [
      ChecklistSuggestion('bag_swimsuit', ChecklistCategory.equipaje),
      ChecklistSuggestion('bag_sunglasses', ChecklistCategory.equipaje),
    ],
    if (cold) const ChecklistSuggestion('bag_jacket', ChecklistCategory.equipaje),
    if (rainy) const ChecklistSuggestion('bag_umbrella', ChecklistCategory.equipaje),

    // Salud
    const ChecklistSuggestion('health_meds', ChecklistCategory.salud),
    if (coast) ...const [
      ChecklistSuggestion('health_sunscreen', ChecklistCategory.salud),
      ChecklistSuggestion('health_repellent', ChecklistCategory.salud),
    ],

    // Tecnología
    const ChecklistSuggestion('tech_charger', ChecklistCategory.tecnologia),
    if (flies || takesBus || days > 2) const ChecklistSuggestion('tech_powerbank', ChecklistCategory.tecnologia),
    if (trip.tripType == 'Trabajo') const ChecklistSuggestion('tech_laptop', ChecklistCategory.tecnologia),

    // Reservas
    if (trip.lodgingCost > 0) const ChecklistSuggestion('book_lodging', ChecklistCategory.reservas),
    if (flies) ...const [
      ChecklistSuggestion('book_checkin', ChecklistCategory.reservas),
      ChecklistSuggestion('book_boarding_pass', ChecklistCategory.reservas),
      ChecklistSuggestion('book_airport_early', ChecklistCategory.reservas),
    ],
    if (takesBus) const ChecklistSuggestion('book_bus_tickets', ChecklistCategory.reservas),

    // Casa (antes de salir)
    const ChecklistSuggestion('home_unplug', ChecklistCategory.casa),
    const ChecklistSuggestion('home_care', ChecklistCategory.casa),

    // Otro
    if (drives) const ChecklistSuggestion('other_car_check', ChecklistCategory.otro),
    if (trip.persons > 1) const ChecklistSuggestion('other_group', ChecklistCategory.otro),
    const ChecklistSuggestion('other_itinerary', ChecklistCategory.otro),
  ];
  return out;
}

String _normalize(String text) {
  const from = 'áéíóúüñ';
  const to = 'aeiouun';
  final lower = text.toLowerCase();
  final buffer = StringBuffer();
  for (final ch in lower.split('')) {
    final i = from.indexOf(ch);
    buffer.write(i >= 0 ? to[i] : ch);
  }
  return buffer.toString();
}
