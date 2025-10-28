import 'package:flutter_test/flutter_test.dart';
import 'package:ai_social_hub_2838/config/env_config.dart';
import 'package:ai_social_hub_2838/services/ayrshare_service.dart';
import 'package:ai_social_hub_2838/services/supabase_service.dart';

/// API Connection Tests
/// 
/// Run with: flutter test test/api_test.dart
void main() {
  group('Environment Configuration', () {
    test('Should have all required environment variables', () {
      expect(EnvConfig.supabaseUrl, isNotEmpty);
      expect(EnvConfig.supabaseAnonKey, isNotEmpty);
      expect(EnvConfig.ayrshareApiKey, isNotEmpty);
      expect(EnvConfig.stripePublishableKey, isNotEmpty);
    });

    test('Should validate configuration status', () {
      expect(EnvConfig.isConfigured, isTrue);
      expect(EnvConfig.missingConfigs, isEmpty);
    });
  });

  group('Supabase Service', () {
    test('Should initialize Supabase client', () async {
      await SupabaseService.initialize();
      expect(SupabaseService.instance, isNotNull);
      expect(SupabaseService.instance.client, isNotNull);
    });

    test('Should have correct Supabase URL', () {
      expect(
        EnvConfig.supabaseUrl.startsWith('https://'),
        isTrue,
        reason: 'Supabase URL should start with https://',
      );
    });
  });

  group('Ayrshare Service', () {
    test('Should initialize Ayrshare service', () {
      final service = AyrshareService.instance;
      expect(service, isNotNull);
    });

    test('Should have valid API key format', () {
      expect(
        EnvConfig.ayrshareApiKey.isNotEmpty,
        isTrue,
        reason: 'Ayrshare API key should not be empty',
      );
    });

    test('Should construct correct API URLs', () {
      expect(
        EnvConfig.ayrshareBaseUrl.startsWith('https://'),
        isTrue,
        reason: 'Ayrshare base URL should start with https://',
      );
    });
  });

  group('Stripe Configuration', () {
    test('Should have valid publishable key format', () {
      expect(
        EnvConfig.stripePublishableKey.startsWith('pk_'),
        isTrue,
        reason: 'Stripe publishable key should start with pk_',
      );
    });
  });
}

