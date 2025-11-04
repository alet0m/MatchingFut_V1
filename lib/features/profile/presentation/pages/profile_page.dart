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
  int? _globalRank;
  int? _totalPlayers;
  List<Map<String, dynamic>> _teams = const [];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final currentUser = ref.read(currentUserProvider);
      final supabase = ref.read(supabaseClientProvider);

      final targetUserId = widget.userId ?? currentUser?.id;
      if (targetUserId == null) {
        setState(() => _isLoading = false);
        return;
      }

      var profile =
          await supabase
              .from('profiles')
              .select()
              .eq('id', targetUserId)
              .maybeSingle();

      final isOwnProfile = widget.userId == null && currentUser != null;
      if (profile == null && isOwnProfile) {
        final onboardingData = ref.read(onboardingProvider);
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
        final dateOfBirth = onboardingData['date_of_birth'];
        if (dateOfBirth != null && dateOfBirth.toString().trim().isNotEmpty) {
          newProfile['date_of_birth'] = dateOfBirth;
        }
        try {
          final profileWithOptional = {
            ...newProfile,
            'first_name': onboardingData['first_name'] ?? '',
            'last_name': onboardingData['last_name'] ?? '',
            'photo_url': onboardingData['photo_url'] ?? '',
          };
          await supabase.from('profiles').insert(profileWithOptional);
          profile = profileWithOptional;
        } catch (_) {
          await supabase.from('profiles').insert(newProfile);
          profile = newProfile;
        }
      }

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
        } else {
          // Si no existe fila en players para este usuario, la creamos con valores por defecto
          try {
            await supabase.from('players').insert({'id': targetUserId});
            final created =
                await supabase
                    .from('players')
                    .select(
                      'goals,assists,matches_played,wins,losses,draws,yellow_cards,red_cards,minutes_played,elo_rating',
                    )
                    .eq('id', targetUserId)
                    .maybeSingle();
            if (created != null) {
              stats = {
                'partidos_jugados': created['matches_played'] ?? 0,
                'goles': created['goals'] ?? 0,
                'asistencias': created['assists'] ?? 0,
                'victorias': created['wins'] ?? 0,
                'derrotas': created['losses'] ?? 0,
                'empates': created['draws'] ?? 0,
                'tarjetas_amarillas': created['yellow_cards'] ?? 0,
                'tarjetas_rojas': created['red_cards'] ?? 0,
                'elo': created['elo_rating'] ?? 1000,
              };
            }
          } catch (e) {
            debugPrint('Create default player row failed: $e');
          }
        }
      } catch (e) {
        debugPrint('Stats load warning: $e');
      }

      if (profile != null) {
        profile['estadisticas'] = stats;
        profile['photo_url'] =
            profile['photo_url'] ??
            profile['profile_picture_url'] ??
            profile['profile_image_url'] ??
            '';
        profile['banner_url'] =
            profile['banner_url'] ??
            profile['cover_url'] ??
            profile['header_image_url'] ??
            '';
      }

      // Equipos del usuario
      List<Map<String, dynamic>> teams = [];
      try {
        final list =
            await supabase
                    .from('team_members')
                    .select('team_id, teams!inner(id,name,elo_rating)')
                    .eq('player_id', targetUserId)
                as List<dynamic>;
        teams =
            list
                .map((e) {
                  final m = Map<String, dynamic>.from(e as Map);
                  final t = Map<String, dynamic>.from(m['teams'] ?? {});
                  return {
                    'id': t['id'],
                    'name': t['name'] ?? 'Equipo',
                    'elo': t['elo_rating'] ?? 0,
                  };
                })
                .toList()
                .cast<Map<String, dynamic>>();

        // Opcional: intentar cargar ranking global del equipo si existe la vista
        if (teams.isNotEmpty) {
          try {
            final ids = teams.map((t) => t['id']).whereType<String>().toList();
            if (ids.isNotEmpty) {
              final rankMap = <String, int>{};
              for (final id in ids) {
                final row =
                    await supabase
                        .from('team_global_rank')
                        .select('id,rank')
                        .eq('id', id)
                        .maybeSingle();
                if (row != null) {
                  final rk = (row['rank'] as num?)?.toInt();
                  if (rk != null) rankMap[id] = rk;
                }
              }
              teams =
                  teams
                      .map(
                        (t) => {
                          ...t,
                          if (rankMap.containsKey(t['id']))
                            'rank': rankMap[t['id']],
                        },
                      )
                      .toList();
            }
          } catch (e) {
            debugPrint('Team rank view not available: $e');
          }
        }
      } catch (e) {
        debugPrint('Teams load skipped: $e');
      }

      // Ranking global real (si existe la vista)
      int? gRank;
      int? tPlayers;
      try {
        final rankRow =
            await supabase
                .from('player_global_rank')
                .select('global_rank,total_players')
                .eq('id', targetUserId)
                .maybeSingle();
        if (rankRow != null) {
          gRank = (rankRow['global_rank'] as num?)?.toInt();
          tPlayers = (rankRow['total_players'] as num?)?.toInt();
        }
      } catch (e) {
        debugPrint('Global rank not available: $e');
      }

      setState(() {
        _userProfile = profile;
        _teams = teams;
        _globalRank = gRank;
        _totalPlayers = tPlayers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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

  String _initialsFromName(String name) {
    final parts =
        name.trim().split(RegExp(r"\s+")).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  String _getBioField(String key, {String suffix = "", bool isList = false}) {
    try {
      final bio = _userProfile?["bio"];
      if (bio == null) return "-";
      final bioMap = Map<String, dynamic>.from(json.decode(bio));
      final value = bioMap[key];
      if (value == null) return "-";
      if (isList && value is List) return value.join(", ");
      return value.toString() + suffix;
    } catch (_) {
      return "-";
    }
  }

  // UI helpers (original minimal design, responsive)
  Widget _buildProfileHeader({
    required String name,
    required String email,
    required String photoUrl,
    required num elo,
    required num matches,
  }) {
    final hasElo = matches > 0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final avatarSize = maxW < 360 ? 80.0 : 100.0;
        final nameSize = maxW < 360 ? 22.0 : 28.0;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(avatarSize / 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(avatarSize / 2),
                  child:
                      photoUrl.isNotEmpty
                          ? Image.network(photoUrl, fit: BoxFit.cover)
                          : Center(
                            child: Text(
                              _initialsFromName(name),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name.isEmpty ? 'Jugador' : name,
                style: TextStyle(
                  fontSize: nameSize,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 6),
              if (email.isNotEmpty)
                Text(
                  email,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient:
                      hasElo
                          ? const LinearGradient(
                            colors: [Color(0xFFFF6F00), Color(0xFFE65100)],
                          )
                          : null,
                  color: hasElo ? null : Colors.grey[200],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  hasElo ? 'ELO ${elo.toStringAsFixed(0)}' : 'Sin ranking',
                  style: TextStyle(
                    color: hasElo ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid({
    required num matches,
    required num elo,
    String? rankLabel,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        int cols = maxW >= 380 ? 3 : 2;
        const spacing = 12.0;
        final itemW = (maxW - spacing * (cols - 1)) / cols;
        final cards = <Widget>[
          _buildStatCard(
            'Partidos',
            matches.toStringAsFixed(0),
            Icons.sports_soccer,
            const Color(0xFF2E7D32),
          ),
          _buildStatCard(
            'ELO',
            matches > 0 ? elo.toStringAsFixed(0) : '---',
            Icons.trending_up,
            const Color(0xFFFF6F00),
          ),
          _buildStatCard(
            'Equipos',
            _teams.length.toString(),
            Icons.group,
            const Color(0xFF1976D2),
          ),
        ];
        if (rankLabel != null && rankLabel.isNotEmpty) {
          cards.add(
            _buildStatCard(
              'Ranking global',
              rankLabel,
              Icons.emoji_events_outlined,
              const Color(0xFF6A1B9A),
            ),
          );
        }
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards.map((c) => SizedBox(width: itemW, child: c)).toList(),
        );
      },
    );
  }

  Widget _buildTeamsCard(List<Map<String, dynamic>> teams) {
    if (teams.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: const [
            Icon(Icons.group_outlined, color: Color(0xFF1976D2)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Sin equipos aún',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2).withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: const [
                Icon(Icons.group, color: Color(0xFF1976D2)),
                SizedBox(width: 8),
                Text(
                  'Equipos y rankings',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ...teams.map((t) {
            final elo = t['elo'];
            final trank =
                (t['rank'] is num) ? (t['rank'] as num).toInt() : null;
            return ListTile(
              leading: const Icon(
                Icons.shield_outlined,
                color: Color(0xFF1976D2),
              ),
              title: Text(t['name']?.toString() ?? 'Equipo'),
              subtitle: Text(
                elo is num
                    ? (trank != null
                        ? 'ELO ${elo.toStringAsFixed(0)} · #$trank'
                        : 'ELO ${elo.toStringAsFixed(0)}')
                    : 'Sin ranking',
              ),
            );
          }).toList(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(String text) {
    final value = text.trim();
    if (value.isEmpty || value == '-') return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.short_text, color: Color(0xFF2E7D32)),
              SizedBox(width: 8),
              Text(
                'Descripción',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildInterestsCard(List<String> interests) {
    if (interests.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.interests_outlined, color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Text(
                  'Intereses',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  interests
                      .map(
                        (i) => Chip(
                          label: Text(i),
                          backgroundColor: const Color(
                            0xFF2E7D32,
                          ).withOpacity(0.08),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getBioList(String key) {
    try {
      final bio = _userProfile?["bio"];
      if (bio == null) return const [];
      final bioMap = Map<String, dynamic>.from(json.decode(bio));
      final value = bioMap[key];
      if (value is List) return value.map((e) => e.toString()).toList();
      if (value is String && value.trim().isNotEmpty) return [value];
      return const [];
    } catch (_) {
      return const [];
    }
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> items) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF2E7D32), size: 22),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: items),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final bool isOwnProfile =
        widget.userId == null || widget.userId == currentUser?.id;
    final String? viewedUserId = widget.userId ?? currentUser?.id;

    final photoUrl =
        _userProfile?['photo_url'] ??
        _userProfile?['profile_picture_url'] ??
        _userProfile?['profile_image_url'] ??
        '';
    final nombre =
        (_userProfile?['display_name'] ?? _userProfile?['full_name'] ?? '')
            .toString()
            .trim();
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

    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
        ),
      );
    }

    if (_userProfile == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: const Center(
          child: Text(
            'No se pudo cargar el perfil',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    // Optional ranking label if available
    String? rankLabel;
    if (_globalRank != null) {
      rankLabel =
          _totalPlayers != null
              ? '#$_globalRank de $_totalPlayers'
              : '#$_globalRank';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          nombre.isEmpty ? 'Perfil' : nombre,
          style: const TextStyle(color: Color(0xFF1B5E20)),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Amigos',
            onPressed: () => GoRouter.of(context).push('/friends'),
            icon: const Icon(Icons.people_outline, color: Color(0xFF2E7D32)),
          ),
          if (isOwnProfile)
            IconButton(
              tooltip: 'Editar perfil',
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
                  _loadUserProfile();
                }
              },
              icon: const Icon(Icons.edit_outlined, color: Color(0xFFFF6F00)),
            ),
          if (!isOwnProfile && viewedUserId != null)
            _MoreActionsButton(userId: viewedUserId),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(
              name: nombre,
              email: (_userProfile?['email'] ?? '').toString(),
              photoUrl: photoUrl,
              elo: (stats['elo'] ?? 1000) as num,
              matches: (stats['partidos_jugados'] ?? 0) as num,
            ),
            const SizedBox(height: 24),
            _buildStatsGrid(
              matches: (stats['partidos_jugados'] ?? 0) as num,
              elo: (stats['elo'] ?? 1000) as num,
              rankLabel: rankLabel,
            ),
            const SizedBox(height: 24),
            _buildTeamsCard(_teams),
            const SizedBox(height: 16),
            _buildDescriptionCard(_getBioField('descripcion')),
            const SizedBox(height: 16),
            _buildInfoCard('Información deportiva', Icons.sports_soccer, [
              _buildInfoRow(
                'Edad',
                (_userProfile != null && _userProfile!['date_of_birth'] != null)
                    ? _calculateAge(_userProfile!['date_of_birth'])
                    : '-',
              ),
              _buildInfoRow(
                'Posición',
                (_userProfile?['position'] ?? '-').toString(),
              ),
              _buildInfoRow(
                'Pie dominante',
                (_userProfile?['preferred_foot'] ?? '-').toString(),
              ),
              _buildInfoRow(
                'Nivel',
                (_userProfile?['skill_level'] ?? '-').toString(),
              ),
              _buildInfoRow('Tipo de juego', _getBioField('tipo_juego')),
            ]),
            const SizedBox(height: 16),
            _buildInfoCard('Características físicas', Icons.fitness_center, [
              _buildInfoRow('Altura', _getBioField('altura', suffix: ' cm')),
              _buildInfoRow('Peso', _getBioField('peso', suffix: ' kg')),
            ]),
            const SizedBox(height: 16),
            _buildInfoCard('Preferencias', Icons.schedule, [
              _buildInfoRow(
                'Horario preferido',
                _getBioField('horario_preferido'),
              ),
              _buildInfoRow(
                'Días disponibles',
                _getBioField('dias_disponibles', isList: true),
              ),
              _buildInfoRow(
                'Comuna',
                (_userProfile?['comuna'] ?? '-').toString(),
              ),
            ]),
            const SizedBox(height: 16),
            _buildInterestsCard(_getBioList('intereses')),
            const SizedBox(height: 28),
            if (isOwnProfile)
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 28,
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
    );
  }
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
      await friendsService.respondToFriendRequest(widget.userId, accept);
      if (mounted) {
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
