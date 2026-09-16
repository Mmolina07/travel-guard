// ignore: deprecated_member_use
import 'dart:html' as html;

/// Título de la pestaña del navegador — Fase 5 (go_router): cada ruta
/// pone su propio título en vez de quedarse siempre con el de
/// `index.html`.
void setPageTitle(String title) {
  html.document.title = title;
}
