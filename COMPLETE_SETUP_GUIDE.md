# Complete Setup Guide - Contentflow Pro

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Environment Setup](#environment-setup)
3. [Supabase Configuration](#supabase-configuration)
4. [Ayrshare Configuration](#ayrshare-configuration)
5. [Stripe Configuration](#stripe-configuration)
6. [Running the Application](#running-the-application)
7. [Testing](#testing)
8. [Deployment](#deployment)
9. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software

- **Flutter SDK**: Version 3.6.0 or higher
- **Dart SDK**: Included with Flutter
- **Git**: For version control
- **Android Studio** or **VS Code** with Flutter extensions
- **Xcode** (for iOS development on macOS)

### Install Flutter

```bash
# Download Flutter from https://flutter.dev
# Or use a version manager like fvm

# Verify installation
flutter --version
flutter doctor
```

---

## Environment Setup

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
  static const String supabaseUrl = 'YOUR_SUPABASE_PROJECT_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // Ayrshare API Configuration
  static const String ayrshareApiKey = 'YOUR_AYRSHARE_API_KEY';
  
  // Stripe Configuration
  static const String stripePublishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';
  static const String stripeSecretKey = 'YOUR_STRIPE_SECRET_KEY';
}
```

**Alternatively**, use `--dart-define` for production:

```bash
flutter run \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key \
  --dart-define=AYRSHARE_API_KEY=your_key \
  --dart-define=STRIPE_PUBLISHABLE_KEY=your_key \
  --dart-define=STRIPE_SECRET_KEY=your_key
```

---

## Supabase Configuration

### 1. Create a Supabase Project

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Click "New Project"
3. Fill in project details
4. Copy your project URL and anon key

### 2. Create Database Tables

Run these SQL commands in Supabase SQL Editor:

#### Profiles Table

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Profiles table
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  full_name TEXT,
  avatar_url TEXT,
  ayrshare_profile_key TEXT,
  subscription_tier TEXT DEFAULT 'free',
  subscription_expires_at TIMESTAMP WITH TIME ZONE,
  stripe_customer_id TEXT,
  stripe_subscription_id TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view own profile" 
  ON profiles FOR SELECT 
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" 
  ON profiles FOR UPDATE 
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" 
  ON profiles FOR INSERT 
  WITH CHECK (auth.uid() = id);
```

#### Posts Table

```sql
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  platforms TEXT[] NOT NULL,
  media_urls TEXT[],
  schedule_date TIMESTAMP WITH TIME ZONE,
  status TEXT DEFAULT 'draft',
  platform_specific_content JSONB,
  social_post_ids JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view own posts" 
  ON posts FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own posts" 
  ON posts FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own posts" 
  ON posts FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own posts" 
  ON posts FOR DELETE 
  USING (auth.uid() = user_id);

-- Indexes
CREATE INDEX posts_user_id_idx ON posts(user_id);
CREATE INDEX posts_schedule_date_idx ON posts(schedule_date);
CREATE INDEX posts_status_idx ON posts(status);
```

#### Social Accounts Table

```sql
CREATE TABLE social_accounts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  platform TEXT NOT NULL,
  account_name TEXT,
  account_id TEXT,
  is_connected BOOLEAN DEFAULT true,
  connected_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, platform)
);

-- Enable RLS
ALTER TABLE social_accounts ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view own accounts" 
  ON social_accounts FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own accounts" 
  ON social_accounts FOR ALL 
  USING (auth.uid() = user_id);
```

#### Subscriptions Table

```sql
CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL UNIQUE,
  tier TEXT NOT NULL,
  stripe_customer_id TEXT,
  stripe_subscription_id TEXT,
  status TEXT DEFAULT 'active',
  current_period_start TIMESTAMP WITH TIME ZONE,
  current_period_end TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view own subscription" 
  ON subscriptions FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own subscription" 
  ON subscriptions FOR UPDATE 
  USING (auth.uid() = user_id);
```

#### Post Analytics Table (Optional)

```sql
CREATE TABLE post_analytics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  platform TEXT NOT NULL,
  likes INTEGER DEFAULT 0,
  comments INTEGER DEFAULT 0,
  shares INTEGER DEFAULT 0,
  impressions INTEGER DEFAULT 0,
  reach INTEGER DEFAULT 0,
  engagement_rate DECIMAL(5,2),
  fetched_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(post_id, platform)
);

-- Enable RLS
ALTER TABLE post_analytics ENABLE ROW LEVEL SECURITY;

-- Policy
CREATE POLICY "Users can view own analytics" 
  ON post_analytics FOR SELECT 
  USING (auth.uid() = user_id);
```

### 3. Enable Authentication Providers

1. Go to Authentication → Providers
2. Enable Email/Password
3. (Optional) Enable Google OAuth:
   - Add Google Client ID and Secret
   - Set redirect URL: `io.supabase.flutterquickstart://login-callback/`

### 4. Create Auto-Profile Trigger

```sql
-- Function to create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'avatar_url'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

---

## Ayrshare Configuration

### 1. Sign Up for Ayrshare

1. Go to [Ayrshare](https://www.ayrshare.com/)
2. Create an account
3. Choose a plan (Free, Premium, or Business)

### 2. Get API Key

1. Go to Dashboard → API Keys
2. Copy your API Key
3. Add to `env_config.dart`

### 3. Create User Profiles

Ayrshare uses "profiles" for multi-user support. The app automatically creates a profile for each user on signup.

### 4. Connect Social Accounts

Users need to connect their social media accounts through Ayrshare:

1. Go to Ayrshare Dashboard
2. Navigate to Social Accounts
3. Connect desired platforms
4. Note: Each platform requires OAuth authorization

### 5. Platform-Specific Requirements

**Instagram**:
- Requires Business/Creator account
- Must be linked to Facebook Page

**TikTok**:
- Requires Business account
- Content must follow TikTok guidelines

**LinkedIn**:
- Personal or Company page
- May require additional permissions

**Twitter/X**:
- Standard account
- API access required for advanced features

---

## Stripe Configuration

### 1. Create Stripe Account

1. Go to [Stripe](https://stripe.com)
2. Sign up for an account
3. Complete verification

### 2. Get API Keys

1. Go to Developers → API Keys
2. Copy:
   - Publishable Key (starts with `pk_`)
   - Secret Key (starts with `sk_`)
3. Use Test keys for development

### 3. Create Products and Prices

#### Pro Plan ($29.99/month)

```bash
# Using Stripe CLI
stripe products create \
  --name="Contentflow Pro - Pro Plan" \
  --description="100 posts per month"

stripe prices create \
  --product=prod_xxx \
  --unit-amount=2999 \
  --currency=usd \
  --recurring[interval]=month
```

Copy the Price ID (starts with `price_`) and update `lib/services/stripe_service.dart`:

```dart
static const Map<SubscriptionTier, String> _priceIds = {
  SubscriptionTier.free: '',
  SubscriptionTier.pro: 'price_1234567890', // Replace with your Price ID
  SubscriptionTier.enterprise: 'price_0987654321', // Replace with your Price ID
};
```

#### Enterprise Plan ($99.99/month)

```bash
stripe products create \
  --name="Contentflow Pro - Enterprise Plan" \
  --description="Unlimited posts"

stripe prices create \
  --product=prod_xxx \
  --unit-amount=9999 \
  --currency=usd \
  --recurring[interval]=month
```

### 4. Set Up Webhooks (Optional)

1. Go to Developers → Webhooks
2. Add endpoint: `https://yourdomain.com/api/stripe-webhook`
3. Select events:
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`
4. Copy webhook signing secret

### 5. Enable Customer Portal

1. Go to Settings → Customer Portal
2. Enable portal
3. Configure portal settings
4. This allows customers to manage their subscriptions

---

## Running the Application

### Development

```bash
# Run on connected device/emulator
flutter run

# Run in debug mode with verbose logging
flutter run --debug --verbose

# Run with environment variables
flutter run \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key \
  --dart-define=AYRSHARE_API_KEY=your_key \
  --dart-define=STRIPE_PUBLISHABLE_KEY=your_key \
  --dart-define=STRIPE_SECRET_KEY=your_key
```

### Hot Reload

Press `r` in the terminal to hot reload changes.

Press `R` to hot restart the app.

### Specific Platform

```bash
# Android
flutter run -d android

# iOS (macOS only)
flutter run -d ios

# Web
flutter run -d chrome

# Desktop
flutter run -d windows  # Windows
flutter run -d macos    # macOS
flutter run -d linux    # Linux
```

---

## Testing

### Run Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage
```

### Integration Tests

```bash
# Run integration tests
flutter test integration_test
```

### Manual Testing Checklist

- [ ] User can sign up with email/password
- [ ] User can log in with email/password
- [ ] User can log in with Google (if configured)
- [ ] User profile is created automatically
- [ ] User can create a post
- [ ] User can schedule a post
- [ ] User can view posts in calendar
- [ ] User can connect social accounts
- [ ] User can view subscription details
- [ ] User can upgrade subscription
- [ ] User can manage billing
- [ ] User can log out

---

## Deployment

### Android

#### 1. Configure Signing

Create `android/key.properties`:

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=<your-key-alias>
storeFile=<path-to-keystore-file>
```

#### 2. Build APK

```bash
flutter build apk --release
```

Find APK at: `build/app/outputs/flutter-apk/app-release.apk`

#### 3. Build App Bundle (for Google Play)

```bash
flutter build appbundle --release
```

Find AAB at: `build/app/outputs/bundle/release/app-release.aab`

### iOS

#### 1. Configure Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select your team in Signing & Capabilities
3. Configure Bundle Identifier

#### 2. Build IPA

```bash
flutter build ios --release
```

#### 3. Archive and Upload

1. Open in Xcode
2. Product → Archive
3. Upload to App Store Connect

### Web

```bash
# Build for web
flutter build web --release

# Deploy to hosting
# Copy contents of build/web to your hosting provider
```

### Environment-Specific Builds

```bash
# Production build with environment variables
flutter build apk --release \
  --dart-define=SUPABASE_URL=prod_url \
  --dart-define=SUPABASE_ANON_KEY=prod_key \
  --dart-define=AYRSHARE_API_KEY=prod_key \
  --dart-define=STRIPE_PUBLISHABLE_KEY=prod_key \
  --dart-define=STRIPE_SECRET_KEY=prod_key
```

---

## Troubleshooting

### Common Issues

#### "Supabase not initialized"

**Solution**: Ensure Supabase credentials are correct in `env_config.dart`

#### "Ayrshare API Error"

**Solution**: 
- Check API key is valid
- Verify profile key is set
- Check platform-specific requirements

#### "Stripe Payment Failed"

**Solution**:
- Use test card numbers in development: `4242 4242 4242 4242`
- Check Price IDs are correct
- Verify webhook endpoint if using webhooks

#### "Google Sign-In Not Working"

**Solution**:
- Configure OAuth in Supabase
- Add Google Client ID/Secret
- Configure redirect URLs

#### Build Errors

```bash
# Clean build
flutter clean
flutter pub get
flutter build apk
```

### Getting Help

- **Documentation**: See `CONTENTFLOW_PRO_README.md`
- **API Docs**: 
  - [Ayrshare Docs](https://docs.ayrshare.com)
  - [Supabase Docs](https://supabase.com/docs)
  - [Stripe Docs](https://stripe.com/docs)
- **GitHub Issues**: Report bugs on GitHub

---

## Next Steps

1. **Customize Branding**: Update app name, logo, and colors in `lib/theme/app_theme.dart`
2. **Add Features**: Implement additional features like analytics dashboard
3. **Performance**: Optimize images and lazy load content
4. **Security**: Review and update RLS policies
5. **Testing**: Write more unit and integration tests
6. **Monitoring**: Set up error tracking (Sentry, Firebase Crashlytics)

---

## Production Checklist

- [ ] All API keys configured
- [ ] Database tables created with RLS
- [ ] Authentication providers enabled
- [ ] Social accounts connected in Ayrshare
- [ ] Stripe products and prices created
- [ ] Webhooks configured
- [ ] App signing configured
- [ ] Privacy policy and terms of service added
- [ ] Error tracking set up
- [ ] Analytics configured
- [ ] App store listings prepared
- [ ] Beta testing completed

---

## Support

For support and questions:
- **Email**: support@contentflowpro.com
- **Documentation**: https://docs.contentflowpro.com
- **GitHub**: https://github.com/kritsanan1/ai_social_hub_2838

---

**Built with ❤️ using Flutter, Riverpod, Supabase, Ayrshare, and Stripe**
