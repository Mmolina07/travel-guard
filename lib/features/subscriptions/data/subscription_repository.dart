import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import 'models/suscripcion_model.dart';
import 'models/tarjeta_model.dart';

/// Error al hablar con la pasarela (HU-22) — la UI muestra un mensaje
/// genérico; el detalle queda en el log.
class PaymentException implements Exception {
  const PaymentException(this.message);
  final String message;

  @override
  String toString() => 'PaymentException: $message';
}

/// HU-22 / TG-291: pagos con Mercado Pago (Checkout API).
///
/// 1. La tarjeta se tokeniza **directo contra Mercado Pago** con la
///    Public Key ([tokenizarTarjeta]) — el número y el código de
///    seguridad nunca llegan a Supabase.
/// 2. La Edge Function `mp-pagar-tarjeta` (que tiene el Access Token)
///    cobra con ese token y actualiza `pagos` / `suscripciones`.
///
/// Desde la app solo se leen `suscripciones`; escribirlas es exclusivo
/// de las Edge Functions.
class SubscriptionRepository {
  SubscriptionRepository({SupabaseClient? client, Dio? dio})
      : _client = client ?? SupabaseConfig.client,
        _dio = dio ?? Dio(BaseOptions(baseUrl: 'https://api.mercadopago.com'));

  /// Public Key de Mercado Pago — es pública por diseño (solo sirve para
  /// tokenizar tarjetas, no para cobrar). Se puede cambiar con
  /// `--dart-define=MP_PUBLIC_KEY=...`.
  static const String mpPublicKey = String.fromEnvironment(
    'MP_PUBLIC_KEY',
    defaultValue: 'APP_USR-44683136-ba7c-4fba-97fe-2fba63009296',
  );

  final SupabaseClient _client;
  final Dio _dio;

  /// Suscripción vigente más larga del usuario, o `null` si no es Premium.
  Future<Suscripcion?> fetchSuscripcionActiva(int usuarioId) async {
    final row = await _client
        .from('suscripciones')
        .select()
        .eq('usuario_id', usuarioId)
        .eq('estado', 'activa')
        .gt('fecha_fin', DateTime.now().toUtc().toIso8601String())
        .order('fecha_fin', ascending: false)
        .limit(1)
        .maybeSingle();
    return row == null ? null : Suscripcion.fromMap(row);
  }

  /// Envía la tarjeta a Mercado Pago y devuelve un token de un solo uso.
  Future<String> tokenizarTarjeta(DatosTarjeta tarjeta) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/v1/card_tokens',
        queryParameters: {'public_key': mpPublicKey},
        data: {
          'card_number': tarjeta.numero,
          'expiration_month': tarjeta.mesVencimiento,
          'expiration_year': tarjeta.anioVencimiento,
          'security_code': tarjeta.codigoSeguridad,
          'cardholder': {
            'name': tarjeta.titular,
            'identification': {'type': tarjeta.tipoDocumento, 'number': tarjeta.numeroDocumento},
          },
        },
      );
      final id = res.data?['id'] as String?;
      if (id == null) throw const PaymentException('Mercado Pago no devolvió token');
      return id;
    } on DioException catch (e) {
      throw PaymentException('Tokenización rechazada (${e.response?.statusCode}): ${e.response?.data}');
    }
  }

  /// Tokeniza y cobra el plan. Un rechazo de la tarjeta **no** es una
  /// excepción: vuelve como [ResultadoPago] con estado `rechazado`.
  Future<ResultadoPago> pagarConTarjeta({
    required int usuarioId,
    required PlanSuscripcion plan,
    required DatosTarjeta tarjeta,
  }) async {
    final token = await tokenizarTarjeta(tarjeta);
    final data = await _invoke('mp-pagar-tarjeta', {
      'usuario_id': usuarioId,
      'plan': plan.name,
      'card_token': token,
      'payment_method_id': tarjeta.marca!.mpId,
      'installments': 1,
      'doc_type': tarjeta.tipoDocumento,
      'doc_number': tarjeta.numeroDocumento,
    });
    return ResultadoPago.fromMap(data);
  }

  /// Vuelve a consultar cómo quedó un pago (pantalla de resultado).
  Future<ResultadoPago> confirmarPago(int pagoId) async {
    final data = await _invoke('mp-confirmar-pago', {'pago_id': pagoId});
    return ResultadoPago.fromMap(data);
  }

  Future<Map<String, dynamic>> _invoke(String function, Map<String, dynamic> body) async {
    try {
      final res = await _client.functions.invoke(function, body: body);
      final data = res.data;
      if (data is! Map<String, dynamic>) {
        throw PaymentException('$function devolvió ${res.status}: $data');
      }
      return data;
    } on FunctionException catch (e) {
      throw PaymentException('$function falló (${e.status}): ${e.details}');
    }
  }
}
