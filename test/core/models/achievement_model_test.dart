import 'package:flutter_test/flutter_test.dart';
import 'package:gamified_tax_deduction/core/models/achievement.dart';

void main() {
  group('Achievement Model', () {
    test('copyWith creates a copy with updated values', () {
      final achievement = Achievement(
        id: 'test',
        name: 'Test',
        description: 'A test achievement',
        imageUrl: 'assets/images/test.png',
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
        imageUrl: 'assets/images/test.png',
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

    test('all list contains expected achievements', () {
      final ids = Achievements.all.map((e) => e.id).toList();
      expect(ids, contains('first_receipt'));
      expect(ids, contains('ten_receipts'));
    });
  });
}
