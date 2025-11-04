import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/onboarding/presentation/pages/welcome_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/friends/presentation/pages/friends_page.dart';
import '../../features/friends/presentation/pages/search_friends_page.dart';
import '../../features/matches/presentation/pages/matches_page_enhanced.dart';
import '../../features/matches/presentation/pages/simple_match_selector.dart';
import '../../features/matches/presentation/pages/live_match_page.dart';
import '../../features/matches/presentation/pages/radial_match_search_page.dart';
import '../../features/matches/presentation/pages/create_public_match_page.dart';
import '../../features/matches/presentation/pages/create_match_page_enhanced.dart';
import '../../features/teams/presentation/pages/teams_page.dart';
import '../../features/teams/presentation/pages/team_chat_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/maps/presentation/pages/maps_page.dart';
import '../../features/maps/presentation/pages/territorial_map_page.dart';
import '../../features/maps/presentation/pages/rankings_page.dart';
import '../../features/maps/presentation/pages/challenges_page.dart'
    as territorial_challenges;
import '../../features/maps/presentation/pages/create_challenge_page.dart';
import '../../features/challenges/presentation/pages/search_teams_page.dart';
import '../../features/challenges/presentation/pages/challenges_page.dart'
    as team_challenges;
import '../../features/recruitment/presentation/pages/recruitment_page.dart';
import '../../features/recruitment/presentation/pages/create_recruitment_post_page.dart';
import '../../shared/widgets/main_scaffold.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../debug/health_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';

// Refresca el router cuando cambia el estado de autenticación (web necesita esto)
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final supabase = Supabase.instance.client;
  return GoRouter(
    // Evita inconsistencias con '/' en web
    initialLocation: '/welcome',
    // Reescucha cambios de sesión para evitar pantallas en blanco o loops
    refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),
    redirect: (context, state) {
      final user = supabase.auth.currentUser;
      final isLoggedIn = user != null;

      final path = state.fullPath ?? state.uri.toString();
      debugPrint('🔄 Router: $path, logged in: $isLoggedIn');

      // Si no está logueado, permitir páginas públicas
      if (!isLoggedIn &&
          path != '/welcome' &&
          path != '/login' &&
          path != '/register' &&
          path != '/') {
        return '/welcome';
      }

      // Si está logueado y viene desde register, llevar al onboarding inmediatamente
      if (isLoggedIn && path == '/register') {
        return '/onboarding';
      }

      // Si está logueado y va a welcome o login o raíz, ir al dashboard
      if (isLoggedIn &&
          (path == '/welcome' || path == '/login' || path == '/')) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      // Raíz explícita para evitar pantalla en blanco si navegan a '/'
      GoRoute(path: '/', redirect: (context, state) => '/welcome'),
      // Ruta de bienvenida
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomePage(),
      ),

      // Ruta de login
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),

      // Ruta de registro
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),

      // Diagnóstico (solo para desarrollo)
      GoRoute(path: '/health', builder: (context, state) => const HealthPage()),

      // Shell route para navegación principal
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          // Dashboard
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardPage(),
          ),

          // Amigos
          GoRoute(
            path: '/friends',
            builder: (context, state) => const FriendsPage(),
          ),
          GoRoute(
            path: '/friends/search',
            builder: (context, state) => const SearchFriendsPage(),
          ),

          // Partidos
          GoRoute(
            path: '/matches',
            builder: (context, state) => const MatchesPageEnhanced(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const SimpleMatchTypeSelector(),
              ),
              GoRoute(
                path: ':matchId',
                builder: (context, state) {
                  final id = state.pathParameters['matchId']!;
                  return Text('Detalles del partido: $id');
                },
              ),
              GoRoute(
                path: ':matchId/edit',
                builder: (context, state) {
                  final id = state.pathParameters['matchId']!;
                  return CreateMatchPageEnhanced(teamId: id);
                },
              ),
              GoRoute(
                path: ':matchId/live',
                builder: (context, state) {
                  final id = state.pathParameters['matchId']!;
                  return LiveMatchPage(matchId: id);
                },
              ),
            ],
          ),

          // Equipos
          GoRoute(
            path: '/teams',
            builder: (context, state) => const TeamsPage(),
            routes: [
              GoRoute(
                path: ':teamId/chat',
                builder: (context, state) {
                  final teamId = state.pathParameters['teamId']!;
                  return TeamChatPage(teamId: teamId);
                },
              ),
            ],
          ),

          // Notificaciones
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsPage(),
          ),

          // Perfil
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: '/profile/:userId',
            builder: (context, state) {
              final id = state.pathParameters['userId']!;
              return ProfilePage(userId: id);
            },
          ),

          // Crear partido directo
          GoRoute(
            path: '/create-match',
            builder: (context, state) => const CreateMatchPageEnhanced(),
          ),
          // Crear partido público
          GoRoute(
            path: '/create-public-match',
            builder: (context, state) => const CreatePublicMatchPage(),
          ),

          // Mapas y territorio
          GoRoute(path: '/maps', builder: (context, state) => const MapsPage()),
          GoRoute(
            path: '/territorial-map',
            builder: (context, state) => const TerritorialMapPage(),
          ),
          GoRoute(
            path: '/rankings',
            builder: (context, state) => const RankingsPage(),
          ),
          GoRoute(
            path: '/challenges',
            builder:
                (context, state) =>
                    const territorial_challenges.ChallengesPage(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreateChallengePage(),
              ),
              GoRoute(
                path: 'details/:challengeId',
                builder: (context, state) {
                  final id = state.pathParameters['challengeId']!;
                  return Text('Detalle desafío territorial: $id');
                },
              ),
              GoRoute(
                path: 'history/:challengeId',
                builder: (context, state) {
                  final id = state.pathParameters['challengeId']!;
                  return Text('Historial desafío territorial: $id');
                },
              ),
            ],
          ),

          // Reclutamiento
          GoRoute(
            path: '/recruitment',
            builder: (context, state) => const RecruitmentPage(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreateRecruitmentPostPage(),
              ),
            ],
          ),

          // Configuración
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),

      // Rutas fuera del shell
      GoRoute(
        path: '/radial-search',
        builder: (context, state) => const RadialMatchSearchPage(),
      ),
      GoRoute(
        path: '/search-teams/:teamId',
        builder: (context, state) {
          final teamId = state.pathParameters['teamId']!;
          return SearchTeamsPage(currentTeamId: teamId);
        },
      ),
      GoRoute(
        path: '/challenges/:teamId',
        builder: (context, state) {
          final teamId = state.pathParameters['teamId']!;
          return team_challenges.ChallengesPage(teamId: teamId);
        },
      ),
      GoRoute(
        path: '/live-match/:matchId',
        builder: (context, state) {
          final id = state.pathParameters['matchId']!;
          return LiveMatchPage(matchId: id);
        },
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${state.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/welcome'),
                  child: const Text('Ir al Inicio'),
                ),
              ],
            ),
          ),
        ),
  );
});
