import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import '../../../auth/data/auth_service.dart';
import '../../../onboarding/data/onboarding_provider.dart';
import 'complete_edit_profile_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final currentUser = ref.read(currentUserProvider);

      if (currentUser != null) {
        final supabase = ref.read(supabaseClientProvider);
        var profile =
            await supabase
                .from('profiles')
                .select()
                .eq('id', currentUser.id)
                .maybeSingle();

        // Si no existe el perfil, crearlo con datos del onboarding
        if (profile == null) {
          final onboardingData = ref.read(onboardingProvider);

          // Preparar datos básicos que sabemos que existen en la tabla
          final newProfile = {
            'id': currentUser.id,
            'email': currentUser.email,
            'display_name': onboardingData['display_name'] ?? '',
            'full_name': onboardingData['full_name'] ?? '',
            'bio': json.encode(onboardingData['bio'] ?? {}),
            'position': onboardingData['position'] ?? '',
            'preferred_foot': onboardingData['preferred_foot'] ?? '',
            'comuna': onboardingData['comuna'] ?? 'quilicura',
            'skill_level': onboardingData['skill_level'] ?? 'principiante',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
            'is_active': true,
            'tag': onboardingData['tag'] ?? '',
            'has_completed_onboarding': true,
          };

          // Agregar date_of_birth solo si no está vacío
          final dateOfBirth = onboardingData['date_of_birth'];
          if (dateOfBirth != null && dateOfBirth.toString().trim().isNotEmpty) {
            newProfile['date_of_birth'] = dateOfBirth;
          }

          // Agregar campos opcionales solo si existen en la tabla
          try {
            // Intentar con todos los campos
            final profileWithOptional = {
              ...newProfile,
              'first_name': onboardingData['first_name'] ?? '',
              'last_name': onboardingData['last_name'] ?? '',
              'photo_url': onboardingData['photo_url'] ?? '',
            };
            await supabase.from('profiles').insert(profileWithOptional);
            profile = profileWithOptional;
          } catch (e) {
            // Si falla, intentar solo con campos básicos
            print(
              'Warning: Some profile fields may not exist, using basic fields only: $e',
            );
            await supabase.from('profiles').insert(newProfile);
            profile = newProfile;
          }
        }

        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar perfil: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  String _calculateAge(String dateIso) {
    try {
      final date = DateTime.parse(dateIso);
      final now = DateTime.now();
      int age = now.year - date.year;
      if (now.month < date.month ||
          (now.month == date.month && now.day < date.day)) {
        age--;
      }
      return age.toString();
    } catch (_) {
      return "-";
    }
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _statBannerItem(String label, dynamic value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFFFF6F00), size: 22),
        SizedBox(width: 4),
        Text(
          value.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  String _getBioField(String key, {String suffix = "", bool isList = false}) {
    try {
      final bio = _userProfile?["bio"];
      if (bio == null) return "-";
      final bioMap = Map<String, dynamic>.from(json.decode(bio));
      final value = bioMap[key];
      if (value == null) return "-";
      if (isList && value is List) {
        return value.join(", ");
      }
      return value.toString() + suffix;
    } catch (_) {
      return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats =
        _userProfile?['estadisticas'] ??
        {
          'partidos_jugados': 0,
          'goles': 0,
          'asistencias': 0,
          'victorias': 0,
          'derrotas': 0,
          'empates': 0,
          'tarjetas_amarillas': 0,
          'tarjetas_rojas': 0,
          'elo': 1000,
        };
    final photoUrl = _userProfile?['photo_url'] ?? '';
    final nombre =
        _userProfile?['display_name'] ?? _userProfile?['full_name'] ?? '';
    final posicion = _userProfile?['position'] ?? '';
    final elo = stats['elo'] ?? 1000;

    if (_isLoading) {
      return Container(
        color: const Color(0xFFF8F9FA),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
        ),
      );
    }

    if (_userProfile == null) {
      return Container(
        color: const Color(0xFFF8F9FA),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No se pudo cargar el perfil',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 120,
                    top: 32,
                    right: 24,
                    bottom: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        posicion,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _statBannerItem('ELO', elo, Icons.leaderboard),
                          const SizedBox(width: 24),
                          _statBannerItem(
                            'Partidos',
                            stats['partidos_jugados'],
                            Icons.sports_soccer,
                          ),
                          const SizedBox(width: 24),
                          _statBannerItem(
                            'Goles',
                            stats['goles'],
                            Icons.sports,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 24,
                top: 32,
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                  child:
                      photoUrl.isEmpty
                          ? const Icon(
                            Icons.person,
                            size: 48,
                            color: Color(0xFF2E7D32),
                          )
                          : null,
                ),
              ),
            ],
          ),
          // Botón para ir a la lista de amigos
          Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 16.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit, color: Color(0xFFFF6F00)),
                    label: const Text(
                      'Editar',
                      style: TextStyle(color: Color(0xFFFF6F00)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFFF6F00),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (_userProfile != null) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => CompleteEditProfilePage(
                                  userProfile: _userProfile!,
                                ),
                          ),
                        );
                        _loadUserProfile(); // Recargar datos después de editar
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.people, color: Color(0xFF2E7D32)),
                    label: const Text(
                      'Amigos',
                      style: TextStyle(color: Color(0xFF2E7D32)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2E7D32),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      GoRouter.of(context).push('/friends');
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.cake,
                                  color: Color(0xFFFF6F00),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Edad: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _userProfile != null &&
                                          _userProfile!['date_of_birth'] != null
                                      ? _calculateAge(
                                        _userProfile!['date_of_birth'],
                                      )
                                      : '-',
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(
                                  Icons.sports_soccer,
                                  color: Color(0xFFFF6F00),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Posición: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(_userProfile?['position'] ?? '-'),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(
                                  Icons.emoji_events,
                                  color: Color(0xFFFF6F00),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Nivel: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(_userProfile?['skill_level'] ?? '-'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Datos físicos y experiencia',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildProfileRow(
                              'Altura',
                              _getBioField('altura', suffix: ' cm'),
                            ),
                            _buildProfileRow(
                              'Peso',
                              _getBioField('peso', suffix: ' kg'),
                            ),
                            _buildProfileRow(
                              'Experiencia',
                              _getBioField('experiencia', suffix: ' años'),
                            ),
                            _buildProfileRow(
                              'Pie hábil',
                              _userProfile != null
                                  ? _userProfile!['preferred_foot'] ?? '-'
                                  : '-',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Preferencias y objetivos',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildProfileRow(
                              'Tipo de juego',
                              _getBioField('tipo_juego'),
                            ),
                            _buildProfileRow(
                              'Días disponibles',
                              _getBioField('dias_disponibles', isList: true),
                            ),
                            _buildProfileRow(
                              'Horario preferido',
                              _getBioField('horario_preferido'),
                            ),
                            _buildProfileRow(
                              'Objetivos',
                              _getBioField('objetivos', isList: true),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.logout),
                        label: const Text('Cerrar sesión'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 32,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          try {
                            print(
                              '🔄 Iniciando proceso completo de cierre de sesión',
                            );

                            // NO mostrar diálogo para evitar problemas de navegación
                            // Proceder directamente con el logout

                            // 1. Cerrar sesión en AuthService (incluye limpieza de Supabase y SharedPreferences)
                            await ref.read(authServiceProvider).signOut();
                            print('✅ AuthService signOut completado');

                            // 2. Invalidar providers de Riverpod para limpiar el estado
                            ref.invalidate(currentUserProvider);
                            ref.invalidate(authStateProvider);
                            ref.read(onboardingProvider.notifier).state = {};
                            print('✅ Providers de Riverpod invalidados');

                            // 3. Navegar directamente sin diálogos intermedios
                            if (mounted) {
                              GoRouter.of(context).go('/welcome');
                              print('✅ Navegación a welcome completada');
                            }
                          } catch (e) {
                            print('❌ Error durante el cierre de sesión: $e');

                            // Aún así limpiar estado local
                            ref.invalidate(currentUserProvider);
                            ref.invalidate(authStateProvider);
                            ref.read(onboardingProvider.notifier).state = {};

                            // Navegar al welcome de todas formas
                            if (mounted) {
                              GoRouter.of(context).go('/welcome');
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ...aquí va el método build y helpers...
  // Puedes pegar aquí el método build limpio y helpers que ya tienes.
}
// ignore_for_file: deprecated_member_use

// ...existing code...
