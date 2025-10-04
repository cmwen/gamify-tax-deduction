import Foundation

// MARK: - Achievement Unlock Event
struct AchievementUnlockEvent {
    let achievement: Achievement
    let unlockedAt: Date
    let message: String
}

// MARK: - Achievement Service
class AchievementService {
    private var achievements: [Achievement]
    
    init() {
        self.achievements = Self.initializeAchievements()
    }
    
    /// Initialize default achievement set
    /// - Returns: Array of predefined achievements
    private static func initializeAchievements() -> [Achievement] {
        return [
            // Scanning Milestones
            Achievement(
                name: "First Steps",
                description: "Scan your first receipt",
                category: .scanning,
                threshold: 1,
                icon: "🎯"
            ),
            Achievement(
                name: "Getting Started",
                description: "Scan 10 receipts",
                category: .scanning,
                threshold: 10,
                icon: "📸"
            ),
            Achievement(
                name: "Dedicated Tracker",
                description: "Scan 50 receipts",
                category: .scanning,
                threshold: 50,
                icon: "📚"
            ),
            Achievement(
                name: "Receipt Master",
                description: "Scan 100 receipts",
                category: .scanning,
                threshold: 100,
                icon: "🏆"
            ),
            
            // Savings Milestones
            Achievement(
                name: "First $100",
                description: "Track $100 in potential tax savings",
                category: .savings,
                threshold: 10000, // $100 in cents
                icon: "💰"
            ),
            Achievement(
                name: "Smart Saver",
                description: "Track $500 in potential tax savings",
                category: .savings,
                threshold: 50000, // $500 in cents
                icon: "💵"
            ),
            Achievement(
                name: "Tax Champion",
                description: "Track $1,000 in potential tax savings",
                category: .savings,
                threshold: 100000, // $1,000 in cents
                icon: "🌟"
            ),
            Achievement(
                name: "Deduction Legend",
                description: "Track $5,000 in potential tax savings",
                category: .savings,
                threshold: 500000, // $5,000 in cents
                icon: "👑"
            ),
            
            // Consistency Rewards
            Achievement(
                name: "Building Momentum",
                description: "Scan receipts 3 days in a row",
                category: .consistency,
                threshold: 3,
                icon: "🔥"
            ),
            Achievement(
                name: "Weekly Warrior",
                description: "Scan receipts 7 days in a row",
                category: .consistency,
                threshold: 7,
                icon: "💪"
            ),
            Achievement(
                name: "Monthly Master",
                description: "Scan receipts 30 days in a row",
                category: .consistency,
                threshold: 30,
                icon: "⭐"
            ),
            
            // Learning Achievements
            Achievement(
                name: "Tax Tip Explorer",
                description: "Read 5 educational tips",
                category: .learning,
                threshold: 5,
                icon: "💡"
            ),
            Achievement(
                name: "Deduction Detective",
                description: "Read 20 educational tips",
                category: .learning,
                threshold: 20,
                icon: "🔍"
            )
        ]
    }
    
    /// Check and unlock achievements based on user progress
    /// - Parameter userProgress: Current user progress
    /// - Returns: Array of newly unlocked achievements
    func checkForUnlocks(userProgress: UserProgress) -> [AchievementUnlockEvent] {
        var newlyUnlocked: [AchievementUnlockEvent] = []
        let now = Date()
        
        for i in 0..<achievements.count {
            let achievement = achievements[i]
            
            // Skip if already unlocked
            if achievement.isUnlocked || userProgress.achievementIds.contains(achievement.id) {
                continue
            }
            
            // Check if threshold is met based on category
            var thresholdMet = false
            
            switch achievement.category {
            case .scanning:
                thresholdMet = userProgress.totalReceiptsScanned >= achievement.threshold
            case .savings:
                thresholdMet = userProgress.totalPotentialSavings >= achievement.threshold
            case .consistency:
                thresholdMet = userProgress.currentStreak >= achievement.threshold
            case .learning:
                // This would be tracked separately, placeholder for now
                thresholdMet = false
            }
            
            if thresholdMet {
                // Create unlocked version of achievement
                var unlockedAchievement = achievement
                unlockedAchievement.isUnlocked = true
                unlockedAchievement.unlockedAt = now
                achievements[i] = unlockedAchievement
                
                newlyUnlocked.append(AchievementUnlockEvent(
                    achievement: unlockedAchievement,
                    unlockedAt: now,
                    message: getUnlockMessage(for: achievement.category)
                ))
            }
        }
        
        return newlyUnlocked
    }
    
    /// Get a celebratory message for unlocking an achievement
    /// - Parameter category: The achievement category
    /// - Returns: Celebration message
    private func getUnlockMessage(for category: Achievement.Category) -> String {
        switch category {
        case .scanning:
            return "🎉 Keep up the great tracking habits!"
        case .savings:
            return "💰 You're building real tax savings!"
        case .consistency:
            return "🔥 Your consistency is paying off!"
        case .learning:
            return "📚 Knowledge is power!"
        }
    }
    
    /// Update user progress after scanning a receipt
    /// - Parameters:
    ///   - currentProgress: Current user progress
    ///   - newReceipt: Newly scanned receipt
    /// - Returns: Updated user progress
    func updateProgressWithReceipt(
        currentProgress: UserProgress,
        newReceipt: Receipt
    ) -> UserProgress {
        let now = Date()
        
        // Calculate streak
        var newStreak = currentProgress.currentStreak
        if let lastScanDate = currentProgress.lastScanDate {
            let daysSinceLastScan = getDaysDifference(from: lastScanDate, to: now)
            
            if daysSinceLastScan == 0 {
                // Same day - maintain streak
                newStreak = currentProgress.currentStreak
            } else if daysSinceLastScan == 1 {
                // Next day - increment streak
                newStreak = currentProgress.currentStreak + 1
            } else {
                // Streak broken - reset to 1
                newStreak = 1
            }
        } else {
            // First scan ever
            newStreak = 1
        }
        
        // Update longest streak if necessary
        let longestStreak = max(currentProgress.longestStreak, newStreak)
        
        return UserProgress(
            userId: currentProgress.userId,
            totalReceiptsScanned: currentProgress.totalReceiptsScanned + 1,
            totalPotentialSavings: currentProgress.totalPotentialSavings + newReceipt.potentialTaxSaving,
            currentStreak: newStreak,
            longestStreak: longestStreak,
            lastScanDate: now,
            achievementIds: currentProgress.achievementIds,
            createdAt: currentProgress.createdAt,
            lastUpdated: now
        )
    }
    
    /// Calculate days difference between two dates
    /// - Parameters:
    ///   - date1: First date
    ///   - date2: Second date
    /// - Returns: Number of days between dates
    private func getDaysDifference(from date1: Date, to date2: Date) -> Int {
        let calendar = Calendar.current
        let startOfDay1 = calendar.startOfDay(for: date1)
        let startOfDay2 = calendar.startOfDay(for: date2)
        let components = calendar.dateComponents([.day], from: startOfDay1, to: startOfDay2)
        return components.day ?? 0
    }
    
    /// Get all achievements
    /// - Returns: Array of all achievements
    func getAllAchievements() -> [Achievement] {
        return achievements
    }
    
    /// Get unlocked achievements
    /// - Parameter achievementIds: Array of unlocked achievement IDs
    /// - Returns: Array of unlocked achievements
    func getUnlockedAchievements(achievementIds: [UUID]) -> [Achievement] {
        return achievements.filter { achievementIds.contains($0.id) }
    }
    
    /// Get next achievement to unlock in a category
    /// - Parameters:
    ///   - category: Achievement category
    ///   - currentValue: Current progress value
    /// - Returns: Next achievement to unlock, or nil if none
    func getNextAchievement(
        category: Achievement.Category,
        currentValue: Int
    ) -> Achievement? {
        let categoryAchievements = achievements
            .filter { $0.category == category && !$0.isUnlocked }
            .sorted { $0.threshold < $1.threshold }
        
        return categoryAchievements.first { $0.threshold > currentValue }
    }
    
    /// Get progress toward next achievement in a category
    /// - Parameters:
    ///   - category: Achievement category
    ///   - currentValue: Current progress value
    /// - Returns: Progress percentage (0-100) or nil if no next achievement
    func getProgressToNextAchievement(
        category: Achievement.Category,
        currentValue: Int
    ) -> Int? {
        guard let next = getNextAchievement(category: category, currentValue: currentValue) else {
            return nil
        }
        
        return min(100, Int(floor(Double(currentValue) / Double(next.threshold) * 100)))
    }
}

// MARK: - Achievement Extension for Mutable Properties
extension Achievement {
    var isUnlocked: Bool {
        get { unlockedAt != nil }
        set {
            if newValue && unlockedAt == nil {
                // This is handled by creating new instances
            }
        }
    }
}
