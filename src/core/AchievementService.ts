/**
 * Achievement Service
 * Manages gamification achievements and progress tracking
 * Celebrates user milestones and encourages consistent habits
 */

import { Achievement, UserProgress, Receipt } from './DataModels';

export interface AchievementUnlockEvent {
  achievement: Achievement;
  unlockedAt: Date;
  message: string;
}

export class AchievementService {
  private achievements: Achievement[];

  constructor() {
    this.achievements = this.initializeAchievements();
  }

  /**
   * Initialize default achievement set
   * @returns Array of predefined achievements
   */
  private initializeAchievements(): Achievement[] {
    return [
      // Scanning Milestones
      {
        id: 'first-scan',
        name: 'First Steps',
        description: 'Scan your first receipt',
        category: 'scanning',
        threshold: 1,
        icon: '🎯',
        isUnlocked: false
      },
      {
        id: 'scan-10',
        name: 'Getting Started',
        description: 'Scan 10 receipts',
        category: 'scanning',
        threshold: 10,
        icon: '📸',
        isUnlocked: false
      },
      {
        id: 'scan-50',
        name: 'Dedicated Tracker',
        description: 'Scan 50 receipts',
        category: 'scanning',
        threshold: 50,
        icon: '📚',
        isUnlocked: false
      },
      {
        id: 'scan-100',
        name: 'Receipt Master',
        description: 'Scan 100 receipts',
        category: 'scanning',
        threshold: 100,
        icon: '🏆',
        isUnlocked: false
      },

      // Savings Milestones
      {
        id: 'save-100',
        name: 'First $100',
        description: 'Track $100 in potential tax savings',
        category: 'savings',
        threshold: 10000, // $100 in cents
        icon: '💰',
        isUnlocked: false
      },
      {
        id: 'save-500',
        name: 'Smart Saver',
        description: 'Track $500 in potential tax savings',
        category: 'savings',
        threshold: 50000, // $500 in cents
        icon: '💵',
        isUnlocked: false
      },
      {
        id: 'save-1000',
        name: 'Tax Champion',
        description: 'Track $1,000 in potential tax savings',
        category: 'savings',
        threshold: 100000, // $1,000 in cents
        icon: '🌟',
        isUnlocked: false
      },
      {
        id: 'save-5000',
        name: 'Deduction Legend',
        description: 'Track $5,000 in potential tax savings',
        category: 'savings',
        threshold: 500000, // $5,000 in cents
        icon: '👑',
        isUnlocked: false
      },

      // Consistency Rewards
      {
        id: 'streak-3',
        name: 'Building Momentum',
        description: 'Scan receipts 3 days in a row',
        category: 'consistency',
        threshold: 3,
        icon: '🔥',
        isUnlocked: false
      },
      {
        id: 'streak-7',
        name: 'Weekly Warrior',
        description: 'Scan receipts 7 days in a row',
        category: 'consistency',
        threshold: 7,
        icon: '💪',
        isUnlocked: false
      },
      {
        id: 'streak-30',
        name: 'Monthly Master',
        description: 'Scan receipts 30 days in a row',
        category: 'consistency',
        threshold: 30,
        icon: '⭐',
        isUnlocked: false
      },

      // Learning Achievements
      {
        id: 'learn-5',
        name: 'Tax Tip Explorer',
        description: 'Read 5 educational tips',
        category: 'learning',
        threshold: 5,
        icon: '💡',
        isUnlocked: false
      },
      {
        id: 'learn-20',
        name: 'Deduction Detective',
        description: 'Read 20 educational tips',
        category: 'learning',
        threshold: 20,
        icon: '🔍',
        isUnlocked: false
      }
    ];
  }

  /**
   * Check and unlock achievements based on user progress
   * @param userProgress - Current user progress
   * @returns Array of newly unlocked achievements
   */
  checkForUnlocks(userProgress: UserProgress): AchievementUnlockEvent[] {
    const newlyUnlocked: AchievementUnlockEvent[] = [];
    const now = new Date();

    for (const achievement of this.achievements) {
      // Skip if already unlocked
      if (achievement.isUnlocked || userProgress.achievementIds.includes(achievement.id)) {
        continue;
      }

      // Check if threshold is met based on category
      let thresholdMet = false;
      
      switch (achievement.category) {
        case 'scanning':
          thresholdMet = userProgress.totalReceiptsScanned >= achievement.threshold;
          break;
        case 'savings':
          thresholdMet = userProgress.totalPotentialSavings >= achievement.threshold;
          break;
        case 'consistency':
          thresholdMet = userProgress.currentStreak >= achievement.threshold;
          break;
        case 'learning':
          // This would be tracked separately, placeholder for now
          thresholdMet = false;
          break;
      }

      if (thresholdMet) {
        achievement.isUnlocked = true;
        newlyUnlocked.push({
          achievement: { ...achievement, unlockedAt: now },
          unlockedAt: now,
          message: this.getUnlockMessage(achievement)
        });
      }
    }

    return newlyUnlocked;
  }

  /**
   * Get a celebratory message for unlocking an achievement
   * @param achievement - The achievement that was unlocked
   * @returns Celebration message
   */
  private getUnlockMessage(achievement: Achievement): string {
    const messages: Record<string, string> = {
      'scanning': '🎉 Keep up the great tracking habits!',
      'savings': '💰 You\'re building real tax savings!',
      'consistency': '🔥 Your consistency is paying off!',
      'learning': '📚 Knowledge is power!'
    };

    return messages[achievement.category] || '🎉 Achievement unlocked!';
  }

  /**
   * Update user progress after scanning a receipt
   * @param currentProgress - Current user progress
   * @param newReceipt - Newly scanned receipt
   * @returns Updated user progress
   */
  updateProgressWithReceipt(
    currentProgress: UserProgress,
    newReceipt: Receipt
  ): UserProgress {
    const now = new Date();
    
    // Calculate streak
    let newStreak = currentProgress.currentStreak;
    if (currentProgress.lastScanDate) {
      const daysSinceLastScan = this.getDaysDifference(
        currentProgress.lastScanDate,
        now
      );
      
      if (daysSinceLastScan === 0) {
        // Same day - maintain streak
        newStreak = currentProgress.currentStreak;
      } else if (daysSinceLastScan === 1) {
        // Next day - increment streak
        newStreak = currentProgress.currentStreak + 1;
      } else {
        // Streak broken - reset to 1
        newStreak = 1;
      }
    } else {
      // First scan ever
      newStreak = 1;
    }

    // Update longest streak if necessary
    const longestStreak = Math.max(currentProgress.longestStreak, newStreak);

    return {
      ...currentProgress,
      totalReceiptsScanned: currentProgress.totalReceiptsScanned + 1,
      totalPotentialSavings: currentProgress.totalPotentialSavings + newReceipt.potentialTaxSaving,
      currentStreak: newStreak,
      longestStreak,
      lastScanDate: now,
      lastUpdated: now
    };
  }

  /**
   * Calculate days difference between two dates
   * @param date1 - First date
   * @param date2 - Second date
   * @returns Number of days between dates
   */
  private getDaysDifference(date1: Date, date2: Date): number {
    const msPerDay = 24 * 60 * 60 * 1000;
    const startOfDay1 = new Date(date1.getFullYear(), date1.getMonth(), date1.getDate());
    const startOfDay2 = new Date(date2.getFullYear(), date2.getMonth(), date2.getDate());
    return Math.floor((startOfDay2.getTime() - startOfDay1.getTime()) / msPerDay);
  }

  /**
   * Get all achievements
   * @returns Array of all achievements
   */
  getAllAchievements(): Achievement[] {
    return [...this.achievements];
  }

  /**
   * Get unlocked achievements
   * @param achievementIds - Array of unlocked achievement IDs
   * @returns Array of unlocked achievements
   */
  getUnlockedAchievements(achievementIds: string[]): Achievement[] {
    return this.achievements.filter(a => achievementIds.includes(a.id));
  }

  /**
   * Get next achievement to unlock in a category
   * @param category - Achievement category
   * @param currentValue - Current progress value
   * @returns Next achievement to unlock, or null if none
   */
  getNextAchievement(
    category: Achievement['category'],
    currentValue: number
  ): Achievement | null {
    const categoryAchievements = this.achievements
      .filter(a => a.category === category && !a.isUnlocked)
      .sort((a, b) => a.threshold - b.threshold);

    return categoryAchievements.find(a => a.threshold > currentValue) || null;
  }

  /**
   * Get progress toward next achievement in a category
   * @param category - Achievement category
   * @param currentValue - Current progress value
   * @returns Progress percentage (0-100) or null if no next achievement
   */
  getProgressToNextAchievement(
    category: Achievement['category'],
    currentValue: number
  ): number | null {
    const next = this.getNextAchievement(category, currentValue);
    if (!next) return null;

    return Math.min(100, Math.floor((currentValue / next.threshold) * 100));
  }
}
