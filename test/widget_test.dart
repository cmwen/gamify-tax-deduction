import 'package:flutter_test/flutter_test.dart';
import 'package:gamified_tax_deduction/main.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize the FFI database factory for tests
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  testWidgets('App starts and displays dashboard', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GamifiedTaxDeductionApp());
    
    // Pump and settle to wait for async operations to complete
    await tester.pumpAndSettle();

    // Verify that the dashboard screen is displayed
    expect(find.text('Tax Deduction Tracker'), findsOneWidget);
    expect(find.text('Total Potential Savings'), findsOneWidget);
    expect(find.text('Scan New Receipt'), findsOneWidget);
  });
}