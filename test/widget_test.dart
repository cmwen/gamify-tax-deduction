import 'package:flutter_test/flutter_test.dart';
import 'package:gamified_tax_deduction/core/database/database_helper.dart';
import 'package:gamified_tax_deduction/core/services/achievement_service.dart';
import 'package:gamified_tax_deduction/main.dart';
import 'package:gamified_tax_deduction/core/services/theme_service.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize the FFI database factory for tests
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  testWidgets('App starts and displays dashboard', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final dbHelper = DatabaseHelper.instance;
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => AchievementService(dbHelper: dbHelper),
          ),
          ChangeNotifierProvider(
            create: (_) => ThemeService(),
          ),
        ],
        child: const GamifiedTaxDeductionApp(),
      ),
    );
    
    // Pump and settle to wait for async operations to complete
    await tester.pumpAndSettle();

    // Verify that the dashboard screen is displayed
    expect(find.text('Tax Deduction Tracker'), findsOneWidget);
    expect(find.text('Total Potential Savings'), findsOneWidget);
    expect(find.text('Scan New Receipt'), findsOneWidget);
  });
}
