import 'package:flutter_test/flutter_test.dart';
import 'package:gamified_tax_deduction/main.dart';

void main() {
  testWidgets('App starts and displays dashboard', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GamifiedTaxDeductionApp());

    // Verify that the dashboard screen is displayed
    expect(find.text('Tax Deduction Tracker'), findsOneWidget);
    expect(find.text('Total Potential Savings'), findsOneWidget);
    expect(find.text('Scan New Receipt'), findsOneWidget);
  });
}