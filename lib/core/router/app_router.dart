import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/home/home_screen.dart';
import '../../features/habit_form/habit_form_screen.dart';
import '../../features/habit_detail/habit_detail_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/premium/premium_screen.dart';
import '../../features/stats/stats_screen.dart';
import '../../features/themes/themes_screen.dart';
import '../../providers/habit_provider.dart';
import '../../providers/premium_provider.dart';
import '../constants/app_constants.dart';
import '../hive/hive_service.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      // First launch: redirect to onboarding if no name set
      final path = state.uri.path;
      if (path != '/onboarding' && HiveService.userName == null) {
        return '/onboarding';
      }
      // Guard: free users can only have 3 habits
      if (path == '/habit/new') {
        final count = ref.read(habitProvider).length;
        final isPremium = ref.read(premiumProvider);
        if (count >= AppConstants.kFreeHabitLimit && !isPremium) {
          return '/premium';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        pageBuilder: (context, state) => _slideTransition(
          state,
          const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        pageBuilder: (context, state) => _slideTransition(
          state,
          const HomeScreen(),
        ),
      ),
      GoRoute(
        path: '/habit/new',
        name: 'habitNew',
        pageBuilder: (context, state) => _slideTransition(
          state,
          const HabitFormScreen(),
        ),
      ),
      GoRoute(
        path: '/habit/:id/edit',
        name: 'habitEdit',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _slideTransition(state, HabitFormScreen(habitId: id));
        },
      ),
      GoRoute(
        path: '/habit/:id',
        name: 'habitDetail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _slideTransition(state, HabitDetailScreen(habitId: id));
        },
      ),
      GoRoute(
        path: '/premium',
        name: 'premium',
        pageBuilder: (context, state) => _modalTransition(
          state,
          const PremiumScreen(),
        ),
      ),
      GoRoute(
        path: '/stats',
        name: 'stats',
        pageBuilder: (context, state) => _slideTransition(
          state,
          const StatsScreen(),
        ),
      ),
      GoRoute(
        path: '/themes',
        name: 'themes',
        pageBuilder: (context, state) => _slideTransition(
          state,
          const ThemesScreen(),
        ),
      ),
    ],
  );
});

CustomTransitionPage<void> _slideTransition(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slideIn = Tween<Offset>(
        begin: const Offset(0.06, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ));
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(position: slideIn, child: child),
      );
    },
  );
}

CustomTransitionPage<void> _modalTransition(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slideUp = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ));
      return SlideTransition(position: slideUp, child: child);
    },
  );
}
