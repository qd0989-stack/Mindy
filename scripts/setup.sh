#!/bin/bash

# Mindy App Setup Script

set -e

echo "🚀 Setting up Mindy App..."

# Check for Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter first."
    echo "   https://docs.flutter.dev/get-started/install"
    exit 1
fi

# Check Flutter version
echo "📦 Flutter version: $(flutter --version)"

# Get dependencies
echo "📥 Installing dependencies..."
flutter pub get

# Analyze code
echo "🔍 Analyzing code..."
flutter analyze

# Run tests
echo "🧪 Running tests..."
flutter test || echo "⚠️ Some tests may have failed"

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Run the app: flutter run"
echo "  2. Build for Android: flutter build apk --release"
echo "  3. Build for iOS: flutter build ios --release"
echo "  4. Build for Web: flutter build web --release"
