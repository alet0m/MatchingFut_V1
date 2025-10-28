import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import '../../../auth/data/auth_service.dart';
import '../../../../shared/utils/auth_utils.dart';
import '../../../onboarding/data/onboarding_provider.dart';
import 'complete_edit_profile_page.dart';
import '../../../friends/providers/friends_providers.dart';
import '../../../safety/data/safety_service.dart';
import '../../../safety/data/safety_providers.dart';

class ProfilePage extends ConsumerStatefulWidget {
  final String? userId; // Si es null, muestra el perfil propio
  const ProfilePage({super.key, this.userId});

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
      final supabase = ref.read(supabaseClientProvider);

      // Si viene un userId en la ruta, mostramos ese perfil sin crear nada
      final targetUserId = widget.userId ?? currentUser?.id;
      if (targetUserId == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      var profile =
          await supabase
              .from('profiles')
              .select()
              .eq('id', targetUserId)
              .maybeSingle();

      // Solo crear perfil si NO hay userId de tercero y es tu propio perfil
      final isOwnProfile = widget.userId == null && currentUser != null;
      if (profile == null && isOwnProfile) {
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

      // Cargar estadísticas desde la tabla players para mostrar detalles
      Map<String, dynamic> stats = {
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
      try {
        final player =
            await supabase
                .from('players')
                .select(
                  'goals,assists,matches_played,wins,losses,draws,yellow_cards,red_cards,minutes_played,elo_rating',
                )
                .eq('id', targetUserId)
                .maybeSingle();
        if (player != null) {
          stats = {
            'partidos_jugados': player['matches_played'] ?? 0,
            'goles': player['goals'] ?? 0,
            'asistencias': player['assists'] ?? 0,
            'victorias': player['wins'] ?? 0,
            'derrotas': player['losses'] ?? 0,
            'empates': player['draws'] ?? 0,
            'tarjetas_amarillas': player['yellow_cards'] ?? 0,
            'tarjetas_rojas': player['red_cards'] ?? 0,
            'elo': player['elo_rating'] ?? 1000,
          };
        }
      } catch (e) {
        debugPrint('Stats load warning: $e');
      }

      // Normalizar campo de foto para distintos nombres de columna
      if (profile != null) {
        profile['estadisticas'] = stats;
        profile['photo_url'] =
            profile['photo_url'] ??
            profile['profile_picture_url'] ??
            profile['profile_image_url'] ??
            '';
      }

      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
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

  String _calculateAge(dynamic dateIso) {
    try {
      final date =
          dateIso is DateTime ? dateIso : DateTime.parse(dateIso.toString());
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
    final currentUser = ref.watch(currentUserProvider);
    final bool isOwnProfile =
        widget.userId == null || widget.userId == currentUser?.id;
    final String? viewedUserId = widget.userId ?? currentUser?.id;
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
    final photoUrl =
        _userProfile?['photo_url'] ??
        _userProfile?['profile_picture_url'] ??
        _userProfile?['profile_image_url'] ??
        '';
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
              Text(
                widget.userId != null
                    ? 'No se encontró el perfil solicitado'
                    : 'No se pudo cargar el perfil',
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
                  if (isOwnProfile) ...[
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
                  ],
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
                  const SizedBox(width: 8),
                  if (!isOwnProfile && viewedUserId != null)
                    _FriendActionButton(userId: viewedUserId),
                  if (!isOwnProfile && viewedUserId != null)
                    _MoreActionsButton(userId: viewedUserId),
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
                    if (isOwnProfile)
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
                            await signOutCompletely(ref, context);
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

class _FriendActionButton extends ConsumerStatefulWidget {
  final String userId;
  const _FriendActionButton({required this.userId});

  @override
  ConsumerState<_FriendActionButton> createState() =>
      _FriendActionButtonState();
}

class _FriendActionButtonState extends ConsumerState<_FriendActionButton> {
  bool _working = false;

  @override
  Widget build(BuildContext context) {
    final friendsService = ref.read(friendsServiceProvider);

    return FutureBuilder<String?>(
      future: friendsService.getPendingRequestStatus(widget.userId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 46,
            height: 46,
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final status = snap.data; // 'sent' | 'received' | null
        if (status == 'sent') {
          return const Chip(
            label: Text('Enviado', style: TextStyle(fontSize: 12)),
            backgroundColor: Colors.orange,
            labelStyle: TextStyle(color: Colors.white),
          );
        }

        if (status == 'received') {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Rechazar',
                onPressed: _working ? null : () => _respond(false),
                icon: const Icon(Icons.close, color: Colors.red),
              ),
              const SizedBox(width: 4),
              ElevatedButton.icon(
                onPressed: _working ? null : () => _respond(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                ),
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Aceptar', style: TextStyle(fontSize: 12)),
              ),
            ],
          );
        }

        return FutureBuilder<bool>(
          future: friendsService.areFriends(widget.userId),
          builder: (context, fSnap) {
            if (fSnap.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                width: 46,
                height: 46,
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }
            final areFriends = fSnap.data ?? false;
            if (areFriends) {
              return const Chip(
                label: Text('Amigos', style: TextStyle(fontSize: 12)),
                backgroundColor: Color(0xFF2E7D32),
                labelStyle: TextStyle(color: Colors.white),
              );
            }

            return ElevatedButton.icon(
              onPressed: _working ? null : _send,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.person_add),
              label: const Text('Agregar amigo'),
            );
          },
        );
      },
    );
  }

  Future<void> _send() async {
    setState(() => _working = true);
    try {
      final friendsService = ref.read(friendsServiceProvider);
      await friendsService.sendFriendRequest(widget.userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud enviada'),
            backgroundColor: Colors.green,
          ),
        );
      }
      // refrescar estado
      setState(() => _working = false);
    } catch (e) {
      setState(() => _working = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _respond(bool accept) async {
    setState(() => _working = true);
    try {
      final friendsService = ref.read(friendsServiceProvider);
      // Si el estado era 'received', el requester es el userId del perfil que veo
      await friendsService.respondToFriendRequest(widget.userId, accept);
      if (mounted) {
        // Invalidar listas relacionadas
        ref.invalidate(friendRequestsProvider);
        ref.invalidate(friendsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              accept ? 'Solicitud aceptada' : 'Solicitud rechazada',
            ),
            backgroundColor: accept ? Colors.green : Colors.orange,
          ),
        );
      }
      setState(() => _working = false);
    } catch (e) {
      setState(() => _working = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _MoreActionsButton extends ConsumerWidget {
  final String userId;
  const _MoreActionsButton({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      tooltip: 'Más acciones',
      onSelected: (value) async {
        switch (value) {
          case 'block':
            await _confirmBlock(context, ref, userId);
            break;
          case 'report':
            await _openReportDialog(context, ref, userId);
            break;
        }
      },
      itemBuilder:
          (context) => const [
            PopupMenuItem(value: 'block', child: Text('Bloquear usuario')),
            PopupMenuItem(value: 'report', child: Text('Reportar usuario')),
          ],
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: const Icon(Icons.more_vert, color: Color(0xFF2E7D32)),
      ),
    );
  }

  Future<void> _confirmBlock(
    BuildContext context,
    WidgetRef ref,
    String uid,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Bloquear usuario'),
            content: const Text(
              'Al bloquear a un usuario:\n\n- No podrán enviarse solicitudes ni mensajes.\n- No se verán en búsquedas ni listas.\n- Podrás desbloquearlo más adelante desde Ajustes.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Bloquear'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await ref.read(safetyServiceProvider).blockUser(uid);
        // Invalidar datos relacionados
        ref.invalidate(friendRequestsProvider);
        ref.invalidate(friendsProvider);
        ref.invalidate(blockedUsersProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuario bloqueado'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _openReportDialog(
    BuildContext context,
    WidgetRef ref,
    String uid,
  ) async {
    final categories = <String, String>{
      'spam': 'Spam',
      'acoso': 'Acoso',
      'contenido_inapropiado': 'Contenido inapropiado',
      'suplantacion': 'Suplantación',
      'trampa': 'Trampa',
      'otro': 'Otro',
    };
    String selected = 'acoso';
    final controller = TextEditingController();
    bool alsoBlock = true;

    final submitted = await showDialog<bool>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Reportar usuario'),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Normas de reporte:\n- Usa esta función ante conductas que violen las reglas.\n- Los reportes se revisan y pueden implicar sanciones.\n- El uso indebido de reportes puede conllevar medidas.',
                          style: TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selected,
                          decoration: const InputDecoration(
                            labelText: 'Categoría',
                          ),
                          items:
                              categories.entries
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e.key,
                                      child: Text(e.value),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (v) => setState(() => selected = v ?? 'acoso'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: controller,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Detalles (opcional, 10-500 caracteres)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        CheckboxListTile(
                          value: alsoBlock,
                          onChanged:
                              (v) => setState(() => alsoBlock = v ?? true),
                          title: const Text('También bloquear a este usuario'),
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Enviar'),
                    ),
                  ],
                ),
          ),
    );

    if (submitted == true) {
      try {
        final details = controller.text.trim();
        if (details.isNotEmpty &&
            (details.length < 10 || details.length > 500)) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Detalles entre 10 y 500 caracteres'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        await ref
            .read(safetyServiceProvider)
            .reportUser(
              reportedUserId: uid,
              category: selected,
              details: details.isEmpty ? null : details,
            );
        if (alsoBlock) {
          await ref.read(safetyServiceProvider).blockUser(uid);
          ref.invalidate(friendRequestsProvider);
          ref.invalidate(friendsProvider);
          ref.invalidate(blockedUsersProvider);
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reporte enviado. Gracias.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}
// ignore_for_file: deprecated_member_use

// ...existing code...
