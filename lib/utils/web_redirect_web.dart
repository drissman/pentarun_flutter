// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

// SPEC-KIT §3.1 ERRATA v2.1 — window.location.href bypasse popup blocker
// window.open() avec 'noopener,noreferrer' est bloqué silencieusement après
// les `await` PKCE (contexte user-activation expiré). window.location.href
// est une navigation directe qui ne nécessite pas de user-activation.
void webRedirect(String url) {
  html.window.location.href = url;
}
