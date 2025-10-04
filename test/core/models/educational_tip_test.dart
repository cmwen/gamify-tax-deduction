import 'package:flutter_test/flutter_test.dart';
import 'package:gamified_tax_deduction/core/models/educational_tip.dart';

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
    test('should have at least one tip', () {
      expect(EducationalTips.all, isNotEmpty);
    });

    test('all tips should have required fields', () {
      for (final tip in EducationalTips.all) {
        expect(tip.id, isNotEmpty);
        expect(tip.title, isNotEmpty);
        expect(tip.content, isNotEmpty);
        expect(tip.category, isNotEmpty);
      }
    });

    test('getRandomTip should return a valid tip', () {
      final tip = EducationalTips.getRandomTip();
      
      expect(tip, isNotNull);
      expect(EducationalTips.all, contains(tip));
    });

    test('getTipsByCategory should filter correctly', () {
      // Assuming 'meals' category exists
      final mealsTips = EducationalTips.getTipsByCategory('meals');
      
      for (final tip in mealsTips) {
        expect(tip.category, 'meals');
      }
    });

    test('getTipsByCategory should return empty list for non-existent category', () {
      final tips = EducationalTips.getTipsByCategory('non_existent_category');
      
      expect(tips, isEmpty);
    });

    test('should have diverse tip categories', () {
      final categories = EducationalTips.all.map((t) => t.category).toSet();
      
      // Should have multiple categories for better user experience
      expect(categories.length, greaterThan(1));
    });

    test('tip content should contain educational information', () {
      for (final tip in EducationalTips.all) {
        // Tips should be descriptive
        expect(tip.content.length, greaterThan(20));
      }
    });
  });
}
