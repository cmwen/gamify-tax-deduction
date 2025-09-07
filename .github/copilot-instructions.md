# Gamified Tax Deduction Tracker

Privacy-first Flutter mobile application that gamifies tax deduction tracking with receipt scanning, local data storage, and achievement-based progress tracking.

**Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

## Working Effectively

### Bootstrap, Build, and Test Repository:
**CRITICAL**: Network restrictions WILL prevent standard Flutter installation. Expected errors:

1. **Install Flutter SDK** (Known to fail with network restrictions):
   ```bash
   # Method 1: Using snap (requires sudo) - FAILS with "context canceled"
   sudo snap install flutter --classic
   
   # Method 2: Manual download - FAILS with Dart SDK download
   cd /tmp
   git clone https://github.com/flutter/flutter.git -b stable --depth 1
   export PATH="/tmp/flutter/bin:$PATH"
   flutter doctor  # FAILS: "It appears that the downloaded file is corrupt"
   
   # Method 3: Use CI for validation (RECOMMENDED)
   # When local installation fails due to network limitations,
   # rely on the CI pipeline for build and test validation
   ```

2. **Install dependencies and validate setup**:
   ```bash
   cd /home/runner/work/gamify-tax-deduction/gamify-tax-deduction
   flutter doctor  # Check system setup
   flutter pub get  # Install dependencies - takes 2-3 minutes. NEVER CANCEL. Set timeout to 10+ minutes.
   ```

3. **Build the application**:
   ```bash
   # Android build
   flutter build apk --debug  # Takes 5-8 minutes. NEVER CANCEL. Set timeout to 15+ minutes.
   
   # iOS build (no code signing)
   flutter build ios --no-codesign  # Takes 3-5 minutes. NEVER CANCEL. Set timeout to 10+ minutes.
   ```

4. **Run tests**:
   ```bash
   flutter test  # Takes 1-2 minutes. NEVER CANCEL. Set timeout to 5+ minutes.
   ```

5. **Code analysis and linting**:
   ```bash
   flutter analyze  # Takes 30-60 seconds. Set timeout to 3+ minutes.
   ```

### Run the Application:
**ALWAYS run the bootstrapping steps first.**

```bash
# Run on connected device/emulator
flutter run  # Takes 2-3 minutes for initial build. NEVER CANCEL. Set timeout to 10+ minutes.

# Run in debug mode with hot reload
flutter run --debug
```

### Development Environment Setup:
- **Android**: Requires Android Studio + SDK 24+ + Java 11+
- **iOS**: Requires macOS + Xcode 13.0+ + iOS 15.0+
- **Flutter**: Version 3.24.4 exactly (as specified in CI)
- **Dart**: SDK 3.0.0+ (included with Flutter)

## Validation

### Manual Testing Scenarios:
**CRITICAL**: After making changes, ALWAYS run through these complete end-to-end scenarios:

1. **Dashboard Load Test**:
   - Launch app
   - Verify "Tax Deduction Tracker" title displays
   - Verify "Total Potential Savings" shows $0.00 initially
   - Verify "Scan New Receipt" button is present and clickable

2. **Receipt Scanning Flow** (if camera available):
   - Tap "Scan New Receipt" button
   - Verify camera permission is requested
   - Verify camera preview displays
   - Test OCR text recognition functionality

3. **Database Functionality**:
   - Verify SQLite database initializes correctly
   - Test receipt storage and retrieval
   - Verify tax savings calculations work

### Automated Validation:
**Always run these commands before committing changes:**

```bash
# Required checks (CI will fail without these)
flutter analyze  # Code analysis
flutter test     # Unit and widget tests

# Additional validation
flutter pub deps  # Check dependency health
```

### Build Timing and Timeout Expectations:
- **flutter pub get**: 2-3 minutes (timeout: 10+ minutes)
- **flutter analyze**: 30-60 seconds (timeout: 3+ minutes)  
- **flutter test**: 1-2 minutes (timeout: 5+ minutes)
- **flutter build apk**: 5-8 minutes (timeout: 15+ minutes)
- **flutter build ios**: 3-5 minutes (timeout: 10+ minutes)
- **flutter run**: 2-3 minutes initial (timeout: 10+ minutes)

**NEVER CANCEL any build or test command.** Builds may take longer on slower machines.

## Network and Environment Limitations

### Known Issues:
- **Flutter SDK Download**: WILL fail due to network restrictions to storage.googleapis.com
- **Snap Installation**: Requires sudo access and WILL fail with "context canceled"
- **Dart SDK Download**: WILL fail with "downloaded file is corrupt" error
- **Workaround**: Use CI pipeline (.github/workflows/ci.yml) for validation

### If Installation Fails (Expected Scenario):
1. **Document the specific error**: 
   - Network timeout accessing storage.googleapis.com
   - "context canceled" for snap installation
   - "downloaded file is corrupt" for manual installation
2. **Use the CI pipeline** (.github/workflows/ci.yml) for build validation
3. **Validate file changes** through code analysis without running builds
4. **CI Environment**: Ubuntu with Flutter 3.24.4 - validates all builds/tests successfully

## Code Structure

### Code Statistics and Structure:
```
Total Dart files: 9 files (656 lines of code)

lib/ (6 files, 656 lines):
├── main.dart (27 lines)                 # Application entry point
├── core/ (3 files, 178 lines)          # Shared business logic
│   ├── database/database_helper.dart (69 lines)     # SQLite operations
│   ├── models/data_models.dart (69 lines)           # Receipt, UserProfile models
│   └── services/tax_calculation_service.dart (40 lines)  # Tax calculations
└── features/ (3 files, 451 lines)      # Feature modules
    ├── dashboard/dashboard_screen.dart (175 lines)   # Main UI screen
    └── receipt_scanner/receipt_scanner_screen.dart (276 lines)  # Camera + OCR

test/ (3 files, 118 lines):
├── widget_test.dart (13 lines)         # Main widget tests
└── core/ (2 files, 105 lines)          # Unit tests
    ├── models/data_models_test.dart (65 lines)       # Model tests
    └── services/tax_calculation_service_test.dart (40 lines)  # Service tests
```
```
lib/
├── main.dart                 # Application entry point
├── core/                     # Shared business logic
│   ├── database/            # SQLite database management
│   ├── models/              # Data models (Receipt, UserProfile)
│   └── services/            # Business services (tax calculations)
└── features/                # Feature modules
    ├── dashboard/           # Main app dashboard
    └── receipt_scanner/     # Camera + OCR functionality

test/
├── widget_test.dart         # Main widget tests
└── core/                    # Unit tests for core functionality
```

### Important Files to Check After Changes:
- **lib/main.dart**: Application initialization and routing
- **pubspec.yaml**: Dependencies and Flutter configuration
- **lib/core/database/database_helper.dart**: Database operations
- **lib/core/models/data_models.dart**: Core data structures
- **analysis_options.yaml**: Linting rules and code style

### Frequently Modified Areas:
- **Dashboard**: lib/features/dashboard/dashboard_screen.dart
- **Scanner**: lib/features/receipt_scanner/receipt_scanner_screen.dart
- **Database**: lib/core/database/ (when adding new tables/queries)
- **Models**: lib/core/models/ (when adding new data structures)

## CI/CD Pipeline

### GitHub Actions Configuration:
Location: `.github/workflows/ci.yml`

The CI runs three jobs:
1. **Lint**: `flutter analyze` on Ubuntu
2. **Build and Test**: `flutter test` + `flutter build apk` + `flutter build ios --no-codesign`
3. **Documentation**: Markdown link checking

### Exact CI Commands:
```bash
# These commands are validated to work in CI:
flutter pub get
flutter analyze
flutter test  
flutter build apk --debug
flutter build ios --no-codesign
```

## Common Tasks

The following are outputs from frequently run commands. Reference them instead of viewing, searching, or running bash commands to save time.

### Repository Root Structure:
```
.
├── .github/              # GitHub workflows and configurations
├── .gitignore           # Git ignore file
├── CONTRIBUTING.md      # Contributor guidelines
├── LICENSE              # MIT license
├── README.md            # Main project documentation (Flutter setup guide)
├── analysis_options.yaml # Dart/Flutter linting configuration
├── android/             # Android platform configuration
├── docs/                # Project documentation
├── ios/                 # iOS platform configuration  
├── lib/                 # Flutter/Dart source code
├── pubspec.yaml         # Flutter dependencies and metadata
└── test/                # Unit and widget tests
```

### Key Dependencies (from pubspec.yaml):
```yaml
dependencies:
  flutter: sdk: flutter
  sqflite: ^2.3.0                    # Local SQLite database
  camera: ^0.10.5+5                  # Camera access for receipt scanning
  google_mlkit_text_recognition: ^0.12.0  # OCR text recognition
  path_provider: ^2.1.1              # File system access
  flutter_secure_storage: ^9.0.0     # Secure local storage
  uuid: ^4.1.0                       # Unique identifier generation

dev_dependencies:
  flutter_test: sdk: flutter
  flutter_lints: ^3.0.0              # Linting rules
```

### CI Workflow Commands (from .github/workflows/ci.yml):
```bash
# Linting Job:
flutter pub get
flutter analyze

# Build and Test Job:
flutter pub get
flutter test
flutter build apk --debug
flutter build ios --no-codesign
```

### Architecture Notes:
- **Privacy-First**: All data stays local, no cloud services
- **Flutter 3.24.4**: Cross-platform mobile development
- **SQLite**: Local-only database storage
- **Material Design**: UI framework
- **OCR Integration**: Google ML Kit for text recognition
- **Camera Integration**: Flutter camera plugin

## Troubleshooting

### Common Development Issues:
1. **Build Failures**: Check Flutter/Dart versions match CI (3.24.4)
2. **Test Failures**: Ensure database is properly initialized in tests
3. **Camera Issues**: Verify device permissions and platform configurations
4. **Network Issues**: Use CI for validation if local installation fails

### Emergency Validation (When Flutter Installation Fails):
**RECOMMENDED APPROACH**: When local Flutter installation fails due to network restrictions:

1. **Code Analysis Without Flutter**:
   ```bash
   # Check Dart syntax and imports (basic validation)
   find lib/ -name "*.dart" -exec echo "Checking: {}" \; -exec head -10 {} \;
   
   # Verify file structure and line counts
   find lib/ test/ -name "*.dart" -exec wc -l {} \;
   
   # Check for common issues
   grep -r "TODO\|FIXME\|HACK" lib/ test/
   ```

2. **Create minimal test that validates your changes**:
   ```bash
   # Edit test files to validate your changes
   # Focus on unit tests in test/core/ directory
   ```

3. **Push to branch and verify CI passes**:
   ```bash
   git add .
   git commit -m "Your changes"
   git push origin your-branch-name
   # Check GitHub Actions for build/test results
   ```

4. **Document environment limitations in your changes**

### Performance Considerations:
- **Initial Build**: First build takes longest (5-8 minutes)
- **Hot Reload**: Subsequent changes are much faster (5-10 seconds)
- **Database**: SQLite operations are synchronous and fast
- **OCR**: On-device text recognition may take 1-2 seconds per image

## Quick Reference

### Most Common Development Commands:
```bash
# When you can install Flutter locally (rare due to network restrictions):
flutter pub get      # Install dependencies (2-3 min, timeout: 10+ min)
flutter analyze      # Code analysis (30-60 sec, timeout: 3+ min)
flutter test         # Run tests (1-2 min, timeout: 5+ min)
flutter run          # Launch app (2-3 min, timeout: 10+ min)

# When Flutter installation fails (common scenario):
# 1. Make code changes using any editor
# 2. Validate syntax by examining imports and structure
# 3. Push changes and rely on CI for validation
git add . && git commit -m "Your changes" && git push
```

### File Editing Priorities:
1. **lib/features/dashboard/dashboard_screen.dart** - Main UI (175 lines)
2. **lib/core/models/data_models.dart** - Data structures (69 lines)  
3. **lib/core/database/database_helper.dart** - Database operations (69 lines)
4. **test/core/** - Unit tests for core functionality

### When Making Changes:
- **Always check**: Imports, syntax, and logical flow
- **Always run** (if Flutter available): `flutter analyze` and `flutter test`
- **Always validate**: Push to branch and check CI results
- **Always document**: Any network/environment limitations encountered

This codebase is well-structured for Flutter development with clear separation of concerns, comprehensive testing, and a focus on privacy-first architecture.