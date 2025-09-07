import 'package:flutter_test/flutter_test.dart';
import 'package:gamified_tax_deduction/core/models/data_models.dart';

void main() {
  group('UserProfile', () {
    test('should create UserProfile with required fields', () {
      const profile = UserProfile(
        incomeBracket: 'medium',
        filingStatus: 'single',
      );

      expect(profile.incomeBracket, 'medium');
      expect(profile.filingStatus, 'single');
    });

    test('should convert to/from JSON correctly', () {
      const profile = UserProfile(
        incomeBracket: 'high',
        filingStatus: 'married',
      );

      final json = profile.toJson();
      final fromJson = UserProfile.fromJson(json);

      expect(fromJson.incomeBracket, profile.incomeBracket);
      expect(fromJson.filingStatus, profile.filingStatus);
    });
  });

  group('Receipt', () {
    test('should create Receipt with required fields', () {
      final receipt = Receipt(
        id: 'test-id',
        createdAt: DateTime(2023, 1, 1),
        imagePath: '/path/to/image.jpg',
        totalAmount: 25.99,
        potentialTaxSaving: 5.72,
      );

      expect(receipt.id, 'test-id');
      expect(receipt.totalAmount, 25.99);
      expect(receipt.potentialTaxSaving, 5.72);
    });

    test('should convert to/from Map correctly', () {
      final receipt = Receipt(
        id: 'test-id',
        createdAt: DateTime(2023, 1, 1),
        imagePath: '/path/to/image.jpg',
        vendorName: 'Test Vendor',
        totalAmount: 25.99,
        potentialTaxSaving: 5.72,
        category: 'office',
      );

      final map = receipt.toMap();
      final fromMap = Receipt.fromMap(map);

      expect(fromMap.id, receipt.id);
      expect(fromMap.vendorName, receipt.vendorName);
      expect(fromMap.totalAmount, receipt.totalAmount);
      expect(fromMap.potentialTaxSaving, receipt.potentialTaxSaving);
      expect(fromMap.category, receipt.category);
    });
  });
}