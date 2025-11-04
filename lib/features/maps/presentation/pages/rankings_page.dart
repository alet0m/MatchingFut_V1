import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/team_model.dart';
import '../../../../shared/widgets/comuna_selector_widget.dart';
import '../services/ranking_service.dart';
import '../../../locations/data/location_service.dart';

final rankingServiceProvider = Provider<RankingService>((ref) {
  return RankingService();
});

class RankingsPage extends ConsumerStatefulWidget {
  const RankingsPage({super.key});

  @override
  ConsumerState<RankingsPage> createState() => _RankingsPageState();
}

class _RankingsPageState extends ConsumerState<RankingsPage>
    with SingleTickerProviderStateMixin {
  String? _selectedComunaId;
  String? _selectedComunaName;
  late TabController _tabController; // 2 tabs: Global / Comuna
  bool _isLoading = false;
  List<TeamModel> _globalRankings = [];
  List<TeamModel> _comunaRankings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initFromQueryOrDefault();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initFromQueryOrDefault() async {
    try {
      setState(() => _isLoading = true);
      final locationService = ref.read(locationServiceProvider);
      final qp = Uri.base.queryParameters;
      final comunaQuery = (qp['comuna'] ?? '').trim();
      final comunaIdQuery = (qp['comunaId'] ?? '').trim();

      if (comunaIdQuery.isNotEmpty) {
        final comunas = await locationService.getActiveComunas();
        final found = comunas.firstWhere(
          (c) => c.id == comunaIdQuery,
          orElse:
              () => comunas.isNotEmpty ? comunas.first : throw 'Sin comunas',
        );
        _selectedComunaId = found.id;
        _selectedComunaName = found.name;
      } else if (comunaQuery.isNotEmpty) {
        final comunas = await locationService.getActiveComunas();
        final found = comunas.firstWhere(
          (c) => c.name.toLowerCase() == comunaQuery.toLowerCase(),
          orElse:
              () => comunas.isNotEmpty ? comunas.first : throw 'Sin comunas',
        );
        _selectedComunaId = found.id;
        _selectedComunaName = found.name;
      } else {
        final comunas = await locationService.getActiveComunas();
        if (comunas.isNotEmpty) {
          final defaultComuna = comunas.firstWhere(
            (c) => c.name.toLowerCase() == 'quilicura',
            orElse: () => comunas.first,
          );
          _selectedComunaId = defaultComuna.id;
          _selectedComunaName = defaultComuna.name;
        }
      }

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

      setState(() {
        _globalRankings = globalRankings;
        _comunaRankings = comunaRankings;
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
          tabs: const [Tab(text: 'Global'), Tab(text: 'Comuna')],
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
                        _buildRankingList(_globalRankings, 'global'),
                        _buildRankingList(_comunaRankings, 'comuna'),
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
        if (rank == 1) {
          backgroundColor = Colors.amber[100];
        } else if (rank == 2)
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

  // Sección de "Sectores" eliminada: ya no usamos sectores en la app
}
