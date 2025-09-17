import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamified_tax_deduction/features/profile/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ProfileScreen', () {
    testWidgets('should display saved profile data on load', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'user_income_bracket': 'medium',
        'user_filing_status': 'married',
      });

      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle(); // Wait for async initState to complete

      expect(find.text('medium'), findsOneWidget);
      expect(find.text('married'), findsOneWidget);
    });

    testWidgets('Save button should be disabled until both fields are selected', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));

      final saveButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(saveButton.onPressed, isNull);

      // Select income bracket
      await tester.tap(find.text('Select Income Bracket'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('low').last);
      await tester.pumpAndSettle();

      final saveButtonAfterFirstSelection = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(saveButtonAfterFirstSelection.onPressed, isNull);

      // Select filing status
      await tester.tap(find.text('Select Filing Status'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('single').last);
      await tester.pumpAndSettle();

      final saveButtonAfterSecondSelection = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(saveButtonAfterSecondSelection.onPressed, isNotNull);
    });

    testWidgets('should save profile data when save button is pressed', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                child: const Text('Go to Profile'),
              ),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Go to Profile'));
      await tester.pumpAndSettle();

      // Select income bracket and filing status
      await tester.tap(find.text('Select Income Bracket'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('high').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select Filing Status'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('married').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user_income_bracket'), 'high');
      expect(prefs.getString('user_filing_status'), 'married');
    });
  });
}
