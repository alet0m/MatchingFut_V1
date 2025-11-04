import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../features/auth/data/auth_service.dart';

class SafetyService {
  final SupabaseClient _supabase;
  SafetyService(this._supabase);

  Future<void> blockUser(String targetUserId) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) throw Exception('Usuario no autenticado');
    if (uid == targetUserId) throw Exception('No puedes bloquearte a ti mismo');

    // Upsert para idempotencia
    await _supabase.from('user_blocks').upsert({
      'blocker_id': uid,
      'blocked_id': targetUserId,
    }, onConflict: 'blocker_id,blocked_id');

    // Al bloquear: eliminar cualquier relación/solicitud de amistad en ambas direcciones
    try {
      await _supabase
          .from('friendships')
          .delete()
          .or(
            'and(requester_id.eq.$uid,receiver_id.eq.$targetUserId),and(requester_id.eq.$targetUserId,receiver_id.eq.$uid)',
          );
    } catch (_) {
      // Ignorar si no hay permisos o no existen filas; el bloqueo sigue vigente
    }
  }

  Future<void> unblockUser(String targetUserId) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) throw Exception('Usuario no autenticado');

    await _supabase
        .from('user_blocks')
        .delete()
        .eq('blocker_id', uid)
        .eq('blocked_id', targetUserId);
  }

  Future<bool> isBlockedAnyDirection(String otherUserId) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return false;
    final rec =
        await _supabase
            .from('user_blocks')
            .select()
            .or(
              'and(blocker_id.eq.$uid,blocked_id.eq.$otherUserId),and(blocker_id.eq.$otherUserId,blocked_id.eq.$uid)',
            )
            .maybeSingle();
    return rec != null;
  }

  Future<void> reportUser({
    required String reportedUserId,
    required String
    category, // spam, acoso, contenido_inapropiado, suplantacion, trampa, otro
    String? details,
  }) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) throw Exception('Usuario no autenticado');
    if (uid == reportedUserId) {
      throw Exception('No puedes reportarte a ti mismo');
    }

    await _supabase.from('user_reports').insert({
      'reporter_id': uid,
      'reported_id': reportedUserId,
      'category': category,
      if (details != null && details.trim().isNotEmpty)
        'details': details.trim(),
    });
  }
}

final safetyServiceProvider = Provider<SafetyService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SafetyService(supabase);
});
