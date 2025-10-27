import 'package:flutter_test/flutter_test.dart';
import 'package:gamified_tax_deduction/core/models/educational_tip.dart';
import 'package:gamified_tax_deduction/core/models/user_profile.dart';

void main() {
  group('EducationalTip', () {
    test('should create educational tip with all properties', () {
      const tip = EducationalTip(
        id: 'test_tip',
        title: 'Test Title',
        content: 'Test Content',
        category: 'test',
        icon: '💡',
      );

      expect(tip.id, 'test_tip');
      expect(tip.title, 'Test Title');
      expect(tip.content, 'Test Content');
      expect(tip.category, 'test');
      expect(tip.icon, '💡');
    });

    test('should allow null icon', () {
      const tip = EducationalTip(
        id: 'test_tip',
        title: 'Test Title',
        content: 'Test Content',
        category: 'test',
      );

      expect(tip.icon, isNull);
    });
  });

  group('EducationalTips', () {
    test('should have tips for each supported country', () {
      for (final country in TaxCountry.values) {
        expect(EducationalTips.forCountry(country), isNotEmpty,
            reason: 'Expected tips for $country');
      }
    });

    test('all tips should have required fields', () {
      for (final country in TaxCountry.values) {
        for (final tip in EducationalTips.forCountry(country)) {
          expect(tip.id, isNotEmpty);
          expect(tip.title, isNotEmpty);
          expect(tip.content, isNotEmpty);
          expect(tip.category, isNotEmpty);
        }
      }
    });

    test('getRandomTip should return a tip from the requested country', () {
      for (final country in TaxCountry.values) {
        final tip = EducationalTips.getRandomTip(country);

        expect(tip, isNotNull);
        expect(EducationalTips.forCountry(country), contains(tip));
      }
    });

    test('getTipsByCategory should filter correctly per country', () {
      final mealsTipsUS = EducationalTips.getTipsByCategory(TaxCountry.unitedStates, 'meals');
      for (final tip in mealsTipsUS) {
        expect(tip.category, 'meals');
      }

      final travelTipsAU = EducationalTips.getTipsByCategory(TaxCountry.australia, 'travel');
      for (final tip in travelTipsAU) {
        expect(tip.category, 'travel');
      }
    });

    test('getTipsByCategory returns empty list when category is missing', () {
      final tips = EducationalTips.getTipsByCategory(TaxCountry.unitedStates, 'non_existent_category');
      expect(tips, isEmpty);
    });

    test('each country list should include multiple categories', () {
      for (final country in TaxCountry.values) {
        final categories = EducationalTips.forCountry(country).map((t) => t.category).toSet();
        expect(categories.length, greaterThan(1));
      }
    });

    test('tip content should contain educational information', () {
      for (final country in TaxCountry.values) {
        for (final tip in EducationalTips.forCountry(country)) {
          expect(tip.content.length, greaterThan(20));
        }
      }
    });
  });
}
