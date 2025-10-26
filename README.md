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
- ✅ Guided review screen to confirm totals, vendor, and category before saving
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

- ✅ Full receipt history screen with pull-to-refresh and chronological sorting

#### User Experience Enhancements
- ✅ Enhanced dashboard with better visual hierarchy
- ✅ Improved recent receipts module with vendor/category context
- ✅ Rewarding receipt save confirmation screen
- ✅ Comprehensive disclaimers for tax estimates
- ✅ Empty states with helpful guidance
- ✅ Responsive design and smooth transitions

For detailed documentation, see the `docs/` folder.

## Android Release Automation

### Configure Signing
1. Generate a signing key once (update aliases/passwords as needed):
   ```bash
   keytool -genkeypair -v \
     -keystore upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias gamifyTaxRelease
   ```
2. Base64‑encode the keystore so it can live in a GitHub secret:
   ```bash
   base64 upload-keystore.jks > upload-keystore.jks.base64
   ```
   (macOS users can pipe to `pbcopy` to copy it directly.)
3. Create these repository secrets so the workflow can recreate the key at runtime:
   - `ANDROID_KEYSTORE_BASE64` – contents of `upload-keystore.jks.base64`
   - `ANDROID_KEYSTORE_PASSWORD` – keystore password entered above
   - `ANDROID_KEY_ALIAS` – e.g. `gamifyTaxRelease`
   - `ANDROID_KEY_PASSWORD` – key password (can match the keystore password)

For local release builds, add an untracked `android/key.properties` file that matches:
```
storePassword=<ANDROID_KEYSTORE_PASSWORD>
keyPassword=<ANDROID_KEY_PASSWORD>
keyAlias=<ANDROID_KEY_ALIAS>
storeFile=app/upload-keystore.jks
```
Then drop `upload-keystore.jks` in `android/app/`.

### Build & Publish with GitHub Actions
- Workflow: `.github/workflows/release-apk.yml`
- Triggers: manual `workflow_dispatch` (build artifact only) or tags matching `v*` (build + publish GitHub Release).
- Outputs: signed `app-release.apk` uploaded as an artifact, and when tagged, attached to the release automatically.

Typical release flow:
1. Bump app version in `pubspec.yaml`.
2. Commit and push to `main`.
3. Tag the commit (e.g. `git tag v1.2.0 && git push origin v1.2.0`).
4. GitHub Actions builds the signed APK and publishes it in the tagged release.
