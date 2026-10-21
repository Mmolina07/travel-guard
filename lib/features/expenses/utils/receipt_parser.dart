import 'receipt_category_rules.dart';

/// Lo que se pudo leer de un recibo. Cada campo es `null` si no se
/// encontró con suficiente seguridad: el parser nunca inventa datos, el
/// usuario completa lo que falte en el formulario.
class ReceiptData {
  final int? amount;
  final DateTime? date;
  final String? establishment;

  /// Nombre de la categoría de `categorias_gasto` sugerida por
  /// [ReceiptCategoryRules] (p.ej. "Comida"), o `null` si nada coincidió.
  final String? categoryName;

  const ReceiptData({this.amount, this.date, this.establishment, this.categoryName});

  bool get isEmpty => amount == null && date == null && establishment == null;
}

/// Extrae monto total, fecha y establecimiento del texto de un recibo
/// (salida del OCR, una fila del recibo por línea). Solo reglas y
/// expresiones regulares, pensado para recibos colombianos: `43.000` son
/// cuarenta y tres mil pesos.
abstract final class ReceiptParser {
  static ReceiptData parse(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((l) => l.isNotEmpty)
        .toList();
    final establishment = _findEstablishment(lines);
    return ReceiptData(
      amount: _findTotal(lines),
      date: _findDate(lines),
      establishment: establishment,
      categoryName: ReceiptCategoryRules.suggest(text, establishment: establishment),
    );
  }

  // ─── Monto ───

  /// Palabras que marcan la línea del total, de la más a la menos
  /// específica. Solo se toma un monto de una línea con alguna de ellas:
  /// nunca cualquier número del recibo.
  static const _totalKeywords = [
    'TOTAL A PAGAR',
    'TOTAL PAGADO',
    'VALOR PAGADO',
    'VALOR A PAGAR',
    'NETO A PAGAR',
    'VALOR TOTAL',
    'TOTAL COP',
    'GRAN TOTAL',
    'TOTAL',
    'IMPORTE',
  ];

  /// Líneas con "TOTAL" que no son el total a pagar.
  static final _notTotal = RegExp(
    r'SUB\s?TOTAL|TOTAL\s+(IVA|IMPUESTO|ITEMS?|ARTICULOS?|PRODUCTOS?|UNIDADES|DESCUENTO)|BASE|CAMBIO|EFECTIVO RECIBIDO',
  );

  /// Un monto: `$43.000`, `43,000`, `$ 43.000`, `43.000,50`, `43000`.
  static final _money = RegExp(r'\$?\s?(\d{1,3}(?:[.,]\d{3})+(?:[.,]\d{1,2})?|\d+(?:[.,]\d{1,2})?)');

  static int? _findTotal(List<String> lines) {
    int? best;
    var bestRank = _totalKeywords.length;
    for (var i = 0; i < lines.length; i++) {
      final upper = _normalize(lines[i]);
      if (_notTotal.hasMatch(upper)) continue;
      final rank = _totalKeywords.indexWhere(upper.contains);
      if (rank == -1) continue;
      // El valor suele ir en la misma fila; si el OCR lo separó, en la
      // siguiente o, en fotos torcidas, en la anterior.
      var amount = _lastAmount(lines[i]);
      if (amount == null && i + 1 < lines.length) amount = _lastAmount(lines[i + 1]);
      if (amount == null && i > 0) amount = _lastAmount(lines[i - 1]);
      if (amount == null) continue;
      // Más específica gana; entre iguales, la mayor (el total final
      // suele ser el monto más grande de las líneas de total).
      if (rank < bestRank || (rank == bestRank && amount > (best ?? 0))) {
        best = amount;
        bestRank = rank;
      }
    }
    return best;
  }

  static int? _lastAmount(String line) {
    int? last;
    for (final m in _money.allMatches(line)) {
      final value = parseMoney(m.group(1)!);
      if (value != null && value > 0) last = value;
    }
    return last;
  }

  /// `43.000` → 43000, `43,000` → 43000, `43.000,50` → 43000 (sin
  /// centavos), `43,50` → 43, `43000` → 43000.
  static int? parseMoney(String raw) {
    final s = raw.replaceAll(RegExp(r'[^\d.,]'), '');
    if (s.isEmpty) return null;
    // Separador seguido de 1-2 dígitos al final: son centavos.
    final cents = RegExp(r'[.,]\d{1,2}$');
    final whole = cents.hasMatch(s) ? s.substring(0, cents.firstMatch(s)!.start) : s;
    final digits = whole.replaceAll(RegExp(r'[.,]'), '');
    return digits.isEmpty ? null : int.tryParse(digits);
  }

  // ─── Fecha ───

  static const _months = {
    'ENE': 1, 'FEB': 2, 'MAR': 3, 'ABR': 4, 'MAY': 5, 'JUN': 6,
    'JUL': 7, 'AGO': 8, 'SEP': 9, 'SET': 9, 'OCT': 10, 'NOV': 11, 'DIC': 12,
  };

  // Límites "sin dígito al lado" en vez de \b: el OCR suele pegar la
  // fecha a la palabra siguiente ("2026/10/19Hora: 19:36"), y a veces
  // mete un espacio junto a un separador ("2026/10/ 19").
  static final _ymd = RegExp(r'(?<!\d)(\d{4}) ?[/\-.] ?(\d{1,2}) ?[/\-.] ?(\d{1,2})(?!\d)');
  static final _dmy = RegExp(r'(?<!\d)(\d{1,2}) ?[/\-.] ?(\d{1,2}) ?[/\-.] ?(\d{4}|\d{2})(?!\d)');
  static final _dMonY = RegExp(r'\b(\d{1,2})[\s/\-.]?(ENE|FEB|MAR|ABR|MAY|JUN|JUL|AGO|SEPT?|SET|OCT|NOV|DIC)[A-Z]*[\s/\-.,]*(\d{4})\b');

  /// Líneas que suelen traer la fecha de la compra.
  static final _dateHint = RegExp(r'FECHA|EXPEDICION|GENERACION|EMISION|EMITID');

  /// Líneas con fechas que NO son de la compra: vigencia de la
  /// resolución de facturación ("DEL 2024-09-10 AL 2026-09-10"), etc.
  static final _notPurchaseDate =
      RegExp(r'RESOLUCION|VIGENCIA|AUTORIZ|RANGO|HABILITA|VENCE|HASTA|DESDE|\bDEL\b.*\bAL\b');

  static DateTime? _findDate(List<String> lines) {
    // Primero las líneas de "Fecha"/"Expedición".
    // Las de vigencias/resoluciones se descartan: mejor sin fecha que con
    // la de la resolución de facturación (2024) en vez de la de compra.
    int rank(String l) => _dateHint.hasMatch(_normalize(l)) ? 0 : 1;
    final ordered = [
      for (final l in lines)
        if (!_notPurchaseDate.hasMatch(_normalize(l))) l,
    ]..sort((a, b) => rank(a).compareTo(rank(b)));
    for (final line in ordered) {
      final date = parseDate(line);
      if (date != null) return date;
    }
    return null;
  }

  /// Primera fecha válida de [line] (dd/mm/aaaa, dd-mm-aaaa, aaaa-mm-dd,
  /// dd/mm/aa o "06 OCT 2026"), o `null`.
  static DateTime? parseDate(String line) {
    // El OCR suele pegar la hora al día, a veces sin los dos puntos
    // ("2026-08-1614:54" o "2026-08-161454:33"): se separa lo que sigue.
    final upper = _normalize(line)
        .replaceAllMapped(
          RegExp(r'(\d{4} ?[/\-.] ?\d{1,2} ?[/\-.] ?\d{2})(\d)'),
          (m) => '${m[1]} ${m[2]}',
        )
        .replaceAllMapped(
          RegExp(r'(\d{1,2} ?[/\-.] ?\d{1,2} ?[/\-.] ?\d{4})(\d)'),
          (m) => '${m[1]} ${m[2]}',
        );
    for (final m in _ymd.allMatches(upper)) {
      final d = _validDate(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
      if (d != null) return d;
    }
    for (final m in _dmy.allMatches(upper)) {
      var year = int.parse(m[3]!);
      if (m[3]!.length == 2) year += 2000;
      final d = _validDate(year, int.parse(m[2]!), int.parse(m[1]!));
      if (d != null) return d;
    }
    for (final m in _dMonY.allMatches(upper)) {
      final month = _months[m[2]!.substring(0, 3)];
      if (month == null) continue;
      final d = _validDate(int.parse(m[3]!), month, int.parse(m[1]!));
      if (d != null) return d;
    }
    return null;
  }

  static DateTime? _validDate(int y, int m, int d) {
    if (m < 1 || m > 12 || d < 1 || d > 31) return null;
    final date = DateTime(y, m, d);
    // DateTime "corrige" 31/02 a marzo: si no coincide, no era válida.
    if (date.year != y || date.month != m || date.day != d) return null;
    final now = DateTime.now();
    if (y < 2000 || date.isAfter(now.add(const Duration(days: 366)))) return null;
    return date;
  }

  // ─── Establecimiento ───

  /// Lo que no puede ser el nombre del negocio aunque esté arriba.
  static final _notName = RegExp(
    r'\b(NIT|RUT|TEL|TELEFONO|CEL|CELULAR|DIRECCION|DIR|CRA|CARRERA|CALLE|CL|KR|CR|AV|AVENIDA|DIAG|TRANSV|NO\.?|N°|FACTURA|REGIMEN|RESOLUCION|DIAN|FECHA|HORA|CAJA|CAJERO|TICKET|IVA|PREFIJO|AUTORIZA|RANGO|BIENVENIDOS?|GRACIAS|CLIENTE|MESA|MESERO|PEDIDO|ORDEN|COPIA|ORIGINAL|SUCURSAL|SEDE|PAGO|VALOR|TOTAL|SUBTOTAL|CONTADO|EFECTIVO|CAMBIO|IMPUESTOS?|DESCUENTO|PRECIO|CANT|DESCRIPCION)\b|WWW\.|@|\.COM|#',
  );
  static final _time = RegExp(r'\b\d{1,2}:\d{2}');

  /// NIT (sin dígito de verificación) → nombre comercial de cadenas
  /// grandes. Sirve cuando el nombre no sale en la foto (recibos donde
  /// solo aparece la razón social, o con el borde cortado): es el dato
  /// real del recibo, no una suposición. Para ampliar, agrega el NIT.
  static const knownNits = {
    '900276962': 'Tiendas D1',
    '890900608': 'Almacenes Éxito',
  };

  static final _nit = RegExp(r'NIT\s*[:.]?\s*(\d[\d.]{7,12}\d)');

  /// Marcas conocidas (palabra en el recibo → nombre a mostrar). Si la
  /// marca aparece arriba pero la línea del nombre salió ilegible, se usa
  /// este nombre limpio. Para ampliar, agrega la marca en minúscula y sin
  /// tildes. (Sin "ara" ni "consumo": son palabras comunes en recibos.)
  static const knownBrands = {
    'carulla': 'Carulla',
    'exito': 'Éxito',
    'olimpica': 'Olímpica',
    'd1': 'Tiendas D1',
    'jumbo': 'Jumbo',
    'euro': 'Euro',
    'makro': 'Makro',
    'pricesmart': 'PriceSmart',
    'colsubsidio': 'Colsubsidio',
    'surtimax': 'Surtimax',
    'zapatoca': 'Zapatoca',
    'isimo': 'Ísimo',
    'falabella': 'Falabella',
    'juan valdez': 'Juan Valdez',
    'starbucks': 'Starbucks',
    'frisby': 'Frisby',
    'el corral': 'El Corral',
    'terpel': 'Terpel',
    'primax': 'Primax',
  };

  static String? _findEstablishment(List<String> lines) {
    final header = _nameFromLines(lines);
    final brand = _brandIn(lines.take(12));
    if (brand != null) {
      final (key, name) = brand;
      // La línea del encabezado ya nombra la marca ("CARULLA GRAN VIA"):
      // es más precisa que el nombre genérico.
      if (header != null && _hasWord(removeAccents(header.toLowerCase()), key)) return header;
      return name;
    }
    return header ?? _nameFromNit(lines);
  }

  static (String, String)? _brandIn(Iterable<String> lines) {
    for (final line in lines) {
      final lower = removeAccents(line.toLowerCase());
      for (final entry in knownBrands.entries) {
        if (_hasWord(lower, entry.key)) return (entry.key, entry.value);
      }
    }
    return null;
  }

  static bool _hasWord(String text, String word) =>
      RegExp('(^|[^a-z0-9])${RegExp.escape(word)}(\$|[^a-z0-9])').hasMatch(text);

  static String? _nameFromNit(List<String> lines) {
    for (final line in lines) {
      for (final m in _nit.allMatches(_normalize(line))) {
        final digits = m[1]!.replaceAll('.', '');
        if (digits.length < 9) continue;
        final name = knownNits[digits.substring(0, 9)];
        if (name != null) return name;
      }
    }
    return null;
  }

  static String? _nameFromLines(List<String> lines) {
    // El nombre casi siempre va en las primeras filas del recibo.
    for (final line in lines.take(6)) {
      final upper = _normalize(line);
      if (_notName.hasMatch(upper) || _time.hasMatch(upper)) continue;
      if (parseDate(line) != null) continue;
      final letters = RegExp(r'[A-Z]').allMatches(upper).length;
      final digits = RegExp(r'\d').allMatches(upper).length;
      if (letters < 3 || digits > letters / 3) continue;
      if (line.length > 45) continue;
      // Todo en minúsculas casi siempre es ruido del OCR ("efon de ten"):
      // los nombres de negocio van en mayúsculas o con inicial mayúscula.
      if (line == line.toLowerCase()) continue;
      return line.replaceAll(RegExp(r'^[^\wÁÉÍÓÚÑáéíóúñ]+|[^\wÁÉÍÓÚÑáéíóúñ.]+$'), '').trim();
    }
    return null;
  }

  /// Mayúsculas sin tildes, para comparar palabras clave.
  static String _normalize(String s) => removeAccents(s.toUpperCase());
}

String removeAccents(String s) {
  const from = 'ÁÉÍÓÚÜÑáéíóúüñ';
  const to = 'AEIOUUNaeiouun';
  final buffer = StringBuffer();
  for (final ch in s.split('')) {
    final i = from.indexOf(ch);
    buffer.write(i == -1 ? ch : to[i]);
  }
  return buffer.toString();
}
