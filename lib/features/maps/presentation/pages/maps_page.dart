import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/responsive_panel.dart';
import '../../data/maps_repository.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../shared/widgets/comuna_selector_widget.dart';
import '../widgets/summary_widgets.dart';

// Página principal de Ranking (antes "MapsPage").
// Se elimina la sección de Canchas y se centra en mostrar preview de rankings
// y acciones territoriales. Mantiene el nombre de la clase para no romper rutas existentes.
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
    // Repositorio ya no usa canchas, sólo ranking. ResponsivePanel se adaptó.
    final repo = MapsRepositoryReal(ref.watch(supabaseProvider));
    // final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Métricas rápidas
              SummaryMetrics(comunaId: _selectedComunaId),
              const SizedBox(height: 16),
              const Text(
                'Ranking ELO (Global / Comuna)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
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
                    // Panel ahora sólo Ranking (se quitó Canchas)
                    ResponsivePanel(
                      region: _selectedRegionName,
                      comuna: _selectedComunaName ?? '',
                      repo: repo,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              // Sectores más disputados (si hay comuna seleccionada)
              HottestSectors(comunaId: _selectedComunaId),
              const SizedBox(height: 24),
              const Text(
                '¿Cómo subir en el Ranking?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Pasos del sistema territorial
              _buildStepCard(
                context,
                number: '1',
                title: 'Controla Sectores',
                description:
                    'Conquista sectores activos para obtener presencia territorial y bonificaciones.',
              ),
              _buildStepCard(
                context,
                number: '2',
                title: 'Desafía Equipos',
                description:
                    'Retar a equipos fuertes te da mayores ganancias de ELO si ganas.',
              ),
              _buildStepCard(
                context,
                number: '3',
                title: 'Juega Partidos Clave',
                description:
                    'Participa en partidos oficiales y territoriales para incrementar tu ELO.',
              ),
              _buildStepCard(
                context,
                number: '4',
                title: 'Optimiza Estrategia',
                description:
                    'Equilibra desafíos, control territorial y consistencia para estabilizar tu ascenso.',
              ),

              const SizedBox(height: 24),
              // Card de Ranking Completo, full-width y por encima de los consejos
              _buildFeatureCard(
                context,
                title: 'Ranking Completo',
                description: 'Ver todos los equipos',
                icon: Icons.emoji_events,
                color: Theme.of(context).colorScheme.secondary,
                onTap: () => context.push('/rankings'),
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
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Center(
                child: Text(
                  number,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
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

// ---------- Extras: Summary metrics and hottest sectors cards ----------

// Summary/Hottest widgets moved to summary_widgets.dart
