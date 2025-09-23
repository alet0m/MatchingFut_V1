import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/auth_service.dart';

// Función auxiliar para limpiar completamente el estado de la aplicación
Future<void> clearAppState(WidgetRef ref) async {
  try {
    // Limpiar providers de Riverpod
    ref.invalidate(currentUserProvider);
    ref.invalidate(authStateProvider);
    // Nota: onboardingProvider se limpia automáticamente con invalidate

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

    // Cerrar sesión en Supabase
    await ref.read(authServiceProvider).signOut();

    // Limpiar estado completo
    await clearAppState(ref);

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
    }
  } catch (e) {
    // Aún así limpiar estado local
    await clearAppState(ref);

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
