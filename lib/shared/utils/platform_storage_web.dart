// Web-specific implementation using dart:html
import 'dart:html' as html;

Future<void> clearAuthStorage() async {
  try {
    // Remove Supabase auth tokens and any cached session
    // Supabase stores keys like 'sb-<project-ref>-auth-token'
    final keys = List<String>.from(html.window.localStorage.keys);
    for (final k in keys) {
      if (k.startsWith('sb-') || k.contains('supabase') || k.contains('auth')) {
        html.window.localStorage.remove(k);
      }
    }
    // As a fallback, clear sessionStorage too
    final sKeys = List<String>.from(html.window.sessionStorage.keys);
    for (final k in sKeys) {
      if (k.startsWith('sb-') || k.contains('supabase') || k.contains('auth')) {
        html.window.sessionStorage.remove(k);
      }
    }
  } catch (_) {
    // As last resort, clear all local and session storage
    try {
      html.window.localStorage.clear();
    } catch (_) {}
    try {
      html.window.sessionStorage.clear();
    } catch (_) {}
  }
}

Future<void> reloadWebApp() async {
  try {
    html.window.location.reload();
  } catch (_) {
    // ignore
  }
}
