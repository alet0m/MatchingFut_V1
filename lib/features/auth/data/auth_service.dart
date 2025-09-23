import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider para el cliente de Supabase
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Provider para el estado de autenticación
final authStateProvider = StreamProvider<AuthState>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return supabase.auth.onAuthStateChange;
});

// Provider para el usuario actual
final currentUserProvider = Provider<User?>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return supabase.auth.currentUser;
});

// Servicio de autenticación
class AuthService {
  final SupabaseClient _supabase;

  AuthService(this._supabase);

  // Registrar nuevo usuario
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? tag,
  }) async {
    // Verificar si el email ya existe en profiles
    final existingEmail =
        await _supabase
            .from('profiles')
            .select()
            .eq('email', email)
            .maybeSingle();
    if (existingEmail != null) {
      throw Exception('El email ya está registrado');
    }

    // Verificar si el tag ya existe en profiles
    if (tag != null) {
      final existingTag =
          await _supabase
              .from('profiles')
              .select()
              .eq('tag', tag)
              .maybeSingle();
      if (existingTag != null) {
        throw Exception('El tag ya está en uso, elige otro');
      }
    }

    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    if (response.user != null) {
      // Crear perfil en la tabla profiles
      await _supabase.from('profiles').insert({
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
        if (tag != null) 'tag': tag,
      });
    }
    return response;
  }

  // Iniciar sesión
  Future<AuthResponse> signIn({
    required String email,
    required String password,
    bool keepSession = false,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    // Guardar preferencia local
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keepSession', keepSession);
    return response;
  }

  // Guardar información de sesión localmente
  Future<void> saveSessionLocally(AuthResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keepSession', true);
    await prefs.setString('userId', response.user!.id);
    await prefs.setString('userEmail', response.user!.email ?? '');
    // No almacenar tokens sensibles, Supabase maneja eso internamente
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      print('🔐 Iniciando proceso de cierre de sesión completo...');

      // 1. Cerrar sesión en Supabase
      await _supabase.auth.signOut();
      print('✅ Sesión de Supabase cerrada');

      // 2. Limpiar SharedPreferences completamente
      final prefs = await SharedPreferences.getInstance();

      // Obtener todas las claves antes de limpiar para debug
      final allKeys = prefs.getKeys();
      print(
        '🧹 Limpiando ${allKeys.length} claves de SharedPreferences: $allKeys',
      );

      // Limpiar todas las claves una por una
      for (final key in allKeys) {
        final removed = await prefs.remove(key);
        print('   ${removed ? '✅' : '❌'} Removida clave: $key');
      }

      // También hacer un clear general por seguridad
      await prefs.clear();
      print('✅ SharedPreferences limpiado completamente');

      // 3. Verificar que realmente se limpiaron los datos
      final remainingKeys = prefs.getKeys();
      if (remainingKeys.isNotEmpty) {
        print(
          '⚠️ Advertencia: Aún quedan ${remainingKeys.length} claves: $remainingKeys',
        );
        // Intentar limpiar nuevamente si quedan datos
        for (final key in remainingKeys) {
          await prefs.remove(key);
        }
        await prefs.clear();
      }

      print('🎉 Proceso de cierre de sesión completado exitosamente');
    } catch (e) {
      print('❌ Error durante el cierre de sesión: $e');

      // Aún así intentar limpiar datos locales como fallback
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        print('✅ Datos locales limpiados a pesar del error');
      } catch (localError) {
        print('❌ Error al limpiar datos locales: $localError');
      }

      rethrow;
    }
  }

  // Obtener datos del perfil del usuario
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final response =
        await _supabase
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();
    return response;
  }

  // Actualizar perfil del usuario
  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    // Si se actualiza el tag, verificar que sea único
    if (data.containsKey('tag')) {
      final tag = data['tag'];
      final existingTag =
          await _supabase
              .from('profiles')
              .select()
              .eq('tag', tag)
              .neq('id', userId)
              .maybeSingle();
      if (existingTag != null) {
        throw Exception('El tag ya está en uso, elige otro');
      }
    }

    try {
      await _supabase.from('profiles').update(data).eq('id', userId);
    } catch (e) {
      // Si hay error PGRST204 con has_completed_onboarding, intentar sin esa columna
      if (e.toString().contains('PGRST204') &&
          e.toString().contains('has_completed_onboarding')) {
        print(
          'Warning: has_completed_onboarding column not found, updating without it',
        );

        // Crear una copia de data sin has_completed_onboarding
        final dataWithoutOnboarding = Map<String, dynamic>.from(data);
        dataWithoutOnboarding.remove('has_completed_onboarding');

        // Intentar actualizar sin esa columna
        await _supabase
            .from('profiles')
            .update(dataWithoutOnboarding)
            .eq('id', userId);

        // Log para debugging
        print('Profile updated successfully without has_completed_onboarding');
      } else {
        // Re-lanzar el error si no es el problema específico
        rethrow;
      }
    }
  }
}

// Provider para el servicio de autenticación
final authServiceProvider = Provider<AuthService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AuthService(supabase);
});
