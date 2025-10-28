import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/matches_providers.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/models/match_model.dart';

class MatchesPageEnhanced extends ConsumerStatefulWidget {
  const MatchesPageEnhanced({super.key});

  @override
  ConsumerState<MatchesPageEnhanced> createState() =>
      _MatchesPageEnhancedState();
}

class _MatchesPageEnhancedState extends ConsumerState<MatchesPageEnhanced>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Partidos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refrescar datos
              ref.invalidate(publicMatchesProvider);
              ref.invalidate(myMatchesProvider);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Públicos'),
            Tab(text: 'Mis Partidos'),
            Tab(text: 'En Vivo'),
            Tab(text: 'Historial'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPublicMatches(),
          _buildMyMatches(),
          _buildLiveMatches(),
          _buildMatchHistory(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-match'),
        backgroundColor: const Color(0xFFFF6F00),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPublicMatches() {
    final publicMatchesAsync = ref.watch(publicMatchesProvider);

    return publicMatchesAsync.when(
      data: (matches) {
        if (matches.isEmpty) {
          return _buildEmptyState(
            icon: Icons.sports_soccer,
            title: 'No hay partidos públicos',
            subtitle: 'Sé el primero en crear un partido público',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(publicMatchesProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              return _buildPublicMatchCard(matches[index]);
            },
          ),
        );
      },
      loading: () => const LoadingWidget(),
      error:
          (error, stackTrace) =>
              _buildErrorWidget('Error cargando partidos públicos'),
    );
  }

  Widget _buildMyMatches() {
    final myMatchesAsync = ref.watch(myMatchesProvider);

    return myMatchesAsync.when(
      data: (matches) {
        if (matches.isEmpty) {
          return _buildEmptyState(
            icon: Icons.sports_soccer_outlined,
            title: 'No tienes partidos',
            subtitle: 'Crea un partido o únete a uno público',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myMatchesProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              return _buildMyMatchCard(matches[index]);
            },
          ),
        );
      },
      loading: () => const LoadingWidget(),
      error:
          (error, stackTrace) =>
              _buildErrorWidget('Error cargando tus partidos'),
    );
  }

  Widget _buildLiveMatches() {
    final liveMatchesAsync = ref.watch(liveMatchesProvider);

    return liveMatchesAsync.when(
      data: (matches) {
        if (matches.isEmpty) {
          return _buildEmptyState(
            icon: Icons.live_tv,
            title: 'No hay partidos en vivo',
            subtitle: 'Los partidos activos aparecerán aquí',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            return _buildLiveMatchCard(matches[index]);
          },
        );
      },
      loading: () => const LoadingWidget(),
      error:
          (error, stackTrace) =>
              _buildErrorWidget('Error cargando partidos en vivo'),
    );
  }

  Widget _buildMatchHistory() {
    final historyAsync = ref.watch(matchHistoryProvider);

    return historyAsync.when(
      data: (matches) {
        if (matches.isEmpty) {
          return _buildEmptyState(
            icon: Icons.history,
            title: 'Sin historial',
            subtitle: 'Tus partidos finalizados aparecerán aquí',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            return _buildHistoryMatchCard(matches[index]);
          },
        );
      },
      loading: () => const LoadingWidget(),
      error:
          (error, stackTrace) => _buildErrorWidget('Error cargando historial'),
    );
  }

  Widget _buildPublicMatchCard(MatchModel match) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/match/${match.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getMatchTypeColor(match.matchType),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getMatchTypeLabel(match.matchType),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'PÚBLICO',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match.hostTeamName ?? 'Equipo Local',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Text('vs', style: TextStyle(color: Colors.grey)),
                        Text(
                          match.guestTeamName ?? 'Esperando oponente...',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color:
                                match.guestTeamName != null
                                    ? null
                                    : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatDate(match.scheduledDate),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatTime(match.scheduledDate),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      match.location,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              if (match.guestTeamId == null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _joinPublicMatch(match.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Unirse al Partido'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyMatchCard(MatchModel match) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/match/${match.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(match.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusLabel(match.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (match.status == 'scheduled')
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleMatchAction(match, value),
                      itemBuilder:
                          (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 16),
                                  SizedBox(width: 8),
                                  Text('Editar'),
                                ],
                              ),
                            ),
                            if (match.status == 'scheduled')
                              const PopupMenuItem(
                                value: 'start',
                                child: Row(
                                  children: [
                                    Icon(Icons.play_arrow, size: 16),
                                    SizedBox(width: 8),
                                    Text('Iniciar'),
                                  ],
                                ),
                              ),
                            const PopupMenuItem(
                              value: 'cancel',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.cancel,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Cancelar',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match.hostTeamName ?? 'Equipo Local',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (match.hostTeamScore != null &&
                            match.guestTeamScore != null)
                          Text(
                            '${match.hostTeamScore} - ${match.guestTeamScore}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          )
                        else
                          const Text(
                            'vs',
                            style: TextStyle(color: Colors.grey),
                          ),
                        Text(
                          match.guestTeamName ?? 'Sin oponente',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color:
                                match.guestTeamName != null
                                    ? null
                                    : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatDate(match.scheduledDate),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatTime(match.scheduledDate),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      match.location,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveMatchCard(MatchModel match) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.red[400]!, Colors.red[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: InkWell(
          onTap: () => context.push('/match/${match.id}/live'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: Colors.white, size: 8),
                          SizedBox(width: 4),
                          Text(
                            'EN VIVO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatMatchTime(match),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            match.hostTeamName ?? 'Local',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '${match.hostTeamScore ?? 0}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      '-',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            match.guestTeamName ?? 'Visitante',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '${match.guestTeamScore ?? 0}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Toca para ver detalles en vivo',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryMatchCard(MatchModel match) {
    final isWin =
        match.hostTeamScore != null &&
        match.guestTeamScore != null &&
        match.hostTeamScore! > match.guestTeamScore!;
    final isDraw =
        match.hostTeamScore != null &&
        match.guestTeamScore != null &&
        match.hostTeamScore == match.guestTeamScore;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/match/${match.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color:
                      isWin
                          ? Colors.green
                          : isDraw
                          ? Colors.orange
                          : Colors.red,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${match.hostTeamName} vs ${match.guestTeamName}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          '${match.hostTeamScore} - ${match.guestTeamScore}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(match.scheduledDate),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  Icon(
                    isWin
                        ? Icons.trending_up
                        : isDraw
                        ? Icons.trending_flat
                        : Icons.trending_down,
                    color:
                        isWin
                            ? Colors.green
                            : isDraw
                            ? Colors.orange
                            : Colors.red,
                  ),
                  Text(
                    isWin
                        ? 'Victoria'
                        : isDraw
                        ? 'Empate'
                        : 'Derrota',
                    style: TextStyle(
                      fontSize: 10,
                      color:
                          isWin
                              ? Colors.green
                              : isDraw
                              ? Colors.orange
                              : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(publicMatchesProvider);
              ref.invalidate(myMatchesProvider);
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Filtrar Partidos'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text('Todos'),
                  value: 'all',
                  groupValue: _selectedFilter,
                  onChanged: (value) {
                    setState(() => _selectedFilter = value!);
                    Navigator.of(context).pop();
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Futbolito'),
                  value: 'futbolito',
                  groupValue: _selectedFilter,
                  onChanged: (value) {
                    setState(() => _selectedFilter = value!);
                    Navigator.of(context).pop();
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Fútbol 11'),
                  value: 'futbol',
                  groupValue: _selectedFilter,
                  onChanged: (value) {
                    setState(() => _selectedFilter = value!);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _joinPublicMatch(String matchId) async {
    try {
      final matchesService = ref.read(matchesServiceProvider);
      await matchesService.joinPublicMatch(matchId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Te has unido al partido exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(publicMatchesProvider);
        ref.invalidate(myMatchesProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al unirse al partido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleMatchAction(MatchModel match, String action) {
    switch (action) {
      case 'edit':
        context.push('/match/${match.id}/edit');
        break;
      case 'start':
        _startMatch(match.id);
        break;
      case 'cancel':
        _cancelMatch(match.id);
        break;
    }
  }

  Future<void> _startMatch(String matchId) async {
    try {
      final matchesService = ref.read(matchesServiceProvider);
      await matchesService.startMatch(matchId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Partido iniciado'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(myMatchesProvider);
        ref.invalidate(liveMatchesProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar partido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cancelMatch(String matchId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancelar Partido'),
            content: const Text(
              '¿Estás seguro de que quieres cancelar este partido?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Sí, cancelar'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      final matchesService = ref.read(matchesServiceProvider);
      await matchesService.cancelMatch(matchId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Partido cancelado'),
            backgroundColor: Colors.orange,
          ),
        );
        ref.invalidate(myMatchesProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cancelar partido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getMatchTypeColor(String matchType) {
    switch (matchType) {
      case 'futbolito':
        return const Color(0xFF2E7D32);
      case 'futbol':
        return const Color(0xFF1565C0);
      default:
        return Colors.grey;
    }
  }

  String _getMatchTypeLabel(String matchType) {
    switch (matchType) {
      case 'futbolito':
        return 'FUTBOLITO';
      case 'futbol':
        return 'FÚTBOL 11';
      default:
        return matchType.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return Colors.blue;
      case 'live':
        return Colors.red;
      case 'finished':
        return Colors.green;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'scheduled':
        return 'PROGRAMADO';
      case 'live':
        return 'EN VIVO';
      case 'finished':
        return 'FINALIZADO';
      case 'cancelled':
        return 'CANCELADO';
      default:
        return status.toUpperCase();
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final matchDay = DateTime(date.year, date.month, date.day);

    if (matchDay == today) {
      return 'Hoy';
    } else if (matchDay == today.add(const Duration(days: 1))) {
      return 'Mañana';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatMatchTime(MatchModel match) {
    if (match.startedAt == null) return '0\'';

    final elapsed = DateTime.now().difference(match.startedAt!);
    final minutes = elapsed.inMinutes;

    return '$minutes\'';
  }
}
