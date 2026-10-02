// Lógica compartida de HU-22 / TG-291 (Mercado Pago, Checkout API).
//
// Secretos (Supabase → Edge Functions → Secrets):
//   MP_ACCESS_TOKEN            Access Token de Mercado Pago (vendedor de prueba).
//   MP_SIMULAR_COBRO=true      Ver `mp-pagar-tarjeta`: el cobro se simula
//                              (la tokenización sigue siendo real).
//   MP_TEST_PAYER_EMAIL        Correo del comprador de prueba (cobro real en sandbox).
//   SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY  ya vienen puestos por Supabase.

import { createClient, SupabaseClient } from "npm:@supabase/supabase-js@2";

export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

/// Precios definidos en el servidor — nunca se confía en un monto que
/// mande la app. Deben coincidir con `PlanSuscripcion` en
/// `suscripcion_model.dart`. Los meses de cada plan los aplica el
/// trigger `activar_premium_por_pago()`.
export const PLANES = {
  mensual: { monto: 9900, titulo: "TravelGuard Premium · Plan mensual" },
  anual: { monto: 95000, titulo: "TravelGuard Premium · Plan anual" },
} as const;
export type Plan = keyof typeof PLANES;

export function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

export function adminClient(): SupabaseClient {
  return createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { persistSession: false } },
  );
}

export function accessToken(): string {
  const token = Deno.env.get("MP_ACCESS_TOKEN");
  if (!token) throw new Error("Falta el secreto MP_ACCESS_TOKEN");
  return token;
}

export async function mpFetch(path: string, init: RequestInit = {}) {
  const res = await fetch(`https://api.mercadopago.com${path}`, {
    ...init,
    headers: {
      Authorization: `Bearer ${accessToken()}`,
      "Content-Type": "application/json",
      ...(init.headers ?? {}),
    },
  });
  const body = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new Error(`Mercado Pago ${res.status}: ${JSON.stringify(body)}`);
  }
  return body;
}

/// Estado de Mercado Pago → estado de `pagos`.
function mapEstado(status: string): string {
  switch (status) {
    case "approved":
      return "aprobado";
    case "in_process":
    case "pending":
    case "authorized":
      return "en_proceso";
    case "rejected":
      return "rechazado";
    case "cancelled":
      return "cancelado";
    case "refunded":
    case "charged_back":
      return "reembolsado";
    default:
      return "pendiente";
  }
}

// deno-lint-ignore no-explicit-any
type MpPayment = Record<string, any>;

/// Lleva un pago de Mercado Pago (consultado directo a su API, nunca
/// datos que mande el navegador) a `pagos`. La suscripción NO se crea
/// aquí: la crea el trigger `trg_pagos_activar_premium` (TG-293,
/// `docs/db/hu22_trigger_activar_premium.sql`) cuando `estado` pasa a
/// 'aprobado'. Es idempotente: el cobro, el webhook y la confirmación
/// pueden llamarla varias veces para el mismo pago.
export async function syncPayment(db: SupabaseClient, payment: MpPayment) {
  const pagoId = Number(payment.external_reference);
  if (!Number.isFinite(pagoId)) {
    throw new Error(`Pago ${payment.id} sin external_reference válido`);
  }

  const { data: pago, error } = await db
    .from("pagos")
    .select("*")
    .eq("id", pagoId)
    .single();
  if (error || !pago) throw new Error(`No existe el pago ${pagoId}`);

  // Un pago ya aprobado no se "desaprueba" porque llegue tarde una
  // notificación de un intento rechazado anterior del mismo checkout.
  const estado = mapEstado(payment.status);
  if (pago.estado === "aprobado" && estado !== "reembolsado") return pago;

  // Defensa extra: el monto cobrado debe ser el del plan.
  if (estado === "aprobado" && Number(payment.transaction_amount) < Number(pago.monto)) {
    throw new Error(`Monto cobrado distinto al del plan en el pago ${pagoId}`);
  }
  const { error: updateError } = await db
    .from("pagos")
    .update({
      estado,
      mp_payment_id: String(payment.id),
      mp_status_detail: payment.status_detail ?? null,
    })
    .eq("id", pagoId);
  if (updateError) throw updateError;

  return { ...pago, estado };
}
