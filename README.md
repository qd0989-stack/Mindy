# ✨ Mindy - Voice-Activated Psychological Wellness Companion

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-blue?style=for-the-badge" alt="Platforms">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License">
</p>

Mindy is a voice-activated psychological wellness companion app built with Flutter. It provides a safe, supportive space for users to talk through challenges, track their mental wellness journey, and access evidence-based coping strategies.

> ⚠️ **Important**: Mindy is a wellness support tool. It doesn't replace a licensed therapist, doctor, or emergency services.

## 🌟 Features

### Safety & Ethics
- Real-time crisis detection (self-harm, suicide, abuse, harm-to-others)
- Calibrated escalation with localized crisis resources
- Persistent disclaimer at first launch and every long call
- No clinical claims (never uses "therapist", "psychologist", "diagnose", etc.)
- Anti-dark-pattern design (no guilt notifications, no engagement streaks)

### User Experience
- **Account Type Selection**: Adult (20+) or Teen (under 20)
- **Guardian Consent Flow**: For users under 18 (GDPR Art. 8)
- **Trusted Adult Contact**: Optional contact for teen crisis escalation
- **Personalized Memory**: Remembers recurring themes, goals, and what's worked before

### Voice Calling ("Call Mindy")
- Voice sessions up to 3 hours with rolling context summarization
- Wellbeing checkpoint every 45-60 minutes
- Session pause/resume functionality
- Crisis detection runs the entire call

### Data Privacy & Compliance
- GDPR "special category" data handling
- Explicit granular consent
- Encryption at rest (flutter_secure_storage)
- Data export (GDPR right to portability)
- Account deletion (GDPR right to erasure)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.x or later
- Android Studio / Xcode (for mobile builds)
- Git

### Installation

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/mindy.git
cd mindy

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Building

```bash
# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release

# Build for Web
flutter build web --release
```

## 📁 Project Structure

```
mindy/
├── lib/
│   ├── core/              # App-wide configuration
│   │   ├── config/        # Production environment config
│   │   ├── constants/     # App constants, disclaimer text
│   │   ├── di/           # Dependency injection (get_it)
│   │   ├── router/       # GoRouter navigation
│   │   └── theme/        # Wellness-focused Material Design 3 theme
│   ├── domain/
│   │   └── entities/     # User, Session, Memory, CrisisDetection, Consent
│   ├── presentation/
│   │   ├── blocs/        # State management (flutter_bloc)
│   │   ├── screens/     # 9 screens (Splash, Onboarding, Home, Voice Call, etc.)
│   │   └── widgets/      # Reusable widgets
│   ├── services/         # External services
│   │   ├── crisis_detection_service.dart
│   │   ├── personalization_engine.dart
│   │   ├── storage_service.dart
│   │   └── voice_pipeline_service.dart
│   └── main.dart
├── android/              # Android configuration
├── ios/                  # iOS configuration
└── web/                  # Web configuration
```

## 🔧 Configuration

### Voice Services (Production)

Replace placeholder API endpoints in `lib/core/config/production_config.dart`:

```dart
static const String sttApiUrl = 'https://your-stt-provider.com';
static const String ttsApiUrl = 'https://your-tts-provider.com';
static const String llmApiUrl = 'https://your-llm-provider.com';
```

### Recommended Providers

- **Speech-to-Text**: Deepgram, Whisper (OpenAI)
- **Text-to-Speech**: ElevenLabs, Google Cloud TTS
- **LLM**: Anthropic Claude, OpenAI GPT-4
- **Wake Word**: Picovoice Porcupine

## 📱 Screenshots

| Home | Voice Call | Onboarding |
|------|-----------|------------|
| ![Home](docs/screenshots/home.png) | ![Voice Call](docs/screenshots/voice-call.png) | ![Onboarding](docs/screenshots/onboarding.png) |

## ⚖️ Legal Notes

> 🔴 **Requires Legal Review Before Launch**:
> 
> - Minor consent age varies 13-16 by EU member state
> - MDR (Medical Device Regulation) applicability review needed
> - Mandatory reporting obligations for crisis flow
> - Teen crisis escalation with trusted adults

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Evidence-based therapy frameworks: CBT, ACT, DBT, Motivational Interviewing
- Crisis resource aggregators: Befrienders Worldwide, findahelpline.com

---

*Built with ❤️ for mental wellness*

