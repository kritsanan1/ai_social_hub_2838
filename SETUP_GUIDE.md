# Contentflow Pro - Setup Guide

Complete step-by-step guide to set up and run Contentflow Pro.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Ayrshare Setup](#ayrshare-setup)
3. [Supabase Setup](#supabase-setup)
4. [Stripe Setup](#stripe-setup)
5. [Application Configuration](#application-configuration)
6. [Running the App](#running-the-app)
7. [Testing](#testing)

---

## Prerequisites

### Required Software

1. **Flutter SDK** (version 3.6.0 or higher)
   ```bash
   # Install Flutter
   # Visit: https://docs.flutter.dev/get-started/install
   
   # Verify installation
   flutter doctor
   ```

2. **Git**
   ```bash
   git --version
   ```

3. **Code Editor** (VS Code or Android Studio recommended)

### Required Accounts

- ✅ Ayrshare Account (https://www.ayrshare.com)
- ✅ Supabase Account (https://supabase.com)
- ✅ Stripe Account (https://stripe.com)

---

## Ayrshare Setup

### Step 1: Create Ayrshare Account

1. Go to https://www.ayrshare.com
2. Sign up for an account
3. Choose a plan (Free plan available for testing)

### Step 2: Get API Key

1. Log in to Ayrshare Dashboard
2. Navigate to **API Dashboard** → **API Key**
3. Copy your API Key
4. Save it securely (you'll need it later)

### Step 3: Understand User Profiles

Ayrshare uses **User Profiles** to manage multiple users/clients:

- **Primary Profile**: Your main account (uses API Key)
- **User Profiles**: Sub-accounts for your users (uses Profile Keys)

The app automatically creates User Profiles for each registered user.

### Step 4: Connect Social Accounts (Optional for Testing)

1. In Ayrshare Dashboard, go to **Social Accounts**
2. Connect at least one social media account (e.g., Facebook, Twitter)
3. This allows you to test posting functionality

---

## Supabase Setup

### Step 1: Create Supabase Project

1. Go to https://supabase.com
2. Sign in and click **New Project**
3. Fill in project details:
   - Project name: `contentflow-pro`
   - Database password: (choose a strong password)
   - Region: (choose closest to your users)
4. Click **Create new project**
5. Wait for project to be provisioned (~2 minutes)

### Step 2: Get Project Credentials

1. In your project dashboard, go to **Settings** → **API**
2. Copy the following:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **Anon/Public Key** (starts with `eyJ...`)

### Step 3: Create Database Tables

1. Go to **SQL Editor** in Supabase Dashboard
2. Click **New Query**
3. Copy and paste the following SQL:

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Profiles Table
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  ayrshare_profile_key TEXT,
  subscription_tier TEXT DEFAULT 'free',
  subscription_expires_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- Posts Table
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  platforms TEXT[] NOT NULL,
  media_urls TEXT[],
  schedule_date TIMESTAMP WITH TIME ZONE,
  status TEXT DEFAULT 'draft',
  platform_specific_content JSONB,
  social_post_ids JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Enable Row Level Security
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Posts policies
CREATE POLICY "Users can view own posts"
  ON posts FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own posts"
  ON posts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own posts"
  ON posts FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own posts"
  ON posts FOR DELETE
  USING (auth.uid() = user_id);

-- Social Accounts Table
CREATE TABLE social_accounts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  platform TEXT NOT NULL,
  account_name TEXT,
  account_id TEXT,
  is_connected BOOLEAN DEFAULT true,
  connected_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, platform)
);

-- Enable Row Level Security
ALTER TABLE social_accounts ENABLE ROW LEVEL SECURITY;

-- Social accounts policies
CREATE POLICY "Users can view own social accounts"
  ON social_accounts FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own social accounts"
  ON social_accounts FOR ALL
  USING (auth.uid() = user_id);

-- Subscriptions Table
CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  tier TEXT NOT NULL,
  stripe_customer_id TEXT,
  stripe_subscription_id TEXT,
  status TEXT DEFAULT 'active',
  current_period_start TIMESTAMP WITH TIME ZONE,
  current_period_end TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Enable Row Level Security
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

-- Subscriptions policies
CREATE POLICY "Users can view own subscription"
  ON subscriptions FOR SELECT
  USING (auth.uid() = user_id);

-- Post Analytics Table
CREATE TABLE post_analytics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  platform TEXT NOT NULL,
  impressions INTEGER DEFAULT 0,
  likes INTEGER DEFAULT 0,
  comments INTEGER DEFAULT 0,
  shares INTEGER DEFAULT 0,
  clicks INTEGER DEFAULT 0,
  fetched_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(post_id, platform)
);

-- Enable Row Level Security
ALTER TABLE post_analytics ENABLE ROW LEVEL SECURITY;

-- Analytics policies
CREATE POLICY "Users can view analytics for own posts"
  ON post_analytics FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM posts
      WHERE posts.id = post_analytics.post_id
      AND posts.user_id = auth.uid()
    )
  );

-- Create function to handle new user signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, email, full_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'avatar_url'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for new user signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
```

4. Click **Run** to execute the SQL
5. Verify tables are created in **Table Editor**

### Step 4: Configure Authentication

1. Go to **Authentication** → **Providers**
2. Enable **Email** provider (enabled by default)
3. (Optional) Enable **Google** OAuth:
   - Toggle Google provider
   - Add Google OAuth credentials
   - Configure redirect URLs

---

## Stripe Setup

### Step 1: Create Stripe Account

1. Go to https://stripe.com
2. Sign up for an account
3. Complete business verification (can skip for testing)

### Step 2: Get API Keys

1. Go to **Developers** → **API Keys**
2. Toggle **Test mode** (top right)
3. Copy **Publishable key** (starts with `pk_test_...`)
4. Save it securely

### Step 3: Create Products and Prices

1. Go to **Products** → **Add Product**
2. Create three products:

**Free Plan**
- Name: Free
- Price: $0/month
- Billing: Recurring monthly

**Pro Plan**
- Name: Pro
- Price: $29.99/month
- Billing: Recurring monthly

**Enterprise Plan**
- Name: Enterprise
- Price: $99.99/month
- Billing: Recurring monthly

3. Copy Price IDs for each plan (you'll need them later)

### Step 4: Configure Webhooks (Optional)

1. Go to **Developers** → **Webhooks**
2. Add endpoint: `https://your-app-url.com/stripe-webhook`
3. Select events:
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`

---

## Application Configuration

### Step 1: Clone Repository

```bash
git clone https://github.com/kritsanan1/ai_social_hub_2838.git
cd ai_social_hub_2838
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Configure Environment Variables

Open `lib/config/env_config.dart` and update with your credentials:

```dart
class EnvConfig {
  // Supabase Configuration
  static const String supabaseUrl = 'https://xxxxx.supabase.co'; // Your Supabase URL
  static const String supabaseAnonKey = 'eyJ...'; // Your Supabase Anon Key

  // Ayrshare API Configuration
  static const String ayrshareApiKey = 'YOUR_AYRSHARE_API_KEY'; // Your Ayrshare API Key
  static const String ayrshareBaseUrl = 'https://api.ayrshare.com/api';

  // Stripe Configuration
  static const String stripePublishableKey = 'pk_test_...'; // Your Stripe Publishable Key

  // App Configuration
  static const String appName = 'Contentflow Pro';
  static const String appVersion = '1.0.0';
}
```

### Step 4: Verify Configuration

Run the app to check if configuration is correct:

```bash
flutter run
```

If configuration is missing, you'll see an error screen with missing variables.

---

## Running the App

### Development Mode

```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter devices  # List devices
flutter run -d <device-id>

# Run with hot reload
# Press 'r' to hot reload
# Press 'R' to hot restart
```

### Debug Mode

```bash
flutter run --debug
```

### Release Mode

```bash
# Android
flutter run --release

# iOS
flutter run --release --no-codesign
```

---

## Testing

### Test Accounts

Create test accounts for different scenarios:

1. **Free User**
   - Email: `free@test.com`
   - Password: `test123456`

2. **Pro User**
   - Email: `pro@test.com`
   - Password: `test123456`

3. **Enterprise User**
   - Email: `enterprise@test.com`
   - Password: `test123456`

### Test Posting

1. Log in to the app
2. Go to **Connect Socials**
3. Connect a test social account (use Ayrshare dashboard)
4. Go to **Upload Posts**
5. Create a test post
6. Select platforms
7. Click **Post Now** or **Schedule**

### Test Subscription

1. Log in to the app
2. Go to **Subscription**
3. Select a plan
4. Use Stripe test card:
   - Card: `4242 4242 4242 4242`
   - Expiry: Any future date
   - CVC: Any 3 digits
   - ZIP: Any 5 digits

---

## Troubleshooting

### Common Issues

**1. "Supabase not initialized" error**
- Check if Supabase URL and key are correct
- Verify internet connection
- Check Supabase project status

**2. "Ayrshare API Error" messages**
- Verify API key is correct
- Check if social accounts are connected in Ayrshare dashboard
- Review Ayrshare API limits

**3. "User profile not found" error**
- Check if database tables are created
- Verify Row Level Security policies
- Check if trigger function is working

**4. App crashes on startup**
- Run `flutter clean`
- Run `flutter pub get`
- Restart IDE/editor

**5. Hot reload not working**
- Press 'R' for hot restart
- Stop and restart the app

### Debug Commands

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Check for issues
flutter doctor

# Analyze code
flutter analyze

# Run tests
flutter test

# View logs
flutter logs
```

---

## Next Steps

1. ✅ Configure all API keys
2. ✅ Test authentication flow
3. ✅ Connect social media accounts
4. ✅ Test posting functionality
5. ✅ Test subscription flow
6. ✅ Customize branding and theme
7. ✅ Deploy to production

---

## Support

Need help? Check these resources:

- **Documentation**: [CONTENTFLOW_PRO_README.md](./CONTENTFLOW_PRO_README.md)
- **Ayrshare Docs**: https://www.ayrshare.com/docs
- **Supabase Docs**: https://supabase.com/docs
- **Flutter Docs**: https://docs.flutter.dev
- **GitHub Issues**: https://github.com/kritsanan1/ai_social_hub_2838/issues

---

Happy coding! 🚀

