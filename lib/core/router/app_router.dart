import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/onboarding/presentation/pages/welcome_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/friends/presentation/pages/friends_page.dart';
import '../../features/friends/presentation/pages/search_friends_page.dart';
import '../../features/maps/presentation/pages/maps_page.dart';
import '../../features/maps/presentation/pages/territorial_map_page.dart';
import '../../features/maps/presentation/pages/rankings_page.dart';
import '../../features/maps/presentation/pages/challenges_page.dart';
import '../../features/maps/presentation/pages/create_challenge_page.dart';
import '../../features/teams/presentation/pages/teams_page.dart';
import '../../features/teams/presentation/pages/team_chat_page.dart';
import '../../features/challenges/presentation/pages/search_teams_page.dart';
import '../../features/challenges/presentation/pages/challenges_page.dart'
    as team_challenges;
import '../../features/matches/presentation/pages/matches_page_enhanced.dart';
import '../../features/matches/presentation/pages/simple_match_selector.dart';
import '../../features/matches/presentation/pages/live_match_page.dart';
import '../../features/matches/presentation/pages/radial_match_search_page.dart';
import '../../features/matches/presentation/pages/create_public_match_page.dart';
import '../../features/matches/presentation/pages/create_match_page_enhanced.dart';
import '../../features/recruitment/presentation/pages/recruitment_page.dart';
import '../../features/recruitment/presentation/pages/create_recruitment_post_page.dart';
import '../../shared/widgets/main_scaffold.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final user = Supabase.instance.client.auth.currentUser;
      final isLoggedIn = user != null;

      // Rutas públicas que no requieren autenticación
      final publicRoutes = ['/welcome', '/login', '/register'];
      final isPublicRoute = publicRoutes.contains(state.fullPath);

      print('🔄 Router redirect:');
      print('   Path: ${state.fullPath}');
      print('   Is logged in: $isLoggedIn');
      print('   User ID: ${user?.id ?? 'null'}');
      print('   Is public route: $isPublicRoute');

      // Si no está logueado y trata de acceder a ruta privada
      if (!isLoggedIn && !isPublicRoute) {
        print('   → Redirecting to welcome (not authenticated)');
        return '/welcome';
      }

      // Si está logueado y trata de acceder a rutas de auth
      if (isLoggedIn &&
          (state.fullPath == '/welcome' ||
              state.fullPath == '/login' ||
              state.fullPath == '/register')) {
        print('   → User authenticated, checking profile status');

        // Verificar si el usuario ya tiene perfil completo
        final supabase = Supabase.instance.client;
        try {
          final profile =
              await supabase
                  .from('profiles')
                  .select('has_completed_onboarding, full_name, tag')
                  .eq('id', user.id)
                  .maybeSingle();

          print('   Profile data: $profile');

          if (profile == null) {
            print('   → No profile found, redirecting to onboarding');
            return '/onboarding';
          } else if (profile['has_completed_onboarding'] == true) {
            print('   → Profile complete, redirecting to dashboard');
            return '/dashboard';
          } else {
            print('   → Onboarding incomplete, redirecting to onboarding');
            return '/onboarding';
          }
        } catch (e) {
          // Si hay error con has_completed_onboarding, verificar perfil básico
          print('   Error checking has_completed_onboarding: $e');
          try {
            final basicProfile =
                await supabase
                    .from('profiles')
                    .select('id, full_name, tag')
                    .eq('id', user.id)
                    .maybeSingle();

            print('   Basic profile data: $basicProfile');

            // Si tiene perfil básico completo, ir al dashboard
            if (basicProfile != null &&
                basicProfile['full_name'] != null &&
                basicProfile['tag'] != null) {
              print('   → Basic profile complete, redirecting to dashboard');
              return '/dashboard';
            } else {
              print('   → Basic profile incomplete, redirecting to onboarding');
              return '/onboarding';
            }
          } catch (e2) {
            print('   Error checking basic profile: $e2');
            print('   → Redirecting to onboarding (fallback)');
            return '/onboarding';
          }
        }
      }

      // Si está logueado y accede a onboarding pero ya completó el proceso
      if (isLoggedIn && state.fullPath == '/onboarding') {
        print(
          '   → User trying to access onboarding, checking completion status',
        );

        final supabase = Supabase.instance.client;
        try {
          final profile =
              await supabase
                  .from('profiles')
                  .select('has_completed_onboarding')
                  .eq('id', user.id)
                  .maybeSingle();

          if (profile != null && profile['has_completed_onboarding'] == true) {
            print('   → Onboarding already complete, redirecting to dashboard');
            return '/dashboard';
          }
        } catch (e) {
          // Si hay error, permitir acceso a onboarding
          print('   Error checking onboarding status: $e');
          print('   → Allowing access to onboarding');
        }
      }

      print('   → No redirect needed');
      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/welcome'),
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),

      // Shell Route para páginas con navegación persistente
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: '/maps',
            name: 'maps',
            builder: (context, state) => const MapsPage(),
          ),
          GoRoute(
            path: '/territorial-map',
            name: 'territorial-map',
            builder: (context, state) => const TerritorialMapPage(),
          ),
          GoRoute(
            path: '/rankings',
            name: 'rankings',
            builder: (context, state) => const RankingsPage(),
          ),
          GoRoute(
            path: '/challenges',
            name: 'challenges-territorial',
            builder: (context, state) => const ChallengesPage(),
            routes: [
              GoRoute(
                path: 'create',
                name: 'create-challenge',
                builder: (context, state) => const CreateChallengePage(),
              ),
              GoRoute(
                path: 'details/:challengeId',
                name: 'challenge-details',
                builder: (context, state) {
                  return const Text('Detalles del desafío - Pendiente');
                },
              ),
              GoRoute(
                path: 'history/:challengeId',
                name: 'challenge-history',
                builder: (context, state) {
                  return const Text('Historial del desafío - Pendiente');
                },
              ),
            ],
          ),
          GoRoute(
            path: '/teams',
            name: 'teams',
            builder: (context, state) => const TeamsPage(),
            routes: [
              GoRoute(
                path: ':teamId/chat',
                name: 'team-chat',
                builder: (context, state) {
                  final teamId = state.pathParameters['teamId']!;
                  return TeamChatPage(teamId: teamId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/notifications',
            name: 'notifications',
            builder: (context, state) => const NotificationsPage(),
          ),
          GoRoute(
            path: '/matches',
            name: 'matches',
            builder: (context, state) => const MatchesPageEnhanced(),
            routes: [
              GoRoute(
                path: 'create',
                name: 'create-match',
                builder: (context, state) => const SimpleMatchTypeSelector(),
              ),
              GoRoute(
                path: ':matchId',
                name: 'match-details',
                builder: (context, state) {
                  return const Text('Detalles del partido - Pendiente');
                },
              ),
              GoRoute(
                path: ':matchId/edit',
                name: 'edit-match',
                builder: (context, state) {
                  final matchId = state.pathParameters['matchId']!;
                  return CreateMatchPageEnhanced(teamId: matchId);
                },
              ),
              GoRoute(
                path: ':matchId/live',
                name: 'match-live',
                builder: (context, state) {
                  final matchId = state.pathParameters['matchId']!;
                  return LiveMatchPage(matchId: matchId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/create-match',
            name: 'create-match-direct',
            builder: (context, state) => const CreateMatchPageEnhanced(),
          ),
          GoRoute(
            path: '/create-public-match',
            name: 'create-public-match',
            builder: (context, state) => const CreatePublicMatchPage(),
          ),
          GoRoute(
            path: '/recruitment',
            name: 'recruitment',
            builder: (context, state) => const RecruitmentPage(),
            routes: [
              GoRoute(
                path: '/create',
                name: 'create-recruitment-post',
                builder: (context, state) => const CreateRecruitmentPostPage(),
              ),
            ],
          ),
        ],
      ),

      // Rutas especiales sin navegación persistente
      GoRoute(
        path: '/friends',
        name: 'friends',
        builder: (context, state) => const FriendsPage(),
        routes: [
          GoRoute(
            path: '/search',
            name: 'friends-search',
            builder: (context, state) => const SearchFriendsPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/radial-search',
        name: 'radial-search',
        builder: (context, state) => const RadialMatchSearchPage(),
      ),
      GoRoute(
        path: '/search-teams/:teamId',
        name: 'search-teams',
        builder: (context, state) {
          final teamId = state.pathParameters['teamId']!;
          return SearchTeamsPage(currentTeamId: teamId);
        },
      ),
      GoRoute(
        path: '/challenges/:teamId',
        name: 'team-challenges',
        builder: (context, state) {
          final teamId = state.pathParameters['teamId']!;
          return team_challenges.ChallengesPage(teamId: teamId);
        },
      ),
      GoRoute(
        path: '/live-match/:matchId',
        name: 'live-match',
        builder: (context, state) {
          final matchId = state.pathParameters['matchId']!;
          return LiveMatchPage(matchId: matchId);
        },
      ),
    ],
  );
});
