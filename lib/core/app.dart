import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router_simple.dart';
import 'theme/app_theme.dart';
import '../features/friends/providers/friends_notifications_provider.dart';

class FutbolApp extends ConsumerWidget {
  const FutbolApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    // Escuchar notificaciones de amistad en tiempo real y mostrar SnackBars
    ref.listen(friendRequestEventsProvider, (prev, next) {
      final event = next.asData?.value;
      if (event == null) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;
      String text;
      Color color;
      switch (event.type) {
        case 'incoming':
          text = 'Nueva solicitud de amistad';
          color = const Color(0xFF2E7D32);
          break;
        case 'accepted':
          text = '¡Solicitud aceptada! Ya son amigos';
          color = const Color(0xFF2E7D32);
          break;
        case 'rejected':
          text = 'Solicitud rechazada';
          color = const Color(0xFFFF6F00);
          break;
        default:
          text = 'Actualización de amistad';
          color = const Color(0xFF2E7D32);
      }
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(content: Text(text), backgroundColor: color),
      );
    });

    return MaterialApp.router(
      title: 'Fútbol App - Quilicura',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      // Keep app adaptive; we could also clamp text scaling if layout requires
      builder: (context, child) {
        // Optional: Slightly limit extreme system text scale on small devices to reduce overflows.
        // We respect user settings but keep reasonable bounds for mobile layouts.
        final mq = MediaQuery.of(context);
        final textScaler = mq.textScaler.clamp(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.2,
        );
        return MediaQuery(
          data: mq.copyWith(textScaler: textScaler),
          child: child ?? const SizedBox.shrink(),
        );
      },
      routerConfig: router,
    );
  }
}
