import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/notifications/presentation/providers/notifications_providers.dart';
import '../../shared/ui/app_snack.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: child,
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.path;

    String title = 'Dashboard';
    if (currentLocation.startsWith('/matches')) {
      title = 'Partidos';
    } else if (currentLocation.startsWith('/teams')) {
      title = 'Equipos';
    } else if (currentLocation.startsWith('/notifications')) {
      title = 'Notificaciones';
    } else if (currentLocation.startsWith('/maps')) {
      title = 'Ranking';
    } else if (currentLocation.startsWith('/profile')) {
      title = 'Perfil';
    } else if (currentLocation.startsWith('/recruitment')) {
      title = 'Reclutamiento';
    } else if (currentLocation.startsWith('/recruitment')) {
      title = 'Reclutamiento';
    }

    final scheme = Theme.of(context).colorScheme;
    return AppBar(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: scheme.onPrimary,
        ),
      ),
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 0,
      leading: Builder(
        builder:
            (context) => IconButton(
              icon: Icon(Icons.menu_rounded, color: scheme.onPrimary, size: 28),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
      ),
      actions: [
        // Bell with badge
        Builder(
          builder: (context) {
            return _NotificationsBell();
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [scheme.primary, scheme.primary.withValues(alpha: 0.85)],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.transparent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.sports_soccer,
                      size: 30,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Fútbol Quilicura',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Menú Principal',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Ranking
            ListTile(
              leading: const Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 28,
              ),
              title: const Text(
                'Ranking Global',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'Ver posiciones ELO',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement ranking page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ranking próximamente')),
                );
              },
            ),

            // Mis Amigos
            ListTile(
              leading: const Icon(Icons.group, color: Colors.white, size: 28),
              title: const Text(
                'Mis Amigos',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'Conectar con jugadores',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/friends');
              },
            ),

            // Notificaciones
            ListTile(
              leading: const Icon(
                Icons.notifications,
                color: Colors.white,
                size: 28,
              ),
              title: const Text(
                'Notificaciones',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'Invitaciones y alertas',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/notifications');
              },
            ),

            // Reclutamiento
            ListTile(
              leading: const Icon(
                Icons.person_search,
                color: Colors.white,
                size: 28,
              ),
              title: const Text(
                'Reclutamiento',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'Buscar jugadores y equipos',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/recruitment');
              },
            ),

            // Desafíos
            ListTile(
              leading: const Icon(
                Icons.sports_mma,
                color: Colors.white,
                size: 28,
              ),
              title: const Text(
                'Desafíos',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'Retar otros equipos',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to challenges - needs team selection
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Primero crea un equipo para ver desafíos'),
                  ),
                );
              },
            ),

            const Divider(color: Colors.white24),

            // Configuración
            ListTile(
              leading: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 28,
              ),
              title: const Text(
                'Configuración',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/settings');
              },
            ),

            // Ayuda
            ListTile(
              leading: const Icon(
                Icons.help_outline,
                color: Colors.white,
                size: 28,
              ),
              title: const Text(
                'Ayuda',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                AppSnack.info(context, 'Para ayuda contacta al administrador');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.path;

    // Determinar el índice activo basado en la ruta
    int selectedIndex = 0;
    if (currentLocation.startsWith('/matches')) {
      selectedIndex = 1;
    } else if (currentLocation.startsWith('/teams')) {
      selectedIndex = 2;
    } else if (currentLocation.startsWith('/maps')) {
      selectedIndex = 3;
    } else if (currentLocation.startsWith('/profile')) {
      selectedIndex = 4;
    }

    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => _onNavTap(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined, size: 28),
            activeIcon: Icon(Icons.dashboard, size: 28),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer_outlined, size: 28),
            activeIcon: Icon(Icons.sports_soccer, size: 28),
            label: 'Partidos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined, size: 28),
            activeIcon: Icon(Icons.groups, size: 28),
            label: 'Equipos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined, size: 28),
            activeIcon: Icon(Icons.emoji_events, size: 28),
            label: 'Ranking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 28),
            activeIcon: Icon(Icons.person, size: 28),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/matches');
        break;
      case 2:
        context.go('/teams');
        break;
      case 3:
        context.go('/maps');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}

// Bell icon with badge; separated widget to use Consumer without converting MainScaffold into ConsumerWidget
class _NotificationsBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final countAsync = ref.watch(
          // ignore: deprecated_member_use
          // The provider is under notifications feature
          // Import locally to avoid circular imports via top of file
          // We refer using fully qualified import below in a local builder
          notificationsBadgeCountProvider,
        );
        final count = countAsync.asData?.value ?? 0;
        return InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => context.push('/notifications'),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Icon(
                  Icons.notifications,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 26,
                ),
              ),
              if (count > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
