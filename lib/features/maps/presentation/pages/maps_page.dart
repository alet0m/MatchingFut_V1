import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/responsive_panel.dart';
import '../../data/maps_repository.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../shared/widgets/comuna_selector_widget.dart';

class MapsPage extends ConsumerStatefulWidget {
  const MapsPage({super.key});

  @override
  ConsumerState<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends ConsumerState<MapsPage> {
  String? _selectedComunaId;
  String? _selectedComunaName;
  String _selectedRegionName = '';

  void _onComunaSelected(String comunaId, String comunaName) {
    setState(() {
      _selectedComunaId = comunaId;
      _selectedComunaName = comunaName;
      // Región: opcional por ahora (repo mock no la usa). Mantener string no-nulo.
      _selectedRegionName = _selectedRegionName;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Repositorio real con Supabase, sin datos falsos
    final repo = MapsRepositoryReal(ref.watch(supabaseProvider));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunas y Ranking'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Nuevo: Panel responsivo de Canchas y Ranking controlado por Región/Comuna
              const Text(
                'Canchas y Ranking (Global / Comuna)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selector de comuna (incluye selector de región dentro)
                    ComunaSelector(
                      initialComunaId: _selectedComunaId,
                      onComunaSelected: _onComunaSelected,
                    ),
                    const SizedBox(height: 16),
                    ResponsivePanel(
                      region: _selectedRegionName,
                      comuna: _selectedComunaName ?? '', // vacío => Global
                      repo: repo,
                    ),
                  ],
                ),
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

              const SizedBox(height: 24),
              const Text(
                'Explora la App',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFeatureCard(
                    context,
                    title: 'Rankings ELO',
                    description: 'Clasificación de equipos',
                    icon: Icons.leaderboard,
                    color: const Color(0xFFFF6F00),
                    onTap: () => context.push('/rankings'),
                  ),
                  _buildFeatureCard(
                    context,
                    title: 'Desafíos',
                    description: 'Compite por territorios',
                    icon: Icons.sports_kabaddi,
                    color: const Color(0xFF1B5E20),
                    onTap: () => context.push('/challenges'),
                  ),
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
