import '../models/user_profile.dart';

/// Tax calculation service for estimating potential tax savings
/// Simplified calculations for MVP demonstration
class TaxCalculationService {
  static const Map<TaxCountry, Map<IncomeBracket, double>> _countryBracketRates = {
    TaxCountry.unitedStates: {
      IncomeBracket.lowest: 0.10,
      IncomeBracket.low: 0.12,
      IncomeBracket.middle: 0.22,
      IncomeBracket.high: 0.32,
      IncomeBracket.highest: 0.37,
    },
    TaxCountry.australia: {
      IncomeBracket.lowest: 0.00, // Tax-free threshold up to ~18k AUD
      IncomeBracket.low: 0.19,
      IncomeBracket.middle: 0.325,
      IncomeBracket.high: 0.37,
      IncomeBracket.highest: 0.45,
    },
  };

  static const Map<FilingStatus, double> _filingModifiers = {
    FilingStatus.single: 0.0,
    FilingStatus.marriedFilingJointly: -0.02,
    FilingStatus.marriedFilingSeparately: 0.0,
    FilingStatus.headOfHousehold: -0.01,
    FilingStatus.qualifyingWidow: -0.015,
  };

  static const double _defaultRate = 0.22;

  /// Calculate potential tax saving for a business expense using a default profile.
  static double calculatePotentialSaving(
    double amount, {
    TaxCountry country = TaxCountry.unitedStates,
  }) {
    final rates = _countryBracketRates[country] ?? _countryBracketRates[TaxCountry.unitedStates]!;
    final baseRate = rates[IncomeBracket.middle] ?? _defaultRate;
    return amount * baseRate;
  }

  /// Calculate tax savings based on user profile selections.
  static double calculateSavingWithProfile(
    double amount,
    IncomeBracket incomeBracket,
    FilingStatus filingStatus,
    TaxCountry country,
  ) {
    final rates = _countryBracketRates[country] ?? _countryBracketRates[TaxCountry.unitedStates]!;
    final baseRate = rates[incomeBracket] ?? _defaultRate;
    final modifier = _filingModifiers[filingStatus] ?? 0.0;
    final adjustedRate = (baseRate + modifier).clamp(0.0, 0.60);
    return amount * adjustedRate;
  }
}
