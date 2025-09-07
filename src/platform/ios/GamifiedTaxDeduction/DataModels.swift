import Foundation

// MARK: - User Profile
struct UserProfile: Codable {
    enum IncomeBracket: String, Codable, CaseIterable {
        case low = "low"
        case medium = "medium"
        case high = "high"
    }
    
    enum FilingStatus: String, Codable, CaseIterable {
        case single = "single"
        case married = "married"
    }
    
    let incomeBracket: IncomeBracket
    let filingStatus: FilingStatus
    let createdAt: Date
    let lastUpdated: Date
    
    init(incomeBracket: IncomeBracket, filingStatus: FilingStatus) {
        self.incomeBracket = incomeBracket
        self.filingStatus = filingStatus
        let now = Date()
        self.createdAt = now
        self.lastUpdated = now
    }
}

// MARK: - Receipt
struct Receipt: Codable, Identifiable {
    let id: UUID
    let createdAt: Date
    let lastUpdated: Date
    let imagePath: String
    let vendorName: String?
    let totalAmount: Int // Amount in cents
    let potentialTaxSaving: Int // Tax saving in cents
    let category: String?
    let isVerified: Bool
    let notes: String?
    
    init(imagePath: String, 
         totalAmount: Int,
         potentialTaxSaving: Int,
         vendorName: String? = nil,
         category: String? = nil,
         isVerified: Bool = false,
         notes: String? = nil) {
        self.id = UUID()
        let now = Date()
        self.createdAt = now
        self.lastUpdated = now
        self.imagePath = imagePath
        self.totalAmount = totalAmount
        self.potentialTaxSaving = potentialTaxSaving
        self.vendorName = vendorName
        self.category = category
        self.isVerified = isVerified
        self.notes = notes
    }
    
    // Computed properties for display
    var displayAmount: Double {
        return Double(totalAmount) / 100.0
    }
    
    var displayTaxSaving: Double {
        return Double(potentialTaxSaving) / 100.0
    }
}

// MARK: - Achievement
struct Achievement: Codable, Identifiable {
    enum Category: String, Codable, CaseIterable {
        case scanning = "scanning"
        case savings = "savings"
        case consistency = "consistency"
        case learning = "learning"
    }
    
    let id: UUID
    let name: String
    let description: String
    let category: Category
    let threshold: Int
    let icon: String
    let unlockedAt: Date?
    let isUnlocked: Bool
    
    init(name: String,
         description: String,
         category: Category,
         threshold: Int,
         icon: String) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.category = category
        self.threshold = threshold
        self.icon = icon
        self.unlockedAt = nil
        self.isUnlocked = false
    }
}

// MARK: - User Progress
struct UserProgress: Codable {
    let userId: String
    let totalReceiptsScanned: Int
    let totalPotentialSavings: Int // In cents
    let currentStreak: Int
    let longestStreak: Int
    let lastScanDate: Date?
    let achievementIds: [UUID]
    let createdAt: Date
    let lastUpdated: Date
    
    init(userId: String = "default") {
        self.userId = userId
        self.totalReceiptsScanned = 0
        self.totalPotentialSavings = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastScanDate = nil
        self.achievementIds = []
        let now = Date()
        self.createdAt = now
        self.lastUpdated = now
    }
    
    var displayTotalSavings: Double {
        return Double(totalPotentialSavings) / 100.0
    }
}

// MARK: - Educational Tip
struct EducationalTip: Codable, Identifiable {
    enum Category: String, Codable, CaseIterable {
        case businessMeal = "business_meal"
        case homeOffice = "home_office"
        case equipment = "equipment"
        case general = "general"
    }
    
    struct TriggerConditions: Codable {
        let expenseAmountMin: Int?
        let expenseAmountMax: Int?
        let vendorTypes: [String]?
        let categories: [String]?
        
        init(expenseAmountMin: Int? = nil,
             expenseAmountMax: Int? = nil,
             vendorTypes: [String]? = nil,
             categories: [String]? = nil) {
            self.expenseAmountMin = expenseAmountMin
            self.expenseAmountMax = expenseAmountMax
            self.vendorTypes = vendorTypes
            self.categories = categories
        }
    }
    
    let id: UUID
    let title: String
    let content: String
    let category: Category
    let triggerConditions: TriggerConditions
    let displayCount: Int
    let maxDisplays: Int
    let priority: Int
    
    init(title: String,
         content: String,
         category: Category,
         triggerConditions: TriggerConditions = TriggerConditions(),
         maxDisplays: Int = 3,
         priority: Int = 1) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.category = category
        self.triggerConditions = triggerConditions
        self.displayCount = 0
        self.maxDisplays = maxDisplays
        self.priority = priority
    }
}

// MARK: - Tax Configuration
struct TaxConfiguration: Codable {
    struct IncomeBracket: Codable {
        let min: Int
        let max: Int
        let rate: Double
    }
    
    struct FilingStatusConfig: Codable {
        let standardDeduction: Int
    }
    
    let incomeBrackets: [String: IncomeBracket]
    let filingStatuses: [String: FilingStatusConfig]
    let lastUpdated: Date
    
    static let `default` = TaxConfiguration(
        incomeBrackets: [
            "low": IncomeBracket(min: 0, max: 50000, rate: 0.12),
            "medium": IncomeBracket(min: 50001, max: 100000, rate: 0.22),
            "high": IncomeBracket(min: 100001, max: Int.max, rate: 0.32)
        ],
        filingStatuses: [
            "single": FilingStatusConfig(standardDeduction: 1275000), // $12,750 in cents
            "married": FilingStatusConfig(standardDeduction: 2550000)  // $25,500 in cents
        ],
        lastUpdated: Date()
    )
}

// MARK: - App Settings
struct AppSettings: Codable {
    enum Theme: String, Codable, CaseIterable {
        case light = "light"
        case dark = "dark"
        case system = "system"
    }
    
    let isOnboardingComplete: Bool
    let notificationsEnabled: Bool
    let reminderTime: String?
    let theme: Theme
    let currency: String
    let privacyConsentGiven: Bool
    let lastBackupDate: Date?
    let appVersion: String
    
    static let `default` = AppSettings(
        isOnboardingComplete: false,
        notificationsEnabled: true,
        reminderTime: nil,
        theme: .system,
        currency: "USD",
        privacyConsentGiven: false,
        lastBackupDate: nil,
        appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    )
}