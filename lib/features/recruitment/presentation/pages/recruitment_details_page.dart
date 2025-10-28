import 'package:flutter/material.dart';
import '../../shared/models/recruitment_models.dart';

class RecruitmentDetailsPage extends StatelessWidget {
  final RecruitmentPost post;

  const RecruitmentDetailsPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de Publicación'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),

            const SizedBox(height: 16),

            // Tipo de post
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color:
                    post.isTeamPost
                        ? Colors.blue.shade100
                        : Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                post.isTeamPost
                    ? '🏆 Equipo busca jugador'
                    : '⚽ Jugador busca equipo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color:
                      post.isTeamPost
                          ? Colors.blue.shade700
                          : Colors.green.shade700,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Descripción
            const Text(
              'Descripción',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              post.description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Color(0xFF666666),
              ),
            ),

            const SizedBox(height: 24),

            // Información específica
            _buildInfoSection(),

            const SizedBox(height: 24),

            // Ubicación
            _buildLocationSection(),

            const SizedBox(height: 32),

            // Botón de aplicar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implementar aplicación
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funcionalidad en desarrollo'),
                      backgroundColor: Color(0xFF2E7D32),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  post.isTeamPost ? 'Aplicar al Equipo' : 'Contactar Jugador',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),

          if (post.isTeamPost) ...[
            _buildInfoRow(
              'Posición buscada',
              post.positionNeeded ?? 'Flexible',
            ),
            _buildInfoRow(
              'Nivel requerido',
              post.experienceLevel ?? 'Cualquier nivel',
            ),
            if (post.ageRangeMin != null && post.ageRangeMax != null)
              _buildInfoRow(
                'Edad',
                '${post.ageRangeMin} - ${post.ageRangeMax} años',
              ),
            if (post.trainingSchedule != null)
              _buildInfoRow('Entrenamientos', post.trainingSchedule!),
            if (post.teamName != null) _buildInfoRow('Equipo', post.teamName!),
          ] else ...[
            _buildInfoRow('Posición', post.playerPosition ?? 'Flexible'),
            _buildInfoRow(
              'Experiencia',
              post.playerExperience ?? 'Nivel flexible',
            ),
            if (post.availability != null)
              _buildInfoRow('Disponibilidad', post.availability!),
            if (post.preferredComuna != null)
              _buildInfoRow('Comuna preferida', post.preferredComuna!),
          ],

          _buildInfoRow('Publicado por', post.authorName),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.location_on, color: Color(0xFF2E7D32)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ubicación',
                  style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                ),
                const SizedBox(height: 4),
                Text(
                  post.comuna,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
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
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
