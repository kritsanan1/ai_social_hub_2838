import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/social_media_dashboard/social_media_dashboard.dart';
import '../presentation/content_calendar/content_calendar.dart';
import '../presentation/messages_inbox/messages_inbox.dart';
import '../presentation/post_creation/post_creation.dart';
import '../presentation/user_profile/user_profile.dart';
import '../presentation/social_comments/social_comments.dart';
import '../presentation/connect_socials/connect_socials.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/subscription_screen/subscription_screen.dart';
import '../providers/auth_provider.dart';

/// App Router using GoRouter
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      
      final isGoingToSplash = state.matchedLocation == '/splash';
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToSignup = state.matchedLocation == '/signup';
      final isGoingToOnboarding = state.matchedLocation == '/onboarding';
      
      // Show splash while loading
      if (isLoading && !isGoingToSplash) {
        return '/splash';
      }

      // If not authenticated and trying to access protected route
      if (!isAuthenticated && 
          !isGoingToLogin && 
          !isGoingToSignup && 
          !isGoingToOnboarding &&
          !isGoingToSplash) {
        return '/login';
      }

      // If authenticated and trying to access auth screens
      if (isAuthenticated && (isGoingToLogin || isGoingToSignup)) {
        return '/dashboard';
      }

      return null; // No redirect needed
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const LoginScreen(isSignup: true),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingFlow(),
      ),

      // Main App Routes (Protected)
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const SocialMediaDashboard(),
      ),
      GoRoute(
        path: '/calendar',
        name: 'calendar',
        builder: (context, state) => const ContentCalendar(),
      ),
      GoRoute(
        path: '/messages',
        name: 'messages',
        builder: (context, state) => const MessagesInbox(),
      ),
      GoRoute(
        path: '/comments',
        name: 'comments',
        builder: (context, state) => const SocialComments(),
      ),
      GoRoute(
        path: '/upload',
        name: 'upload',
        builder: (context, state) => const PostCreation(),
      ),
      GoRoute(
        path: '/connect',
        name: 'connect',
        builder: (context, state) => const ConnectSocials(),
      ),
      GoRoute(
        path: '/subscription',
        name: 'subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const UserProfile(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.uri.path}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Navigation Extension for easy access
extension NavigationExtension on BuildContext {
  void goToDashboard() => go('/dashboard');
  void goToCalendar() => go('/calendar');
  void goToMessages() => go('/messages');
  void goToComments() => go('/comments');
  void goToUpload() => go('/upload');
  void goToConnect() => go('/connect');
  void goToSubscription() => go('/subscription');
  void goToProfile() => go('/profile');
  void goToSettings() => go('/settings');
  void goToLogin() => go('/login');
  void goToSignup() => go('/signup');
}

