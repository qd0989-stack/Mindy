import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/screens.dart';

/// App router configuration
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Splash/Disclaimer
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),

    // Onboarding
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // Main shell with bottom navigation
    ShellRoute(
      builder: (context, state, child) {
        // Determine current index based on location
        final location = state.uri.path;
        int index = 0;
        if (location.startsWith('/chat')) {
          index = 1;
        } else if (location.startsWith('/insights')) {
          index = 2;
        } else if (location.startsWith('/profile')) {
          index = 3;
        }
        return MainShell(currentIndex: index, child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/chat',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ChatScreen(),
          ),
        ),
        GoRoute(
          path: '/insights',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: InsightsScreen(),
          ),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProfileScreen(),
          ),
        ),
      ],
    ),

    // Voice call (full screen, outside shell)
    GoRoute(
      path: '/call',
      builder: (context, state) => const VoiceCallScreen(),
    ),

    // Tips screen
    GoRoute(
      path: '/tips',
      builder: (context, state) => const TipsScreen(),
    ),
  ],
);
