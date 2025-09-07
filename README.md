# Gamified Tax Deduction Tracker

A privacy-first, local-only mobile application that gamifies the process of tracking tax-deductible expenses. Scan receipts, learn about deductions, and build healthy financial habits through achievement-based progress tracking.

## 🎯 Vision

Empower individuals to take control of their financial wellbeing by making tax deduction tracking as engaging as their favorite mobile games, while maintaining complete privacy and data ownership.

## ✨ Key Features

- **Receipt Scanning**: Use your camera to quickly capture and process receipts with on-device OCR
- **Tax Savings Calculator**: Get instant feedback on potential tax savings from each expense
- **Achievement System**: Unlock rewards for consistent expense tracking and financial milestones
- **Educational Tooltips**: Learn about tax deductions contextually while using the app
- **Complete Privacy**: All data stays on your device - no cloud storage, no tracking, no ads

## 🏗️ Architecture

This app uses a dual-native approach with local-first, privacy-centric design:

- **iOS**: Swift, SwiftUI, XCTest
- **Android**: Kotlin, Jetpack Compose, JUnit
- **Data Storage**: Local SQLite with lightweight wrappers (GRDB.swift / Room)
- **OCR**: Native frameworks (Apple Vision / Google ML Kit)

## 📱 Supported Platforms

- iOS 15.0+
- Android API 24+ (Android 7.0)

## 🚀 Quick Start

### iOS Development Setup

1. **Prerequisites**:
   - macOS with Xcode 13.0+
   - iOS Simulator or physical iOS device

2. **Setup**:
   ```bash
   git clone https://github.com/cmwen/gamify-tax-deduction.git
   cd gamify-tax-deduction/src/platform/ios
   open GamifiedTaxDeduction.xcodeproj
   ```

3. **Run the app**:
   - Select your target device/simulator
   - Press Cmd+R to build and run

### Android Development Setup

1. **Prerequisites**:
   - Android Studio Arctic Fox+
   - Android SDK 24+
   - Java 11+

2. **Setup**:
   ```bash
   git clone https://github.com/cmwen/gamify-tax-deduction.git
   cd gamify-tax-deduction/src/platform/android
   # Open the project in Android Studio
   ```

3. **Run the app**:
   - Sync the project with Gradle files
   - Select your target device/emulator
   - Click the Run button

## 🧪 Testing

### iOS Tests
```bash
cd src/platform/ios
xcodebuild test -scheme GamifiedTaxDeduction -destination 'platform=iOS Simulator,name=iPhone 14'
```

### Android Tests
```bash
cd src/platform/android
./gradlew test
./gradlew connectedAndroidTest
```

## 🤝 Contributing

We welcome contributions from the community! This project is designed to be beginner-friendly for new open-source contributors.

- 📖 Read our [Contributing Guidelines](CONTRIBUTING.md)
- 🐛 Check out [Good First Issues](https://github.com/cmwen/gamify-tax-deduction/labels/good%20first%20issue)
- 💬 Join discussions in [Issues](https://github.com/cmwen/gamify-tax-deduction/issues)

## 📋 Project Status

This project is in active development. See our [Product Backlog](docs/product_backlog.md) and [Design Document](docs/design.md) for implementation progress.

### Current Phase: MVP Development
- ✅ Project scaffolding and architecture
- 🚧 Core receipt scanning functionality
- 🚧 Basic gamification system
- 📋 Educational content integration
- 📋 Platform-specific implementations

## 📚 Documentation

- [Vision Document](docs/vision.md) - Project goals and target user personas
- [Design Document](docs/design.md) - Technical architecture and UX specifications
- [Product Backlog](docs/product_backlog.md) - Feature roadmap and user stories
- [QA Plan](docs/qa_plan.md) - Testing strategy and quality assurance

## 🔒 Privacy & Security

- **Local-Only**: All data processing happens on your device
- **No Analytics**: We don't track your usage or collect any data
- **Open Source**: Full transparency in our code and practices
- **No Accounts**: No sign-up required, no personal information collected

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

Built with ❤️ by the open-source community. Special thanks to all contributors who help make tax compliance more accessible and engaging.

---

**Questions?** Open an [issue](https://github.com/cmwen/gamify-tax-deduction/issues) or check our [discussions](https://github.com/cmwen/gamify-tax-deduction/discussions).