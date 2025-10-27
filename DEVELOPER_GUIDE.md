# Developer Quick Reference

## Project Overview
Privacy-first Flutter mobile app that gamifies tax deduction tracking with receipt scanning, local storage, and achievement-based progress tracking.

## Quick Start

### Running the App
```bash
# Install dependencies (2-3 minutes, timeout: 10+ minutes)
flutter pub get

# Run the app (2-3 minutes initial build, timeout: 10+ minutes)
flutter run

# Run on specific device
flutter run -d <device_id>
```

### Testing
```bash
# Run all tests (1-2 minutes, timeout: 5+ minutes)
flutter test

# Run specific test file
flutter test test/core/models/educational_tip_test.dart

# Run with coverage
flutter test --coverage
```

### Code Quality
```bash
# Analyze code (30-60 seconds, timeout: 3+ minutes)
flutter analyze

# Format code
flutter format lib/ test/

# Check for issues
flutter analyze --no-pub
```

### Building
```bash
# Android debug build (5-8 minutes, timeout: 15+ minutes)
flutter build apk --debug

# iOS build without signing (3-5 minutes, timeout: 10+ minutes)
flutter build ios --no-codesign
```

## Key Features & Locations

### Educational Content System
**Files:**
- `lib/core/models/educational_tip.dart` - 8 categorized tips
- `lib/features/educational/educational_tip_widgets.dart` - UI components

**Usage:**
```dart
// Get random tip for current tax country
final tip = EducationalTips.getRandomTip(profile.taxCountry);

// Display tip card
EducationalTipCard(tip: tip, onDismiss: () {})

// Show dialog
EducationalTipDialog.show(context, tip);

// Show bottom sheet with all tips
EducationalTipsSheet.show(context, country: profile.taxCountry);
```

### Achievement System
**Files:**
- `lib/core/models/achievement.dart` - 13 achievements
- `lib/core/services/achievement_service.dart` - Achievement logic
- `lib/features/achievements/achievement_notification.dart` - Notifications

**Usage:**
```dart
// Access service
final achievementService = Provider.of<AchievementService>(context);

// Check achievements
final newAchievements = await achievementService.checkAchievements(
  receiptCount,
  totalSavings,
);

// Show notification
for (final achievement in newAchievements) {
  await AchievementUnlockedDialog.show(context, achievement);
}
```

### Receipt Scanning
**Files:**
- `lib/features/receipt_scanner/receipt_scanner_screen.dart`

**Flow:**
1. Camera opens automatically
2. User captures receipt
3. OCR extracts amount
4. Tax savings calculated
5. Receipt saved to database
6. Reward screen with educational tip

### Dashboard
**Files:**
- `lib/features/dashboard/dashboard_screen.dart`

**Components:**
- Total potential savings display
- Tip of the day (dismissible)
- Progress tracking with milestones
- Recent receipts list
- Quick actions (scan, achievements, profile, tips)

## Architecture

### Data Flow
```
User Action → Screen → Service → Database
                ↓
            Provider (State Management)
                ↓
            UI Update
```

### Folder Structure
```
lib/
├── core/              # Business logic
│   ├── database/      # SQLite operations
│   ├── models/        # Data models
│   └── services/      # Business services
└── features/          # UI screens by feature
    ├── achievements/
    ├── dashboard/
    ├── educational/
    ├── profile/
    └── receipt_scanner/
```

## Common Tasks

### Adding a New Achievement
1. Add to `Achievements.all` in `lib/core/models/achievement.dart`
2. Add check logic in `achievement_service.dart` → `checkAchievements()`
3. Add test case in `test/core/models/achievement_model_test.dart`

### Adding Educational Tip
1. Add to `EducationalTips.all` in `lib/core/models/educational_tip.dart`
2. Tips are automatically available in all UI components
3. Add test case in `test/core/models/educational_tip_test.dart`

### Modifying Tax Calculation
1. Edit `lib/core/services/tax_calculation_service.dart`
2. Update `calculateSavingWithProfile()` method
3. Add/update tests in `test/core/services/tax_calculation_service_test.dart`

### Adding New Screen
1. Create file in `lib/features/<feature_name>/`
2. Import in parent screen
3. Navigate using `Navigator.push()`
4. Create corresponding test file in `test/features/<feature_name>/`

## Database Schema

### Tables
```sql
-- Receipts
CREATE TABLE receipts(
  id TEXT PRIMARY KEY,
  createdAt TEXT NOT NULL,
  imagePath TEXT NOT NULL,
  vendorName TEXT,
  totalAmount REAL NOT NULL,
  potentialTaxSaving REAL NOT NULL,
  category TEXT
);

-- Achievements
CREATE TABLE achievements(
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  unlocked INTEGER NOT NULL,
  unlockedAt TEXT
);

-- User Profile
CREATE TABLE user_profile(
  id TEXT PRIMARY KEY,
  filingStatus TEXT NOT NULL,
  incomeBracket TEXT NOT NULL
);
```

### Accessing Database
```dart
final db = await DatabaseHelper.instance.database;

// Insert
await DatabaseHelper.instance.insertReceipt(receipt);

// Query
final receipts = await DatabaseHelper.instance.getAllReceipts();
final savings = await DatabaseHelper.instance.getTotalPotentialSavings();
```

## State Management

### Provider Pattern
```dart
// In main.dart
ChangeNotifierProvider(
  create: (context) => AchievementService(dbHelper: dbHelper),
  child: MyApp(),
)

// In widgets
final service = Provider.of<AchievementService>(context);

// Or with Consumer
Consumer<AchievementService>(
  builder: (context, service, child) {
    return Widget();
  },
)
```

## Testing Patterns

### Model Tests
```dart
test('should create model with all properties', () {
  final model = MyModel(/* properties */);
  expect(model.property, expectedValue);
});
```

### Widget Tests
```dart
testWidgets('should display content', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(home: MyWidget()));
  expect(find.text('Expected Text'), findsOneWidget);
});
```

### Service Tests with Mocks
```dart
@GenerateMocks([DatabaseHelper])
void main() {
  test('should perform action', () async {
    final mockDb = MockDatabaseHelper();
    when(mockDb.method()).thenAnswer((_) async => result);
    // Test logic
  });
}
```

## Debugging Tips

### Common Issues

**Camera not initializing:**
- Check permissions in AndroidManifest.xml and Info.plist
- Ensure physical device or emulator has camera support

**Database errors:**
- Delete app data and reinstall
- Check for schema migration issues
- Verify database path with `getDatabasesPath()`

**OCR not working:**
- Ensure Google ML Kit dependencies are installed
- Check network access for first-time model download
- Test with clear, well-lit receipts

**Provider errors:**
- Ensure Provider is above widget tree
- Use `listen: false` in callbacks
- Check for context issues in async operations

### Logging
```dart
// Debug prints (remove in production)
print('Debug: $variable');

// Flutter logging
debugPrint('Debug message');

// Database logging
final db = await DatabaseHelper.instance.database;
print(await db.rawQuery('SELECT * FROM receipts'));
```

## Performance Considerations

### Image Handling
- Images stored in app documents directory
- Original image paths saved in database
- Consider compression for large receipts

### Database Queries
- SQLite queries are fast for local data
- Use indexed columns for frequent queries
- Batch operations when possible

### UI Performance
- Use `const` constructors where possible
- Implement `ListView.builder` for long lists
- Avoid rebuilding entire trees in setState

## CI/CD

### GitHub Actions Workflow
Location: `.github/workflows/ci.yml`

**Runs on:**
- Push to `main`
- Pull requests to `main`

**Jobs:**
1. Lint: `flutter analyze`
2. Test: `flutter test`
3. Build: `flutter build apk` & `flutter build ios --no-codesign`

## Contributing

### Before Committing
1. Run `flutter analyze` - must pass
2. Run `flutter test` - all tests must pass
3. Format code: `flutter format lib/ test/`
4. Add tests for new features
5. Update documentation if needed

### Code Style
- Follow Flutter/Dart conventions
- Use meaningful variable names
- Add comments for complex logic
- Keep functions focused and small
- Use const constructors where possible

## Resources

### Documentation
- `docs/vision.md` - Project vision and goals
- `docs/design.md` - Technical design decisions
- `docs/product_backlog.md` - Feature prioritization
- `IMPLEMENTATION.md` - Implementation summary
- `CHANGELOG.md` - Version history

### External Links
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Material Design 3](https://m3.material.io/)
- [SQLite Documentation](https://www.sqlite.org/docs.html)

## Support

### Getting Help
1. Check documentation in `docs/` folder
2. Review existing tests for usage examples
3. Check GitHub Issues for known problems
4. Review CONTRIBUTING.md for guidelines

### Reporting Issues
Include:
- Flutter version (`flutter --version`)
- Device/emulator details
- Steps to reproduce
- Expected vs actual behavior
- Relevant logs or screenshots

---

**Last Updated**: 2024
**Flutter Version**: 3.24.4
**Maintainers**: See CONTRIBUTING.md
