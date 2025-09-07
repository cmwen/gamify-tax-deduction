package com.gamifiedtaxdeduction.data.model

import org.junit.Test
import org.junit.Assert.*
import java.util.*

class DataModelsTest {
    
    @Test
    fun `test UserProfile creation`() {
        // Given
        val incomeBracket = UserProfile.IncomeBracket.MEDIUM
        val filingStatus = UserProfile.FilingStatus.SINGLE
        
        // When
        val userProfile = UserProfile(incomeBracket, filingStatus)
        
        // Then
        assertEquals(incomeBracket, userProfile.incomeBracket)
        assertEquals(filingStatus, userProfile.filingStatus)
        assertNotNull(userProfile.createdAt)
        assertNotNull(userProfile.lastUpdated)
    }
    
    @Test
    fun `test Receipt creation and display properties`() {
        // Given
        val imagePath = "/path/to/image.jpg"
        val totalAmount = 2500L // $25.00 in cents
        val potentialTaxSaving = 300L // $3.00 in cents
        
        // When
        val receipt = Receipt(
            imagePath = imagePath,
            totalAmount = totalAmount,
            potentialTaxSaving = potentialTaxSaving
        )
        
        // Then
        assertNotNull(receipt.id)
        assertEquals(imagePath, receipt.imagePath)
        assertEquals(totalAmount, receipt.totalAmount)
        assertEquals(potentialTaxSaving, receipt.potentialTaxSaving)
        assertEquals(25.0, receipt.displayAmount, 0.01)
        assertEquals(3.0, receipt.displayTaxSaving, 0.01)
        assertFalse(receipt.isVerified)
    }
    
    @Test
    fun `test UserProgress initialization`() {
        // When
        val userProgress = UserProgress()
        
        // Then
        assertEquals(0, userProgress.totalReceiptsScanned)
        assertEquals(0L, userProgress.totalPotentialSavings)
        assertEquals(0, userProgress.currentStreak)
        assertEquals(0, userProgress.longestStreak)
        assertNull(userProgress.lastScanDate)
        assertTrue(userProgress.achievementIds.isEmpty())
        assertEquals(0.0, userProgress.displayTotalSavings, 0.01)
    }
    
    @Test
    fun `test Achievement creation`() {
        // Given
        val name = "First Scan"
        val description = "Scan your first receipt"
        val category = Achievement.Category.SCANNING
        val threshold = 1
        val icon = "star"
        
        // When
        val achievement = Achievement(
            name = name,
            description = description,
            category = category,
            threshold = threshold,
            icon = icon
        )
        
        // Then
        assertEquals(name, achievement.name)
        assertEquals(description, achievement.description)
        assertEquals(category, achievement.category)
        assertEquals(threshold, achievement.threshold)
        assertEquals(icon, achievement.icon)
        assertFalse(achievement.isUnlocked)
        assertNull(achievement.unlockedAt)
    }
    
    @Test
    fun `test TaxConfiguration default values`() {
        // When
        val config = TaxConfiguration.DEFAULT
        
        // Then
        assertEquals(3, config.incomeBrackets.size)
        assertEquals(2, config.filingStatuses.size)
        assertTrue(config.incomeBrackets.containsKey("low"))
        assertTrue(config.incomeBrackets.containsKey("medium"))
        assertTrue(config.incomeBrackets.containsKey("high"))
        assertTrue(config.filingStatuses.containsKey("single"))
        assertTrue(config.filingStatuses.containsKey("married"))
        
        // Test income bracket rates
        assertEquals(0.12, config.incomeBrackets["low"]?.rate ?: 0.0, 0.01)
        assertEquals(0.22, config.incomeBrackets["medium"]?.rate ?: 0.0, 0.01)
        assertEquals(0.32, config.incomeBrackets["high"]?.rate ?: 0.0, 0.01)
    }
    
    @Test
    fun `test AppSettings default values`() {
        // When
        val settings = AppSettings()
        
        // Then
        assertFalse(settings.isOnboardingComplete)
        assertTrue(settings.notificationsEnabled)
        assertEquals(AppSettings.Theme.SYSTEM, settings.theme)
        assertEquals("USD", settings.currency)
        assertFalse(settings.privacyConsentGiven)
        assertNotNull(settings.appVersion)
    }
    
    @Test
    fun `test EducationalTip creation`() {
        // Given
        val title = "Business Meal Tip"
        val content = "Business meals are typically 50% deductible"
        val category = EducationalTip.Category.BUSINESS_MEAL
        
        // When
        val tip = EducationalTip(
            title = title,
            content = content,
            category = category
        )
        
        // Then
        assertEquals(title, tip.title)
        assertEquals(content, tip.content)
        assertEquals(category, tip.category)
        assertEquals(0, tip.displayCount)
        assertEquals(3, tip.maxDisplays)
        assertEquals(1, tip.priority)
    }
}