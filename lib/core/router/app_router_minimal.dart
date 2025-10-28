import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/pages/dashboard_page_simple.dart';
import '../../shared/widgets/main_scaffold_simple.dart';

// Clase de configuración de autenticación
class AuthState {
  final bool isAuthenticated;
  final String? userId;

  const AuthState({required this.isAuthenticated, this.userId});
}

// Provider de autenticación simplificado
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState(isAuthenticated: true)) {
    _init();
  }

  void _init() {
    // Simular usuario autenticado para testing
    state = const AuthState(isAuthenticated: true, userId: 'test-user');
  }
}

// Router simplificado
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (!authState.isAuthenticated && state.uri.path != '/') {
        return '/';
      }
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainScaffoldSimple(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'dashboard',
            builder: (context, state) => const DashboardPageSimple(),
          ),
        ],
      ),
    ],
  );
});
