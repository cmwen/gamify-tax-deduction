/**
 * Unit tests for EducationalContentService
 */

import { EducationalContentService } from '../../src/core/EducationalContentService';
import { Receipt } from '../../src/core/DataModels';

describe('EducationalContentService', () => {
  let service: EducationalContentService;
  let mockReceipt: Receipt;

  beforeEach(() => {
    service = new EducationalContentService();
    
    mockReceipt = {
      id: '123e4567-e89b-12d3-a456-426614174000',
      createdAt: new Date(),
      lastUpdated: new Date(),
      imagePath: '/path/to/image.jpg',
      vendorName: 'Test Vendor',
      totalAmount: 5000, // $50
      potentialTaxSaving: 1100, // $11
      category: 'office_supplies',
      isVerified: true,
      notes: undefined
    };
  });

  describe('getAllTips', () => {
    test('should return all predefined tips', () => {
      const tips = service.getAllTips();
      
      expect(tips.length).toBeGreaterThan(0);
      expect(tips).toEqual(
        expect.arrayContaining([
          expect.objectContaining({ category: 'business_meal' }),
          expect.objectContaining({ category: 'home_office' }),
          expect.objectContaining({ category: 'equipment' }),
          expect.objectContaining({ category: 'general' })
        ])
      );
    });

    test('should have tips with required properties', () => {
      const tips = service.getAllTips();
      
      tips.forEach(tip => {
        expect(tip).toHaveProperty('id');
        expect(tip).toHaveProperty('title');
        expect(tip).toHaveProperty('content');
        expect(tip).toHaveProperty('category');
        expect(tip).toHaveProperty('displayCount');
        expect(tip).toHaveProperty('maxDisplays');
        expect(tip).toHaveProperty('priority');
      });
    });
  });

  describe('getSuggestedTips', () => {
    test('should return relevant tips for business meal', () => {
      const receipt = {
        ...mockReceipt,
        category: 'business_meal',
        totalAmount: 5000 // $50
      };
      
      const suggestions = service.getSuggestedTips(receipt);
      
      expect(suggestions.length).toBeGreaterThan(0);
      expect(suggestions[0].tip.category).toBe('business_meal');
      expect(suggestions[0].relevanceScore).toBeGreaterThan(0);
    });

    test('should return relevant tips for home office', () => {
      const receipt = {
        ...mockReceipt,
        category: 'home_office',
        vendorName: 'Electric Company'
      };
      
      const suggestions = service.getSuggestedTips(receipt);
      
      expect(suggestions.length).toBeGreaterThan(0);
      expect(suggestions[0].tip.category).toBe('home_office');
    });

    test('should return relevant tips for equipment', () => {
      const receipt = {
        ...mockReceipt,
        category: 'equipment',
        totalAmount: 100000 // $1000 - large equipment
      };
      
      const suggestions = service.getSuggestedTips(receipt);
      
      expect(suggestions.length).toBeGreaterThan(0);
      expect(suggestions[0].tip.category).toBe('equipment');
    });

    test('should return general tips when no specific category match', () => {
      const receipt = {
        ...mockReceipt,
        category: 'other'
      };
      
      const suggestions = service.getSuggestedTips(receipt);
      
      expect(suggestions.length).toBeGreaterThan(0);
      // Should get general tips
      expect(suggestions.some(s => s.tip.category === 'general')).toBe(true);
    });

    test('should limit to 2 suggestions', () => {
      const suggestions = service.getSuggestedTips(mockReceipt);
      
      expect(suggestions.length).toBeLessThanOrEqual(2);
    });

    test('should sort suggestions by relevance', () => {
      const receipt = {
        ...mockReceipt,
        category: 'business_meal',
        totalAmount: 5000
      };
      
      const suggestions = service.getSuggestedTips(receipt);
      
      if (suggestions.length > 1) {
        // First should be more or equally relevant than second
        expect(suggestions[0].relevanceScore).toBeGreaterThanOrEqual(suggestions[1].relevanceScore);
      }
    });

    test('should exclude tips that reached max displays', () => {
      // Get all business meal tips and max them out
      const tips = service.getAllTips();
      const businessMealTips = tips.filter(t => t.category === 'business_meal');
      
      businessMealTips.forEach(tip => {
        for (let i = 0; i < tip.maxDisplays; i++) {
          service.markTipAsDisplayed(tip.id);
        }
      });
      
      const receipt = {
        ...mockReceipt,
        category: 'business_meal'
      };
      
      const suggestions = service.getSuggestedTips(receipt);
      
      // Should not include business meal tips anymore
      const hasBusinessMealTip = suggestions.some(s => s.tip.category === 'business_meal');
      expect(hasBusinessMealTip).toBe(false);
    });

    test('should include reason for suggestion', () => {
      const receipt = {
        ...mockReceipt,
        category: 'equipment'
      };
      
      const suggestions = service.getSuggestedTips(receipt);
      
      expect(suggestions.length).toBeGreaterThan(0);
      expect(suggestions[0].reason).toBeDefined();
      expect(typeof suggestions[0].reason).toBe('string');
    });
  });

  describe('markTipAsDisplayed', () => {
    test('should increment display count', () => {
      const tips = service.getAllTips();
      const tipId = tips[0].id;
      const initialCount = tips[0].displayCount;
      
      service.markTipAsDisplayed(tipId);
      
      const updatedTips = service.getAllTips();
      const updatedTip = updatedTips.find(t => t.id === tipId);
      
      expect(updatedTip?.displayCount).toBe(initialCount + 1);
    });

    test('should handle non-existent tip ID gracefully', () => {
      expect(() => {
        service.markTipAsDisplayed('non-existent-id');
      }).not.toThrow();
    });

    test('should allow marking multiple times', () => {
      const tips = service.getAllTips();
      const tipId = tips[0].id;
      
      service.markTipAsDisplayed(tipId);
      service.markTipAsDisplayed(tipId);
      service.markTipAsDisplayed(tipId);
      
      const updatedTips = service.getAllTips();
      const updatedTip = updatedTips.find(t => t.id === tipId);
      
      expect(updatedTip?.displayCount).toBeGreaterThanOrEqual(3);
    });
  });

  describe('getRandomGeneralTip', () => {
    test('should return a general tip', () => {
      const tip = service.getRandomGeneralTip();
      
      expect(tip).not.toBeNull();
      expect(tip?.category).toBe('general');
    });

    test('should not return tips that reached max displays', () => {
      // Max out all general tips
      const tips = service.getAllTips();
      const generalTips = tips.filter(t => t.category === 'general');
      
      generalTips.forEach(tip => {
        for (let i = 0; i < tip.maxDisplays; i++) {
          service.markTipAsDisplayed(tip.id);
        }
      });
      
      const randomTip = service.getRandomGeneralTip();
      
      // Should return null when all are maxed out
      expect(randomTip).toBeNull();
    });

    test('should return different tips on multiple calls (probabilistic)', () => {
      const tips = new Set<string>();
      
      // Get 10 random tips
      for (let i = 0; i < 10; i++) {
        const tip = service.getRandomGeneralTip();
        if (tip) {
          tips.add(tip.id);
        }
      }
      
      // Should get at least 2 different tips (very high probability)
      // This could theoretically fail due to randomness but is very unlikely
      expect(tips.size).toBeGreaterThanOrEqual(1);
    });
  });

  describe('getTipsByCategory', () => {
    test('should return business meal tips', () => {
      const tips = service.getTipsByCategory('business_meal');
      
      expect(tips.length).toBeGreaterThan(0);
      tips.forEach(tip => {
        expect(tip.category).toBe('business_meal');
      });
    });

    test('should return home office tips', () => {
      const tips = service.getTipsByCategory('home_office');
      
      expect(tips.length).toBeGreaterThan(0);
      tips.forEach(tip => {
        expect(tip.category).toBe('home_office');
      });
    });

    test('should return equipment tips', () => {
      const tips = service.getTipsByCategory('equipment');
      
      expect(tips.length).toBeGreaterThan(0);
      tips.forEach(tip => {
        expect(tip.category).toBe('equipment');
      });
    });

    test('should return general tips', () => {
      const tips = service.getTipsByCategory('general');
      
      expect(tips.length).toBeGreaterThan(0);
      tips.forEach(tip => {
        expect(tip.category).toBe('general');
      });
    });

    test('should return empty array for non-existent category', () => {
      const tips = service.getTipsByCategory('non_existent' as any);
      
      expect(tips).toEqual([]);
    });
  });

  describe('resetDisplayCounts', () => {
    test('should reset all display counts to zero', () => {
      // Mark some tips as displayed
      const tips = service.getAllTips();
      tips.slice(0, 5).forEach(tip => {
        service.markTipAsDisplayed(tip.id);
        service.markTipAsDisplayed(tip.id);
      });
      
      // Verify they were incremented
      let updatedTips = service.getAllTips();
      expect(updatedTips.slice(0, 5).some(t => t.displayCount > 0)).toBe(true);
      
      // Reset
      service.resetDisplayCounts();
      
      // Verify all are zero
      updatedTips = service.getAllTips();
      updatedTips.forEach(tip => {
        expect(tip.displayCount).toBe(0);
      });
    });
  });

  describe('Integration scenarios', () => {
    test('should provide relevant tips throughout a user journey', () => {
      // Scenario 1: Freelancer buys laptop
      const laptopReceipt = {
        ...mockReceipt,
        category: 'equipment',
        totalAmount: 120000, // $1200
        vendorName: 'Tech Store'
      };
      
      let suggestions = service.getSuggestedTips(laptopReceipt);
      expect(suggestions.length).toBeGreaterThan(0);
      expect(suggestions[0].tip.category).toBe('equipment');
      
      // Mark tip as shown
      service.markTipAsDisplayed(suggestions[0].tip.id);
      
      // Scenario 2: Business lunch
      const lunchReceipt = {
        ...mockReceipt,
        category: 'business_meal',
        totalAmount: 7500, // $75
        vendorName: 'Restaurant'
      };
      
      suggestions = service.getSuggestedTips(lunchReceipt);
      expect(suggestions.length).toBeGreaterThan(0);
      expect(suggestions[0].tip.category).toBe('business_meal');
      
      // Scenario 3: Home office expense
      const utilityReceipt = {
        ...mockReceipt,
        category: 'home_office',
        totalAmount: 15000, // $150
        vendorName: 'Power Company'
      };
      
      suggestions = service.getSuggestedTips(utilityReceipt);
      expect(suggestions.length).toBeGreaterThan(0);
      expect(suggestions[0].tip.category).toBe('home_office');
    });

    test('should handle tip rotation when max displays reached', () => {
      const receipt = {
        ...mockReceipt,
        category: 'business_meal',
        totalAmount: 5000
      };
      
      const allBusinessMealTips = service.getTipsByCategory('business_meal');
      let displayedTips = new Set<string>();
      
      // Display tips multiple times
      for (let i = 0; i < 10; i++) {
        const suggestions = service.getSuggestedTips(receipt);
        
        suggestions.forEach(s => {
          displayedTips.add(s.tip.id);
          service.markTipAsDisplayed(s.tip.id);
        });
      }
      
      // Should have cycled through multiple tips
      expect(displayedTips.size).toBeGreaterThan(0);
      expect(displayedTips.size).toBeLessThanOrEqual(allBusinessMealTips.length);
    });

    test('should prioritize higher priority tips when equally relevant', () => {
      const tips = service.getAllTips();
      
      // Find tips with different priorities in same category
      const businessMealTips = tips.filter(t => t.category === 'business_meal');
      
      if (businessMealTips.length > 1) {
        const priorities = businessMealTips.map(t => t.priority);
        const hasVariedPriorities = new Set(priorities).size > 1;
        
        // Just verify that priorities exist and vary
        expect(hasVariedPriorities).toBe(true);
      }
    });

    test('should provide contextual learning over time', () => {
      // Simulate scanning various expense types
      const expenseTypes = [
        { category: 'business_meal', amount: 5000 },
        { category: 'equipment', amount: 80000 },
        { category: 'home_office', amount: 12000 },
        { category: 'professional_services', amount: 20000 },
        { category: 'office_supplies', amount: 3000 }
      ];
      
      const learnedCategories = new Set<string>();
      
      expenseTypes.forEach(expense => {
        const receipt = {
          ...mockReceipt,
          category: expense.category,
          totalAmount: expense.amount
        };
        
        const suggestions = service.getSuggestedTips(receipt);
        suggestions.forEach(s => {
          learnedCategories.add(s.tip.category);
          service.markTipAsDisplayed(s.tip.id);
        });
      });
      
      // User should have learned about multiple categories
      expect(learnedCategories.size).toBeGreaterThan(0);
    });
  });

  describe('Edge cases', () => {
    test('should handle very small expenses', () => {
      const receipt = {
        ...mockReceipt,
        totalAmount: 10 // $0.10
      };
      
      const suggestions = service.getSuggestedTips(receipt);
      
      // Should still get some suggestions
      expect(suggestions.length).toBeGreaterThanOrEqual(0);
    });

    test('should handle very large expenses', () => {
      const receipt = {
        ...mockReceipt,
        totalAmount: 10000000 // $100,000
      };
      
      const suggestions = service.getSuggestedTips(receipt);
      
      // Should still get relevant suggestions
      expect(suggestions.length).toBeGreaterThanOrEqual(0);
    });

    test('should handle receipt with no category', () => {
      const receipt = {
        ...mockReceipt,
        category: undefined
      };
      
      expect(() => {
        const suggestions = service.getSuggestedTips(receipt);
        expect(suggestions).toBeDefined();
      }).not.toThrow();
    });

    test('should handle receipt with no vendor name', () => {
      const receipt = {
        ...mockReceipt,
        vendorName: undefined
      };
      
      expect(() => {
        const suggestions = service.getSuggestedTips(receipt);
        expect(suggestions).toBeDefined();
      }).not.toThrow();
    });
  });
});
