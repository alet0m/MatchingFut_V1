import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SimpleMatchTypeSelector extends StatefulWidget {
  const SimpleMatchTypeSelector({super.key});

  @override
  State<SimpleMatchTypeSelector> createState() =>
      _SimpleMatchTypeSelectorState();
}

class _SimpleMatchTypeSelectorState extends State<SimpleMatchTypeSelector> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Partido'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F9FA), Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                const Text(
                  '¿Qué tipo de partido quieres crear?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),

                const SizedBox(height: 32),

                // Opción 1: Partido Personalizado
                _buildMatchTypeCard(
                  context,
                  icon: Icons.groups,
                  title: 'Partido Personalizado',
                  subtitle: 'Invita a un equipo específico',
                  description:
                      'Elige un equipo rival de tu elección e invítalos a jugar. Perfecto para partidos entre conocidos.',
                  color: const Color(0xFF2E7D32),
                  onTap: () {
                    // Navegar a crear partido directo con modalidad
                    context.go('/create-match');
                  },
                ),

                const SizedBox(height: 20),

                // Opción 2: Buscar Partido Público
                _buildMatchTypeCard(
                  context,
                  icon: Icons.search,
                  title: 'Buscar Partido Público',
                  subtitle: 'Publica y espera que otros equipos acepten',
                  description:
                      'Crea una publicación para que otros equipos de tu nivel puedan unirse al desafío.',
                  color: const Color(0xFF1976D2),
                  onTap: () {
                    // Navegar a crear partido público
                    context.go('/create-public-match');
                  },
                ),

                const SizedBox(height: 20),

                // Información adicional
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          'Los partidos públicos aparecen en "Partidos Cercanos" para que otros equipos puedan encontrarlos fácilmente.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchTypeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.arrow_forward_ios, color: color, size: 16),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              description,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
