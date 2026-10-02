// TG-291: la pantalla de resultado llama esto cuando se abre por URL
// (recarga, enlace) o el usuario pide "volver a consultar" un pago en
// proceso. Busca el pago en la API de Mercado Pago por
// `external_reference` y sincroniza `pagos` / `suscripciones`; si no hay
// nada allá (p. ej. cobro simulado), devuelve lo que ya está guardado.
//
// Body: { "pago_id": 34 }

import { adminClient, corsHeaders, json, mpFetch, syncPayment } from "../_shared/mercadopago.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Método no permitido" }, 405);

  try {
    const { pago_id } = await req.json();
    const pagoId = Number(pago_id);
    if (!Number.isInteger(pagoId)) return json({ error: "pago_id inválido" }, 400);

    const db = adminClient();
    const search = await mpFetch(
      `/v1/payments/search?external_reference=${pagoId}&sort=date_created&criteria=desc`,
    );
    // deno-lint-ignore no-explicit-any
    const results: any[] = search.results ?? [];
    // Un mismo checkout puede tener varios intentos (rechazado y luego
    // aprobado): manda el aprobado si existe, si no el más reciente.
    const payment = results.find((p) => p.status === "approved") ?? results[0];

    if (payment) await syncPayment(db, payment);

    const { data: pago } = await db
      .from("pagos")
      .select("id, plan, monto, estado, mp_status_detail")
      .eq("id", pagoId)
      .maybeSingle();
    if (!pago) return json({ error: "Pago no encontrado" }, 404);

    const { data: suscripcion } = await db
      .from("suscripciones")
      .select("*")
      .eq("pago_id", pagoId)
      .maybeSingle();

    return json({ pago, suscripcion });
  } catch (e) {
    console.error("mp-confirmar-pago", e);
    return json({ error: "No se pudo confirmar el pago" }, 500);
  }
});
