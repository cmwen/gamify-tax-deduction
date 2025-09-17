import 'package:flutter_test/flutter_test.dart';
import 'package:gamified_tax_deduction/core/models/user_profile.dart';
import 'package:gamified_tax_deduction/core/services/tax_calculation_service.dart';

void main() {
  group('TaxCalculationService', () {
    test('calculatePotentialSaving should return 22% of amount', () {
      const amount = 100.0;
      final result = TaxCalculationService.calculatePotentialSaving(amount);
      
      expect(result, 22.0);
    });

    test('calculateSavingWithProfile should use correct tax rates', () {
      const amount = 100.0;

      // Test low income bracket
      final lowResult = TaxCalculationService.calculateSavingWithProfile(
        amount, IncomeBracket.low, FilingStatus.single
      );
      expect(lowResult, 12.0);

      // Test medium income bracket
      final mediumResult = TaxCalculationService.calculateSavingWithProfile(
        amount, IncomeBracket.middle, FilingStatus.single
      );
      expect(mediumResult, 22.0);

      // Test high income bracket
      final highResult = TaxCalculationService.calculateSavingWithProfile(
        amount, IncomeBracket.high, FilingStatus.single
      );
      expect(highResult, 32.0);
    });
  });
}