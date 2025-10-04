/**
 * Unit tests for AchievementService
 */

import { AchievementService } from '../../src/core/AchievementService';
import { UserProgress, Receipt } from '../../src/core/DataModels';

describe('AchievementService', () => {
  let service: AchievementService;
  let baseProgress: UserProgress;
  let mockReceipt: Receipt;

  beforeEach(() => {
    service = new AchievementService();
    
    baseProgress = {
      userId: 'test-user',
      totalReceiptsScanned: 0,
      totalPotentialSavings: 0,
      currentStreak: 0,
      longestStreak: 0,
      lastScanDate: undefined,
      achievementIds: [],
      createdAt: new Date(),
      lastUpdated: new Date()
    };

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

  describe('getAllAchievements', () => {
    test('should return all predefined achievements', () => {
      const achievements = service.getAllAchievements();
      
      expect(achievements.length).toBeGreaterThan(0);
      expect(achievements).toEqual(
        expect.arrayContaining([
          expect.objectContaining({ id: 'first-scan' }),
          expect.objectContaining({ id: 'save-100' }),
          expect.objectContaining({ id: 'streak-3' })
        ])
      );
    });

    test('should include all achievement categories', () => {
      const achievements = service.getAllAchievements();
      const categories = [...new Set(achievements.map(a => a.category))];
      
      expect(categories).toContain('scanning');
      expect(categories).toContain('savings');
      expect(categories).toContain('consistency');
      expect(categories).toContain('learning');
    });

    test('should have achievements sorted by threshold within categories', () => {
      const achievements = service.getAllAchievements();
      const scanningAchievements = achievements
        .filter(a => a.category === 'scanning')
        .map(a => a.threshold);
      
      // Verify we have progressive thresholds
      expect(scanningAchievements).toContain(1);   // First scan
      expect(scanningAchievements).toContain(10);  // 10 scans
      expect(scanningAchievements).toContain(50);  // 50 scans
      expect(scanningAchievements).toContain(100); // 100 scans
    });
  });

  describe('checkForUnlocks', () => {
    test('should unlock first-scan achievement', () => {
      const progress = { ...baseProgress, totalReceiptsScanned: 1 };
      const unlocked = service.checkForUnlocks(progress);
      
      expect(unlocked.length).toBe(1);
      expect(unlocked[0].achievement.id).toBe('first-scan');
      expect(unlocked[0].achievement.isUnlocked).toBe(true);
      expect(unlocked[0].unlockedAt).toBeInstanceOf(Date);
      expect(unlocked[0].message).toContain('tracking habits');
    });

    test('should unlock multiple achievements at once', () => {
      const progress = {
        ...baseProgress,
        totalReceiptsScanned: 10,
        totalPotentialSavings: 10000 // $100
      };
      const unlocked = service.checkForUnlocks(progress);
      
      // Should unlock: first-scan, scan-10, save-100
      expect(unlocked.length).toBe(3);
      const ids = unlocked.map(u => u.achievement.id);
      expect(ids).toContain('first-scan');
      expect(ids).toContain('scan-10');
      expect(ids).toContain('save-100');
    });

    test('should not unlock already unlocked achievements', () => {
      const progress = {
        ...baseProgress,
        totalReceiptsScanned: 10,
        achievementIds: ['first-scan'] // Already unlocked
      };
      const unlocked = service.checkForUnlocks(progress);
      
      // Should only unlock scan-10, not first-scan again
      expect(unlocked.length).toBe(1);
      expect(unlocked[0].achievement.id).toBe('scan-10');
    });

    test('should unlock savings milestones', () => {
      const progress = {
        ...baseProgress,
        totalPotentialSavings: 100000 // $1000
      };
      const unlocked = service.checkForUnlocks(progress);
      
      // Should unlock save-100, save-500, save-1000
      expect(unlocked.length).toBe(3);
      const ids = unlocked.map(u => u.achievement.id);
      expect(ids).toContain('save-100');
      expect(ids).toContain('save-500');
      expect(ids).toContain('save-1000');
    });

    test('should unlock streak achievements', () => {
      const progress = {
        ...baseProgress,
        currentStreak: 7
      };
      const unlocked = service.checkForUnlocks(progress);
      
      // Should unlock streak-3, streak-7
      expect(unlocked.length).toBe(2);
      const ids = unlocked.map(u => u.achievement.id);
      expect(ids).toContain('streak-3');
      expect(ids).toContain('streak-7');
    });

    test('should return empty array when no achievements unlocked', () => {
      const unlocked = service.checkForUnlocks(baseProgress);
      expect(unlocked).toEqual([]);
    });
  });

  describe('updateProgressWithReceipt', () => {
    test('should increment receipt count', () => {
      const updated = service.updateProgressWithReceipt(baseProgress, mockReceipt);
      
      expect(updated.totalReceiptsScanned).toBe(1);
      expect(updated.totalPotentialSavings).toBe(mockReceipt.potentialTaxSaving);
      expect(updated.lastScanDate).toBeInstanceOf(Date);
    });

    test('should start streak at 1 for first scan', () => {
      const updated = service.updateProgressWithReceipt(baseProgress, mockReceipt);
      
      expect(updated.currentStreak).toBe(1);
      expect(updated.longestStreak).toBe(1);
    });

    test('should maintain streak when scanning same day', () => {
      const progress = {
        ...baseProgress,
        currentStreak: 5,
        longestStreak: 5,
        lastScanDate: new Date()
      };
      
      const updated = service.updateProgressWithReceipt(progress, mockReceipt);
      
      expect(updated.currentStreak).toBe(5); // Same day, no change
      expect(updated.longestStreak).toBe(5);
    });

    test('should increment streak when scanning next day', () => {
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      
      const progress = {
        ...baseProgress,
        currentStreak: 3,
        longestStreak: 3,
        lastScanDate: yesterday
      };
      
      const updated = service.updateProgressWithReceipt(progress, mockReceipt);
      
      expect(updated.currentStreak).toBe(4); // Incremented
      expect(updated.longestStreak).toBe(4);
    });

    test('should reset streak when gap is more than 1 day', () => {
      const threeDaysAgo = new Date();
      threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);
      
      const progress = {
        ...baseProgress,
        currentStreak: 10,
        longestStreak: 10,
        lastScanDate: threeDaysAgo
      };
      
      const updated = service.updateProgressWithReceipt(progress, mockReceipt);
      
      expect(updated.currentStreak).toBe(1); // Reset
      expect(updated.longestStreak).toBe(10); // Longest preserved
    });

    test('should update longest streak when current exceeds it', () => {
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      
      const progress = {
        ...baseProgress,
        currentStreak: 10,
        longestStreak: 10,
        lastScanDate: yesterday
      };
      
      const updated = service.updateProgressWithReceipt(progress, mockReceipt);
      
      expect(updated.currentStreak).toBe(11);
      expect(updated.longestStreak).toBe(11); // Updated
    });

    test('should accumulate savings correctly', () => {
      const progress = {
        ...baseProgress,
        totalPotentialSavings: 50000 // $500
      };
      
      const receipt = {
        ...mockReceipt,
        potentialTaxSaving: 25000 // $250
      };
      
      const updated = service.updateProgressWithReceipt(progress, receipt);
      
      expect(updated.totalPotentialSavings).toBe(75000); // $750 total
    });
  });

  describe('getUnlockedAchievements', () => {
    test('should return achievements matching provided IDs', () => {
      const achievements = service.getUnlockedAchievements(['first-scan', 'save-100']);
      
      expect(achievements.length).toBe(2);
      expect(achievements[0].id).toBe('first-scan');
      expect(achievements[1].id).toBe('save-100');
    });

    test('should return empty array for empty ID list', () => {
      const achievements = service.getUnlockedAchievements([]);
      expect(achievements).toEqual([]);
    });

    test('should handle non-existent IDs gracefully', () => {
      const achievements = service.getUnlockedAchievements(['non-existent']);
      expect(achievements).toEqual([]);
    });
  });

  describe('getNextAchievement', () => {
    test('should return next scanning achievement', () => {
      const next = service.getNextAchievement('scanning', 5);
      
      expect(next).not.toBeNull();
      expect(next?.id).toBe('scan-10');
      expect(next?.threshold).toBe(10);
    });

    test('should return next savings achievement', () => {
      const next = service.getNextAchievement('savings', 40000); // $400
      
      expect(next).not.toBeNull();
      expect(next?.id).toBe('save-500');
      expect(next?.threshold).toBe(50000); // $500
    });

    test('should return next consistency achievement', () => {
      const next = service.getNextAchievement('consistency', 5);
      
      expect(next).not.toBeNull();
      expect(next?.id).toBe('streak-7');
      expect(next?.threshold).toBe(7);
    });

    test('should return null when at highest achievement', () => {
      const next = service.getNextAchievement('scanning', 200);
      
      // All scanning achievements should be unlocked
      expect(next).toBeNull();
    });

    test('should skip unlocked achievements', () => {
      // First, "unlock" an achievement
      const progress = { ...baseProgress, totalReceiptsScanned: 1 };
      service.checkForUnlocks(progress);
      
      const next = service.getNextAchievement('scanning', 1);
      
      // Should skip first-scan and return scan-10
      expect(next?.id).toBe('scan-10');
    });
  });

  describe('getProgressToNextAchievement', () => {
    test('should calculate progress percentage correctly', () => {
      const progress = service.getProgressToNextAchievement('scanning', 5);
      
      // 5 out of 10 = 50%
      expect(progress).toBe(50);
    });

    test('should return 100% when at or past threshold', () => {
      const progress = service.getProgressToNextAchievement('scanning', 15);
      
      // Past the scan-10 threshold, at 100%
      expect(progress).toBe(100);
    });

    test('should return null when no next achievement', () => {
      const progress = service.getProgressToNextAchievement('scanning', 200);
      
      expect(progress).toBeNull();
    });

    test('should calculate savings progress correctly', () => {
      const progress = service.getProgressToNextAchievement('savings', 7500); // $75
      
      // 7500 out of 10000 ($100) = 75%
      expect(progress).toBe(75);
    });
  });

  describe('Integration scenarios', () => {
    test('should handle complete user journey', () => {
      let progress = baseProgress;
      
      // Day 1: First scan
      const receipt1 = { ...mockReceipt, potentialTaxSaving: 1000 }; // $10
      progress = service.updateProgressWithReceipt(progress, receipt1);
      let unlocked = service.checkForUnlocks(progress);
      
      expect(unlocked.length).toBe(1); // first-scan
      expect(progress.currentStreak).toBe(1);
      progress = { ...progress, achievementIds: [...progress.achievementIds, ...unlocked.map(u => u.achievement.id)] };
      
      // Day 2: Another scan
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      progress = { ...progress, lastScanDate: yesterday };
      
      const receipt2 = { ...mockReceipt, potentialTaxSaving: 2000 }; // $20
      progress = service.updateProgressWithReceipt(progress, receipt2);
      
      expect(progress.currentStreak).toBe(2);
      expect(progress.totalReceiptsScanned).toBe(2);
      expect(progress.totalPotentialSavings).toBe(3000); // $30 total
      
      // Continue scanning to reach 10 receipts and $100
      for (let i = 0; i < 8; i++) {
        const receipt = { ...mockReceipt, potentialTaxSaving: 1000 };
        progress = service.updateProgressWithReceipt(progress, receipt);
      }
      
      unlocked = service.checkForUnlocks(progress);
      const unlockedIds = unlocked.map(u => u.achievement.id);
      
      expect(unlockedIds).toContain('scan-10');
      expect(unlockedIds).toContain('save-100');
      expect(progress.totalReceiptsScanned).toBe(10);
      expect(progress.totalPotentialSavings).toBeGreaterThanOrEqual(10000); // At least $100
    });

    test('should track longest streak correctly over time', () => {
      let progress = baseProgress;
      
      // Build a 5-day streak
      for (let i = 0; i < 5; i++) {
        const date = new Date();
        date.setDate(date.getDate() - (4 - i)); // Go backwards in time
        progress = { ...progress, lastScanDate: i === 0 ? undefined : date };
        
        progress = service.updateProgressWithReceipt(progress, mockReceipt);
      }
      
      expect(progress.currentStreak).toBe(5);
      expect(progress.longestStreak).toBe(5);
      
      // Break the streak
      const weekAgo = new Date();
      weekAgo.setDate(weekAgo.getDate() - 7);
      progress = { ...progress, lastScanDate: weekAgo };
      
      progress = service.updateProgressWithReceipt(progress, mockReceipt);
      
      expect(progress.currentStreak).toBe(1); // Reset
      expect(progress.longestStreak).toBe(5); // Preserved
    });
  });
});
