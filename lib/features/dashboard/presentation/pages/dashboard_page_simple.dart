// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardPageSimple extends ConsumerWidget {
  const DashboardPageSimple({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título de bienvenida
              const Text(
                '¡Hola Futbolero! ⚽',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tu cancha digital te espera',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 32),

              // Grid de tarjetas de acción
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildActionCard(
                    context,
                    'Partidos',
                    'Ver todos los partidos disponibles',
                    Icons.sports_soccer,
                    '/matches',
                  ),
                  _buildActionCard(
                    context,
                    'Equipos',
                    'Explorar equipos y unirte',
                    Icons.groups,
                    '/teams',
                  ),
                  _buildActionCard(
                    context,
                    'Territorio',
                    'Explorar canchas cercanas',
                    Icons.map,
                    '/maps',
                  ),
                  _buildActionCard(
                    context,
                    'Amigos',
                    'Conectar con jugadores',
                    Icons.people,
                    '/friends',
                  ),
                  _buildActionCard(
                    context,
                    'Búsqueda Radial',
                    'Buscar partidos cercanos',
                    Icons.my_location,
                    '/radial-search',
                  ),
                  _buildActionCard(
                    context,
                    'Mi Perfil',
                    'Ver estadísticas y progreso',
                    Icons.person,
                    '/profile',
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Sección de estadísticas rápidas
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estado de la App',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatusItem('✅ Sistema de amigos integrado'),
                    _buildStatusItem('✅ Menú hamburguesa con ranking'),
                    _buildStatusItem('✅ Búsqueda radial operativa'),
                    _buildStatusItem('✅ Navegación completa verificada'),
                    _buildStatusItem(
                      '🔧 Optimización mouse_tracker en progreso',
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

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    String route,
  ) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF2E7D32)),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
    );
  }
}
