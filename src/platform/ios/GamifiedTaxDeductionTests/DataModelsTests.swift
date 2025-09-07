import XCTest
@testable import GamifiedTaxDeduction

class DataModelsTests: XCTestCase {
    
    func testUserProfileCreation() {
        // Given
        let incomeBracket = UserProfile.IncomeBracket.medium
        let filingStatus = UserProfile.FilingStatus.single
        
        // When
        let userProfile = UserProfile(incomeBracket: incomeBracket, filingStatus: filingStatus)
        
        // Then
        XCTAssertEqual(userProfile.incomeBracket, incomeBracket)
        XCTAssertEqual(userProfile.filingStatus, filingStatus)
        XCTAssertNotNil(userProfile.createdAt)
        XCTAssertNotNil(userProfile.lastUpdated)
    }
    
    func testReceiptCreation() {
        // Given
        let imagePath = "/path/to/image.jpg"
        let totalAmount = 2500 // $25.00 in cents
        let potentialTaxSaving = 300 // $3.00 in cents
        
        // When
        let receipt = Receipt(
            imagePath: imagePath,
            totalAmount: totalAmount,
            potentialTaxSaving: potentialTaxSaving
        )
        
        // Then
        XCTAssertNotNil(receipt.id)
        XCTAssertEqual(receipt.imagePath, imagePath)
        XCTAssertEqual(receipt.totalAmount, totalAmount)
        XCTAssertEqual(receipt.potentialTaxSaving, potentialTaxSaving)
        XCTAssertEqual(receipt.displayAmount, 25.0)
        XCTAssertEqual(receipt.displayTaxSaving, 3.0)
        XCTAssertFalse(receipt.isVerified)
    }
    
    func testUserProgressInitialization() {
        // When
        let userProgress = UserProgress()
        
        // Then
        XCTAssertEqual(userProgress.totalReceiptsScanned, 0)
        XCTAssertEqual(userProgress.totalPotentialSavings, 0)
        XCTAssertEqual(userProgress.currentStreak, 0)
        XCTAssertEqual(userProgress.longestStreak, 0)
        XCTAssertNil(userProgress.lastScanDate)
        XCTAssertTrue(userProgress.achievementIds.isEmpty)
        XCTAssertEqual(userProgress.displayTotalSavings, 0.0)
    }
    
    func testAchievementCreation() {
        // Given
        let name = "First Scan"
        let description = "Scan your first receipt"
        let category = Achievement.Category.scanning
        let threshold = 1
        let icon = "star"
        
        // When
        let achievement = Achievement(
            name: name,
            description: description,
            category: category,
            threshold: threshold,
            icon: icon
        )
        
        // Then
        XCTAssertEqual(achievement.name, name)
        XCTAssertEqual(achievement.description, description)
        XCTAssertEqual(achievement.category, category)
        XCTAssertEqual(achievement.threshold, threshold)
        XCTAssertEqual(achievement.icon, icon)
        XCTAssertFalse(achievement.isUnlocked)
        XCTAssertNil(achievement.unlockedAt)
    }
    
    func testTaxConfigurationDefault() {
        // When
        let config = TaxConfiguration.default
        
        // Then
        XCTAssertEqual(config.incomeBrackets.count, 3)
        XCTAssertEqual(config.filingStatuses.count, 2)
        XCTAssertNotNil(config.incomeBrackets["low"])
        XCTAssertNotNil(config.incomeBrackets["medium"])
        XCTAssertNotNil(config.incomeBrackets["high"])
        XCTAssertNotNil(config.filingStatuses["single"])
        XCTAssertNotNil(config.filingStatuses["married"])
    }
    
    func testAppSettingsDefault() {
        // When
        let settings = AppSettings.default
        
        // Then
        XCTAssertFalse(settings.isOnboardingComplete)
        XCTAssertTrue(settings.notificationsEnabled)
        XCTAssertEqual(settings.theme, .system)
        XCTAssertEqual(settings.currency, "USD")
        XCTAssertFalse(settings.privacyConsentGiven)
        XCTAssertNotNil(settings.appVersion)
    }
}