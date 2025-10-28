import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/welcome',
    debugLogDiagnostics: true,
    routes: [
      // Ruta de bienvenida (inicial)
      GoRoute(
        path: '/welcome',
        builder: (context, state) {
          debugPrint('🎯 Mostrando WelcomePage');
          return const WelcomePage();
        },
      ),

      // Ruta de login
      GoRoute(
        path: '/login',
        builder: (context, state) {
          debugPrint('🎯 Mostrando LoginPage');
          return const LoginPage();
        },
      ),

      // Ruta de registro
      GoRoute(
        path: '/register',
        builder: (context, state) {
          debugPrint('🎯 Mostrando RegisterPage');
          return const RegisterPage();
        },
      ),

      // Dashboard simple (sin shell)
      GoRoute(
        path: '/dashboard',
        builder: (context, state) {
          debugPrint('🎯 Mostrando DashboardPage');
          return const DashboardPage();
        },
      ),
    ],
    errorBuilder: (context, state) {
      debugPrint('❌ Error en router: ${state.error}');
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${state.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/welcome'),
                child: const Text('Volver a Inicio'),
              ),
            ],
          ),
        ),
      );
    },
  );
});
