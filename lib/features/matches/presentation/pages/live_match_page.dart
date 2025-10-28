// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';

import '../../data/live_match_service.dart';
import '../../data/match_events_service.dart';
import '../../../../shared/models/match_model.dart';
import '../../../../shared/models/match_event_model.dart';

class LiveMatchPage extends ConsumerStatefulWidget {
  final String matchId;

  const LiveMatchPage({super.key, required this.matchId});

  @override
  ConsumerState<LiveMatchPage> createState() => _LiveMatchPageState();
}

class _LiveMatchPageState extends ConsumerState<LiveMatchPage>
    with TickerProviderStateMixin {
  Timer? _timer;
  Duration _matchDuration = Duration.zero;
  bool _isMatchRunning = false;
  late AnimationController _scoreAnimationController;
  late Animation<double> _scoreAnimation;

  // Controllers para eventos rápidos
  final TextEditingController _eventDescriptionController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _scoreAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scoreAnimationController.dispose();
    _eventDescriptionController.dispose();
    super.dispose();
  }

  void _startMatchTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isMatchRunning) {
        setState(() {
          _matchDuration = Duration(seconds: _matchDuration.inSeconds + 1);
        });
      }
    });
  }

  void _stopMatchTimer() {
    _timer?.cancel();
    setState(() {
      _isMatchRunning = false;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes);
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  int get _currentMinute => _matchDuration.inMinutes;

  Future<void> _addGoal(String teamId, MatchModel match) async {
    try {
      final liveMatchService = ref.read(liveMatchServiceProvider);
      final matchEventsService = ref.read(matchEventsServiceProvider);

      // Actualizar marcador
      await liveMatchService.addGoal(widget.matchId, teamId);

      // Agregar evento
      await matchEventsService.addEvent(
        matchId: widget.matchId,
        eventType: 'goal',
        teamId: teamId,
        minute: _currentMinute,
        description: 'Gol anotado',
      );

      // Animación de celebración
      _scoreAnimationController.forward().then((_) {
        _scoreAnimationController.reverse();
      });

      // Invalidar providers para actualizar UI
      ref.invalidate(liveMatchProvider(widget.matchId));
      ref.invalidate(matchEventsProvider(widget.matchId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡GOL! Marcador actualizado'),
            backgroundColor: const Color(0xFF2E7D32),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar gol: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addCard(String teamId, String cardType) async {
    try {
      final matchEventsService = ref.read(matchEventsServiceProvider);

      await matchEventsService.addEvent(
        matchId: widget.matchId,
        eventType: cardType,
        teamId: teamId,
        minute: _currentMinute,
        description:
            cardType == 'yellow_card' ? 'Tarjeta amarilla' : 'Tarjeta roja',
      );

      ref.invalidate(matchEventsProvider(widget.matchId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              cardType == 'yellow_card'
                  ? '🟡 Tarjeta amarilla'
                  : '🟥 Tarjeta roja',
            ),
            backgroundColor:
                cardType == 'yellow_card' ? Colors.orange : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar tarjeta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _startMatch() async {
    try {
      final liveMatchService = ref.read(liveMatchServiceProvider);
      final matchEventsService = ref.read(matchEventsServiceProvider);

      await liveMatchService.startMatch(widget.matchId);

      // Agregar evento de inicio
      await matchEventsService.addEvent(
        matchId: widget.matchId,
        eventType: 'match_start',
        teamId: '', // Se necesita un equipo, usar el primero disponible
        minute: 0,
        description: '🏁 Inicio del partido',
      );

      setState(() {
        _isMatchRunning = true;
        _matchDuration = Duration.zero;
      });

      _startMatchTimer();
      ref.invalidate(liveMatchProvider(widget.matchId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Partido iniciado! ⚽'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
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

  Future<void> _endMatch() async {
    try {
      final liveMatchService = ref.read(liveMatchServiceProvider);
      final matchEventsService = ref.read(matchEventsServiceProvider);

      await liveMatchService.endMatch(widget.matchId);

      // Agregar evento de final
      await matchEventsService.addEvent(
        matchId: widget.matchId,
        eventType: 'match_end',
        teamId: '', // Se necesita un equipo
        minute: _currentMinute,
        description: '🏁 Final del partido',
      );

      _stopMatchTimer();
      ref.invalidate(liveMatchProvider(widget.matchId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Partido finalizado! 🏁'),
            backgroundColor: Color(0xFF1B5E20),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al finalizar partido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final liveMatchAsync = ref.watch(liveMatchProvider(widget.matchId));
    final matchEventsAsync = ref.watch(matchEventsProvider(widget.matchId));

    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        title: const Text(
          'Partido en Vivo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isMatchRunning ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isMatchRunning = !_isMatchRunning;
              });
            },
          ),
        ],
      ),
      body: liveMatchAsync.when(
        data: (match) => _buildLiveMatchUI(match, matchEventsAsync),
        loading:
            () => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
        error:
            (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar partido',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildLiveMatchUI(
    MatchModel match,
    AsyncValue<List<MatchEvent>> matchEventsAsync,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Cronómetro y estado del partido
          _buildMatchHeader(match),

          // Marcador principal
          _buildScoreboard(match),

          // Controles del partido
          _buildMatchControls(match),

          // Eventos rápidos
          _buildQuickActions(match),

          // Lista de eventos
          _buildEventsSection(matchEventsAsync),
        ],
      ),
    );
  }

  Widget _buildMatchHeader(MatchModel match) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Cronómetro
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isMatchRunning ? Icons.timer : Icons.timer_off,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(_matchDuration),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _isMatchRunning ? Colors.red : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    )
                    .animate(onPlay: (controller) => controller.repeat())
                    .fadeIn(duration: 500.ms)
                    .then()
                    .fadeOut(duration: 500.ms),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Estado del partido
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusColor(match.status).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _getStatusColor(match.status)),
            ),
            child: Text(
              _getStatusText(match.status),
              style: TextStyle(
                color: _getStatusColor(match.status),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildScoreboard(MatchModel match) {
    return AnimatedBuilder(
      animation: _scoreAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scoreAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Equipo Local
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2E7D32).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.sports_soccer,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        match.homeTeamId ?? 'Equipo Local',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Marcador
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${match.homeScore}',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '-',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Text(
                            '${match.awayScore}',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'MIN $_currentMinute',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Equipo Visitante
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6F00),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6F00).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.sports_soccer,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        match.awayTeamId ?? 'Equipo Visitante',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6F00),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).animate().slideY(begin: -0.3, duration: 600.ms).fadeIn();
  }

  Widget _buildMatchControls(MatchModel match) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Text(
            'Controles del Partido',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (match.status == 'scheduled') ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _startMatch,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('INICIAR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ] else if (match.status == 'in_progress') ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isMatchRunning = !_isMatchRunning;
                      });
                    },
                    icon: Icon(
                      _isMatchRunning ? Icons.pause : Icons.play_arrow,
                    ),
                    label: Text(_isMatchRunning ? 'PAUSAR' : 'REANUDAR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6F00),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _endMatch,
                    icon: const Icon(Icons.stop),
                    label: const Text('FINALIZAR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    ).animate().slideX(begin: 0.3, duration: 600.ms).fadeIn(delay: 200.ms);
  }

  Widget _buildQuickActions(MatchModel match) {
    if (match.status != 'in_progress') return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Acciones Rápidas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Botones de gol
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _addGoal(match.homeTeamId!, match),
                  icon: const Icon(Icons.sports_soccer, size: 20),
                  label: const Text('GOL LOCAL'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _addGoal(match.awayTeamId!, match),
                  icon: const Icon(Icons.sports_soccer, size: 20),
                  label: const Text('GOL VISIT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6F00),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Botones de tarjetas
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showCardDialog(match.homeTeamId!),
                  icon: const Icon(
                    Icons.rectangle,
                    color: Colors.yellow,
                    size: 16,
                  ),
                  label: const Text('TARJETA'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showCardDialog(match.awayTeamId!),
                  icon: const Icon(
                    Icons.rectangle,
                    color: Colors.yellow,
                    size: 16,
                  ),
                  label: const Text('TARJETA'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().slideX(begin: -0.3, duration: 600.ms).fadeIn(delay: 400.ms);
  }

  Widget _buildEventsSection(AsyncValue<List<MatchEvent>> matchEventsAsync) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Eventos del Partido',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
          const Divider(height: 1),
          matchEventsAsync.when(
            data:
                (events) =>
                    events.isEmpty
                        ? const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.event_note,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Sin eventos registrados',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: events.length,
                          separatorBuilder:
                              (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final event = events[index];
                            return ListTile(
                              leading: _getEventIcon(event.eventType),
                              title: Text(
                                event.description ??
                                    _getEventDescription(event.eventType),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text('Minuto ${event.minute}'),
                              trailing: Text(
                                '${event.minute}\'',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ).animate().slideX(
                              begin: 0.2,
                              duration: 300.ms,
                              delay: Duration(milliseconds: index * 50),
                            );
                          },
                        ),
            loading:
                () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
            error:
                (error, stackTrace) => Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'Error al cargar eventos',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, duration: 600.ms).fadeIn(delay: 600.ms);
  }

  void _showCardDialog(String teamId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Seleccionar Tarjeta'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.rectangle, color: Colors.yellow),
                  title: const Text('Tarjeta Amarilla'),
                  onTap: () {
                    Navigator.pop(context);
                    _addCard(teamId, 'yellow_card');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.rectangle, color: Colors.red),
                  title: const Text('Tarjeta Roja'),
                  onTap: () {
                    Navigator.pop(context);
                    _addCard(teamId, 'red_card');
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _getEventIcon(String eventType) {
    switch (eventType) {
      case 'goal':
        return const Icon(Icons.sports_soccer, color: Color(0xFF2E7D32));
      case 'yellow_card':
        return const Icon(Icons.rectangle, color: Colors.yellow);
      case 'red_card':
        return const Icon(Icons.rectangle, color: Colors.red);
      case 'match_start':
        return const Icon(Icons.play_arrow, color: Color(0xFF2E7D32));
      case 'match_end':
        return const Icon(Icons.stop, color: Color(0xFF1B5E20));
      default:
        return const Icon(Icons.event, color: Colors.grey);
    }
  }

  String _getEventDescription(String eventType) {
    switch (eventType) {
      case 'goal':
        return 'Gol anotado';
      case 'yellow_card':
        return 'Tarjeta amarilla';
      case 'red_card':
        return 'Tarjeta roja';
      case 'match_start':
        return 'Inicio del partido';
      case 'match_end':
        return 'Final del partido';
      default:
        return 'Evento de partido';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return const Color(0xFFFF6F00);
      case 'in_progress':
        return const Color(0xFF2E7D32);
      case 'finished':
        return const Color(0xFF1B5E20);
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'scheduled':
        return 'Programado';
      case 'in_progress':
        return 'En Progreso';
      case 'finished':
        return 'Finalizado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return 'Desconocido';
    }
  }
}
