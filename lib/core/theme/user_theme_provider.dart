import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../../features/auth/data/auth_service.dart';
import 'app_theme.dart';
import 'theme_prefs.dart';

// Stream provider that emits ThemePrefs for the current user, reacting to auth
// changes and realtime updates to their profile row.
final userThemePrefsProvider = StreamProvider<ThemePrefs>((ref) async* {
  // Rebuild on auth changes
  ref.watch(authStateProvider);
  final supabase = ref.watch(supabaseProvider);
  final uid = supabase.auth.currentUser?.id;

  // If not logged in, emit defaults and stop.
  if (uid == null) {
    yield ThemePrefs.defaults();
    return;
  }

  Future<ThemePrefs> load() async {
    try {
      final row =
          await supabase
              .from('profiles')
              .select('theme_prefs')
              .eq('id', uid)
              .maybeSingle();
      final prefsMap = (row?['theme_prefs'] as Map?)?.cast<String, dynamic>();
      return ThemePrefs.fromMap(prefsMap);
    } catch (_) {
      return ThemePrefs.defaults();
    }
  }

  final controller = StreamController<ThemePrefs>.broadcast();
  ThemePrefs? lastEmitted;
  Timer? debounce;
  bool fetching = false;

  void scheduleEmit() {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 150), () async {
      if (fetching) return;
      fetching = true;
      final value = await load();
      if (value.toMap().toString() != lastEmitted?.toMap().toString()) {
        lastEmitted = value;
        controller.add(value);
      }
      fetching = false;
    });
  }

  // initial fetch
  scheduleEmit();

  final ch =
      supabase
          .channel('theme:profiles:$uid')
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'profiles',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'id',
              value: uid,
            ),
            callback: (_) => scheduleEmit(),
          )
          .subscribe();

  ref.onDispose(() {
    debounce?.cancel();
    controller.close();
    supabase.removeChannel(ch);
  });

  yield* controller.stream;
});

// Map ThemePrefs to ThemeMode
final userThemeModeProvider = Provider<ThemeMode>((ref) {
  final prefs = ref
      .watch(userThemePrefsProvider)
      .maybeWhen(data: (d) => d, orElse: () => ThemePrefs.defaults());
  switch (prefs.mode) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
    default:
      return ThemeMode.system;
  }
});

// Compute ThemeData light/dark from prefs using AppTheme helpers
final userLightThemeProvider = Provider<ThemeData>((ref) {
  final prefs = ref
      .watch(userThemePrefsProvider)
      .maybeWhen(data: (d) => d, orElse: () => ThemePrefs.defaults());
  return AppTheme.buildTheme(
    seed: prefs.seedColor,
    accent: prefs.accentColor,
    brightness: Brightness.light,
    amoled: false,
  );
});

final userDarkThemeProvider = Provider<ThemeData>((ref) {
  final prefs = ref
      .watch(userThemePrefsProvider)
      .maybeWhen(data: (d) => d, orElse: () => ThemePrefs.defaults());
  return AppTheme.buildTheme(
    seed: prefs.seedColor,
    accent: prefs.accentColor,
    brightness: Brightness.dark,
    amoled: prefs.style == 'amoled',
  );
});
