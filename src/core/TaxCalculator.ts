/**
 * Tax Calculation Service
 * Calculates potential tax savings based on expense amounts and user profile
 * Uses conservative estimates to avoid over-promising
 */

import { UserProfile, TaxConfiguration } from './DataModels';

export interface TaxCalculationResult {
  potentialSaving: number; // In cents
  effectiveRate: number; // Decimal (e.g., 0.22 for 22%)
  disclaimer: string;
}

export class TaxCalculator {
  private config: TaxConfiguration;

  constructor(config: TaxConfiguration) {
    this.config = config;
  }

  /**
   * Calculate potential tax savings for a given expense amount
   * @param amountInCents - Expense amount in cents
   * @param userProfile - User's tax profile (income bracket and filing status)
   * @param deductionPercentage - Percentage of expense that's deductible (default 100%)
   * @returns Tax calculation result with potential savings
   */
  calculateSavings(
    amountInCents: number,
    userProfile: UserProfile,
    deductionPercentage: number = 1.0
  ): TaxCalculationResult {
    // Get the user's effective tax rate based on income bracket
    const bracket = this.config.incomeBrackets[userProfile.incomeBracket];
    if (!bracket) {
      throw new Error(`Invalid income bracket: ${userProfile.incomeBracket}`);
    }

    const effectiveRate = bracket.rate;
    
    // Calculate deductible amount
    const deductibleAmount = amountInCents * deductionPercentage;
    
    // Calculate potential tax savings (conservative estimate)
    const potentialSaving = Math.floor(deductibleAmount * effectiveRate);

    return {
      potentialSaving,
      effectiveRate,
      disclaimer: 'Estimate only. Consult a tax professional for accurate advice.'
    };
  }

  /**
   * Calculate annual tax savings based on total deductions
   * @param totalDeductionsInCents - Total deductions for the year in cents
   * @param userProfile - User's tax profile
   * @returns Estimated annual tax savings
   */
  calculateAnnualSavings(
    totalDeductionsInCents: number,
    userProfile: UserProfile
  ): TaxCalculationResult {
    return this.calculateSavings(totalDeductionsInCents, userProfile, 1.0);
  }

  /**
   * Get deduction percentage for specific expense categories
   * Some expenses (like business meals) are only partially deductible
   * @param category - Expense category
   * @returns Deduction percentage (0-1)
   */
  getDeductionPercentage(category: string): number {
    const deductionRules: Record<string, number> = {
      'business_meal': 0.5, // 50% deductible
      'entertainment': 0.0, // Generally not deductible after TCJA
      'home_office': 1.0,
      'office_supplies': 1.0,
      'equipment': 1.0,
      'professional_services': 1.0,
      'travel': 1.0,
      'vehicle': 1.0, // Simplified - actual calculation more complex
      'general': 1.0
    };

    return deductionRules[category] || 1.0;
  }

  /**
   * Validate if an expense amount is reasonable for tax deduction
   * Helps prevent user errors or unrealistic entries
   * @param amountInCents - Expense amount in cents
   * @returns Validation result with warnings if applicable
   */
  validateExpenseAmount(amountInCents: number): { 
    isValid: boolean; 
    warning?: string;
  } {
    // Minimum reasonable expense: $0.01
    if (amountInCents < 1) {
      return {
        isValid: false,
        warning: 'Expense amount must be greater than $0.00'
      };
    }

    // Maximum reasonable single expense: $100,000
    if (amountInCents > 10000000) {
      return {
        isValid: true,
        warning: 'Large expense detected. Ensure this is a legitimate business expense.'
      };
    }

    // Very small expenses: Under $1.00
    if (amountInCents < 100) {
      return {
        isValid: true,
        warning: 'Small expense. Consider batching similar expenses for easier tracking.'
      };
    }

    return { isValid: true };
  }

  /**
   * Get estimated quarterly tax savings
   * Useful for quarterly estimated tax payments
   * @param totalDeductionsInCents - Total deductions for the quarter in cents
   * @param userProfile - User's tax profile
   * @returns Quarterly tax savings estimate
   */
  calculateQuarterlySavings(
    totalDeductionsInCents: number,
    userProfile: UserProfile
  ): TaxCalculationResult {
    const annualSavings = this.calculateAnnualSavings(totalDeductionsInCents, userProfile);
    
    return {
      ...annualSavings,
      disclaimer: 'Quarterly estimate. Actual quarterly tax impact may vary based on other income and deductions.'
    };
  }
}

/**
 * Default tax configuration factory
 * Returns current year tax rates (2024 estimates)
 */
export function createDefaultTaxConfiguration(): TaxConfiguration {
  return {
    incomeBrackets: {
      low: { min: 0, max: 50000, rate: 0.12 }, // 12% federal rate
      medium: { min: 50001, max: 100000, rate: 0.22 }, // 22% federal rate
      high: { min: 100001, max: Number.MAX_SAFE_INTEGER, rate: 0.32 } // 32% federal rate (24% + state estimate)
    },
    filingStatuses: {
      single: { standardDeduction: 1375000 }, // $13,750 in cents (2024)
      married: { standardDeduction: 2750000 }  // $27,500 in cents (2024)
    },
    lastUpdated: new Date()
  };
}
