import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/app.dart';
import 'core/config/supabase_config.dart';
// Push notifications removed: using only Supabase Realtime in-app alerts

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('🚀 Iniciando Fútbol App Quilicura...');

  // Configurar modos de depuración
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.toString().contains('mouse_tracker')) {
      debugPrint('⚠️ Ignorando error de mouse_tracker');
      return;
    }
    FlutterError.presentError(details);
  };

  try {
    debugPrint('🔄 Inicializando Supabase...');

    // Inicializar Supabase
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );

    debugPrint('✅ Supabase inicializado correctamente');

    debugPrint('🎯 Iniciando aplicación Flutter...');

    runApp(const ProviderScope(child: FutbolApp()));
  } catch (e, stackTrace) {
    debugPrint('❌ Error durante la inicialización: $e');
    debugPrint('📍 Stack trace: $stackTrace');

    // App de emergencia si falla Supabase
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Error de Inicialización',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Error: $e'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Reintentar
                    main();
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
