/// Tax calculation service for estimating potential tax savings
/// Simplified calculations for MVP demonstration
class TaxCalculationService {
  // Simplified tax deduction rate - in reality this would be much more complex
  static const double standardDeductionRate = 0.22; // 22% tax bracket estimate

  /// Calculate potential tax saving for a business expense
  /// This is a simplified calculation for demonstration purposes
  static double calculatePotentialSaving(double amount) {
    // For demo purposes, assume business expenses are 100% deductible
    // and the user is in a 22% tax bracket
    return amount * standardDeductionRate;
  }

  /// Calculate tax savings based on user profile
  /// Future enhancement: use actual income bracket and filing status
  static double calculateSavingWithProfile(
    double amount,
    String incomeBracket,
    String filingStatus,
  ) {
    double taxRate;
    
    switch (incomeBracket) {
      case 'low':
        taxRate = 0.12; // 12% tax bracket
        break;
      case 'medium':
        taxRate = 0.22; // 22% tax bracket
        break;
      case 'high':
        taxRate = 0.32; // 32% tax bracket
        break;
      default:
        taxRate = 0.22; // Default to 22%
    }

    // Future: adjust for filing status differences
    return amount * taxRate;
  }
}