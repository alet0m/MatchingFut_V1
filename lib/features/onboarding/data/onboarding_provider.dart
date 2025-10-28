import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider global para almacenar los datos del onboarding
final onboardingProvider = StateProvider<Map<String, dynamic>>((ref) => {});

// Ejemplo de uso:
// ref.read(onboardingProvider.notifier).state = {
//   'display_name': 'Edgardo',
//   'full_name': 'Edgardo Pinares',
//   'first_name': 'Edgardo',
//   'last_name': 'Pinares',
//   'photo_url': 'https://...',
//   'bio': {...},
//   ...otros campos...
// };
