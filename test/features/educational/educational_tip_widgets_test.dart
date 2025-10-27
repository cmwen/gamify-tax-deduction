import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamified_tax_deduction/core/models/educational_tip.dart';
import 'package:gamified_tax_deduction/core/models/user_profile.dart';
import 'package:gamified_tax_deduction/features/educational/educational_tip_widgets.dart';

void main() {
  group('EducationalTipCard', () {
    testWidgets('should display tip content', (WidgetTester tester) async {
      const tip = EducationalTip(
        id: 'test',
        title: 'Test Title',
        content: 'Test content for educational tip',
        category: 'test',
        icon: '💡',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EducationalTipCard(tip: tip),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test content for educational tip'), findsOneWidget);
      expect(find.text('💡'), findsOneWidget);
    });

    testWidgets('should show dismiss button when onDismiss is provided',
        (WidgetTester tester) async {
      const tip = EducationalTip(
        id: 'test',
        title: 'Test Title',
        content: 'Test content',
        category: 'test',
      );

      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EducationalTipCard(
              tip: tip,
              onDismiss: () => dismissed = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(dismissed, isTrue);
    });

    testWidgets('should not show dismiss button when onDismiss is null',
        (WidgetTester tester) async {
      const tip = EducationalTip(
        id: 'test',
        title: 'Test Title',
        content: 'Test content',
        category: 'test',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EducationalTipCard(tip: tip),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });
  });

  group('EducationalTipDialog', () {
    testWidgets('should display dialog with tip information',
        (WidgetTester tester) async {
      const tip = EducationalTip(
        id: 'test',
        title: 'Test Title',
        content: 'Test content for dialog',
        category: 'test',
        icon: '🎯',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => EducationalTipDialog.show(context, tip),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test content for dialog'), findsOneWidget);
      expect(find.text('🎯'), findsOneWidget);
      expect(find.text('Got it!'), findsOneWidget);
    });

    testWidgets('should close dialog when button is tapped',
        (WidgetTester tester) async {
      const tip = EducationalTip(
        id: 'test',
        title: 'Test Title',
        content: 'Test content',
        category: 'test',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => EducationalTipDialog.show(context, tip),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Test Title'), findsOneWidget);

      await tester.tap(find.text('Got it!'));
      await tester.pumpAndSettle();

      expect(find.text('Test Title'), findsNothing);
    });
  });

  group('EducationalTipsSheet', () {
    testWidgets('should display all tips in bottom sheet',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => EducationalTipsSheet.show(
                  context,
                  country: TaxCountry.unitedStates,
                ),
                child: const Text('Show Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Tax Deduction Tips'), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb), findsOneWidget);
      
      // Should find at least some tips
      final tipCards = find.byType(EducationalTipCard);
      expect(tipCards, findsWidgets);
    });

    testWidgets('should close sheet when close button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => EducationalTipsSheet.show(
                  context,
                  country: TaxCountry.unitedStates,
                ),
                child: const Text('Show Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Tax Deduction Tips'), findsOneWidget);

      // Find and tap the close button in the sheet
      final closeButtons = find.byIcon(Icons.close);
      await tester.tap(closeButtons.first);
      await tester.pumpAndSettle();

      expect(find.text('Tax Deduction Tips'), findsNothing);
    });
  });
}
