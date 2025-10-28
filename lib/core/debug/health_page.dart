import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HealthPage extends ConsumerStatefulWidget {
  const HealthPage({super.key});

  @override
  ConsumerState<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends ConsumerState<HealthPage> {
  String status = 'Chequeando conexión...';
  String details = '';

  @override
  void initState() {
    super.initState();
    _runChecks();
  }

  Future<void> _runChecks() async {
    final supabase = Supabase.instance.client;

    try {
      // 1) Estado de sesión
      final user = supabase.auth.currentUser;
      // 2) Consulta mínima a la tabla profiles
      final res = await supabase.from('profiles').select('id').limit(1);

      setState(() {
        status = 'OK: Conectado a Supabase';
        final rows = (res as List).length;
        details = [
          'Usuario: ${user?.id ?? 'no autenticado'}',
          'Consulta profiles: ok ($rows filas)',
        ].join('\n');
      });
    } catch (e) {
      setState(() {
        status = 'ERROR: No se pudo conectar a Supabase';
        details = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnóstico')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              status,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Text(details.isEmpty ? '-' : details),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _runChecks,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
