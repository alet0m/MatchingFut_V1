import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://ynpibqsarcyoypoviglf.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlucGlicXNhcmN5b3lwb3ZpZ2xmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMyNDY0OTMsImV4cCI6MjA2ODgyMjQ5M30.KQfBPOIAg3LtQVkUXo9QZgXMzSfMwsjfofowT2EyMQ4';

  // Configuración real de Supabase para Fútbol App Quilicura
}

// Provider para el cliente de Supabase
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
