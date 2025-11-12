import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/team_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/models/region_model.dart';
import '../../../../shared/models/comuna_model.dart';
import '../services/ranking_service.dart';
import '../../../locations/data/location_service.dart';

final rankingServiceProvider = Provider<RankingService>(
  (ref) => RankingService(),
);

class RankingsPage extends ConsumerStatefulWidget {
  const RankingsPage({super.key});
  @override
  ConsumerState<RankingsPage> createState() => _RankingsPageState();
}

class _RankingsPageState extends ConsumerState<RankingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Filtros jerárquicos: Global / Región / Comuna
  List<RegionModel> _regions = [];
  List<ComunaModel> _comunas = [];
  String _scope = 'global'; // 'global' | 'region' | 'comuna'
  String? _selectedRegionId;
  String? _selectedComunaId;

  // Datos de ranking según el scope
  List<TeamModel> _topTeams = [];
  List<Map<String, dynamic>> _topPlayers = [];
  int? _myTeamRank; // rank de equipo donde soy capitán
  int? _myPlayerRank; // rank personal como jugador

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initRegionsAndData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initRegionsAndData() async {
    try {
      setState(() => _isLoading = true);
      final locationService = ref.read(locationServiceProvider);
      final regions = await locationService.getActiveRegions();
      _regions = regions;
      // Por defecto: mostrar global si hay múltiples regiones.
      if (_regions.isNotEmpty) {
        _selectedRegionId = _regions.first.id;
      }
      await _loadRankings();
    } catch (e) {
      debugPrint('Error inicializando regiones/rankings: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRankings() async {
    setState(() => _isLoading = true);
    try {
      final rankingService = ref.read(rankingServiceProvider);
      final userId = Supabase.instance.client.auth.currentUser?.id;

      if (_scope == 'global') {
        // Global: top equipos y top jugadores basados en players.elo_rating
        final teams = await rankingService.getGlobalRankings();
        final globalPlayers = await rankingService.getGlobalPlayersRanking(
          limit: 100,
        );

        int? myTeamRank;
        int? myPlayerRank;
        if (userId != null) {
          // Rank del equipo del usuario a nivel global
          try {
            final myTeamRes = await Supabase.instance.client
                .from('teams')
                .select('elo_rating')
                .eq('captain_id', userId)
                .eq('is_active', true)
                .limit(1);
            if (myTeamRes.isNotEmpty) {
              final myElo = myTeamRes.first['elo_rating'] as int? ?? 1200;
              final higherTeams = await Supabase.instance.client
                  .from('teams')
                  .select('id')
                  .eq('is_active', true)
                  .gt('elo_rating', myElo);
              myTeamRank = higherTeams.length + 1;
            }
          } catch (e) {
            debugPrint('Error calculando rank global equipo usuario: $e');
          }

          // Rank personal del jugador global desde players
          try {
            int elo = 1200;
            final playerRes = await Supabase.instance.client
                .from('players')
                .select('elo_rating')
                .eq('id', userId)
                .limit(1);
            if (playerRes.isNotEmpty) {
              elo = (playerRes.first['elo_rating'] as int?) ?? 1200;
            }
            final higherPlayers = await Supabase.instance.client
                .from('players')
                .select('id')
                .gt('elo_rating', elo);
            myPlayerRank = higherPlayers.length + 1;
          } catch (e) {
            debugPrint('Error rank global jugador usuario (players): $e');
          }
        }

        setState(() {
          _topTeams = teams.take(100).toList();
          _topPlayers = globalPlayers;
          _myTeamRank = myTeamRank;
          _myPlayerRank = myPlayerRank;
        });
        return;
      }

      if (_scope == 'region') {
        if (_selectedRegionId == null) return;
        final results = await Future.wait([
          rankingService.getRegionTeamsRanking(_selectedRegionId!, limit: 100),
          rankingService.getRegionPlayersRanking(
            _selectedRegionId!,
            limit: 100,
          ),
          if (userId != null)
            rankingService.getUserTeamRankInRegion(userId, _selectedRegionId!),
          if (userId != null)
            rankingService.getUserPlayerRankInRegion(
              userId,
              _selectedRegionId!,
            ),
        ]);
        final teams = results[0] as List<TeamModel>;
        final players = results[1] as List<Map<String, dynamic>>;
        int? myTeamRank;
        int? myPlayerRank;
        if (results.length >= 3 && results[2] is int?)
          myTeamRank = results[2] as int?;
        if (results.length >= 4 && results[3] is int?)
          myPlayerRank = results[3] as int?;
        setState(() {
          _topTeams = teams;
          _topPlayers = players;
          _myTeamRank = myTeamRank;
          _myPlayerRank = myPlayerRank;
        });
        return;
      }

      if (_scope == 'comuna') {
        if (_selectedComunaId == null) return;
        // Equipos por comuna
        final teams = await rankingService.getComunaRankings(
          _selectedComunaId!,
        );
        // Jugadores por comuna basados en players.elo_rating
        final comunaPlayers = await rankingService.getComunaPlayersRanking(
          _selectedComunaId!,
          limit: 100,
        );

        int? myTeamRank;
        int? myPlayerRank;
        if (userId != null) {
          // Rank del equipo y del jugador con la nueva lógica LP -> ELO
          try {
            myTeamRank = await rankingService.getUserTeamRankInComuna(
              userId,
              _selectedComunaId!,
            );
          } catch (e) {
            debugPrint('Error rank equipo comuna usuario: $e');
          }

          try {
            myPlayerRank = await rankingService.getUserPlayerRankInComuna(
              userId,
              _selectedComunaId!,
            );
          } catch (e) {
            debugPrint('Error rank jugador comuna usuario (players): $e');
          }
        }

        setState(() {
          _topTeams = teams.take(100).toList();
          _topPlayers = comunaPlayers;
          _myTeamRank = myTeamRank;
          _myPlayerRank = myPlayerRank;
        });
        return;
      }
    } catch (e) {
      debugPrint('Error cargando rankings scope=$_scope: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar ranking: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _changeScope(String scope) async {
    if (_scope == scope) return;
    setState(() {
      _scope = scope;
      // Reset datos específicos
      if (scope == 'global') {
        _selectedRegionId = null;
        _selectedComunaId = null;
      } else if (scope == 'region') {
        _selectedComunaId = null;
        // Asegurar región seleccionada
        if (_selectedRegionId == null && _regions.isNotEmpty) {
          _selectedRegionId = _regions.first.id;
        }
      } else if (scope == 'comuna') {
        // Necesita región primero
        if (_selectedRegionId == null && _regions.isNotEmpty) {
          _selectedRegionId = _regions.first.id;
        }
      }
    });
    // Cargar comunas si se pasa a scope comuna
    if (scope == 'comuna' && _selectedRegionId != null) {
      final locationService = ref.read(locationServiceProvider);
      _comunas = await locationService.getComunasByRegion(_selectedRegionId!);
      if (_comunas.isNotEmpty) {
        _selectedComunaId = _comunas.first.id;
      }
    }
    await _loadRankings();
  }

  void _onRegionChanged(String? regionId) async {
    if (regionId == null) return;
    setState(() => _selectedRegionId = regionId);
    if (_scope == 'comuna') {
      final locationService = ref.read(locationServiceProvider);
      _comunas = await locationService.getComunasByRegion(regionId);
      _selectedComunaId = _comunas.isNotEmpty ? _comunas.first.id : null;
    }
    await _loadRankings();
  }

  void _onComunaChanged(String? comunaId) async {
    if (comunaId == null) return;
    setState(() => _selectedComunaId = comunaId);
    await _loadRankings();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _scope == 'global'
              ? 'Ranking Global'
              : _scope == 'region'
              ? 'Ranking Regional'
              : 'Ranking por Comuna',
        ),
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: scheme.primary,
          labelColor: scheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          tabs: const [Tab(text: 'Equipos'), Tab(text: 'Jugadores')],
        ),
      ),
      body: Column(
        children: [
          // Selector de scope y controles dependientes
          Container(
            padding: const EdgeInsets.all(12),
            color: scheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Global'),
                      selected: _scope == 'global',
                      onSelected: (_) => _changeScope('global'),
                    ),
                    ChoiceChip(
                      label: const Text('Región'),
                      selected: _scope == 'region',
                      onSelected: (_) => _changeScope('region'),
                    ),
                    ChoiceChip(
                      label: const Text('Comuna'),
                      selected: _scope == 'comuna',
                      onSelected: (_) => _changeScope('comuna'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_scope == 'region' || _scope == 'comuna') ...[
                  DropdownButtonFormField<String>(
                    value: _selectedRegionId,
                    isExpanded: true,
                    items:
                        _regions
                            .map(
                              (r) => DropdownMenuItem(
                                value: r.id,
                                child: Text(r.name),
                              ),
                            )
                            .toList(),
                    onChanged: _onRegionChanged,
                    decoration: const InputDecoration(
                      labelText: 'Región',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                if (_scope == 'comuna') ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedComunaId,
                    isExpanded: true,
                    items:
                        _comunas
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              ),
                            )
                            .toList(),
                    onChanged: _onComunaChanged,
                    decoration: const InputDecoration(
                      labelText: 'Comuna',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ],
            ),
          ),

          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                      controller: _tabController,
                      children: [_buildTeamsTab(), _buildPlayersTab()],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsTab() {
    return ListView.separated(
      itemCount: _topTeams.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _RankHeader(title: 'Tu equipo', rank: _myTeamRank);
        }
        final team = _topTeams[index - 1];
        final rank = index; // 1..N
        Color? bg;
        if (rank == 1) bg = Theme.of(context).colorScheme.primaryContainer;
        if (rank == 2) bg = Theme.of(context).colorScheme.secondaryContainer;
        if (rank == 3) bg = Theme.of(context).colorScheme.tertiaryContainer;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          color: bg,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Text(
                '$rank',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
            title: Text(team.name),
            subtitle:
                team.createdAt != null
                    ? Text(
                      'Fundado: ${team.createdAt!.toIso8601String().substring(0, 10)}',
                    )
                    : null,
            trailing: Text(
              'ELO: ${team.eloRating}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayersTab() {
    return ListView.separated(
      itemCount: _topPlayers.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _RankHeader(title: 'Tu ranking personal', rank: _myPlayerRank);
        }
        final p = _topPlayers[index - 1];
        final rank = index;
        final name = (p['name'] ?? '') as String;
        final elo = (p['elo'] as num?)?.toInt() ?? 0;
        Color? bg;
        if (rank == 1) bg = Theme.of(context).colorScheme.primaryContainer;
        if (rank == 2) bg = Theme.of(context).colorScheme.secondaryContainer;
        if (rank == 3) bg = Theme.of(context).colorScheme.tertiaryContainer;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          color: bg,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Text(
                '$rank',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
            title: Text(name.isEmpty ? 'Jugador' : name),
            trailing: Text(
              'ELO: $elo',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}

class _RankHeader extends StatelessWidget {
  final String title;
  final int? rank;
  const _RankHeader({required this.title, required this.rank});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isTop100 = (rank ?? 999999) <= 100;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isTop100 ? scheme.primaryContainer : scheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isTop100 ? Icons.emoji_events : Icons.trending_up,
              color: isTop100 ? Colors.amber[700] : scheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  if (rank == null)
                    Text(
                      'Sin datos de posición',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    )
                  else if (isTop100)
                    Text(
                      '¡Felicitaciones! Estás en el Top 100 (posición $rank).',
                      style: TextStyle(color: scheme.onSurface),
                    )
                  else
                    Text(
                      'Posición actual: $rank. ¡Sigue mejorando para entrar al Top 100!',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
