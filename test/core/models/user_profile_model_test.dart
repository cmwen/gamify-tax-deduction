import 'package:flutter_test/flutter_test.dart';
import 'package:gamified_tax_deduction/core/models/user_profile.dart';

void main() {
  group('UserProfile Model', () {
    test('fromMap creates a valid UserProfile object', () {
      final map = {
        'id': 'test_id',
        'filingStatus': 'FilingStatus.single',
        'incomeBracket': 'IncomeBracket.middle',
      };

      final profile = UserProfile.fromMap(map);

      expect(profile.id, 'test_id');
      expect(profile.filingStatus, FilingStatus.single);
      expect(profile.incomeBracket, IncomeBracket.middle);
    });

    test('toMap creates a valid map from a UserProfile object', () {
      final profile = UserProfile(
        id: 'test_id',
        filingStatus: FilingStatus.marriedFilingJointly,
        incomeBracket: IncomeBracket.high,
      );

      final map = profile.toMap();

      expect(map['id'], 'test_id');
      expect(map['filingStatus'], 'FilingStatus.marriedFilingJointly');
      expect(map['incomeBracket'], 'IncomeBracket.high');
    });
  });
}
