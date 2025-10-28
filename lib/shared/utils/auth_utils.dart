import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/auth_service.dart';
import 'platform_storage.dart';
import '../../features/onboarding/data/onboarding_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Función auxiliar para limpiar completamente el estado de la aplicación
// Usa ProviderContainer para evitar usar un WidgetRef que pueda estar disposeado tras el cambio de auth
Future<void> clearAppState(ProviderContainer container) async {
  try {
    // Limpiar providers de Riverpod
    container.invalidate(currentUserProvider);
    container.invalidate(authStateProvider);
    // Limpiar onboarding explícitamente
    container.invalidate(onboardingProvider);

    // Limpiar SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Usar debugPrint en lugar de print para evitar warnings
    debugPrint('Estado de la aplicación limpiado completamente');
  } catch (e) {
    debugPrint('Error al limpiar estado: $e');
  }
}

// Función para cerrar sesión completamente
Future<void> signOutCompletely(WidgetRef ref, BuildContext context) async {
  try {
    // Capturar el container lo antes posible (antes de que auth cambie y el widget se deseche)
    final container = ProviderScope.containerOf(context, listen: false);
    // Mostrar indicador de carga solo si el context sigue montado
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text('Cerrando sesión...'),
                ],
              ),
            ),
      );
    }

    // Cerrar sesión en Supabase usando el container (evita usar ref tras dispose)
    await container.read(authServiceProvider).signOut();

    // Limpiar estado completo
    await clearAppState(container);

    if (context.mounted) {
      // Cerrar diálogo de carga
      Navigator.of(context).pop();

      // Navegar al welcome con limpieza completa
      GoRouter.of(context).go('/welcome');

      // Mostrar confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesión cerrada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Verificación rápida: si por alguna razón el usuario siguiera presente, recargamos como fallback (raro)
      Future.microtask(() async {
        await Future.delayed(const Duration(milliseconds: 50));
        final stillLogged = Supabase.instance.client.auth.currentUser != null;
        if (stillLogged) {
          debugPrint(
            '⚠️ Sesión aún presente tras signOut, recargando app (fallback)',
          );
          await reloadWebApp();
        }
      });
    }
  } catch (e) {
    // Aún así limpiar estado local
    try {
      final container = ProviderScope.containerOf(context, listen: false);
      await clearAppState(container);
    } catch (_) {}

    if (context.mounted) {
      // Cerrar diálogo de carga si existe
      try {
        Navigator.of(context).pop();
      } catch (_) {
        // Ignorar error si no hay diálogo que cerrar
      }

      // Navegar al welcome de todas formas
      GoRouter.of(context).go('/welcome');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
