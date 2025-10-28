import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../safety/data/safety_providers.dart';
import '../../../safety/data/safety_service.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockedAsync = ref.watch(blockedUsersProvider);
    final reportsAsync = ref.watch(myReportsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Configuración',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionHeader(title: 'Privacidad'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Usuarios bloqueados',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  blockedAsync.when(
                    data: (list) {
                      if (list.isEmpty) {
                        return const _EmptyState(
                          icon: Icons.block,
                          title: 'No tienes usuarios bloqueados',
                          subtitle:
                              'Desde aquí podrás desbloquear a quien desees',
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final u = list[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                            leading: CircleAvatar(
                              radius: 22,
                              backgroundImage:
                                  u['profile_image_url'] != null
                                      ? NetworkImage(u['profile_image_url'])
                                      : null,
                              backgroundColor: const Color(0xFF2E7D32),
                              child:
                                  u['profile_image_url'] == null
                                      ? const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      )
                                      : null,
                            ),
                            title: Text(
                              u['full_name'] ?? 'Usuario',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              u['email'] ?? '',
                              style: const TextStyle(color: Colors.black54),
                            ),
                            trailing: TextButton.icon(
                              onPressed:
                                  () => _confirmUnblock(
                                    context,
                                    ref,
                                    u['id'] as String,
                                  ),
                              icon: const Icon(
                                Icons.lock_open,
                                color: Colors.orange,
                              ),
                              label: const Text(
                                'Desbloquear',
                                style: TextStyle(color: Colors.orange),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading:
                        () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    error:
                        (e, _) => Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            'Error: $e',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          const _SectionHeader(title: 'Seguridad'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tus reportes',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  reportsAsync.when(
                    data: (list) {
                      if (list.isEmpty) {
                        return const _EmptyState(
                          icon: Icons.flag_outlined,
                          title: 'No has enviado reportes',
                          subtitle: 'Cuando envíes un reporte, aparecerá aquí',
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final r = list[index];
                          final name =
                              (r['reported_full_name'] as String?) ?? 'Usuario';
                          final email = (r['reported_email'] as String?) ?? '';
                          final category = (r['category'] as String?) ?? 'Otro';
                          final createdAt = (r['created_at'] as String?) ?? '';
                          final details = (r['details'] as String?) ?? '';
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                            leading: CircleAvatar(
                              radius: 22,
                              backgroundImage:
                                  r['reported_profile_image_url'] != null
                                      ? NetworkImage(
                                        r['reported_profile_image_url'],
                                      )
                                      : null,
                              backgroundColor: Colors.orange,
                              child:
                                  r['reported_profile_image_url'] == null
                                      ? const Icon(
                                        Icons.report,
                                        color: Colors.white,
                                      )
                                      : null,
                            ),
                            title: Text(
                              '$name • $category',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (email.isNotEmpty)
                                  Text(
                                    email,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  details.length > 120
                                      ? '${details.substring(0, 120)}…'
                                      : details,
                                  style: const TextStyle(color: Colors.black87),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  createdAt,
                                  style: const TextStyle(
                                    color: Colors.black45,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    loading:
                        () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    error:
                        (e, _) => Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            'Error: $e',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmUnblock(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Desbloquear usuario'),
            content: const Text(
              '¿Quieres desbloquear a este usuario? Podrán volver a encontrarse y enviarse solicitudes.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Desbloquear'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await ref.read(safetyServiceProvider).unblockUser(userId);
        ref.invalidate(blockedUsersProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario desbloqueado'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
