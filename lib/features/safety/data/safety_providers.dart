import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/data/auth_service.dart';

final blockedUsersProvider = FutureProvider.autoDispose<
  List<Map<String, dynamic>>
>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final uid = supabase.auth.currentUser?.id;
  if (uid == null) return [];

  // Primero obtenemos ids bloqueados sin join (no debería fallar con nuestras policies)
  final basicRows = await supabase
      .from('user_blocks')
      .select('blocked_id, created_at')
      .eq('blocker_id', uid)
      .order('created_at', ascending: false);

  if (basicRows.isEmpty) return [];

  // Segundo paso: obtener perfiles por IDs (más tolerante que el join embebido)
  try {
    final blockedIds = [for (final r in basicRows) r['blocked_id'] as String];
    // Evitar errores con IN vacío
    if (blockedIds.isEmpty) return [];

    final profilesRows = await supabase
        .from('profiles')
        .select('id, full_name, email, profile_image_url, profile_picture_url')
        .inFilter('id', blockedIds);

    final byId = <String, Map<String, dynamic>>{
      for (final p in profilesRows) (p['id'] as String): p,
    };

    return [
      for (final r in basicRows)
        {
          'blocked_id': r['blocked_id'],
          'created_at': r['created_at'],
          'id': r['blocked_id'],
          'full_name': () {
            final raw = byId[r['blocked_id']]?['full_name'] as String?;
            final resolved =
                (raw != null && raw.trim().isNotEmpty)
                    ? raw
                    : (byId[r['blocked_id']]?['email'] as String?);
            return resolved ?? 'Usuario';
          }(),
          'email': (byId[r['blocked_id']]?['email'] as String?) ?? '',
          'profile_image_url':
              byId[r['blocked_id']]?['profile_image_url'] ??
              byId[r['blocked_id']]?['profile_picture_url'],
        },
    ];
  } catch (_) {
    // Fallback: mínimos si el SELECT a profiles aún no está permitido
    return [
      for (final r in basicRows)
        {
          'blocked_id': r['blocked_id'],
          'created_at': r['created_at'],
          'id': r['blocked_id'],
          'full_name': 'Usuario',
          'email': '',
          'profile_image_url': null,
        },
    ];
  }
});

final myReportsProvider = FutureProvider.autoDispose<
  List<Map<String, dynamic>>
>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final uid = supabase.auth.currentUser?.id;
  if (uid == null) return [];

  // Primero obtenemos filas básicas sin join
  final baseReports = await supabase
      .from('user_reports')
      .select('id, reported_id, category, details, created_at')
      .eq('reporter_id', uid)
      .order('created_at', ascending: false);

  if (baseReports.isEmpty) return [];

  try {
    final reportedIds = [
      for (final r in baseReports) r['reported_id'] as String,
    ];
    if (reportedIds.isEmpty) return [];

    final profilesRows = await supabase
        .from('profiles')
        .select('id, full_name, email, profile_image_url, profile_picture_url')
        .inFilter('id', reportedIds);

    final byId = <String, Map<String, dynamic>>{
      for (final p in profilesRows) (p['id'] as String): p,
    };

    return [
      for (final r in baseReports)
        {
          'id': r['id'],
          'category': r['category'],
          'details': r['details'],
          'created_at': r['created_at'],
          'reported_id': r['reported_id'],
          'reported_full_name': () {
            final raw = byId[r['reported_id']]?['full_name'] as String?;
            final resolved =
                (raw != null && raw.trim().isNotEmpty)
                    ? raw
                    : (byId[r['reported_id']]?['email'] as String?);
            return resolved ?? 'Usuario';
          }(),
          'reported_email': (byId[r['reported_id']]?['email'] as String?) ?? '',
          'reported_profile_image_url':
              byId[r['reported_id']]?['profile_image_url'] ??
              byId[r['reported_id']]?['profile_picture_url'],
        },
    ];
  } catch (_) {
    // Fallback: mínimos si el SELECT a profiles aún no está permitido
    return [
      for (final r in baseReports)
        {
          'id': r['id'],
          'category': r['category'],
          'details': r['details'],
          'created_at': r['created_at'],
          'reported_id': r['reported_id'],
          'reported_full_name': 'Usuario',
          'reported_email': '',
          'reported_profile_image_url': null,
        },
    ];
  }
});
