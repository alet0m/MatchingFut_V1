// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/challenge_model.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../core/config/supabase_config.dart';
import '../../data/challenges_service.dart';

class ChallengesPage extends ConsumerWidget {
  final String teamId;

  const ChallengesPage({super.key, required this.teamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text('Desafíos'),
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Color(0xFFFF6F00),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.inbox), text: 'Recibidos'),
              Tab(icon: Icon(Icons.send), text: 'Enviados'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ReceivedChallengesTab(teamId: teamId),
            _SentChallengesTab(teamId: teamId),
          ],
        ),
      ),
    );
  }
}

class _ReceivedChallengesTab extends ConsumerWidget {
  final String teamId;

  const _ReceivedChallengesTab({required this.teamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(receivedChallengesProvider(teamId));

    return challengesAsync.when(
      data: (challenges) {
        if (challenges.isEmpty) {
          return _buildEmptyState(
            icon: Icons.inbox,
            title: 'No hay desafíos recibidos',
            subtitle: 'Los equipos que te reten aparecerán aquí',
          );
        }
        return _buildChallengesList(challenges, ref, isReceived: true);
      },
      loading: () => const LoadingWidget(),
      error:
          (error, stack) => _buildErrorState(error, () {
            ref.invalidate(receivedChallengesProvider);
          }),
    );
  }

  Widget _buildChallengesList(
    List<ChallengeModel> challenges,
    WidgetRef ref, {
    required bool isReceived,
  }) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return _ChallengeCard(
          challenge: challenge,
          isReceived: isReceived,
          onAccept: () => _acceptChallenge(context, ref, challenge),
          onReject: () => _rejectChallenge(context, ref, challenge),
        );
      },
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 50, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error al cargar desafíos: $error'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }

  void _acceptChallenge(
    BuildContext context,
    WidgetRef ref,
    ChallengeModel challenge,
  ) async {
    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final challengesService = ref.read(challengesServiceProvider);
      final currentUser = ref.read(supabaseProvider).auth.currentUser;

      await challengesService.acceptChallenge(
        challengeId: challenge.id,
        respondedBy: currentUser!.id,
      );

      // Cerrar loading
      Navigator.pop(context);

      // Mostrar éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Desafío aceptado. ¡Partido programado!'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );

      // Refrescar la lista
      ref.invalidate(receivedChallengesProvider);
    } catch (e) {
      Navigator.pop(context); // Cerrar loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al aceptar desafío: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _rejectChallenge(
    BuildContext context,
    WidgetRef ref,
    ChallengeModel challenge,
  ) async {
    // Confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Rechazar Desafío'),
            content: const Text(
              '¿Estás seguro de que quieres rechazar este desafío?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Rechazar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final challengesService = ref.read(challengesServiceProvider);
      final currentUser = ref.read(supabaseProvider).auth.currentUser;

      await challengesService.rejectChallenge(
        challengeId: challenge.id,
        respondedBy: currentUser!.id,
      );

      // Cerrar loading
      Navigator.pop(context);

      // Mostrar mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Desafío rechazado'),
          backgroundColor: Colors.orange,
        ),
      );

      // Refrescar la lista
      ref.invalidate(receivedChallengesProvider);
    } catch (e) {
      Navigator.pop(context); // Cerrar loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al rechazar desafío: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _SentChallengesTab extends ConsumerWidget {
  final String teamId;

  const _SentChallengesTab({required this.teamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(sentChallengesProvider(teamId));

    return challengesAsync.when(
      data: (challenges) {
        if (challenges.isEmpty) {
          return _buildEmptyState(
            icon: Icons.send,
            title: 'No has enviado desafíos',
            subtitle: 'Busca equipos y envíales un desafío',
          );
        }
        return _buildChallengesList(challenges);
      },
      loading: () => const LoadingWidget(),
      error:
          (error, stack) => _buildErrorState(error, () {
            ref.invalidate(sentChallengesProvider);
          }),
    );
  }

  Widget _buildChallengesList(List<ChallengeModel> challenges) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return _ChallengeCard(challenge: challenge, isReceived: false);
      },
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 50, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error al cargar desafíos: $error'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final ChallengeModel challenge;
  final bool isReceived;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const _ChallengeCard({
    required this.challenge,
    required this.isReceived,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          // Header con estado
          Row(
            children: [
              Icon(
                isReceived ? Icons.inbox : Icons.send,
                size: 20,
                color: const Color(0xFFFF6F00),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isReceived ? 'Desafío recibido' : 'Desafío enviado',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6F00),
                  ),
                ),
              ),
              _buildStatusBadge(),
            ],
          ),

          const SizedBox(height: 12),

          // Mensaje si existe
          if (challenge.message != null && challenge.message!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.format_quote, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      challenge.message!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Fecha propuesta si existe
          if (challenge.proposedDate != null) ...[
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Fecha propuesta: ${_formatDate(challenge.proposedDate!)}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Fecha de creación
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                challenge.createdAt != null
                    ? 'Enviado: ${_formatDate(challenge.createdAt!)}'
                    : 'Fecha no disponible',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),

          // Botones de acción para desafíos recibidos y pendientes
          if (isReceived &&
              challenge.status == 'pending' &&
              onAccept != null &&
              onReject != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Rechazar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onAccept,
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Aceptar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;

    switch (challenge.status) {
      case 'pending':
        color = Colors.orange;
        text = 'Pendiente';
        break;
      case 'accepted':
        color = const Color(0xFF2E7D32);
        text = 'Aceptado';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Rechazado';
        break;
      default:
        color = Colors.grey;
        text = challenge.status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
