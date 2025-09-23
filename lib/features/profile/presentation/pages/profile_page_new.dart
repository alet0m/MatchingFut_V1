// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../auth/data/auth_service.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _playerProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final authService = ref.read(authServiceProvider);
      final currentUser = ref.read(currentUserProvider);

      if (currentUser != null) {
        // Obtener perfil básico del usuario
        final userProfile = await authService.getUserProfile(currentUser.id);

        // Obtener perfil completo del jugador
        final supabase = ref.read(supabaseClientProvider);
        final playerProfile =
            await supabase
                .from('player_profiles')
                .select()
                .eq('user_id', currentUser.id)
                .single();

        setState(() {
          _userProfile = userProfile;
          _playerProfile = playerProfile;
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
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
        ),
      );
    }

    if (_userProfile == null || _playerProfile == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Error al cargar el perfil',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUserProfile,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF2E7D32)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función de edición próximamente'),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header del perfil minimalista
            _buildProfileHeader().animate().fadeIn(duration: 600.ms),

            const SizedBox(height: 32),

            // Estadísticas de juego
            _buildStatsGrid().animate().fadeIn(duration: 600.ms, delay: 200.ms),

            const SizedBox(height: 24),

            // Información deportiva
            _buildInfoCard('Información Deportiva', Icons.sports_soccer, [
              _buildInfoRow(
                'Experiencia',
                '${_playerProfile!['years_playing'] ?? 1} años jugando',
              ),
              _buildInfoRow(
                'Posición',
                _formatPosition(_playerProfile!['preferred_position']),
              ),
              _buildInfoRow(
                'Pie dominante',
                _formatFoot(_playerProfile!['dominant_foot']),
              ),
              _buildInfoRow(
                'Nivel',
                _formatSkillLevel(_playerProfile!['skill_level']),
              ),
              _buildInfoRow(
                'Tipo de juego',
                _formatGameType(_playerProfile!['preferred_game_type']),
              ),
            ]).animate().fadeIn(duration: 600.ms, delay: 400.ms),

            const SizedBox(height: 24),

            // Características físicas
            _buildInfoCard('Características Físicas', Icons.fitness_center, [
              _buildInfoRow(
                'Altura',
                '${_playerProfile!['height'] ?? '---'} cm',
              ),
              _buildInfoRow('Peso', '${_playerProfile!['weight'] ?? '---'} kg'),
            ]).animate().fadeIn(duration: 600.ms, delay: 600.ms),

            const SizedBox(height: 24),

            // Preferencias
            _buildInfoCard('Preferencias', Icons.schedule, [
              _buildInfoRow(
                'Hora preferida',
                _playerProfile!['preferred_time']?.toString() ?? 'Flexible',
              ),
              _buildInfoRow(
                'Comuna',
                _userProfile!['comuna_id'] ?? 'No asignada',
              ),
            ]).animate().fadeIn(duration: 600.ms, delay: 800.ms),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final nickname =
        _playerProfile!['nickname'] ?? _userProfile!['full_name'] ?? 'Jugador';
    final currentElo = _playerProfile!['current_elo'];
    final hasElo =
        currentElo != null &&
        currentElo != 1200; // Solo mostrar ELO si ha jugado

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
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
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D32).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.person, size: 50, color: Colors.white),
          ),

          const SizedBox(height: 20),

          // Nombre
          Text(
            nickname,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),

          const SizedBox(height: 8),

          // Email
          Text(
            _userProfile!['email'] ?? '',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),

          const SizedBox(height: 16),

          // ELO Badge (solo si ha jugado)
          if (hasElo)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6F00), Color(0xFFE65100)],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                'ELO $currentElo',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                'Sin ranking',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final currentElo = _playerProfile!['current_elo'];
    final hasElo = currentElo != null && currentElo != 1200;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Partidos',
            '0', // Siempre 0 hasta que implementemos partidos reales
            Icons.sports_soccer,
            const Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'ELO',
            hasElo ? currentElo.toString() : '---',
            Icons.trending_up,
            const Color(0xFFFF6F00),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Equipos',
            '0', // Siempre 0 hasta que se una a un equipo
            Icons.group,
            const Color(0xFF1976D2),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
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
          // Header de la sección
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF2E7D32), size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
          // Contenido
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: items),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
                fontSize: 16,
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
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPosition(String? position) {
    switch (position) {
      case 'goalkeeper':
        return 'Portero';
      case 'defender':
        return 'Defensa';
      case 'midfielder':
        return 'Mediocampista';
      case 'forward':
        return 'Delantero';
      default:
        return 'No especificada';
    }
  }

  String _formatFoot(String? foot) {
    switch (foot) {
      case 'right':
        return 'Derecho';
      case 'left':
        return 'Izquierdo';
      case 'both':
        return 'Ambos';
      default:
        return 'No especificado';
    }
  }

  String _formatSkillLevel(String? level) {
    switch (level) {
      case 'beginner':
        return 'Principiante';
      case 'intermediate':
        return 'Intermedio';
      case 'advanced':
        return 'Avanzado';
      case 'semi_professional':
        return 'Semi-profesional';
      default:
        return 'No especificado';
    }
  }

  String _formatGameType(String? gameType) {
    switch (gameType) {
      case 'futsal':
        return 'Futsal';
      case 'football7':
        return 'Fútbol 7';
      case 'football11':
        return 'Fútbol 11';
      default:
        return 'No especificado';
    }
  }
}
