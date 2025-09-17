import 'package:flutter_test/flutter_test.dart';
import 'package:gamified_tax_deduction/core/database/database_helper.dart';
import 'package:gamified_tax_deduction/core/models/user_profile.dart';
import 'package:gamified_tax_deduction/core/services/profile_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite/sqflite.dart';

import 'profile_service_test.mocks.dart';

@GenerateMocks([DatabaseHelper, Database])
void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockDatabase mockDatabase;
  late ProfileService profileService;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    when(mockDbHelper.database).thenAnswer((_) async => mockDatabase);
    profileService = ProfileService(dbHelper: mockDbHelper);
  });

  group('ProfileService', () {
    final testProfile = UserProfile(
      id: 'test_id',
      filingStatus: FilingStatus.single,
      incomeBracket: IncomeBracket.middle,
    );

    test('saveProfile calls db.insert', () async {
      when(mockDatabase.insert(
        any,
        any,
        conflictAlgorithm: anyNamed('conflictAlgorithm'),
      )).thenAnswer((_) async => 1);

      await profileService.saveProfile(testProfile);

      verify(mockDatabase.insert(
        'user_profile',
        testProfile.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      )).called(1);
    });

    test('getProfile returns a profile when one exists', () async {
      when(mockDatabase.query(any, limit: anyNamed('limit')))
          .thenAnswer((_) async => [testProfile.toMap()]);

      final profile = await profileService.getProfile();

      expect(profile, isA<UserProfile>());
      expect(profile?.id, testProfile.id);
    });

    test('getProfile returns null when no profile exists', () async {
      when(mockDatabase.query(any, limit: anyNamed('limit')))
          .thenAnswer((_) async => []);

      final profile = await profileService.getProfile();

      expect(profile, isNull);
    });

    test('getOrCreateProfile returns existing profile', () async {
       when(mockDatabase.query(any, limit: anyNamed('limit')))
          .thenAnswer((_) async => [testProfile.toMap()]);

      final profile = await profileService.getOrCreateProfile();

      expect(profile.id, testProfile.id);
      verify(mockDatabase.query('user_profile', limit: 1)).called(1);
      verifyNever(mockDatabase.insert(any, any));
    });

    test('getOrCreateProfile creates a new profile if none exists', () async {
       when(mockDatabase.query(any, limit: anyNamed('limit')))
          .thenAnswer((_) async => []);
      when(mockDatabase.insert(any, any,
              conflictAlgorithm: anyNamed('conflictAlgorithm')))
          .thenAnswer((_) async => 1);

      final profile = await profileService.getOrCreateProfile();

      expect(profile, isA<UserProfile>());
      verify(mockDatabase.query('user_profile', limit: 1)).called(1);
      verify(mockDatabase.insert(
        'user_profile',
        any,
        conflictAlgorithm: ConflictAlgorithm.replace,
      )).called(1);
    });
  });
}
