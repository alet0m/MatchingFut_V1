import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/app.dart';
import 'core/config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Deshabilitar el mouse tracker para evitar errores
  debugPrint('Iniciando aplicación...');

  // Configurar modos de depuración
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.toString().contains('mouse_tracker')) {
      // Ignorar errores de mouse_tracker
      return;
    }
    FlutterError.presentError(details);
  };

  // Inicializar Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const ProviderScope(child: FutbolApp()));
}
