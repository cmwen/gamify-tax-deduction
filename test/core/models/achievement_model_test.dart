import 'package:flutter_test/flutter_test.dart';
import 'package:gamified_tax_deduction/core/models/achievement.dart';

void main() {
  group('Achievement Model', () {
    test('copyWith creates a copy with updated values', () {
      final achievement = Achievement(
        id: 'test',
        name: 'Test',
        description: 'A test achievement',
      );

      final unlockedAchievement = achievement.copyWith(
        unlocked: true,
        unlockedAt: DateTime(2023),
      );

      expect(unlockedAchievement.id, 'test');
      expect(unlockedAchievement.unlocked, isTrue);
      expect(unlockedAchievement.unlockedAt, DateTime(2023));
    });

    test('fromMap and toMap work correctly', () {
      final now = DateTime.now();
      final achievement = Achievement(
        id: 'test',
        name: 'Test',
        description: 'A test achievement',
        unlocked: true,
        unlockedAt: now,
      );

      final map = achievement.toMap();
      final fromMap = Achievement.fromMap(map);

      expect(fromMap.id, achievement.id);
      expect(fromMap.name, achievement.name);
      expect(fromMap.description, achievement.description);
      expect(fromMap.unlocked, achievement.unlocked);
      // Using toIso8601String for consistent comparison
      expect(fromMap.unlockedAt?.toIso8601String(), achievement.unlockedAt?.toIso8601String());
    });
  });

  group('Achievements Class', () {
    test('all list is not empty', () {
      expect(Achievements.all, isNotEmpty);
    });

    test('all list contains expected scanning achievements', () {
      final ids = Achievements.all.map((e) => e.id).toList();
      expect(ids, contains('first_receipt'));
      expect(ids, contains('five_receipts'));
      expect(ids, contains('ten_receipts'));
      expect(ids, contains('twenty_five_receipts'));
      expect(ids, contains('fifty_receipts'));
      expect(ids, contains('hundred_receipts'));
    });

    test('all list contains expected savings achievements', () {
      final ids = Achievements.all.map((e) => e.id).toList();
      expect(ids, contains('fifty_deduction'));
      expect(ids, contains('hundred_deduction'));
      expect(ids, contains('two_fifty_deduction'));
      expect(ids, contains('five_hundred_deduction'));
      expect(ids, contains('thousand_deduction'));
      expect(ids, contains('two_thousand_deduction'));
      expect(ids, contains('five_thousand_deduction'));
    });

    test('all achievements should have unique ids', () {
      final ids = Achievements.all.map((e) => e.id).toList();
      final uniqueIds = ids.toSet();
      expect(ids.length, uniqueIds.length);
    });

    test('all achievements should have required fields', () {
      for (final achievement in Achievements.all) {
        expect(achievement.id, isNotEmpty);
        expect(achievement.name, isNotEmpty);
        expect(achievement.description, isNotEmpty);
        expect(achievement.unlocked, isFalse); // Should start unlocked
        expect(achievement.unlockedAt, isNull); // Should not have unlock date initially
      }
    });

    test('should have progressive milestones', () {
      // Receipt counting achievements should be progressive
      final receiptAchievements = [
        'first_receipt',
        'five_receipts',
        'ten_receipts',
        'twenty_five_receipts',
        'fifty_receipts',
        'hundred_receipts',
      ];
      
      final ids = Achievements.all.map((e) => e.id).toList();
      for (final achievementId in receiptAchievements) {
        expect(ids, contains(achievementId));
      }

      // Savings achievements should be progressive
      final savingsAchievements = [
        'fifty_deduction',
        'hundred_deduction',
        'two_fifty_deduction',
        'five_hundred_deduction',
        'thousand_deduction',
      ];
      
      for (final achievementId in savingsAchievements) {
        expect(ids, contains(achievementId));
      }
    });
  });
}
