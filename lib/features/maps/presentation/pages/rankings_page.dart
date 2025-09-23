import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/team_model.dart';
import '../../../../shared/models/comuna_model.dart';
import '../../../../shared/widgets/comuna_selector_widget.dart';
import '../services/ranking_service.dart';

final rankingServiceProvider = Provider<RankingService>((ref) {
  return RankingService();
});

class RankingsPage extends ConsumerStatefulWidget {
  const RankingsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RankingsPage> createState() => _RankingsPageState();
}

class _RankingsPageState extends ConsumerState<RankingsPage>
    with SingleTickerProviderStateMixin {
  String? _selectedComunaId;
  String? _selectedComunaName;
  late TabController _tabController;
  bool _isLoading = false;
  List<TeamModel> _globalRankings = [];
  List<TeamModel> _comunaRankings = [];
  List<TeamModel> _sectorControllers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDefaultComuna();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

      await _loadRankings();
    } catch (e) {
      debugPrint('Error cargando comuna por defecto: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRankings() async {
    if (_selectedComunaId == null) return;

    setState(() => _isLoading = true);

    try {
      final rankingService = ref.read(rankingServiceProvider);

      // Cargar rankings globales
      final globalRankings = await rankingService.getGlobalRankings();

      // Cargar rankings de la comuna seleccionada
      final comunaRankings = await rankingService.getComunaRankings(
        _selectedComunaId!,
      );

      // Cargar equipos con control de sectores
      final sectorControllers = await rankingService.getSectorControllers(
        _selectedComunaId!,
      );

      setState(() {
        _globalRankings = globalRankings;
        _comunaRankings = comunaRankings;
        _sectorControllers = sectorControllers;
      });
    } catch (e) {
      debugPrint('Error cargando rankings: $e');
      // Mostrar mensaje de error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar rankings: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onComunaSelected(String comunaId, String comunaName) {
    setState(() {
      _selectedComunaId = comunaId;
      _selectedComunaName = comunaName;
    });
    _loadRankings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedComunaName != null
              ? 'Rankings de $_selectedComunaName'
              : 'Rankings ELO',
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Global'),
            Tab(text: 'Comuna'),
            Tab(text: 'Sectores'),
          ],
        ),
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

          // Contenido principal
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Ranking Global
                        _buildRankingList(_globalRankings, 'global'),

                        // Tab 2: Ranking por Comuna
                        _buildRankingList(_comunaRankings, 'comuna'),

                        // Tab 3: Equipos con control de sectores
                        _buildSectorControllersList(),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingList(List<TeamModel> teams, String rankingType) {
    if (teams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              rankingType == 'global'
                  ? 'No hay equipos en el ranking global todavía'
                  : 'No hay equipos en esta comuna todavía',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        final rank = index + 1;

        // Color del fondo según posición
        Color? backgroundColor;
        if (rank == 1)
          backgroundColor = Colors.amber[100];
        else if (rank == 2)
          backgroundColor = Colors.grey[200];
        else if (rank == 3)
          backgroundColor = Colors.brown[100];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          color: backgroundColor,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF2E7D32),
              child: Text(
                rank.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(team.name),
            subtitle: Text(
              'Fundado: ${team.createdAt?.toIso8601String().substring(0, 10) ?? 'N/A'}',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'ELO: ${team.eloRating}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Partidos: ${team.totalMatches}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            onTap: () {
              // Navegar al perfil del equipo
              // context.push('/teams/${team.id}');
            },
          ),
        );
      },
    );
  }

  Widget _buildSectorControllersList() {
    if (_sectorControllers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.map_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay sectores controlados todavía',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _sectorControllers.length,
      itemBuilder: (context, index) {
        final team = _sectorControllers[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFFF6F00),
              child: Icon(Icons.location_on, color: Colors.white),
            ),
            title: Text(team.name),
            subtitle: Text(
              // Usamos wins + draws como aproximación de sectores controlados
              'Sectores controlados: ${team.wins + team.draws}',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'ELO: ${team.eloRating}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  // Usamos días temporales basados en partidos
                  'Días: ${team.totalMatches * 5}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            onTap: () {
              // Navegar al mapa con filtro para este equipo
              // context.push('/map?teamId=${team.id}');
            },
          ),
        );
      },
    );
  }
}
