import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/models/team_model.dart';
import '../../../../shared/models/sector_model.dart';
import '../../../../shared/widgets/comuna_selector_widget.dart';
import '../widgets/territorial_map_widget.dart';
import '../services/challenges_service.dart';
import '../../data/sector_control_service.dart';

final challengesServiceProvider = Provider<ChallengesService>((ref) {
  return ChallengesService();
});

class CreateChallengePage extends ConsumerStatefulWidget {
  const CreateChallengePage({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateChallengePage> createState() =>
      _CreateChallengePageState();
}

class _CreateChallengePageState extends ConsumerState<CreateChallengePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Selecciones del usuario
  String? _selectedComunaId;
  String? _selectedComunaName;
  SectorModel? _selectedSector;
  TeamModel? _defenderTeam;
  TeamModel? _userTeam;
  String? _challengeReason;

  @override
  void initState() {
    super.initState();
    _loadUserTeam();
    _loadDefaultComuna();
  }

  Future<void> _loadUserTeam() async {
    try {
      setState(() => _isLoading = true);

      final challengesService = ref.read(challengesServiceProvider);
      final team = await challengesService.getUserTeam();

      setState(() {
        _userTeam = team;
      });
    } catch (e) {
      debugPrint('Error cargando equipo del usuario: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDefaultComuna() async {
    try {
      setState(() => _isLoading = true);

      // Carga la comuna por defecto (Quilicura)
      await Future.delayed(const Duration(milliseconds: 300)); // Simular carga

      setState(() {
        _selectedComunaId = 'quilicura-id'; // Este ID debe venir de la BD real
        _selectedComunaName = 'Quilicura';
      });
    } catch (e) {
      debugPrint('Error cargando comuna por defecto: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onComunaSelected(String comunaId, String comunaName) {
    setState(() {
      _selectedComunaId = comunaId;
      _selectedComunaName = comunaName;
      _selectedSector = null;
      _defenderTeam = null;
    });
  }

  void _onSectorSelected(SectorModel sector) async {
    setState(() {
      _isLoading = true;
      _selectedSector = sector;
    });

    try {
      // Cargar información del equipo que controla este sector
      final sectorControlService = ref.read(sectorControlServiceProvider);
      final controllingTeam = await sectorControlService
          .getSectorControllingTeam(sector.id);

      setState(() {
        _defenderTeam = controllingTeam;
      });
    } catch (e) {
      debugPrint('Error cargando equipo controlador: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitChallenge() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSector == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar un sector para desafiar'),
        ),
      );
      return;
    }

    if (_defenderTeam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Este sector no está controlado por ningún equipo todavía',
          ),
        ),
      );
      return;
    }

    if (_userTeam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes un equipo para crear desafíos'),
        ),
      );
      return;
    }

    // Validar que no estés desafiando a tu propio equipo
    if (_defenderTeam!.id == _userTeam!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No puedes desafiar a tu propio equipo')),
      );
      return;
    }

    _formKey.currentState!.save();

    try {
      setState(() => _isLoading = true);

      final challengesService = ref.read(challengesServiceProvider);
      final challengeId = await challengesService.createChallenge(
        sectorId: _selectedSector!.id,
        defenderTeamId: _defenderTeam!.id,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Desafío creado con éxito')));

      // Navegar de vuelta a la lista de desafíos
      if (mounted) {
        context.go('/challenges');
      }
    } catch (e) {
      debugPrint('Error creando desafío: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al crear desafío: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Desafío Territorial'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Sección 1: Selector de comuna
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: const Color(0xFFF8F9FA),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '1. Selecciona la comuna para el desafío:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ComunaSelector(
                            initialComunaId: _selectedComunaId,
                            onComunaSelected: _onComunaSelected,
                          ),
                        ],
                      ),
                    ),

                    // Sección 2: Mapa para seleccionar sector
                    Expanded(
                      child:
                          _selectedComunaId != null
                              ? Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    alignment: Alignment.centerLeft,
                                    child: const Text(
                                      '2. Selecciona un sector para desafiar:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: TerritorialMapWidget(
                                      comunaId: _selectedComunaId!,
                                      onSectorTapped: _onSectorSelected,
                                      initialSectorId: _selectedSector?.id,
                                    ),
                                  ),
                                ],
                              )
                              : const Center(
                                child: Text(
                                  'Selecciona una comuna para continuar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                    ),

                    // Sección 3: Información del sector y equipo defensor
                    if (_selectedSector != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.grey[100],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sector seleccionado: ${_selectedSector!.name}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _defenderTeam != null
                                ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Equipo defensor: ${_defenderTeam!.name}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      'ELO: ${_defenderTeam!.eloRating}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                )
                                : const Text(
                                  'Este sector no está controlado por ningún equipo',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Razón del desafío (opcional)',
                                hintText:
                                    'Ej: Queremos demostrar quién manda en este sector',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                              onSaved: (value) => _challengeReason = value,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    _defenderTeam != null
                                        ? _submitChallenge
                                        : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6F00),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                child: const Text(
                                  'Lanzar Desafío',
                                  style: TextStyle(fontSize: 16),
                                ),
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
