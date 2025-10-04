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
- 📸 **Receipt Scanning**: Capture receipts using your device camera with OCR text recognition
- 💰 **Tax Savings Calculator**: Instantly see potential tax deductions based on your income profile
- 🏆 **Achievement System**: Unlock 13+ achievements as you track your expenses
- 💡 **Educational Tips**: Learn about tax deductions with contextual educational content
- 📊 **Progress Tracking**: Visual progress bars and milestones to keep you motivated
- 🔒 **Privacy-First**: All data stored locally on your device using SQLite
- 🎨 **Beautiful UI**: Material Design 3 with smooth animations and intuitive navigation
- 📱 **Cross-Platform**: Works on both iOS and Android devices

### Features Implemented

#### Core Functionality (MVP)
- ✅ Receipt scanning with camera integration
- ✅ On-device OCR using Google ML Kit
- ✅ Local SQLite database for secure storage
- ✅ Tax savings calculation based on user profile
- ✅ User profile setup (income bracket, filing status)

#### Gamification System
- ✅ 13 achievements across scanning and savings milestones
- ✅ Visual progress tracking with percentage indicators
- ✅ Achievement unlock notifications with celebratory UI
- ✅ Progress bars showing advancement toward next milestone
- ✅ Beautiful achievements screen with unlock dates

#### Educational Content
- ✅ 8 educational tips covering key deduction categories
- ✅ "Tip of the Day" on dashboard (dismissible)
- ✅ Contextual tips shown after receipt scanning
- ✅ Full tips library accessible via lightbulb icon
- ✅ Tips cover: business meals, home office, equipment, mileage, supplies, professional services, education, and record keeping

#### User Experience Enhancements
- ✅ Enhanced dashboard with better visual hierarchy
- ✅ Improved receipt list with detailed information
- ✅ Rewarding receipt save confirmation screen
- ✅ Comprehensive disclaimers for tax estimates
- ✅ Empty states with helpful guidance
- ✅ Responsive design and smooth transitions

For detailed documentation, see the `docs/` folder.