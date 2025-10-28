// Fallback implementation for non-web platforms (no-op)
Future<void> clearAuthStorage() async {
  // No action needed on mobile/desktop
}

Future<void> reloadWebApp() async {
  // No-op on non-web platforms
}
