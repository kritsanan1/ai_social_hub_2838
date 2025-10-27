import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/content_calendar/content_calendar.dart';
import '../presentation/user_profile/user_profile.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/post_creation/post_creation.dart';
import '../presentation/social_media_dashboard/social_media_dashboard.dart';
import '../presentation/messages_inbox/messages_inbox.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String contentCalendar = '/content-calendar';
  static const String userProfile = '/user-profile';
  static const String login = '/login-screen';
  static const String onboardingFlow = '/onboarding-flow';
  static const String postCreation = '/post-creation';
  static const String socialMediaDashboard = '/social-media-dashboard';
  static const String messagesInbox = '/messages-inbox';
  static const String dashboard = '/dashboard';
  static const String messages = '/messages';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    contentCalendar: (context) => const ContentCalendar(),
    userProfile: (context) => const UserProfile(),
    login: (context) => const LoginScreen(),
    onboardingFlow: (context) => const OnboardingFlow(),
    postCreation: (context) => const PostCreation(),
    socialMediaDashboard: (context) => const SocialMediaDashboard(),
    dashboard: (context) => const SocialMediaDashboard(),
    messagesInbox: (context) => const MessagesInbox(),
    messages: (context) => const MessagesInbox(),
  };
}
