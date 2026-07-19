/// Production environment configuration
/// This file contains production API endpoints and feature flags
class ProductionConfig {
  ProductionConfig._();

  // API Endpoints (placeholder - replace with actual endpoints)
  static const String apiBaseUrl = 'https://api.mindy.app/v1';
  static const String sttApiUrl = 'https://api.mindy.app/v1/stt';
  static const String ttsApiUrl = 'https://api.mindy.app/v1/tts';
  static const String llmApiUrl = 'https://api.mindy.app/v1/llm';

  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enableVoicePipeline = true;
  static const bool enableWakeWordDetection = true;

  // Rate Limits
  static const int maxVoiceCallMinutes = 180;
  static const int wellbeingCheckpointMinutes = 45;

  // Subscription
  static const double subscriptionPrice = 3.99;
  static const String currency = 'EUR';

  // Storage Keys (must match app_constants.dart)
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyUserProfile = 'user_profile';
  static const String keyConsentGiven = 'consent_given';
  static const String keySubscriptionStatus = 'subscription_status';
  static const String keyDisclaimerAcknowledged = 'disclaimer_acknowledged';
}

/// Environment selector
enum AppEnvironment { development, staging, production }

class EnvironmentConfig {
  static AppEnvironment current = AppEnvironment.production;

  static String get apiBaseUrl {
    switch (current) {
      case AppEnvironment.development:
        return 'https://dev-api.mindy.app/v1';
      case AppEnvironment.staging:
        return 'https://staging-api.mindy.app/v1';
      case AppEnvironment.production:
        return 'https://api.mindy.app/v1';
    }
  }

  static bool get isProduction => current == AppEnvironment.production;
}
