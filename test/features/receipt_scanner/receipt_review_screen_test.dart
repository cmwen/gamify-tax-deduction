import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamified_tax_deduction/features/receipt_scanner/receipt_review_screen.dart';

void main() {
  Future<void> _pumpScreen(
    WidgetTester tester, {
    required double amount,
    String? vendor,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ReceiptReviewScreen(
          initialAmount: amount,
          initialVendorName: vendor,
          imagePath: '',
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('prefills amount and vendor from OCR results', (tester) async {
    await _pumpScreen(tester, amount: 42.5, vendor: 'Coffee Shop');

    final amountField = tester.widget<TextFormField>(
      find.byType(TextFormField).first,
    );
    final vendorField = tester.widget<TextFormField>(
      find.byType(TextFormField).at(1),
    );

    expect(amountField.controller?.text, '42.50');
    expect(vendorField.controller?.text, 'Coffee Shop');
  });

  testWidgets('shows validation error when amount is empty', (tester) async {
    await _pumpScreen(tester, amount: 10, vendor: null);

    final amountFinder = find.byType(TextFormField).first;
    await tester.enterText(amountFinder, '');
    await tester.tap(find.text('Save & Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter the receipt total.'), findsOneWidget);
  });
}
