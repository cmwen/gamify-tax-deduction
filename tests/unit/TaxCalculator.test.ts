/**
 * Unit tests for TaxCalculator service
 */

import { TaxCalculator, createDefaultTaxConfiguration } from '../../src/core/TaxCalculator';
import { UserProfile } from '../../src/core/DataModels';

describe('TaxCalculator', () => {
  let calculator: TaxCalculator;
  let lowIncomeProfile: UserProfile;
  let mediumIncomeProfile: UserProfile;
  let highIncomeProfile: UserProfile;

  beforeEach(() => {
    calculator = new TaxCalculator(createDefaultTaxConfiguration());
    
    lowIncomeProfile = {
      incomeBracket: 'low',
      filingStatus: 'single',
      createdAt: new Date(),
      lastUpdated: new Date()
    };

    mediumIncomeProfile = {
      incomeBracket: 'medium',
      filingStatus: 'single',
      createdAt: new Date(),
      lastUpdated: new Date()
    };

    highIncomeProfile = {
      incomeBracket: 'high',
      filingStatus: 'married',
      createdAt: new Date(),
      lastUpdated: new Date()
    };
  });

  describe('calculateSavings', () => {
    test('should calculate correct savings for low income bracket', () => {
      const result = calculator.calculateSavings(10000, lowIncomeProfile); // $100 expense
      
      // Low bracket rate is 12%, so $100 * 0.12 = $12 (1200 cents)
      expect(result.potentialSaving).toBe(1200);
      expect(result.effectiveRate).toBe(0.12);
      expect(result.disclaimer).toContain('Estimate only');
    });

    test('should calculate correct savings for medium income bracket', () => {
      const result = calculator.calculateSavings(10000, mediumIncomeProfile); // $100 expense
      
      // Medium bracket rate is 22%, so $100 * 0.22 = $22 (2200 cents)
      expect(result.potentialSaving).toBe(2200);
      expect(result.effectiveRate).toBe(0.22);
    });

    test('should calculate correct savings for high income bracket', () => {
      const result = calculator.calculateSavings(10000, highIncomeProfile); // $100 expense
      
      // High bracket rate is 32%, so $100 * 0.32 = $32 (3200 cents)
      expect(result.potentialSaving).toBe(3200);
      expect(result.effectiveRate).toBe(0.32);
    });

    test('should apply deduction percentage correctly', () => {
      // Business meal at 50% deductible
      const result = calculator.calculateSavings(10000, mediumIncomeProfile, 0.5);
      
      // $100 * 0.5 * 0.22 = $11 (1100 cents)
      expect(result.potentialSaving).toBe(1100);
    });

    test('should handle large amounts correctly', () => {
      const result = calculator.calculateSavings(500000, highIncomeProfile); // $5000 expense
      
      // $5000 * 0.32 = $1600 (160000 cents)
      expect(result.potentialSaving).toBe(160000);
    });

    test('should handle small amounts correctly', () => {
      const result = calculator.calculateSavings(50, lowIncomeProfile); // $0.50 expense
      
      // $0.50 * 0.12 = $0.06 (6 cents)
      expect(result.potentialSaving).toBe(6);
    });

    test('should floor the result to avoid fractional cents', () => {
      const result = calculator.calculateSavings(333, lowIncomeProfile); // $3.33 expense
      
      // $3.33 * 0.12 = $0.3996, should floor to 39 cents
      expect(result.potentialSaving).toBe(39);
    });

    test('should throw error for invalid income bracket', () => {
      const invalidProfile = {
        ...lowIncomeProfile,
        incomeBracket: 'invalid' as any
      };

      expect(() => {
        calculator.calculateSavings(10000, invalidProfile);
      }).toThrow('Invalid income bracket');
    });
  });

  describe('getDeductionPercentage', () => {
    test('should return 50% for business meals', () => {
      expect(calculator.getDeductionPercentage('business_meal')).toBe(0.5);
    });

    test('should return 0% for entertainment', () => {
      expect(calculator.getDeductionPercentage('entertainment')).toBe(0.0);
    });

    test('should return 100% for office supplies', () => {
      expect(calculator.getDeductionPercentage('office_supplies')).toBe(1.0);
    });

    test('should return 100% for home office', () => {
      expect(calculator.getDeductionPercentage('home_office')).toBe(1.0);
    });

    test('should return 100% for equipment', () => {
      expect(calculator.getDeductionPercentage('equipment')).toBe(1.0);
    });

    test('should return 100% for unknown categories (conservative default)', () => {
      expect(calculator.getDeductionPercentage('unknown_category')).toBe(1.0);
    });

    test('should return 100% for general category', () => {
      expect(calculator.getDeductionPercentage('general')).toBe(1.0);
    });
  });

  describe('validateExpenseAmount', () => {
    test('should reject amounts less than 1 cent', () => {
      const result = calculator.validateExpenseAmount(0);
      expect(result.isValid).toBe(false);
      expect(result.warning).toContain('greater than $0.00');
    });

    test('should accept valid small amounts with warning', () => {
      const result = calculator.validateExpenseAmount(50); // $0.50
      expect(result.isValid).toBe(true);
      expect(result.warning).toContain('Small expense');
    });

    test('should accept normal amounts without warning', () => {
      const result = calculator.validateExpenseAmount(5000); // $50
      expect(result.isValid).toBe(true);
      expect(result.warning).toBeUndefined();
    });

    test('should accept large amounts with warning', () => {
      const result = calculator.validateExpenseAmount(10000001); // $100,000.01
      expect(result.isValid).toBe(true);
      expect(result.warning).toContain('Large expense');
    });

    test('should accept amounts at boundaries', () => {
      // $1.00 - should be valid without warning
      const result1 = calculator.validateExpenseAmount(100);
      expect(result1.isValid).toBe(true);
      expect(result1.warning).toBeUndefined();

      // $100,000.00 - should be valid with warning
      const result2 = calculator.validateExpenseAmount(10000000);
      expect(result2.isValid).toBe(true);
      expect(result2.warning).toBeUndefined();
    });
  });

  describe('calculateAnnualSavings', () => {
    test('should calculate annual savings correctly', () => {
      const result = calculator.calculateAnnualSavings(100000, mediumIncomeProfile); // $1000 total
      
      // $1000 * 0.22 = $220 (22000 cents)
      expect(result.potentialSaving).toBe(22000);
      expect(result.effectiveRate).toBe(0.22);
    });

    test('should handle zero total deductions', () => {
      const result = calculator.calculateAnnualSavings(0, lowIncomeProfile);
      expect(result.potentialSaving).toBe(0);
    });
  });

  describe('calculateQuarterlySavings', () => {
    test('should calculate quarterly savings with appropriate disclaimer', () => {
      const result = calculator.calculateQuarterlySavings(25000, mediumIncomeProfile); // $250
      
      // $250 * 0.22 = $55 (5500 cents)
      expect(result.potentialSaving).toBe(5500);
      expect(result.disclaimer).toContain('Quarterly estimate');
    });
  });

  describe('createDefaultTaxConfiguration', () => {
    test('should create valid default configuration', () => {
      const config = createDefaultTaxConfiguration();
      
      expect(config.incomeBrackets).toHaveProperty('low');
      expect(config.incomeBrackets).toHaveProperty('medium');
      expect(config.incomeBrackets).toHaveProperty('high');
      expect(config.filingStatuses).toHaveProperty('single');
      expect(config.filingStatuses).toHaveProperty('married');
      expect(config.lastUpdated).toBeInstanceOf(Date);
    });

    test('should have correct tax rates', () => {
      const config = createDefaultTaxConfiguration();
      
      expect(config.incomeBrackets.low.rate).toBe(0.12);
      expect(config.incomeBrackets.medium.rate).toBe(0.22);
      expect(config.incomeBrackets.high.rate).toBe(0.32);
    });

    test('should have correct standard deductions', () => {
      const config = createDefaultTaxConfiguration();
      
      // $13,750 for single filers
      expect(config.filingStatuses.single.standardDeduction).toBe(1375000);
      // $27,500 for married filers
      expect(config.filingStatuses.married.standardDeduction).toBe(2750000);
    });
  });

  describe('Integration scenarios', () => {
    test('should calculate realistic freelancer scenario', () => {
      // Freelancer with $60k income (medium bracket)
      const freelancer = mediumIncomeProfile;
      
      // $500 laptop expense
      const laptopSavings = calculator.calculateSavings(50000, freelancer);
      expect(laptopSavings.potentialSaving).toBe(11000); // $110
      
      // $50 business lunch (50% deductible)
      const lunchPercentage = calculator.getDeductionPercentage('business_meal');
      const lunchSavings = calculator.calculateSavings(5000, freelancer, lunchPercentage);
      expect(lunchSavings.potentialSaving).toBe(550); // $5.50
      
      // Total savings
      const totalSavings = laptopSavings.potentialSaving + lunchSavings.potentialSaving;
      expect(totalSavings).toBe(11550); // $115.50
    });

    test('should calculate realistic small business scenario', () => {
      // Small business owner with $120k income (high bracket)
      const businessOwner = highIncomeProfile;
      
      // $2000 office equipment
      const equipmentSavings = calculator.calculateSavings(200000, businessOwner);
      expect(equipmentSavings.potentialSaving).toBe(64000); // $640
      
      // $300 professional services
      const servicesSavings = calculator.calculateSavings(30000, businessOwner);
      expect(servicesSavings.potentialSaving).toBe(9600); // $96
      
      // Annual total
      const annualTotal = equipmentSavings.potentialSaving + servicesSavings.potentialSaving;
      expect(annualTotal).toBe(73600); // $736
    });
  });
});
