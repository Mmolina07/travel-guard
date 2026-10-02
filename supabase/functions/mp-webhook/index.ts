// TG-291: notificaciones de Mercado Pago (`notification_url` de cada
// cobro). Cubre los pagos que quedan "en proceso" y se aprueban o
// rechazan después: la suscripción se activa aunque la app esté cerrada.
//
// La notificación solo trae el id del pago; el estado se consulta a la
// API de Mercado Pago con nuestro Access Token, así que una
// notificación falsa no puede aprobar nada.
//
// Se despliega con --no-verify-jwt (Mercado Pago no manda JWT).

import { adminClient, json, mpFetch, syncPayment } from "../_shared/mercadopago.ts";

Deno.serve(async (req) => {
  try {
    const url = new URL(req.url);
    // deno-lint-ignore no-explicit-any
    let body: any = {};
    if (req.method === "POST") body = await req.json().catch(() => ({}));

    // Formatos que manda Mercado Pago: webhooks (`type` + `data.id`) e
    // IPN viejo (`topic` + `id`), en el body o en la query.
    const type = body.type ?? body.topic ?? url.searchParams.get("type") ??
      url.searchParams.get("topic");
    const paymentId = body.data?.id ?? url.searchParams.get("data.id") ??
      url.searchParams.get("id");

    if (type !== "payment" || !paymentId) return json({ ignored: true });

    const payment = await mpFetch(`/v1/payments/${encodeURIComponent(String(paymentId))}`);
    await syncPayment(adminClient(), payment);
    return json({ ok: true });
  } catch (e) {
    console.error("mp-webhook", e);
    // 500 → Mercado Pago reintenta más tarde.
    return json({ error: "error procesando la notificación" }, 500);
  }
});
