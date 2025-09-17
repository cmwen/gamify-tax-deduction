import 'package:flutter_test/flutter_test.dart';
import 'package:gamified_tax_deduction/core/models/data_models.dart';
import 'package:gamified_tax_deduction/core/services/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ProfileService', () {
    late ProfileService profileService;

    setUp(() {
      profileService = ProfileService();
    });

    test('getProfile returns null when no profile is saved', () async {
      SharedPreferences.setMockInitialValues({});
      final profile = await profileService.getProfile();
      expect(profile, isNull);
    });

    test('saveProfile and getProfile work correctly', () async {
      SharedPreferences.setMockInitialValues({});
      const userProfile = UserProfile(
        incomeBracket: 'high',
        filingStatus: 'married',
      );

      await profileService.saveProfile(userProfile);
      final retrievedProfile = await profileService.getProfile();

      expect(retrievedProfile, isNotNull);
      expect(retrievedProfile!.incomeBracket, userProfile.incomeBracket);
      expect(retrievedProfile.filingStatus, userProfile.filingStatus);
    });

    test('getProfile returns the correct data for a saved profile', () async {
      SharedPreferences.setMockInitialValues({
        'user_income_bracket': 'low',
        'user_filing_status': 'single',
      });

      final profile = await profileService.getProfile();

      expect(profile, isNotNull);
      expect(profile!.incomeBracket, 'low');
      expect(profile.filingStatus, 'single');
    });
  });
}
