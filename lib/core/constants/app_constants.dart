/// App-wide constants for Mindy wellness companion
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Mindy';
  static const String appVersion = '1.0.0';

  // Wake Word
  static const String wakeWord = 'Hey Mindy';

  // Pricing
  static const double subscriptionPrice = 3.99; // EUR
  static const String currency = 'EUR';

  // Session Limits
  static const int maxCallDurationMinutes = 180; // 3 hours
  static const int wellbeingCheckpointIntervalMinutes = 45;
  static const int sessionContextWindowMessages = 10;

  // Free Tier Limits
  static const int freeTierDailyChats = 5;
  static const int freeTierMaxCallMinutes = 5;

  // GDPR - Minimum age for consent varies by EU country (13-16)
  // This is a fallback default - legal counsel should confirm per country
  static const int defaultMinConsentAge = 16;
  static const int legalAdulthoodAge = 18;

  // Crisis Detection - Thresholds
  static const double crisisRiskThreshold = 0.7;
  static const int crisisKeywordMatchCount = 2;

  // Storage Keys
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyUserProfile = 'user_profile';
  static const String keyConsentGiven = 'consent_given';
  static const String keySubscriptionStatus = 'subscription_status';
  static const String keyDisclaimerAcknowledged = 'disclaimer_acknowledged';

  // Disclaimer Text
  static const String disclaimerText =
      'Mindy is a wellness support tool. It doesn\'t replace a licensed '
      'therapist, doctor, or emergency services. If you\'re in crisis, '
      'please contact emergency services (112 in EU) or a crisis helpline.';

  // Crisis Resources (EU-focused)
  static const String euEmergencyNumber = '112';
  static const String befriendersWorldwide = 'https://www.befrienders.org';
  static const String findAHelpline = 'https://findahelpline.com';
}
