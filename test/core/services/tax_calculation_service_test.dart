import 'package:flutter_test/flutter_test.dart';
import 'package:gamified_tax_deduction/core/models/user_profile.dart';
import 'package:gamified_tax_deduction/core/services/tax_calculation_service.dart';

void main() {
  group('TaxCalculationService', () {
    test('calculatePotentialSaving should default to US middle bracket', () {
      const amount = 100.0;
      final result = TaxCalculationService.calculatePotentialSaving(amount);

      expect(result, 22.0);
    });

    test('calculatePotentialSaving should respect selected country', () {
      const amount = 100.0;
      final result = TaxCalculationService.calculatePotentialSaving(
        amount,
        country: TaxCountry.australia,
      );

      expect(result, closeTo(32.5, 0.001));
    });

    test('calculateSavingWithProfile should use correct tax rates', () {
      const amount = 100.0;

      // Test low income bracket
      final lowResult = TaxCalculationService.calculateSavingWithProfile(
        amount,
        IncomeBracket.low,
        FilingStatus.single,
        TaxCountry.unitedStates,
      );
      expect(lowResult, 12.0);

      // Test medium income bracket
      final mediumResult = TaxCalculationService.calculateSavingWithProfile(
        amount,
        IncomeBracket.middle,
        FilingStatus.single,
        TaxCountry.unitedStates,
      );
      expect(mediumResult, 22.0);

      // Test high income bracket
      final highResult = TaxCalculationService.calculateSavingWithProfile(
        amount,
        IncomeBracket.high,
        FilingStatus.single,
        TaxCountry.unitedStates,
      );
      expect(highResult, 32.0);
    });

    test('calculateSavingWithProfile adapts rates for Australia', () {
      const amount = 100.0;

      final lowResult = TaxCalculationService.calculateSavingWithProfile(
        amount,
        IncomeBracket.low,
        FilingStatus.single,
        TaxCountry.australia,
      );
      expect(lowResult, closeTo(19.0, 0.001));

      final highestResult = TaxCalculationService.calculateSavingWithProfile(
        amount,
        IncomeBracket.highest,
        FilingStatus.single,
        TaxCountry.australia,
      );
      expect(highestResult, closeTo(45.0, 0.001));
    });
  });
}
