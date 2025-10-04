/**
 * Educational Content Service
 * Provides contextual tax education tips based on user activity
 * Helps users learn about deductions while using the app
 */

import { EducationalTip, Receipt } from './DataModels';

export interface TipSuggestion {
  tip: EducationalTip;
  relevanceScore: number; // 0-100, higher is more relevant
  reason: string;
}

export class EducationalContentService {
  private tips: EducationalTip[];

  constructor() {
    this.tips = this.initializeEducationalTips();
  }

  /**
   * Initialize default educational content
   * @returns Array of educational tips
   */
  private initializeEducationalTips(): EducationalTip[] {
    return [
      // Business Meal Tips
      {
        id: 'business-meal-basic',
        title: 'Business Meal Deductions',
        content: '💡 Business meals are typically 50% deductible when discussing work with clients or colleagues. Keep notes about who attended and what was discussed.',
        category: 'business_meal',
        triggerConditions: {
          expenseAmount: { min: 1000, max: 20000 }, // $10-$200
          vendorType: ['restaurant', 'cafe', 'food'],
          category: ['business_meal']
        },
        displayCount: 0,
        maxDisplays: 3,
        priority: 10
      },
      {
        id: 'business-meal-limits',
        title: 'Meal Deduction Limits',
        content: '💡 Entertainment expenses (like sporting events) are generally not deductible, even if business is discussed. Focus on meals where business is the primary purpose.',
        category: 'business_meal',
        triggerConditions: {
          expenseAmount: { min: 5000 }, // $50+
          category: ['business_meal', 'entertainment']
        },
        displayCount: 0,
        maxDisplays: 2,
        priority: 8
      },

      // Home Office Tips
      {
        id: 'home-office-basics',
        title: 'Home Office Deduction',
        content: '💡 Home office expenses can include a portion of your rent, utilities, and internet costs. The space must be used regularly and exclusively for business.',
        category: 'home_office',
        triggerConditions: {
          category: ['home_office', 'utilities', 'internet']
        },
        displayCount: 0,
        maxDisplays: 3,
        priority: 9
      },
      {
        id: 'home-office-simplified',
        title: 'Simplified Home Office Method',
        content: '💡 The IRS offers a simplified method: deduct $5 per square foot of home office space, up to 300 square feet ($1,500 maximum). This can be easier than tracking actual expenses.',
        category: 'home_office',
        triggerConditions: {
          category: ['home_office']
        },
        displayCount: 0,
        maxDisplays: 2,
        priority: 7
      },

      // Equipment Tips
      {
        id: 'equipment-section179',
        title: 'Equipment Deductions',
        content: '💡 Section 179 allows you to deduct the full cost of qualifying equipment in the year of purchase, rather than depreciating it over several years. Great for computers, furniture, and machinery!',
        category: 'equipment',
        triggerConditions: {
          expenseAmount: { min: 50000 }, // $500+
          category: ['equipment', 'office_supplies']
        },
        displayCount: 0,
        maxDisplays: 3,
        priority: 10
      },
      {
        id: 'equipment-depreciation',
        title: 'Depreciation vs. Immediate Deduction',
        content: '💡 Business equipment over $2,500 may need to be depreciated over several years instead of deducted immediately. Consult a tax professional for large purchases.',
        category: 'equipment',
        triggerConditions: {
          expenseAmount: { min: 250000 } // $2,500+
        },
        displayCount: 0,
        maxDisplays: 2,
        priority: 9
      },

      // General Tips
      {
        id: 'general-recordkeeping',
        title: 'Keep Good Records',
        content: '💡 The IRS recommends keeping receipts and records for at least 3 years. This app helps you organize everything in one place!',
        category: 'general',
        triggerConditions: {},
        displayCount: 0,
        maxDisplays: 2,
        priority: 5
      },
      {
        id: 'general-ordinary-necessary',
        title: 'Ordinary and Necessary Test',
        content: '💡 To be deductible, expenses must be both "ordinary" (common in your industry) and "necessary" (helpful for your business). When in doubt, ask yourself: would most people in my profession have this expense?',
        category: 'general',
        triggerConditions: {},
        displayCount: 0,
        maxDisplays: 3,
        priority: 6
      },
      {
        id: 'general-mixed-use',
        title: 'Personal vs. Business Use',
        content: '💡 If you use something for both personal and business purposes (like your phone), you can only deduct the business portion. Keep track of your business usage percentage.',
        category: 'general',
        triggerConditions: {},
        displayCount: 0,
        maxDisplays: 3,
        priority: 7
      },
      {
        id: 'general-documentation',
        title: 'Documentation Best Practices',
        content: '💡 For each expense, note: date, amount, business purpose, and who was involved. This makes tax time much easier and protects you in an audit.',
        category: 'general',
        triggerConditions: {},
        displayCount: 0,
        maxDisplays: 2,
        priority: 8
      },

      // Professional Services
      {
        id: 'professional-services',
        title: 'Professional Service Deductions',
        content: '💡 Legal fees, accounting costs, and consulting services directly related to your business are fully deductible. Keep invoices and statements organized.',
        category: 'general',
        triggerConditions: {
          expenseAmount: { min: 10000 }, // $100+
          category: ['professional_services']
        },
        displayCount: 0,
        maxDisplays: 2,
        priority: 7
      },

      // Travel Tips
      {
        id: 'travel-overnight',
        title: 'Business Travel Deductions',
        content: '💡 When traveling overnight for business, you can deduct transportation, lodging, and 50% of meals. Keep all receipts and document the business purpose.',
        category: 'general',
        triggerConditions: {
          expenseAmount: { min: 10000 }, // $100+
          category: ['travel', 'lodging']
        },
        displayCount: 0,
        maxDisplays: 3,
        priority: 9
      }
    ];
  }

  /**
   * Get relevant tips for a newly scanned receipt
   * @param receipt - The scanned receipt
   * @returns Array of relevant tips, sorted by relevance
   */
  getSuggestedTips(receipt: Receipt): TipSuggestion[] {
    const suggestions: TipSuggestion[] = [];

    for (const tip of this.tips) {
      // Skip if already shown max times
      if (tip.displayCount >= tip.maxDisplays) {
        continue;
      }

      const relevance = this.calculateRelevance(tip, receipt);
      if (relevance > 0) {
        suggestions.push({
          tip,
          relevanceScore: relevance,
          reason: this.getRelevanceReason(tip, receipt)
        });
      }
    }

    // Sort by relevance score (descending) and priority (descending)
    suggestions.sort((a, b) => {
      if (b.relevanceScore !== a.relevanceScore) {
        return b.relevanceScore - a.relevanceScore;
      }
      return b.tip.priority - a.tip.priority;
    });

    return suggestions.slice(0, 2); // Return top 2 most relevant tips
  }

  /**
   * Calculate relevance score for a tip based on receipt
   * @param tip - Educational tip
   * @param receipt - Receipt to match against
   * @returns Relevance score (0-100)
   */
  private calculateRelevance(tip: EducationalTip, receipt: Receipt): number {
    let score = 0;
    const conditions = tip.triggerConditions;

    // Base score from priority
    score += tip.priority;

    // Category match (highest priority)
    if (receipt.category && conditions.categories?.includes(receipt.category)) {
      score += 40;
    } else if (tip.category === 'general') {
      score += 10; // General tips are always somewhat relevant
    }

    // Amount range match
    if (conditions.expenseAmountMin || conditions.expenseAmountMax) {
      const min = conditions.expenseAmountMin || 0;
      const max = conditions.expenseAmountMax || Number.MAX_SAFE_INTEGER;
      
      if (receipt.totalAmount >= min && receipt.totalAmount <= max) {
        score += 30;
      }
    }

    // Vendor type match (if we had vendor categorization)
    if (receipt.vendorName && conditions.vendorTypes) {
      const vendorLower = receipt.vendorName.toLowerCase();
      const hasMatch = conditions.vendorTypes.some(type => 
        vendorLower.includes(type.toLowerCase())
      );
      if (hasMatch) {
        score += 20;
      }
    }

    // Reduce score based on how many times already shown
    const displayPenalty = (tip.displayCount / tip.maxDisplays) * 20;
    score -= displayPenalty;

    return Math.max(0, Math.min(100, score));
  }

  /**
   * Get human-readable reason for tip relevance
   * @param tip - Educational tip
   * @param receipt - Receipt that triggered the tip
   * @returns Explanation of relevance
   */
  private getRelevanceReason(tip: EducationalTip, receipt: Receipt): string {
    if (receipt.category && tip.triggerConditions.categories?.includes(receipt.category)) {
      return `Relevant to ${receipt.category} expenses`;
    }
    
    if (tip.triggerConditions.expenseAmountMin && 
        receipt.totalAmount >= tip.triggerConditions.expenseAmountMin) {
      return 'Relevant for this expense amount';
    }

    return 'General tax deduction tip';
  }

  /**
   * Mark a tip as displayed
   * @param tipId - ID of the tip that was shown
   */
  markTipAsDisplayed(tipId: string): void {
    const tip = this.tips.find(t => t.id === tipId);
    if (tip) {
      tip.displayCount += 1;
    }
  }

  /**
   * Get a random general tip for dashboard display
   * @returns Random general tip that hasn't been shown too many times
   */
  getRandomGeneralTip(): EducationalTip | null {
    const availableTips = this.tips.filter(
      t => t.category === 'general' && t.displayCount < t.maxDisplays
    );

    if (availableTips.length === 0) {
      return null;
    }

    const randomIndex = Math.floor(Math.random() * availableTips.length);
    return availableTips[randomIndex];
  }

  /**
   * Get tips by category
   * @param category - Tip category
   * @returns Array of tips in that category
   */
  getTipsByCategory(category: EducationalTip['category']): EducationalTip[] {
    return this.tips.filter(t => t.category === category);
  }

  /**
   * Reset display counts (useful for testing or new year)
   */
  resetDisplayCounts(): void {
    this.tips.forEach(tip => {
      tip.displayCount = 0;
    });
  }

  /**
   * Get all tips
   * @returns Array of all educational tips
   */
  getAllTips(): EducationalTip[] {
    return [...this.tips];
  }
}
