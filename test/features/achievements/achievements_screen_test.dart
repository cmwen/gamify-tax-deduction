import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamified_tax_deduction/core/database/database_helper.dart';
import 'package:gamified_tax_deduction/core/models/achievement.dart';
import 'package:gamified_tax_deduction/core/services/achievement_service.dart';
import 'package:gamified_tax_deduction/features/achievements/achievements_screen.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'achievements_screen_test.mocks.dart';

@GenerateMocks([DatabaseHelper])
void main() {
  late MockDatabaseHelper mockDbHelper;
  late AchievementService achievementService;

  AchievementService buildService() => AchievementService(dbHelper: mockDbHelper);

  Widget createWidgetUnderTest() {
    return ChangeNotifierProvider.value(
      value: achievementService,
      child: const MaterialApp(
        home: AchievementsScreen(),
      ),
    );
  }

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
  });

  testWidgets('shows loading indicator initially', (WidgetTester tester) async {
    when(mockDbHelper.getAchievements()).thenAnswer((_) async => []);
    achievementService = buildService();

    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('displays achievements after loading', (WidgetTester tester) async {
    final achievements = [
      Achievement(
        id: 'a1',
        name: 'Achievement 1',
        description: 'Desc 1',
        unlocked: true,
        unlockedAt: DateTime.now(),
      ),
      Achievement(id: 'a2', name: 'Achievement 2', description: 'Desc 2'),
    ];
    when(mockDbHelper.getAchievements()).thenAnswer((_) async => achievements);
    achievementService = buildService();

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Achievement 1'), findsOneWidget);
    expect(find.text('Achievement 2'), findsOneWidget);
  });
}
