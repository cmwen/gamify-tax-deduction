/**
 * Core data models for the Gamified Tax Deduction app
 * These models represent the fundamental data structures used across both platforms
 */

// User profile data stored in secure local storage (Keychain/Keystore)
export interface UserProfile {
  incomeBracket: 'low' | 'medium' | 'high';
  filingStatus: 'single' | 'married';
  createdAt: Date;
  lastUpdated: Date;
}

// Receipt data stored in local SQLite database
export interface Receipt {
  id: string; // UUID
  createdAt: Date;
  lastUpdated: Date;
  imagePath: string; // Path to the image file in local app storage
  vendorName?: string; // Extracted from OCR or user input
  totalAmount: number; // Amount in cents to avoid floating point issues
  potentialTaxSaving: number; // Calculated tax saving in cents
  category?: string; // For Post-MVP categorization
  isVerified: boolean; // Whether user has confirmed the OCR data
  notes?: string; // User-added notes
}

// Achievement data for gamification
export interface Achievement {
  id: string;
  name: string;
  description: string;
  category: 'scanning' | 'savings' | 'consistency' | 'learning';
  threshold: number; // The value needed to unlock this achievement
  icon: string; // Icon identifier
  unlockedAt?: Date; // When user achieved this
  isUnlocked: boolean;
}

// User progress tracking
export interface UserProgress {
  userId: string; // For future multi-user support
  totalReceiptsScanned: number;
  totalPotentialSavings: number; // In cents
  currentStreak: number; // Days of consecutive scanning
  longestStreak: number;
  lastScanDate?: Date;
  achievementIds: string[]; // List of unlocked achievement IDs
  createdAt: Date;
  lastUpdated: Date;
}

// Educational content structure
export interface EducationalTip {
  id: string;
  title: string;
  content: string;
  category: 'business_meal' | 'home_office' | 'equipment' | 'general';
  triggerConditions: {
    expenseAmount?: { min?: number; max?: number };
    vendorType?: string[];
    category?: string[];
  };
  displayCount: number; // How many times this tip has been shown
  maxDisplays: number; // Maximum times to show this tip
  priority: number; // Higher priority tips shown first
}

// Tax calculation configuration
export interface TaxConfiguration {
  incomeBrackets: {
    low: { min: number; max: number; rate: number };
    medium: { min: number; max: number; rate: number };
    high: { min: number; max: number; rate: number };
  };
  filingStatuses: {
    single: { standardDeduction: number };
    married: { standardDeduction: number };
  };
  lastUpdated: Date;
}

// App settings and preferences
export interface AppSettings {
  isOnboardingComplete: boolean;
  notificationsEnabled: boolean;
  reminderTime?: string; // Time for daily scan reminders
  theme: 'light' | 'dark' | 'system';
  currency: 'USD'; // For future internationalization
  privacyConsentGiven: boolean;
  lastBackupDate?: Date;
  appVersion: string;
}