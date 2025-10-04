import Foundation

// MARK: - Tax Calculation Result
struct TaxCalculationResult {
    let potentialSaving: Int // In cents
    let effectiveRate: Double // Decimal (e.g., 0.22 for 22%)
    let disclaimer: String
}

// MARK: - Tax Calculator
class TaxCalculator {
    private let config: TaxConfiguration
    
    init(config: TaxConfiguration = .default) {
        self.config = config
    }
    
    /// Calculate potential tax savings for a given expense amount
    /// - Parameters:
    ///   - amountInCents: Expense amount in cents
    ///   - userProfile: User's tax profile (income bracket and filing status)
    ///   - deductionPercentage: Percentage of expense that's deductible (default 1.0)
    /// - Returns: Tax calculation result with potential savings
    func calculateSavings(
        amountInCents: Int,
        userProfile: UserProfile,
        deductionPercentage: Double = 1.0
    ) -> TaxCalculationResult {
        // Get the user's effective tax rate based on income bracket
        guard let bracket = config.incomeBrackets[userProfile.incomeBracket.rawValue] else {
            fatalError("Invalid income bracket: \(userProfile.incomeBracket)")
        }
        
        let effectiveRate = bracket.rate
        
        // Calculate deductible amount
        let deductibleAmount = Double(amountInCents) * deductionPercentage
        
        // Calculate potential tax savings (conservative estimate)
        let potentialSaving = Int(floor(deductibleAmount * effectiveRate))
        
        return TaxCalculationResult(
            potentialSaving: potentialSaving,
            effectiveRate: effectiveRate,
            disclaimer: "Estimate only. Consult a tax professional for accurate advice."
        )
    }
    
    /// Calculate annual tax savings based on total deductions
    /// - Parameters:
    ///   - totalDeductionsInCents: Total deductions for the year in cents
    ///   - userProfile: User's tax profile
    /// - Returns: Estimated annual tax savings
    func calculateAnnualSavings(
        totalDeductionsInCents: Int,
        userProfile: UserProfile
    ) -> TaxCalculationResult {
        return calculateSavings(
            amountInCents: totalDeductionsInCents,
            userProfile: userProfile,
            deductionPercentage: 1.0
        )
    }
    
    /// Get deduction percentage for specific expense categories
    /// Some expenses (like business meals) are only partially deductible
    /// - Parameter category: Expense category
    /// - Returns: Deduction percentage (0-1)
    func getDeductionPercentage(for category: String) -> Double {
        let deductionRules: [String: Double] = [
            "business_meal": 0.5, // 50% deductible
            "entertainment": 0.0, // Generally not deductible after TCJA
            "home_office": 1.0,
            "office_supplies": 1.0,
            "equipment": 1.0,
            "professional_services": 1.0,
            "travel": 1.0,
            "vehicle": 1.0, // Simplified - actual calculation more complex
            "general": 1.0
        ]
        
        return deductionRules[category] ?? 1.0
    }
    
    /// Validate if an expense amount is reasonable for tax deduction
    /// Helps prevent user errors or unrealistic entries
    /// - Parameter amountInCents: Expense amount in cents
    /// - Returns: Validation result with warnings if applicable
    func validateExpenseAmount(_ amountInCents: Int) -> (isValid: Bool, warning: String?) {
        // Minimum reasonable expense: $0.01
        if amountInCents < 1 {
            return (false, "Expense amount must be greater than $0.00")
        }
        
        // Maximum reasonable single expense: $100,000
        if amountInCents > 10_000_000 {
            return (true, "Large expense detected. Ensure this is a legitimate business expense.")
        }
        
        // Very small expenses: Under $1.00
        if amountInCents < 100 {
            return (true, "Small expense. Consider batching similar expenses for easier tracking.")
        }
        
        return (true, nil)
    }
    
    /// Get estimated quarterly tax savings
    /// Useful for quarterly estimated tax payments
    /// - Parameters:
    ///   - totalDeductionsInCents: Total deductions for the quarter in cents
    ///   - userProfile: User's tax profile
    /// - Returns: Quarterly tax savings estimate
    func calculateQuarterlySavings(
        totalDeductionsInCents: Int,
        userProfile: UserProfile
    ) -> TaxCalculationResult {
        let annualResult = calculateAnnualSavings(
            totalDeductionsInCents: totalDeductionsInCents,
            userProfile: userProfile
        )
        
        return TaxCalculationResult(
            potentialSaving: annualResult.potentialSaving,
            effectiveRate: annualResult.effectiveRate,
            disclaimer: "Quarterly estimate. Actual quarterly tax impact may vary based on other income and deductions."
        )
    }
}
