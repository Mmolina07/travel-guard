import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuración y acceso al cliente de Supabase (TG-92).
///
/// El proyecto de Supabase del equipo ya está configurado; la URL y la
/// "publishable key" (clave pública, segura de exponer en el cliente y
/// acotada por las políticas RLS de cada tabla) quedan como valores por
/// defecto. Para usar otro proyecto (p.ej. en CI) se pueden sobrescribir
/// con `--dart-define=SUPABASE_URL=...` y `--dart-define=SUPABASE_ANON_KEY=...`.
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://wtyofjlzjkzjlpdynvay.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_Pxdfi9JmuHqkRYkfyAatuQ_ZcaEKPBL',
  );

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  /// Inicializa Supabase. Debe llamarse una sola vez antes de `runApp`.
  static Future<void> initialize() async {
    if (!isConfigured) {
      throw StateError(
        'Supabase no está configurado. Define SUPABASE_URL y '
        'SUPABASE_ANON_KEY vía --dart-define (ver docs/db/README.md).',
      );
    }
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  /// Cliente Supabase ya inicializado, listo para usarse en repositorios.
  static SupabaseClient get client => Supabase.instance.client;
}
