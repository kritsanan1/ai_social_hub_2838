/// Environment Configuration
/// 
/// This file contains all environment variables and API keys
/// Make sure to add your actual keys before running the app
class EnvConfig {
  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_SUPABASE_URL',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );

  // Ayrshare API Configuration
  static const String ayrshareApiKey = String.fromEnvironment(
    'AYRSHARE_API_KEY',
    defaultValue: 'YOUR_AYRSHARE_API_KEY',
  );
  
  static const String ayrshareBaseUrl = 'https://api.ayrshare.com/api';

  // Stripe Configuration
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'YOUR_STRIPE_PUBLISHABLE_KEY',
  );

  // App Configuration
  static const String appName = 'Contentflow Pro';
  static const String appVersion = '1.0.0';

  // Validate if all required environment variables are set
  static bool get isConfigured {
    return supabaseUrl != 'YOUR_SUPABASE_URL' &&
        supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY' &&
        ayrshareApiKey != 'YOUR_AYRSHARE_API_KEY' &&
        stripePublishableKey != 'YOUR_STRIPE_PUBLISHABLE_KEY';
  }

  // Get missing configurations
  static List<String> get missingConfigs {
    final List<String> missing = [];
    if (supabaseUrl == 'YOUR_SUPABASE_URL') missing.add('SUPABASE_URL');
    if (supabaseAnonKey == 'YOUR_SUPABASE_ANON_KEY') {
      missing.add('SUPABASE_ANON_KEY');
    }
    if (ayrshareApiKey == 'YOUR_AYRSHARE_API_KEY') {
      missing.add('AYRSHARE_API_KEY');
    }
    if (stripePublishableKey == 'YOUR_STRIPE_PUBLISHABLE_KEY') {
      missing.add('STRIPE_PUBLISHABLE_KEY');
    }
    return missing;
  }
}

