// ignore_for_file: avoid_print, deprecated_member_use_from_same_package

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/models/models.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
SupabaseClient supabase(SupabaseRef ref) {
  return Supabase.instance.client;
}

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  UserModel? build() {
    final supabase = ref.read(supabaseProvider);
    final user = supabase.auth.currentUser;

    if (user != null) {
      // Cargar datos del usuario desde la tabla public.users
      _loadUserData(user.id);
    }

    return null;
  }

  Future<void> _loadUserData(String userId) async {
    try {
      final supabase = ref.read(supabaseProvider);

      // Intentar obtener el usuario
      final response =
          await supabase.from('users').select().eq('id', userId).maybeSingle();

      if (response != null) {
        state = UserModel.fromJson(response);
      } else {
        // Si no existe el usuario, crear uno básico
        print('User not found in public.users, creating...');
        await _createUserRecord(userId);
      }
    } catch (e) {
      print('Error loading user data: $e');
      // Intentar crear el usuario si no existe
      await _createUserRecord(userId);
    }
  }

  Future<void> _createUserRecord(String userId) async {
    try {
      final supabase = ref.read(supabaseProvider);
      final authUser = supabase.auth.currentUser;

      if (authUser != null) {
        final newUser = {
          'id': userId,
          'email': authUser.email ?? '',
          'full_name': authUser.userMetadata?['full_name'] ?? 'Usuario',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        await supabase.from('users').insert(newUser);

        // Cargar el usuario recién creado
        final response =
            await supabase.from('users').select().eq('id', userId).single();

        state = UserModel.fromJson(response);
        print('User created successfully');
      }
    } catch (e) {
      print('Error creating user record: $e');
    }
  }

  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final supabase = ref.read(supabaseProvider);
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserData(response.user!.id);
        return state;
      }
      return null;
    } catch (e) {
      throw Exception('Error signing in: $e');
    }
  }

  Future<UserModel?> signUpWithEmail(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      final supabase = ref.read(supabaseProvider);
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user != null) {
        await _loadUserData(response.user!.id);
        return state;
      }
      return null;
    } catch (e) {
      throw Exception('Error signing up: $e');
    }
  }

  Future<void> signOut() async {
    try {
      final supabase = ref.read(supabaseProvider);
      await supabase.auth.signOut();
      state = null;
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    try {
      final supabase = ref.read(supabaseProvider);
      await supabase
          .from('users')
          .update(updatedUser.toJson())
          .eq('id', updatedUser.id);

      state = updatedUser;
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }
}
