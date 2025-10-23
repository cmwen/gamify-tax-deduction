import 'package:flutter_test/flutter_test.dart';
import 'package:gamified_tax_deduction/core/database/database_helper.dart';
import 'package:gamified_tax_deduction/core/models/achievement.dart';
import 'package:gamified_tax_deduction/core/services/achievement_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'achievement_service_test.mocks.dart';

@GenerateMocks([DatabaseHelper])
void main() {
  late MockDatabaseHelper mockDbHelper;

  AchievementService buildService() => AchievementService(dbHelper: mockDbHelper);

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
  });

  group('AchievementService', () {
    test('loads achievements on initialization', () async {
      when(mockDbHelper.getAchievements()).thenAnswer((_) async => []);
      final service = buildService();

      await service.checkAchievements(0, 0);

      verify(mockDbHelper.getAchievements()).called(1);
    });

    test('checkAchievements unlocks "first_receipt" and returns it', () async {
      final achievements = [
        Achievement(id: 'first_receipt', name: 'First', description: '...'),
      ];
      when(mockDbHelper.getAchievements()).thenAnswer((_) async => achievements);
      when(mockDbHelper.updateAchievement(any)).thenAnswer((_) async {});

      final service = buildService();
      final newlyUnlocked = await service.checkAchievements(1, 50.0);

      expect(newlyUnlocked.length, 1);
      expect(newlyUnlocked.first.id, 'first_receipt');
      expect(newlyUnlocked.first.unlocked, isTrue);
      expect(service.achievements.first.unlocked, isTrue);
      verify(mockDbHelper.updateAchievement(any)).called(1);
    });

    test('checkAchievements unlocks "ten_receipts"', () async {
      final achievements = [
        Achievement(id: 'ten_receipts', name: 'Ten', description: '...'),
      ];
      when(mockDbHelper.getAchievements()).thenAnswer((_) async => achievements);
      when(mockDbHelper.updateAchievement(any)).thenAnswer((_) async {});

      final service = buildService();
      final newlyUnlocked = await service.checkAchievements(10, 200.0);

      expect(newlyUnlocked.length, 1);
      expect(service.achievements.first.unlocked, isTrue);
      verify(mockDbHelper.updateAchievement(any)).called(1);
    });

    test('checkAchievements does not unlock already unlocked achievements', () async {
      final achievements = [
        Achievement(id: 'first_receipt', name: 'First', description: '...', unlocked: true),
      ];
      when(mockDbHelper.getAchievements()).thenAnswer((_) async => achievements);

      final service = buildService();
      final newlyUnlocked = await service.checkAchievements(1, 50.0);

      expect(newlyUnlocked.length, 0);
      verifyNever(mockDbHelper.updateAchievement(any));
    });

    test('clearNewlyUnlocked clears the list', () async {
      final achievements = [
        Achievement(id: 'first_receipt', name: 'First', description: '...'),
      ];
      when(mockDbHelper.getAchievements()).thenAnswer((_) async => achievements);
      when(mockDbHelper.updateAchievement(any)).thenAnswer((_) async {});

      final service = buildService();

      await service.checkAchievements(1, 50.0);
      expect(service.newlyUnlocked, isNotEmpty);

      service.clearNewlyUnlocked();
      expect(service.newlyUnlocked, isEmpty);
    });

    test('checkAchievements unlocks multiple achievements at once', () async {
      final achievements = [
        Achievement(id: 'first_receipt', name: 'First', description: '...'),
        Achievement(id: 'five_receipts', name: 'Five', description: '...'),
        Achievement(id: 'fifty_deduction', name: 'Fifty', description: '...'),
      ];
      when(mockDbHelper.getAchievements()).thenAnswer((_) async => achievements);
      when(mockDbHelper.updateAchievement(any)).thenAnswer((_) async {});

      final service = buildService();
      final newlyUnlocked = await service.checkAchievements(5, 75.0);

      expect(newlyUnlocked.length, 3);
      verify(mockDbHelper.updateAchievement(any)).called(3);
    });

    test('checkAchievements triggers initial load when needed', () async {
      final achievements = [
        Achievement(id: 'first_receipt', name: 'First', description: '...'),
      ];
      when(mockDbHelper.getAchievements()).thenAnswer((_) async => achievements);
      when(mockDbHelper.updateAchievement(any)).thenAnswer((_) async {});

      final service = buildService();
      final newlyUnlocked = await service.checkAchievements(1, 10);

      expect(newlyUnlocked, isNotEmpty);
      verify(mockDbHelper.getAchievements()).called(1);
    });
  });
}
