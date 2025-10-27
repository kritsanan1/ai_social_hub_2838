# Contentflow Pro - AI Social Media Management

A comprehensive Flutter application for managing social media content across multiple platforms using Ayrshare API, Supabase authentication, and Stripe payments.

## 🚀 Features

### Core Features
- **Multi-Platform Posting**: Post to Facebook, Instagram, Twitter, LinkedIn, TikTok, YouTube, Pinterest, Reddit, Bluesky, Threads, and more
- **Content Calendar**: Visual calendar for scheduling and managing posts
- **Social Messages**: Unified inbox for direct messages across platforms
- **Social Comments**: Manage and respond to comments from all platforms
- **Analytics Dashboard**: Track performance metrics and engagement
- **Media Management**: Upload and organize images and videos

### Advanced Features
- **AI-Powered Suggestions**: Content recommendations and hashtag generation
- **Auto Scheduling**: Optimal posting times based on audience engagement
- **Multi-User Support**: Manage multiple clients or brands
- **Subscription Management**: Flexible pricing tiers with Stripe integration
- **Real-time Notifications**: Webhooks for instant updates

## 📋 Prerequisites

- Flutter SDK (^3.6.0)
- Dart SDK
- Ayrshare API Account
- Supabase Project
- Stripe Account (for payments)

## 🛠️ Installation

### 1. Clone the Repository

```bash
git clone https://github.com/kritsanan1/ai_social_hub_2838.git
cd ai_social_hub_2838
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Environment Variables

Update `lib/config/env_config.dart` with your API keys:

```dart
class EnvConfig {
  // Supabase Configuration
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // Ayrshare API Configuration
  static const String ayrshareApiKey = 'YOUR_AYRSHARE_API_KEY';

  // Stripe Configuration
  static const String stripePublishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';
}
```

### 4. Setup Supabase Database

Create the following tables in your Supabase project:

#### Profiles Table
```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  email TEXT NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  ayrshare_profile_key TEXT,
  subscription_tier TEXT DEFAULT 'free',
  subscription_expires_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP
);
```

#### Posts Table
```sql
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id),
  content TEXT NOT NULL,
  platforms TEXT[] NOT NULL,
  media_urls TEXT[],
  schedule_date TIMESTAMP,
  status TEXT DEFAULT 'draft',
  platform_specific_content JSONB,
  social_post_ids JSONB,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP
);
```

#### Social Accounts Table
```sql
CREATE TABLE social_accounts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id),
  platform TEXT NOT NULL,
  account_name TEXT,
  account_id TEXT,
  is_connected BOOLEAN DEFAULT true,
  connected_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, platform)
);
```

#### Subscriptions Table
```sql
CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id),
  tier TEXT NOT NULL,
  stripe_customer_id TEXT,
  stripe_subscription_id TEXT,
  status TEXT DEFAULT 'active',
  current_period_start TIMESTAMP,
  current_period_end TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP
);
```

### 5. Run the Application

```bash
flutter run
```

## 📱 App Structure

```
lib/
├── config/
│   └── env_config.dart          # Environment configuration
├── core/
│   └── app_export.dart          # Core exports
├── models/
│   ├── user_model.dart          # User data model
│   └── post_model.dart          # Post data model
├── providers/
│   ├── auth_provider.dart       # Authentication state
│   └── post_provider.dart       # Post management state
├── services/
│   ├── supabase_service.dart    # Supabase client
│   └── ayrshare_service.dart    # Ayrshare API wrapper
├── routes/
│   └── app_router.dart          # GoRouter configuration
├── presentation/
│   ├── splash_screen/           # Splash screen
│   ├── login_screen/            # Login/Signup
│   ├── onboarding_flow/         # Onboarding
│   ├── social_media_dashboard/  # Main dashboard
│   ├── content_calendar/        # Calendar view
│   ├── messages_inbox/          # Messages
│   ├── social_comments/         # Comments management
│   ├── post_creation/           # Create posts
│   ├── connect_socials/         # Connect accounts
│   ├── subscription_screen/     # Subscription plans
│   ├── settings_screen/         # App settings
│   └── user_profile/            # User profile
├── widgets/
│   ├── app_sidebar.dart         # Navigation sidebar
│   ├── app_layout.dart          # Base layout
│   └── custom_error_widget.dart # Error handling
├── theme/
│   └── app_theme.dart           # App theme
└── main.dart                    # App entry point
```

## 🎯 Key Technologies

### State Management
- **Flutter Riverpod**: Modern reactive state management
- Separate providers for each feature (auth, posts, calendar, etc.)
- Automatic dependency injection

### Navigation
- **GoRouter**: Declarative routing with deep linking
- Authentication-based redirects
- Named routes for easy navigation

### Backend Services
- **Supabase**: Authentication, database, and real-time subscriptions
- **Ayrshare API**: Social media posting and management
- **Stripe**: Payment processing and subscription management

### UI/UX
- **Sizer**: Responsive design for all screen sizes
- **Material Design 3**: Modern UI components
- **Google Fonts**: Custom typography
- Touch-optimized interactions

## 🔐 Authentication Flow

1. User signs up/logs in via Supabase
2. Ayrshare profile is automatically created
3. Profile key is stored in user profile
4. User can connect social media accounts
5. Posts are published using user's profile key

## 📊 Subscription Tiers

### Free Plan
- 10 posts per month
- All social platforms
- Basic analytics
- **$0/month**

### Pro Plan
- 100 posts per month
- All social platforms
- Advanced analytics
- Priority support
- **$29.99/month**

### Enterprise Plan
- Unlimited posts
- All social platforms
- Advanced analytics
- Priority support
- Custom integrations
- Dedicated account manager
- **$99.99/month**

## 🌐 Supported Social Platforms

- ✅ Facebook
- ✅ Instagram
- ✅ Twitter/X
- ✅ LinkedIn
- ✅ TikTok
- ✅ YouTube
- ✅ Pinterest
- ✅ Reddit
- ✅ Bluesky
- ✅ Threads
- ✅ Telegram
- ✅ Snapchat
- ✅ Google Business Profile

## 🔧 API Integration

### Ayrshare API Endpoints Used

- `POST /post` - Publish posts
- `GET /history` - Get post history
- `POST /analytics/post` - Get post analytics
- `GET /comments` - Get comments
- `POST /comments` - Reply to comments
- `GET /messages` - Get direct messages
- `POST /messages/send` - Send messages
- `POST /profiles/profile` - Create user profile
- `GET /user` - Get user details
- `POST /media/upload` - Upload media

### Supabase Features Used

- **Authentication**: Email/password and OAuth (Google)
- **Database**: PostgreSQL with Row Level Security
- **Real-time**: Subscribe to data changes
- **Storage**: Media file storage (optional)

## 🎨 Customization

### Theme
Update `lib/theme/app_theme.dart` to customize colors, fonts, and styles.

### Branding
Replace logo and assets in `assets/images/` directory.

### Features
Enable/disable features in respective provider files.

## 🚀 Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 📝 Environment Variables

For production, use `--dart-define` to pass environment variables:

```bash
flutter run \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key \
  --dart-define=AYRSHARE_API_KEY=your_key \
  --dart-define=STRIPE_PUBLISHABLE_KEY=your_key
```

## 🐛 Troubleshooting

### Supabase Connection Issues
- Verify URL and API key
- Check Row Level Security policies
- Ensure tables are created correctly

### Ayrshare API Errors
- Verify API key is valid
- Check platform-specific requirements
- Review Ayrshare documentation

### Stripe Payment Issues
- Use test keys in development
- Verify webhook endpoints
- Check subscription status

## 📚 Additional Resources

- [Ayrshare API Documentation](https://www.ayrshare.com/docs)
- [Supabase Documentation](https://supabase.com/docs)
- [Flutter Riverpod Guide](https://riverpod.dev)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Stripe Flutter SDK](https://pub.dev/packages/flutter_stripe)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👥 Support

For support and questions:
- Email: support@contentflowpro.com
- Documentation: https://docs.contentflowpro.com
- GitHub Issues: https://github.com/kritsanan1/ai_social_hub_2838/issues

---

Built with ❤️ using Flutter, Riverpod, Supabase, Ayrshare, and Stripe

