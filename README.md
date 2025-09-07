# Gamified Tax Deduction App

## Quick Setup Instructions

### Prerequisites
- Flutter 3.24.4 or later
- Dart SDK 3.0.0 or later

### Installation
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter test` to verify setup
4. Run `flutter run` to start the app

### Project Structure
- `lib/` - Main Flutter source code
  - `core/` - Business logic, data models, services
  - `features/` - Feature-specific UI screens
  - `shared/` - Shared widgets and utilities
- `test/` - Unit and widget tests
- `integration_test/` - Integration tests
- `android/` & `ios/` - Platform-specific configurations

### Key Features
- Receipt scanning with camera
- OCR text recognition for expense amounts
- Local SQLite database storage
- Tax savings calculation
- Gamification with progress tracking
- Privacy-first local-only architecture

For detailed documentation, see the `docs/` folder.