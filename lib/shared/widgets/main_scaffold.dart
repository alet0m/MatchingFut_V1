import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    } else if (currentLocation.startsWith('/maps')) {
      title = 'Territorio';
    } else if (currentLocation.startsWith('/profile')) {
      title = 'Perfil';
    } else if (currentLocation.startsWith('/recruitment')) {
      title = 'Reclutamiento';
    } else if (currentLocation.startsWith('/recruitment')) {
      title = 'Reclutamiento';
    }

    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xFF2E7D32),
      foregroundColor: Colors.white,
      elevation: 0,
      leading: Builder(
        builder:
            (context) => IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.transparent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.sports_soccer,
                      size: 30,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Fútbol Quilicura',
                    style: TextStyle(
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
                  const SnackBar(
                    content: Text('Ranking próximamente'),
                    backgroundColor: Color(0xFF2E7D32),
                  ),
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
                    backgroundColor: Color(0xFF2E7D32),
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
                // TODO: Implement settings page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Configuración próximamente'),
                    backgroundColor: Color(0xFF2E7D32),
                  ),
                );
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Para ayuda contacta al administrador'),
                    backgroundColor: Color(0xFF2E7D32),
                  ),
                );
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => _onNavTap(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey[600],
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
            icon: Icon(Icons.map_outlined, size: 28),
            activeIcon: Icon(Icons.map, size: 28),
            label: 'Territorio',
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
