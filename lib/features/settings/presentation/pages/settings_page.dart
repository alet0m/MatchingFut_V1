import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../safety/data/safety_providers.dart';
import '../../../safety/data/safety_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/ui/app_snack.dart';
import '../../../../core/theme/theme_prefs.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockedAsync = ref.watch(blockedUsersProvider);
    final reportsAsync = ref.watch(myReportsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionHeader(title: 'Apariencia'),
          _ThemeSettingsCard(),
          const SizedBox(height: 16),

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
                                  (u['profile_image_url'] != null &&
                                          (u['profile_image_url'] as String)
                                              .isNotEmpty)
                                      ? NetworkImage(u['profile_image_url'])
                                      : null,
                              backgroundColor: scheme.primary,
                              child:
                                  (u['profile_image_url'] == null ||
                                          (u['profile_image_url'] as String)
                                              .isEmpty)
                                      ? Icon(
                                        Icons.person,
                                        color: scheme.onPrimary,
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
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            trailing: TextButton.icon(
                              onPressed:
                                  () => _confirmUnblock(
                                    context,
                                    ref,
                                    u['id'] as String,
                                  ),
                              icon: Icon(
                                Icons.lock_open,
                                color: scheme.secondary,
                              ),
                              label: Text(
                                'Desbloquear',
                                style: TextStyle(color: scheme.secondary),
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
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
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
                                  (r['reported_profile_image_url'] != null &&
                                          (r['reported_profile_image_url']
                                                  as String)
                                              .isNotEmpty)
                                      ? NetworkImage(
                                        r['reported_profile_image_url'],
                                      )
                                      : null,
                              backgroundColor: scheme.tertiary,
                              child:
                                  (r['reported_profile_image_url'] == null ||
                                          (r['reported_profile_image_url']
                                                  as String)
                                              .isEmpty)
                                      ? Icon(
                                        Icons.report,
                                        color: scheme.onTertiary,
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
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  details.length > 120
                                      ? '${details.substring(0, 120)}…'
                                      : details,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  createdAt,
                                  style: TextStyle(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
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
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
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
        if (context.mounted) AppSnack.success(context, 'Usuario desbloqueado');
      } catch (e) {
        if (context.mounted) AppSnack.error(context, 'Error: $e');
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
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
          Icon(
            icon,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Theme settings card moved from Profile to Settings
class _ThemeSettingsCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ThemeSettingsCard> createState() => _ThemeSettingsCardState();
}

class _ThemeSettingsCardState extends ConsumerState<_ThemeSettingsCard> {
  late String _themeMode;
  late String _seedHex;
  late String _accentHex;
  late String _style;

  @override
  void initState() {
    super.initState();
    final prefs = ThemePrefs.defaults();
    _themeMode = prefs.mode;
    _seedHex = prefs.seedHex;
    _accentHex = prefs.accentHex;
    _style = prefs.style;
    _load();
  }

  Future<void> _load() async {
    try {
      final supabase = Supabase.instance.client;
      final uid = supabase.auth.currentUser?.id;
      if (uid == null) return;
      final row =
          await supabase
              .from('profiles')
              .select('theme_prefs')
              .eq('id', uid)
              .maybeSingle();
      final prefs = ThemePrefs.fromMap(
        (row?['theme_prefs'] as Map?)?.cast<String, dynamic>(),
      );
      setState(() {
        _themeMode = prefs.mode;
        _seedHex = prefs.seedHex;
        _accentHex = prefs.accentHex;
        _style = prefs.style;
      });
    } catch (_) {}
  }

  Future<void> _save({
    String? mode,
    String? seed,
    String? accent,
    String? style,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final uid = supabase.auth.currentUser?.id;
      if (uid == null) return;
      setState(() {
        if (mode != null) _themeMode = mode;
        if (seed != null) _seedHex = seed;
        if (accent != null) _accentHex = accent;
        if (style != null) _style = style;
      });
      final prefs = {
        'seed': _seedHex,
        'accent': _accentHex,
        'mode': _themeMode,
        'style': _style,
      };
      await supabase
          .from('profiles')
          .update({'theme_prefs': prefs})
          .eq('id', uid);
      if (mounted) AppSnack.success(context, 'Tema actualizado');
    } catch (e) {
      if (mounted) AppSnack.error(context, 'Error al guardar: $e');
    }
  }

  Widget _radio(String value, String label, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    return RadioListTile<String>(
      value: value,
      groupValue: _themeMode,
      onChanged: (v) => v == null ? null : _save(mode: v),
      title: Row(
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      dense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palettes = [
      {'name': 'Quilicura', 'seed': '#2E7D32', 'accent': '#FF6F00'},
      {'name': 'Bosque', 'seed': '#1B5E20', 'accent': '#66BB6A'},
      {'name': 'Océano', 'seed': '#0D47A1', 'accent': '#00ACC1'},
      {'name': 'Noche', 'seed': '#212121', 'accent': '#FFAB00'},
      {'name': 'AMOLED', 'seed': '#000000', 'accent': '#00E5FF'},
      {'name': 'Fuego', 'seed': '#BF360C', 'accent': '#FFC107'},
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.palette, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Text(
                  'Tema de la app',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final p in palettes)
                  _PaletteCard(
                    name: p['name']!,
                    seedHex: p['seed']!,
                    accentHex: p['accent']!,
                    selected:
                        _seedHex == p['seed']! && _accentHex == p['accent']!,
                    onTap: () => _save(seed: p['seed']!, accent: p['accent']!),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _radio('system', 'Seguir el sistema', Icons.settings_suggest),
            _radio('light', 'Claro', Icons.light_mode),
            _radio('dark', 'Oscuro', Icons.dark_mode),
          ],
        ),
      ),
    );
  }
}

class _PaletteCard extends StatelessWidget {
  final String name;
  final String seedHex;
  final String accentHex;
  final bool selected;
  final VoidCallback onTap;

  const _PaletteCard({
    required this.name,
    required this.seedHex,
    required this.accentHex,
    required this.selected,
    required this.onTap,
  });

  Color _hex(String hex) {
    final clean = hex.replaceAll('#', '');
    final full = clean.length == 6 ? 'FF$clean' : clean;
    return Color(int.parse(full, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final seed = _hex(seedHex);
    final accent = _hex(accentHex);
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? seed : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: seed,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              '#${seedHex.replaceAll('#', '').toUpperCase()} · #${accentHex.replaceAll('#', '').toUpperCase()}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
