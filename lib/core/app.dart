import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router_simple.dart';
import 'theme/user_theme_provider.dart';
import '../shared/ui/app_snack.dart';
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
      String text;
      switch (event.type) {
        case 'incoming':
          text = 'Nueva solicitud de amistad';
          break;
        case 'accepted':
          text = '¡Solicitud aceptada! Ya son amigos';
          break;
        case 'rejected':
          text = 'Solicitud rechazada';
          break;
        default:
          text = 'Actualización de amistad';
      }
      // Usa AppSnack para respetar el tema
      if (!context.mounted) return;
      switch (event.type) {
        case 'incoming':
          AppSnack.info(context, text);
          break;
        case 'accepted':
          AppSnack.success(context, text);
          break;
        case 'rejected':
          AppSnack.warning(context, text);
          break;
        default:
          AppSnack.info(context, text);
      }
    });

    final themeMode = ref.watch(userThemeModeProvider);
    final lightTheme = ref.watch(userLightThemeProvider);
    final darkTheme = ref.watch(userDarkThemeProvider);

    return MaterialApp.router(
      title: 'Fútbol App - Quilicura',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
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
