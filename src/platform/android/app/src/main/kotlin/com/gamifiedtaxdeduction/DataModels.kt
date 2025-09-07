package com.gamifiedtaxdeduction.data.model

import androidx.room.*
import java.util.*

// MARK: - User Profile
data class UserProfile(
    val incomeBracket: IncomeBracket,
    val filingStatus: FilingStatus,
    val createdAt: Date = Date(),
    val lastUpdated: Date = Date()
) {
    enum class IncomeBracket {
        LOW, MEDIUM, HIGH
    }
    
    enum class FilingStatus {
        SINGLE, MARRIED
    }
}

// MARK: - Receipt
@Entity(tableName = "receipts")
data class Receipt(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val createdAt: Date = Date(),
    val lastUpdated: Date = Date(),
    val imagePath: String,
    val vendorName: String? = null,
    val totalAmount: Long, // Amount in cents
    val potentialTaxSaving: Long, // Tax saving in cents
    val category: String? = null,
    val isVerified: Boolean = false,
    val notes: String? = null
) {
    // Computed properties for display
    val displayAmount: Double
        get() = totalAmount / 100.0
    
    val displayTaxSaving: Double
        get() = potentialTaxSaving / 100.0
}

// MARK: - Achievement
@Entity(tableName = "achievements")
data class Achievement(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val name: String,
    val description: String,
    val category: Category,
    val threshold: Int,
    val icon: String,
    val unlockedAt: Date? = null,
    val isUnlocked: Boolean = false
) {
    enum class Category {
        SCANNING, SAVINGS, CONSISTENCY, LEARNING
    }
}

// MARK: - User Progress
@Entity(tableName = "user_progress")
data class UserProgress(
    @PrimaryKey val userId: String = "default",
    val totalReceiptsScanned: Int = 0,
    val totalPotentialSavings: Long = 0L, // In cents
    val currentStreak: Int = 0,
    val longestStreak: Int = 0,
    val lastScanDate: Date? = null,
    val achievementIds: List<String> = emptyList(),
    val createdAt: Date = Date(),
    val lastUpdated: Date = Date()
) {
    val displayTotalSavings: Double
        get() = totalPotentialSavings / 100.0
}

// MARK: - Educational Tip
@Entity(tableName = "educational_tips")
data class EducationalTip(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val title: String,
    val content: String,
    val category: Category,
    @Embedded val triggerConditions: TriggerConditions = TriggerConditions(),
    val displayCount: Int = 0,
    val maxDisplays: Int = 3,
    val priority: Int = 1
) {
    enum class Category {
        BUSINESS_MEAL, HOME_OFFICE, EQUIPMENT, GENERAL
    }
    
    data class TriggerConditions(
        val expenseAmountMin: Long? = null,
        val expenseAmountMax: Long? = null,
        val vendorTypes: List<String>? = null,
        val categories: List<String>? = null
    )
}

// MARK: - Tax Configuration
data class TaxConfiguration(
    val incomeBrackets: Map<String, IncomeBracket>,
    val filingStatuses: Map<String, FilingStatusConfig>,
    val lastUpdated: Date = Date()
) {
    data class IncomeBracket(
        val min: Long,
        val max: Long,
        val rate: Double
    )
    
    data class FilingStatusConfig(
        val standardDeduction: Long
    )
    
    companion object {
        val DEFAULT = TaxConfiguration(
            incomeBrackets = mapOf(
                "low" to IncomeBracket(0L, 50000L, 0.12),
                "medium" to IncomeBracket(50001L, 100000L, 0.22),
                "high" to IncomeBracket(100001L, Long.MAX_VALUE, 0.32)
            ),
            filingStatuses = mapOf(
                "single" to FilingStatusConfig(1275000L), // $12,750 in cents
                "married" to FilingStatusConfig(2550000L)  // $25,500 in cents
            )
        )
    }
}

// MARK: - App Settings
data class AppSettings(
    val isOnboardingComplete: Boolean = false,
    val notificationsEnabled: Boolean = true,
    val reminderTime: String? = null,
    val theme: Theme = Theme.SYSTEM,
    val currency: String = "USD",
    val privacyConsentGiven: Boolean = false,
    val lastBackupDate: Date? = null,
    val appVersion: String = "1.0.0"
) {
    enum class Theme {
        LIGHT, DARK, SYSTEM
    }
}

// MARK: - Type Converters for Room Database
class DateConverter {
    @TypeConverter
    fun fromTimestamp(value: Long?): Date? {
        return value?.let { Date(it) }
    }

    @TypeConverter
    fun dateToTimestamp(date: Date?): Long? {
        return date?.time
    }
}

class StringListConverter {
    @TypeConverter
    fun fromStringList(value: List<String>): String {
        return value.joinToString(",")
    }

    @TypeConverter
    fun toStringList(value: String): List<String> {
        return if (value.isEmpty()) emptyList() else value.split(",")
    }
}