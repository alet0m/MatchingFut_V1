import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/models/team_model.dart';
import '../../../../shared/models/sector_model.dart';
import '../../../../shared/widgets/comuna_selector_widget.dart';
import '../services/challenges_service.dart';

final challengesServiceProvider = Provider<ChallengesService>((ref) {
  return ChallengesService();
});

class ChallengesPage extends ConsumerStatefulWidget {
  const ChallengesPage({super.key});

  @override
  ConsumerState<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends ConsumerState<ChallengesPage>
    with SingleTickerProviderStateMixin {
  String? _selectedComunaId;
  String? _selectedComunaName;
  late TabController _tabController;
  bool _isLoading = false;

  // Datos de desafíos
  List<Map<String, dynamic>> _pendingChallenges = [];
  List<Map<String, dynamic>> _activeChallenges = [];
  List<Map<String, dynamic>> _historicalChallenges = [];

  // Equipo del usuario actual
  TeamModel? _userTeam;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserTeam();
    _loadDefaultComuna();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserTeam() async {
    try {
      final challengesService = ref.read(challengesServiceProvider);
      final team = await challengesService.getUserTeam();

      setState(() {
        _userTeam = team;
      });
    } catch (e) {
      debugPrint('Error cargando equipo del usuario: $e');
    }
  }

  Future<void> _loadDefaultComuna() async {
    try {
      setState(() => _isLoading = true);

      // Carga la comuna por defecto (Quilicura)
      await Future.delayed(const Duration(milliseconds: 300)); // Simular carga

      setState(() {
        _selectedComunaId = 'quilicura-id'; // Este ID debe venir de la BD real
        _selectedComunaName = 'Quilicura';
      });

      await _loadChallenges();
    } catch (e) {
      debugPrint('Error cargando comuna por defecto: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadChallenges() async {
    if (_selectedComunaId == null) return;

    setState(() => _isLoading = true);

    try {
      final challengesService = ref.read(challengesServiceProvider);

      // Cargar desafíos pendientes (por confirmar)
      final pendingChallenges = await challengesService.getPendingChallenges(
        _selectedComunaId!,
      );

      // Cargar desafíos activos (confirmados, pendientes de jugar)
      final activeChallenges = await challengesService.getActiveChallenges(
        _selectedComunaId!,
      );

      // Cargar historial de desafíos (completados)
      final historicalChallenges = await challengesService
          .getHistoricalChallenges(_selectedComunaId!);

      setState(() {
        _pendingChallenges = pendingChallenges;
        _activeChallenges = activeChallenges;
        _historicalChallenges = historicalChallenges;
      });
    } catch (e) {
      debugPrint('Error cargando desafíos: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar desafíos: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onComunaSelected(String comunaId, String comunaName) {
    setState(() {
      _selectedComunaId = comunaId;
      _selectedComunaName = comunaName;
    });
    _loadChallenges();
  }

  Future<void> _acceptChallenge(String challengeId) async {
    try {
      setState(() => _isLoading = true);

      final challengesService = ref.read(challengesServiceProvider);
      await challengesService.acceptChallenge(challengeId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Desafío aceptado con éxito')),
      );

      await _loadChallenges();
    } catch (e) {
      debugPrint('Error aceptando desafío: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al aceptar desafío: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _rejectChallenge(String challengeId) async {
    try {
      setState(() => _isLoading = true);

      final challengesService = ref.read(challengesServiceProvider);
      await challengesService.rejectChallenge(challengeId);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Desafío rechazado')));

      await _loadChallenges();
    } catch (e) {
      debugPrint('Error rechazando desafío: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al rechazar desafío: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedComunaName != null
              ? 'Desafíos en $_selectedComunaName'
              : 'Desafíos Territoriales',
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Pendientes'),
            Tab(text: 'Activos'),
            Tab(text: 'Historial'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChallenges,
          ),
        ],
      ),
      body: Column(
        children: [
          // Selector de comuna
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFF8F9FA),
            child: ComunaSelector(
              initialComunaId: _selectedComunaId,
              onComunaSelected: _onComunaSelected,
            ),
          ),

          // Información del equipo del usuario
          if (_userTeam != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.grey[100],
              child: Row(
                children: [
                  const Icon(Icons.group, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 8),
                  Text(
                    'Tu equipo: ${_userTeam!.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    'ELO: ${_userTeam!.eloRating}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

          // Contenido principal
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Desafíos Pendientes
                        _buildChallengesList(_pendingChallenges, 'pending'),

                        // Tab 2: Desafíos Activos
                        _buildChallengesList(_activeChallenges, 'active'),

                        // Tab 3: Historial de Desafíos
                        _buildChallengesList(
                          _historicalChallenges,
                          'historical',
                        ),
                      ],
                    ),
          ),
        ],
      ),
      floatingActionButton:
          _userTeam != null
              ? FloatingActionButton(
                onPressed: () {
                  // Navegar a la página para crear un nuevo desafío
                  context.push('/challenges/create');
                },
                backgroundColor: const Color(0xFFFF6F00),
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  Widget _buildChallengesList(
    List<Map<String, dynamic>> challenges,
    String type,
  ) {
    if (challenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'pending'
                  ? Icons.pending_actions
                  : type == 'active'
                  ? Icons.sports_soccer
                  : Icons.history,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              type == 'pending'
                  ? 'No hay desafíos pendientes'
                  : type == 'active'
                  ? 'No hay desafíos activos'
                  : 'No hay historial de desafíos',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: challenges.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        final String challengeId = challenge['id'];
        final TeamModel challengerTeam = challenge['challenger_team'];
        final TeamModel defenderTeam = challenge['defender_team'];
        final SectorModel sector = challenge['sector'];
        final DateTime challengeDate = DateTime.parse(
          challenge['challenge_date'],
        );
        final String status = challenge['status'];

        // Determinar si el usuario es el desafiante o el defensor
        final bool isUserChallenger = _userTeam?.id == challengerTeam.id;
        final bool isUserDefender = _userTeam?.id == defenderTeam.id;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  'Desafío por: ${sector.name}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Fecha: ${_formatDate(challengeDate)}'),
                trailing: _buildStatusChip(status),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Desafiante:',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            challengerTeam.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  isUserChallenger
                                      ? const Color(0xFF2E7D32)
                                      : null,
                            ),
                          ),
                          Text('ELO: ${challengerTeam.eloRating}'),
                        ],
                      ),
                    ),
                    const Icon(Icons.sports_kabaddi),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Defensor:',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            defenderTeam.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  isUserDefender
                                      ? const Color(0xFF2E7D32)
                                      : null,
                            ),
                          ),
                          Text('ELO: ${defenderTeam.eloRating}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Acciones según estado y rol del usuario
              if (type == 'pending' && isUserDefender)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => _rejectChallenge(challengeId),
                        child: const Text('Rechazar'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _acceptChallenge(challengeId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Aceptar'),
                      ),
                    ],
                  ),
                ),

              if (type == 'active')
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () {
                      // Navegar a los detalles del desafío
                      context.push('/challenges/details/$challengeId');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6F00),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Ver Detalles'),
                  ),
                ),

              if (type == 'historical')
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: OutlinedButton(
                    onPressed: () {
                      // Navegar a los detalles del desafío completado
                      context.push('/challenges/history/$challengeId');
                    },
                    child: const Text('Ver Resultado'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    String label;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.orange;
        label = 'Pendiente';
        break;
      case 'accepted':
        backgroundColor = Colors.blue;
        label = 'Aceptado';
        break;
      case 'rejected':
        backgroundColor = Colors.red;
        label = 'Rechazado';
        break;
      case 'completed':
        backgroundColor = Colors.green;
        label = 'Completado';
        break;
      case 'canceled':
        backgroundColor = Colors.grey;
        label = 'Cancelado';
        break;
      default:
        backgroundColor = Colors.grey;
        label = status;
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: backgroundColor,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
