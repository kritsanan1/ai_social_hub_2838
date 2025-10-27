# AI Social Hub - Flutter Web Application

## Overview
A modern Flutter-based social media management application that enables users to manage multiple social media accounts, schedule posts, view analytics, and interact with AI-powered content suggestions. The application is built with Flutter and optimized for web deployment on Replit.

**Current State:** Fully configured and running on Replit with Flutter web support enabled.

**Last Updated:** October 27, 2025

## Project Architecture

### Technology Stack
- **Framework:** Flutter 3.29.3 (Web Platform)
- **Language:** Dart SDK ^3.6.0
- **Build System:** Flutter build system with web support
- **Package Manager:** Flutter pub

### Key Dependencies
- **UI/Design:** Sizer (responsive design), Google Fonts, Flutter SVG
- **Networking:** Dio, Connectivity Plus
- **Storage:** Shared Preferences, Cached Network Image
- **Charts:** FL Chart
- **Calendar:** Table Calendar
- **Media:** Image Picker
- **Authentication:** Flutter Signin Button
- **Permissions:** Permission Handler

### Project Structure
```
ai_social_hub/
├── lib/
│   ├── core/              # Core utilities and exports
│   ├── presentation/      # UI screens and widgets
│   │   ├── splash_screen/
│   │   ├── login_screen/
│   │   ├── onboarding_flow/
│   │   ├── social_media_dashboard/
│   │   ├── post_creation/
│   │   ├── content_calendar/
│   │   ├── messages_inbox/
│   │   └── user_profile/
│   ├── routes/           # Application routing
│   ├── theme/            # Theme configuration
│   ├── widgets/          # Reusable components
│   └── main.dart         # Application entry point
├── assets/               # Static assets (images, etc.)
├── web/                  # Web-specific files
├── android/              # Android platform code
├── ios/                  # iOS platform code
└── pubspec.yaml          # Dependencies
```

### Features
- **Multi-platform Social Media Management:** Manage multiple social accounts
- **Content Scheduling:** Plan and schedule posts with calendar view
- **AI-Powered Suggestions:** Get content recommendations
- **Analytics Dashboard:** Track performance metrics with charts
- **Message Inbox:** Unified messaging across platforms
- **User Profile:** Manage account settings and team members
- **Responsive Design:** Adapts to different screen sizes

## Replit Configuration

### Workflow
The application runs a single workflow:
- **Name:** Flutter Web Server
- **Command:** `flutter run -d web-server --web-hostname=0.0.0.0 --web-port=5000`
- **Port:** 5000 (webview output)
- **Type:** Frontend development server

### Environment Configuration
The project includes an `env.json` file with placeholder API keys for:
- Supabase (URL and Anon Key)
- OpenAI API Key
- Gemini API Key
- Anthropic API Key
- Perplexity API Key

**Note:** These are placeholder values and should be updated with real credentials when integrating external services.

### Development Workflow
1. Dependencies are managed via `flutter pub get`
2. Web support is enabled via `flutter config --enable-web`
3. The app runs on port 5000 with hostname 0.0.0.0 for Replit proxy compatibility
4. Hot reload is available by pressing "r" in the console

## Recent Changes

### October 27, 2025 - Initial Replit Setup
- Enabled Flutter web support
- Configured workflow to run on port 5000 with 0.0.0.0 binding
- Updated .gitignore to include web folder (removed /web/ exclusion)
- Installed all Flutter dependencies
- Set up development environment for Replit

## Architecture Decisions

### Why Flutter Web?
- The project was originally a mobile app but includes web support dependency
- Flutter web allows running the app in Replit's browser-based environment
- Enables quick preview and iteration without mobile device emulators

### Port Configuration
- Port 5000 is used because it's the only non-firewalled port in Replit
- Hostname 0.0.0.0 allows Replit's proxy to forward traffic correctly

### Theme System
- Dual theme support (light/dark mode)
- Google Fonts for typography instead of local fonts
- Material Design components
- Responsive sizing with Sizer package

## User Preferences
None documented yet. Will be updated as preferences are expressed.

## Known Limitations
- The app is designed primarily for mobile but runs in web mode on Replit
- Some mobile-specific features (camera, permissions) may have limited web support
- API keys in env.json are placeholders and need to be replaced for full functionality

## Next Steps
- Set up deployment configuration
- Replace placeholder API keys with real credentials when needed
- Test all features in web environment
- Consider adding authentication integration
