// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2E7D32), // Verde césped
                  Color(0xFF1B5E20), // Verde oscuro
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo animado (por ahora usamos un ícono, después se puede reemplazar)
                      Container(
                            width: 120,
                            height: 120,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.sports_soccer,
                              size: 60,
                              color: Color(0xFF2E7D32),
                            ),
                          )
                          .animate()
                          .scale(duration: 800.ms, curve: Curves.elasticOut)
                          .then()
                          .shimmer(duration: 1500.ms),

                      const SizedBox(height: 40),

                      // Título principal
                      const Text(
                        '¡Bienvenido a',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(duration: 1000.ms).slideY(begin: 0.3),

                      const Text(
                            'FÚTBOL QUILICURA!',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          )
                          .animate(delay: 300.ms)
                          .fadeIn(duration: 1000.ms)
                          .slideY(begin: 0.3),

                      const SizedBox(height: 20),

                      // Subtítulo
                      const Text(
                            'Conecta, juega y domina tu territorio\nen el fútbol más competitivo de Quilicura',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          )
                          .animate(delay: 600.ms)
                          .fadeIn(duration: 1000.ms)
                          .slideY(begin: 0.3),

                      const SizedBox(height: 60),

                      // Botones
                      Column(
                        children: [
                          SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => context.go('/register'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF6F00),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 8,
                                  ),
                                  child: const Text(
                                    'CREAR CUENTA',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              )
                              .animate(delay: 900.ms)
                              .fadeIn(duration: 800.ms)
                              .slideY(begin: 0.3),

                          const SizedBox(height: 16),

                          SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () => context.go('/login'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: const BorderSide(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Text(
                                    'YA TENGO CUENTA',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              )
                              .animate(delay: 1100.ms)
                              .fadeIn(duration: 800.ms)
                              .slideY(begin: 0.3),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Indicadores de características
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildFeatureIndicator(
                            icon: Icons.map,
                            label: 'Mapa\nTerritorial',
                          ),
                          _buildFeatureIndicator(
                            icon: Icons.leaderboard,
                            label: 'Ranking\nELO',
                          ),
                          _buildFeatureIndicator(
                            icon: Icons.group,
                            label: 'Equipos\nSociales',
                          ),
                        ],
                      ).animate(delay: 1300.ms).fadeIn(duration: 1000.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Botón de diagnóstico solo en modo debug
          if (kDebugMode)
            Positioned(
              right: 12,
              bottom: 12,
              child: FloatingActionButton.extended(
                heroTag: 'health',
                onPressed: () => context.go('/health'),
                icon: const Icon(Icons.health_and_safety),
                label: const Text('Diagnóstico'),
                backgroundColor: const Color(0xFFFF6F00),
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureIndicator({
    required IconData icon,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
