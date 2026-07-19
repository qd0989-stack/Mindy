# OpenCode Relay Prompt - Mindy App

## What Was Built

I've built the **core structure** of the Mindy Flutter app - a voice-activated psychological wellness companion. Here's what exists:

### Completed Features:

1. **Onboarding Flow** (`lib/screens/onboarding_screen.dart`)
   - Adult/Teen account selection
   - Age verification with minor consent flow
   - Communication style preference (direct/gentle/balanced)
   - Stressor selection
   - Trusted adult contact for minors (GDPR compliance)
   - Disclaimer acceptance

2. **Home Screen** (`lib/screens/home_screen.dart`)
   - Animated microphone button with pulse effect
   - Wake word indicator ("Hey Mindy")
   - Quick action buttons (Chat, History, Tips)
   - Time-based greeting
   - Settings access

3. **Chat Interface** (`lib/screens/chat_screen.dart`)
   - Real-time crisis detection (5-level system)
   - Contextual responses based on user input
   - Crisis alert banner with resources
   - Communication style adaptation
   - Disclaimer access

4. **Voice Call Screen** (`lib/screens/voice_call_screen.dart`)
   - Call timer
   - Wellbeing checkpoint prompts every 45 minutes
   - Transcript view
   - Mute/Speaker controls
   - End call functionality

5. **Settings Screen** (`lib/screens/settings_screen.dart`)
   - Profile management
   - Communication style settings
   - Privacy controls
   - Data export/delete
   - About section

6. **Crisis Detection Service** (`lib/services/crisis_service.dart`)
   - Multi-language keyword detection (EN/DE/FR/ES/IT)
   - 5 crisis levels: none, elevated, moderate, high, immediate
   - Localized crisis resources
   - EU emergency number (112)

7. **Theme** (`lib/theme/`)
   - Dark theme with purple/cyan gradient
   - AppColors and AppTheme configuration

### Landing Page
Updated `web/index.html` with:
- Mobile app preview mockup
- App Store/Google Play badges (Coming Soon)
- Feature highlights
- Disclaimer

---

## What Needs To Be Done

### CRITICAL - REQUIRES LEGAL REVIEW BEFORE PROCEEDING:

1. **Minor Consent Flow (GDPR Art. 8)**
   - Exact consent age varies 13-16 across EU member states
   - Needs legal counsel to determine correct age per country

2. **MDR (Medical Device Regulation) Assessment**
   - EU MDR may classify mental health apps
   - Legal review required to determine if Class I/IIa medical device

3. **Mandatory Reporting Obligations**
   - Crisis escalation for minors
   - Teen trusted adult notification flow
   - Varies by jurisdiction

4. **Clinical Governance**
   - Advisory relationship with licensed psychologist required
   - Review intake flow, crisis protocol, teen safeguards

### Technical Tasks Remaining:

1. **Voice Pipeline Integration**
   - On-device wake word detection (Porcupine/Picovoice)
   - STT integration (Deepgram/Whisper)
   - TTS integration (ElevenLabs)
   - LLM integration (Anthropic API)

2. **Backend Services**
   - Session/state management service
   - Encrypted user profile storage
   - Summarization service for long-call memory compaction
   - Consent management system

3. **Database & Storage**
   - User data encryption at rest
   - EU-region hosting setup
   - Data access/export/delete API endpoints

4. **Mobile Build Configuration**
   - iOS provisioning profiles
   - Android signing keys
   - App Store Connect setup
   - Google Play Console setup

5. **Push Notifications**
   - Firebase Cloud Messaging or equivalent
   - Notification permission flow

6. **In-App Purchases**
   - Apple IAP configuration
   - Google Play Billing
   - Subscription management

7. **Analytics & Monitoring**
   - Crash reporting (Firebase Crashlytics)
   - Usage analytics (GDPR-compliant)
   - Crisis interaction logging

8. **Security Hardening**
   - Certificate pinning
   - Biometric authentication option
   - Session timeout handling

9. **Testing**
   - Unit tests for crisis detection
   - Integration tests for user flows
   - Accessibility testing
   - Security audit

---

## Repository

**GitHub:** https://github.com/qd0989-stack/Mindy

**Live Landing Page:** https://qd0989-stack.github.io/Mindy/

---

## Quick Start

```bash
cd /workspace/project/mindy_app
flutter pub get
flutter run
```

---

## Important Notes

- The app uses simulated responses for now - no actual AI/LLM integration
- Voice calling is simulated - needs actual STT→LLM→TTS pipeline
- All crisis detection is keyword-based - needs refinement
- No actual user data storage yet - just in-memory
- No authentication system yet

---

## Questions to Answer

1. Which EU countries is this targeting first?
2. What's the backend hosting preference? (AWS/GCP/Azure/Firebase)
3. Which LLM provider? (Anthropic/OpenAI/Other)
4. What's the subscription payment processor preference?
5. Is there a budget for clinical advisory services?

---

**⚠️ DO NOT LAUNCH WITHOUT LEGAL REVIEW**
**⚠️ DO NOT CLAIM "THERAPIST" OR "PSYCHOLOGIST"**
**⚠️ CRISIS PROTOCOL MUST BE REVIEWED BY LICENSED PROFESSIONAL**
