// TG-291: cobro directo con tarjeta (Mercado Pago Checkout API).
//
// La app tokeniza la tarjeta directo contra Mercado Pago con la Public
// Key (`POST /v1/card_tokens`), así que aquí solo llega un token de un
// solo uso — nunca el número, la fecha ni el código de seguridad.
//
// Body: {
//   "usuario_id": 12, "plan": "mensual" | "anual", "card_token": "…",
//   "payment_method_id": "visa" | "master" | "amex" | "diners",
//   "installments": 1, "doc_type": "CC", "doc_number": "123456789"
// }

import { adminClient, corsHeaders, json, mpFetch, Plan, PLANES, syncPayment } from "../_shared/mercadopago.ts";

const METODOS = new Set(["visa", "master", "amex", "diners"]);

/// Modo simulado (`MP_SIMULAR_COBRO=true`): el sandbox de Mercado Pago
/// para cuentas de Colombia rechaza todo cobro de prueba ("Unauthorized
/// use of live credentials"), tanto en Checkout Pro como por API. La
/// tarjeta igual se tokeniza de verdad en Mercado Pago; solo el cobro se
/// decide aquí, con la misma regla del sandbox: titular APRO → aprobado,
/// CONT → en proceso, cualquier otro → rechazado.
async function cobroSimulado(token: string, pagoId: number, monto: number) {
  const card = await mpFetch(`/v1/card_tokens/${encodeURIComponent(token)}`);
  const titular = String(card.cardholder?.name ?? "").trim().toUpperCase();
  const [status, detail] = titular === "APRO"
    ? ["approved", "accredited"]
    : titular === "CONT"
    ? ["in_process", "pending_contingency"]
    : ["rejected", "cc_rejected_other_reason"];
  return {
    id: `sim-${pagoId}`,
    status,
    status_detail: `simulado_${detail}`,
    external_reference: String(pagoId),
    transaction_amount: monto,
  };
}

/// Motivo corto del rechazo de la API (cabe en `pagos.mp_status_detail`).
function motivoError(e: unknown): string {
  const text = e instanceof Error ? e.message : String(e);
  const match = text.match(/"message":"([^"]+)"/);
  return `api: ${match?.[1] ?? text}`.slice(0, 80);
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Método no permitido" }, 405);

  try {
    const body = await req.json();
    const usuarioId = Number(body.usuario_id);
    const plan = String(body.plan);
    const token = String(body.card_token ?? "");
    const metodo = String(body.payment_method_id ?? "");
    const cuotas = Number(body.installments ?? 1);
    const docType = String(body.doc_type ?? "CC");
    const docNumber = String(body.doc_number ?? "").replace(/\D/g, "");

    if (!Number.isInteger(usuarioId)) return json({ error: "usuario_id inválido" }, 400);
    if (!(plan in PLANES)) return json({ error: "plan inválido" }, 400);
    if (!token) return json({ error: "card_token requerido" }, 400);
    if (!METODOS.has(metodo)) return json({ error: "medio de pago no soportado" }, 400);
    if (!Number.isInteger(cuotas) || cuotas < 1 || cuotas > 36) return json({ error: "cuotas inválidas" }, 400);
    if (!["CC", "CE", "NIT", "PAS"].includes(docType) || docNumber.length < 5) {
      return json({ error: "documento inválido" }, 400);
    }

    const db = adminClient();
    const { data: usuario } = await db
      .from("usuarios")
      .select("id, email, tipo_usuario")
      .eq("id", usuarioId)
      .maybeSingle();
    if (!usuario || usuario.tipo_usuario !== "turista") {
      return json({ error: "Solo los turistas pueden suscribirse" }, 403);
    }

    const { monto, titulo } = PLANES[plan as Plan];
    const { data: pago, error } = await db
      .from("pagos")
      .insert({ usuario_id: usuarioId, plan, monto, moneda: "COP" })
      .select()
      .single();
    if (error) throw error;

    // Con credenciales de prueba Mercado Pago rechaza pagadores con
    // correos reales ("invalid users involved"): en sandbox se usa el
    // correo del comprador de prueba si está configurado.
    const payerEmail = Deno.env.get("MP_TEST_PAYER_EMAIL") ?? usuario.email;

    // deno-lint-ignore no-explicit-any
    let payment: any = null;
    try {
      payment = Deno.env.get("MP_SIMULAR_COBRO") === "true"
        ? await cobroSimulado(token, pago.id, monto)
        : await mpFetch("/v1/payments", {
        method: "POST",
        // Evita cobros dobles si la app reintenta la misma petición.
        headers: { "X-Idempotency-Key": `travelguard-pago-${pago.id}` },
        body: JSON.stringify({
          transaction_amount: monto,
          token,
          description: titulo,
          installments: cuotas,
          payment_method_id: metodo,
          payer: {
            email: payerEmail,
            identification: { type: docType, number: docNumber },
          },
          external_reference: String(pago.id),
          notification_url: `${Deno.env.get("SUPABASE_URL")}/functions/v1/mp-webhook`,
          statement_descriptor: "TRAVELGUARD",
          metadata: { pago_id: pago.id, usuario_id: usuarioId, plan },
        }),
      });
    } catch (e) {
      // Mercado Pago no aceptó el cobro (token vencido, datos
      // inválidos…): queda rechazado, no pendiente para siempre, y la
      // app lo muestra como rechazado en vez de un error genérico.
      console.error("mp-pagar-tarjeta /v1/payments", e);
      await db
        .from("pagos")
        .update({ estado: "rechazado", mp_status_detail: motivoError(e) })
        .eq("id", pago.id);
    }

    if (payment) await syncPayment(db, payment);

    const { data: pagoFinal } = await db
      .from("pagos")
      .select("id, plan, monto, estado, mp_status_detail")
      .eq("id", pago.id)
      .single();
    const { data: suscripcion } = await db
      .from("suscripciones")
      .select("*")
      .eq("pago_id", pago.id)
      .maybeSingle();

    return json({ pago: pagoFinal, suscripcion });
  } catch (e) {
    console.error("mp-pagar-tarjeta", e);
    return json({ error: "No se pudo procesar el pago" }, 502);
  }
});
