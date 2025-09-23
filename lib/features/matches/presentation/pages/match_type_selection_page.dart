import 'package:flutter/material.dart';
import '../../../../shared/models/football_modality.dart';
import 'create_match_page_simple.dart';
import 'create_public_match_page.dart';

class MatchTypeSelectionPage extends StatefulWidget {
  const MatchTypeSelectionPage({super.key});

  @override
  State<MatchTypeSelectionPage> createState() => _MatchTypeSelectionPageState();
}

class _MatchTypeSelectionPageState extends State<MatchTypeSelectionPage> {
  FootballModality selectedModality = FootballModality.futbolito;

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
          child: Column(
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

              const SizedBox(height: 12),

              const Text(
                'Elige primero la modalidad de fútbol:',
                style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
              ),

              const SizedBox(height: 20),

              // Selector de modalidades
              _buildModalitySelector(),

              const SizedBox(height: 32),

              const Text(
                'Elige la opción que mejor se adapte a lo que buscas:',
                style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
              ),

              const SizedBox(height: 40),

              // Opción 1: Partido Personalizado
              _buildMatchTypeCard(
                context,
                icon: Icons.groups,
                title: 'Partido Personalizado',
                subtitle: 'Invita a un equipo específico',
                description:
                    'Selecciona directamente el equipo rival y configura todos los detalles del partido.',
                color: const Color(0xFF2E7D32),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateMatchPage(),
                    ),
                  );
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreatePublicMatchPage(),
                    ),
                  );
                },
              ),

              const Spacer(),

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
                    Expanded(
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
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
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

  Widget _buildModalitySelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children:
                FootballModality.values.map((modality) {
                  final isSelected = selectedModality == modality;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedModality = modality),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              modality.format,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected
                                        ? Color(
                                          int.parse(
                                                modality.colorHex.substring(1),
                                                radix: 16,
                                              ) +
                                              0xFF000000,
                                        )
                                        : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              modality.displayName,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isSelected
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${modality.rules.minPlayers}-${modality.rules.maxPlayers}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}
