import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Página de prueba simple
class TestPage extends StatelessWidget {
  final String title;
  final List<String> routes;

  const TestPage({super.key, required this.title, required this.routes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Navegación de Prueba',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ...routes
                .map(
                  (route) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ElevatedButton(
                      onPressed: () => context.go(route),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text('Ir a $route'),
                    ),
                  ),
                )
                ,
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: const Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 48),
                  SizedBox(height: 8),
                  Text(
                    'App funcionando correctamente',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/test',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/test',
        builder:
            (context, state) => const TestPage(
              title: 'Test Principal',
              routes: ['/welcome', '/login', '/register'],
            ),
      ),
      GoRoute(
        path: '/welcome',
        builder:
            (context, state) => const TestPage(
              title: 'Welcome Test',
              routes: ['/test', '/login', '/register'],
            ),
      ),
      GoRoute(
        path: '/login',
        builder:
            (context, state) => const TestPage(
              title: 'Login Test',
              routes: ['/test', '/welcome', '/register'],
            ),
      ),
      GoRoute(
        path: '/register',
        builder:
            (context, state) => const TestPage(
              title: 'Register Test',
              routes: ['/test', '/welcome', '/login'],
            ),
      ),
    ],
    errorBuilder: (context, state) {
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
                onPressed: () => context.go('/test'),
                child: const Text('Volver al Test'),
              ),
            ],
          ),
        ),
      );
    },
  );
});
