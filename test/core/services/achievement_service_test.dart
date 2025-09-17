import 'package:flutter_test/flutter_test.dart';
import 'package:gamified_tax_deduction/core/database/database_helper.dart';
import 'package:gamified_tax_deduction/core/models/achievement.dart';
import 'package:gamified_tax_deduction/core/services/achievement_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'achievement_service_test.mocks.dart';

@GenerateMocks([DatabaseHelper, AchievementService])
void main() {
  late MockDatabaseHelper mockDbHelper;
  late AchievementService achievementService;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    when(mockDbHelper.getAchievements()).thenAnswer((_) async => []);
    achievementService = AchievementService(dbHelper: mockDbHelper);
  });

  group('AchievementService', () {
    test('loads achievements on initialization', () async {
      when(mockDbHelper.getAchievements()).thenAnswer((_) async => []);
      // The constructor calls _loadAchievements, let's wait for it
      await Future.delayed(Duration.zero);
      verify(mockDbHelper.getAchievements()).called(1);
    });

    test('checkAchievements unlocks "first_receipt"', () async {
      final achievements = [
        Achievement(id: 'first_receipt', name: 'First', description: '...'),
      ];
      // The service will load these achievements
      when(mockDbHelper.getAchievements()).thenAnswer((_) async => achievements);
      when(mockDbHelper.updateAchievement(any)).thenAnswer((_) async {});

      // Recreate the service to make it load the new mock data
      achievementService = AchievementService(dbHelper: mockDbHelper);
      await Future.delayed(Duration.zero); // Wait for async constructor

      await achievementService.checkAchievements(1, 50.0);

      final unlockedAchievement = achievementService.achievements.first;
      expect(unlockedAchievement.unlocked, isTrue);
      verify(mockDbHelper.updateAchievement(any)).called(1);
    });

    test('checkAchievements unlocks "ten_receipts"', () async {
      final achievements = [
        Achievement(id: 'ten_receipts', name: 'Ten', description: '...'),
      ];
      when(mockDbHelper.getAchievements()).thenAnswer((_) async => achievements);
      when(mockDbHelper.updateAchievement(any)).thenAnswer((_) async {});

      achievementService = AchievementService(dbHelper: mockDbHelper);
      await Future.delayed(Duration.zero);

      await achievementService.checkAchievements(10, 200.0);

      expect(achievementService.achievements.first.unlocked, isTrue);
      verify(mockDbHelper.updateAchievement(any)).called(1);
    });

    test('checkAchievements does not unlock already unlocked achievements', () async {
       final achievements = [
        Achievement(id: 'first_receipt', name: 'First', description: '...', unlocked: true),
      ];
      when(mockDbHelper.getAchievements()).thenAnswer((_) async => achievements);

      achievementService = AchievementService(dbHelper: mockDbHelper);
      await Future.delayed(Duration.zero);

      await achievementService.checkAchievements(1, 50.0);

      // We expect that updateAchievement is not called
      verifyNever(mockDbHelper.updateAchievement(any));
    });
  });
}
