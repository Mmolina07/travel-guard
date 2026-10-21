// HU-23 (TG-269): gestionar la suscripción activa — cancelar, reactivar
// o programar el plan del siguiente periodo. `suscripciones` es de solo
// lectura para la app, por eso estos cambios pasan por aquí.
//
// Cancelar NO corta el acceso ni reembolsa: el periodo ya está pagado.
// Marca `cancelada_at` en el último periodo vigente (el que define
// cuándo termina el Premium) y la app deja de ofrecer la renovación.
//
// Body: {
//   "usuario_id": 12,
//   "accion": "cancelar" | "reactivar" | "programar_plan",
//   "plan": "mensual" | "anual"          // solo para programar_plan
// }
// Respuesta: { "suscripciones": [ ...periodos vigentes del usuario ] }

import { adminClient, corsHeaders, json, PLANES } from "../_shared/mercadopago.ts";

const ACCIONES = new Set(["cancelar", "reactivar", "programar_plan"]);

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Método no permitido" }, 405);

  try {
    const { usuario_id, accion, plan } = await req.json();
    const usuarioId = Number(usuario_id);
    if (!Number.isInteger(usuarioId)) return json({ error: "usuario_id inválido" }, 400);
    if (!ACCIONES.has(accion)) return json({ error: "accion inválida" }, 400);
    if (accion === "programar_plan" && !(plan in PLANES)) {
      return json({ error: "plan inválido" }, 400);
    }

    const db = adminClient();
    const ahora = new Date().toISOString();

    // Periodos pagados que todavía no terminan (el actual y los que se
    // sumaron después, ver `activar_premium_por_pago()`).
    const { data: vigentes, error } = await db
      .from("suscripciones")
      .select("*")
      .eq("usuario_id", usuarioId)
      .eq("estado", "activa")
      .gt("fecha_fin", ahora)
      .order("fecha_fin", { ascending: true });
    if (error) throw error;
    if (!vigentes || vigentes.length === 0) {
      return json({ error: "No tienes una suscripción activa" }, 409);
    }
    const ultimo = vigentes[vigentes.length - 1];

    // Reglas de cambio de plan (TG-295, igual que `plan_change_policy.dart`):
    // con la suscripción cancelada no se cambia de plan (hay que
    // reactivar), y solo se programa bajar a un plan más corto o volver
    // al actual — subir a uno más largo se paga (mp-pagar-tarjeta).
    if (accion === "programar_plan") {
      if (ultimo.cancelada_at) {
        return json({ error: "Reactiva la suscripción antes de cambiar de plan" }, 409);
      }
      const meses = (p: string) => (p === "anual" ? 12 : 1);
      if (meses(plan) > meses(ultimo.plan)) {
        return json({ error: "El cambio a un plan más largo se paga" }, 409);
      }
    }

    const cambios = accion === "cancelar"
      ? { cancelada_at: ahora, plan_siguiente: null }
      : accion === "reactivar"
      ? { cancelada_at: null }
      : { plan_siguiente: plan === ultimo.plan ? null : plan };

    const { error: updateError } = await db
      .from("suscripciones")
      .update(cambios)
      .eq("id", ultimo.id);
    if (updateError) throw updateError;

    const { data: actualizadas } = await db
      .from("suscripciones")
      .select("*")
      .eq("usuario_id", usuarioId)
      .eq("estado", "activa")
      .gt("fecha_fin", ahora)
      .order("fecha_inicio", { ascending: true });

    return json({ suscripciones: actualizadas ?? [] });
  } catch (e) {
    console.error("suscripcion-gestionar", e);
    return json({ error: "No se pudo actualizar la suscripción" }, 500);
  }
});
