import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MapsPage extends StatelessWidget {
  const MapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema Territorial'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarjeta de introducción
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '¡Bienvenido al Sistema Territorial!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Domina los sectores de tu comuna, defiende tu territorio y aumenta tu ELO ganando partidos estratégicamente.',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => context.push('/territorial-map'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Ver Mapa Territorial'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Explora el Sistema Territorial',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Tarjetas de acciones principales
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  // Mapa Territorial
                  _buildFeatureCard(
                    context,
                    title: 'Mapa Territorial',
                    description: 'Visualiza y controla sectores',
                    icon: Icons.map,
                    color: const Color(0xFF2E7D32),
                    onTap: () => context.push('/territorial-map'),
                  ),

                  // Rankings
                  _buildFeatureCard(
                    context,
                    title: 'Rankings ELO',
                    description: 'Clasificación de equipos',
                    icon: Icons.leaderboard,
                    color: const Color(0xFFFF6F00),
                    onTap: () => context.push('/rankings'),
                  ),

                  // Desafíos
                  _buildFeatureCard(
                    context,
                    title: 'Desafíos',
                    description: 'Compite por territorios',
                    icon: Icons.sports_kabaddi,
                    color: const Color(0xFF1B5E20),
                    onTap: () => context.push('/challenges'),
                  ),

                  // Crear Desafío
                  _buildFeatureCard(
                    context,
                    title: 'Crear Desafío',
                    description: 'Lanza un nuevo desafío',
                    icon: Icons.add_location_alt,
                    color: const Color(0xFFFF6F00),
                    onTap: () => context.push('/challenges/create'),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Text(
                '¿Cómo funciona?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Pasos del sistema territorial
              _buildStepCard(
                context,
                number: '1',
                title: 'Explora el Mapa',
                description:
                    'Visualiza los sectores disponibles en tu comuna y quién los controla.',
              ),
              _buildStepCard(
                context,
                number: '2',
                title: 'Lanza Desafíos',
                description:
                    'Desafía a equipos que controlan sectores para disputar el territorio.',
              ),
              _buildStepCard(
                context,
                number: '3',
                title: 'Juega Partidos',
                description:
                    'Organiza y juega partidos en los sectores para ganar control territorial.',
              ),
              _buildStepCard(
                context,
                number: '4',
                title: 'Sube en el Ranking',
                description:
                    'Incrementa tu ELO y aumenta tu reputación en la comunidad.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(
    BuildContext context, {
    required String number,
    required String title,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2E7D32),
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
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
