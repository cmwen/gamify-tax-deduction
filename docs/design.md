# Design Document

*Last Updated: 2025-09-07*

## 1. Introduction
This document translates the product backlog into a technical and UX design for the Gamified Tax Deduction application. It covers foundational project structure and the core MVP features, exploring trade-offs and providing clear specifications for implementation.

---

## 2. Foundational Scaffolding & Hygiene (Epic 1)
**Backlog Link**: Epic 1: Foundational Scaffolding & Hygiene
**Goal**: Establish a clean, maintainable, and community-friendly repository to support our open-source vision.
**[Design → Execution]**

### 2.1. Project Structure
The repository will follow a standard, language-agnostic structure to ensure it is intuitive for new contributors.

```
gamify-tax-deduction/
├── .github/              # GitHub-specific files (Actions, issue templates)
│   └── workflows/
│       └── ci.yml        # Continuous Integration workflow
├── docs/                 # Project documentation (vision, backlog, design, etc.)
├── lib/                  # Flutter source code
│   ├── main.dart         # Application entry point
│   ├── features/         # Feature-based modules (e.g., UserProfile, ReceiptScanner)
│   ├── core/             # Shared business logic, utilities, data models
│   └── shared/           # Shared widgets and utilities
├── test/                 # Unit and widget tests
├── integration_test/     # Integration tests
├── android/              # Android-specific configuration
├── ios/                  # iOS-specific configuration
├── .gitignore            # Files and directories to ignore
├── pubspec.yaml          # Flutter dependencies and configuration
├── CONTRIBUTING.md       # Guidelines for contributors
├── LICENSE               # Project license (e.g., MIT)
└── README.md             # Project overview and setup instructions
```

### 2.2. Technology Stack Recommendation
- **Cross-Platform**: Flutter with Dart, using native camera and ML Kit plugins.
- **Testing**: Flutter's built-in testing framework with integration tests.
- **Rationale**: Flutter is chosen to provide a consistent user experience across platforms while maintaining access to native device capabilities through plugins. This approach reduces development complexity, accelerates feature delivery, and ensures consistent behavior for the core "scan and reward" loop across iOS and Android.

### 2.3. `.gitignore` Baseline
A comprehensive `.gitignore` will be created to ignore common OS, IDE, build, and dependency artifacts for Flutter development, including build folders, IDE configurations, and platform-specific generated files.

### 2.4. CI/CD Pipeline (GitHub Actions)
**Backlog Link**: Story 1.2: Setup CI/CD Pipeline
A `ci.yml` workflow will be established with the following steps:
1. **Trigger**: On push to `main` and on pull requests targeting `main`.
2. **Jobs**:
   - `lint`: Run Flutter's built-in linter (`flutter analyze`) to enforce code style.
   - `build_and_test`:
     - Check out the code.
     - Set up Flutter environment.
     - Run `flutter pub get` to install dependencies.
     - Execute `flutter test` for unit tests.
     - Run `flutter build` for both iOS and Android to ensure compilation succeeds.

---

## 3. MVP Architecture & Design (Epic 2)
**Backlog Link**: Epic 2: MVP - Core Habit Loop
**Goal**: Design the core features for the MVP, focusing on the local-first, privacy-centric habit loop.

### 3.1. High-Level Architecture
The application will use a local-first, 3-tier architecture. All data lives on the device and is processed there.

```
+--------------------------------+
|      Presentation Layer        |  (Flutter Widgets)
| (UI, Views, State Management)  |
+--------------------------------+
             |
+--------------------------------+
|      Business Logic Layer      |
| (OCR, Tax Calc, Gamification)  |
+--------------------------------+
             |
+--------------------------------+
|           Data Layer           |  (SQLite via sqflite, Local Storage)
|   (Database, File Storage)     |
+--------------------------------+
```

### 3.2. Data Models
The following data structures will be used for the MVP. They will be stored locally.

```dart
// Stored in a secure local key-value store (e.g., flutter_secure_storage)
class UserProfile {
  final String incomeBracket; // 'low' | 'medium' | 'high'
  final String filingStatus; // 'single' | 'married'
  
  UserProfile({required this.incomeBracket, required this.filingStatus});
}

// Stored in the local SQLite database
class Receipt {
  final String id; // UUID
  final DateTime createdAt;
  final String imagePath; // Path to the image file in local app storage
  final String? vendorName;
  final double totalAmount;
  final double potentialTaxSaving;
  final String? category; // For Post-MVP
  
  Receipt({
    required this.id,
    required this.createdAt,
    required this.imagePath,
    this.vendorName,
    required this.totalAmount,
    required this.potentialTaxSaving,
    this.category,
  });
}
```

### 3.3. Core Feature Design

#### 3.3.1. On-Device OCR (Story 2.2)
**[Design → QA]** *Risk: OCR accuracy is critical. QA should focus on testing with various receipt types (faded, crumpled, different currencies).*

- **Approach 1: Google ML Kit via Flutter Plugin (google_mlkit_text_recognition)**
  - **Pros**: Cross-platform consistency, OS-optimized, ultimate privacy, no cost.
  - **Cons**: Requires Flutter plugin integration.
- **Approach 2: Bundled Open-Source Model (e.g., TensorFlow Lite)**
  - **Pros**: More control over model accuracy.
  - **Cons**: Increases app size, requires model maintenance.

**Decision**: **Approach 1 (Google ML Kit via Flutter Plugin)** is selected for the MVP. It provides the best of both worlds - native performance with cross-platform consistency, aligns with our privacy-first vision, and is cost-effective.

#### 3.3.2. Local Storage (Data Layer)
- **Approach 1: High-Level ORMs (Hive / Isar)**
  - **Pros**: Powerful querying, Flutter-native.
  - **Cons**: Overkill for the MVP's simple data needs.
- **Approach 2: SQLite with sqflite Plugin**
  - **Pros**: Simple, robust, transparent, and easy for new contributors to understand.
  - **Cons**: Requires more boilerplate code for complex queries (not an issue for MVP).

**Decision**: **Approach 2 (SQLite with sqflite)** is selected. This provides a familiar SQL interface that most developers understand, with the `sqflite` plugin providing Flutter integration while maintaining simplicity and control.

### 3.4. UI/UX Flow
The user flow is designed to be as frictionless as possible to encourage habit formation.

1. **First Launch (Onboarding)**
   - `Screen 1`: Welcome screen explaining the app's value proposition (privacy, immediate feedback).
   - `Screen 2`: Simple form to select `incomeBracket` and `filingStatus`. A prominent disclaimer explains this is for local, anonymous estimation only.

2. **Core Loop**
   - `Screen 3 (Dashboard)`: Displays a large, motivating number showing "Total Potential Savings" for the year. A primary call-to-action (CTA) button: `[Scan New Receipt]`.
   - `Action`: User taps `[Scan New Receipt]`.
   - `Screen 4 (Camera View)`: The camera opens. User takes a picture of a receipt.
   - `Screen 5 (Confirmation)`: The app shows the captured image and the OCR-extracted amount. The user can tap to correct the amount.
   - `Action`: User taps `[Confirm]`.
   - `Screen 6 (Reward)`: A rewarding, animated screen appears.
     - **Text**: "Nice! You've unlocked **$2.40** in potential tax savings."
     - **CTA**: `[Scan Another]` or `[Done]`.

This flow provides an immediate, positive feedback loop right after the user performs the desired action (scanning a receipt).

### 3.5. Educational Content Integration (Story 3.2)
**Backlog Link**: Story 3.2: Educational Tooltips
**[Design → QA]** *QA should validate that educational content enhances rather than interrupts the core flow.*

Educational content will be contextually integrated to enhance user understanding without disrupting the habit formation loop:

#### 3.5.1. Educational Tooltip System
- **Trigger Points**: 
  - After successful receipt scan (Screen 6 - Reward)
  - When user reviews receipt history on Dashboard
  - During expense categorization (Post-MVP)

- **Content Strategy**:
  - **Micro-Learning**: 1-2 sentence explanations maximum
  - **Contextual**: Triggered by specific expense types or amounts
  - **Progressive**: More advanced tips for experienced users

#### 3.5.2. Educational Content Examples
```
Business Meal Example:
"💡 Business meals are typically 50% deductible when discussing work with clients or colleagues."

Home Office Example:
"💡 Home office expenses can include a portion of your rent, utilities, and internet costs."

Equipment Purchase Example:
"💡 Business equipment over $2,500 may need to be depreciated over several years instead of deducted immediately."
```

#### 3.5.3. Educational UI Integration
- **Dashboard Integration**: Small "💡 Tip of the Day" card that rotates educational content
- **Receipt Detail View**: Tap-to-reveal "ℹ️" icon next to tax savings estimate
- **Settings Screen**: "Learn About Deductions" section with comprehensive guides

### 3.6. Gamification System Design (Story 2.4)
**Backlog Link**: Story 2.4: Basic Gamification - Progress Tracker
**Goal**: Drive sustained engagement through achievement psychology without manipulation.

#### 3.6.1. Achievement Framework
**Core Principle**: Celebrate positive financial habits, not just app usage.

**Achievement Categories**:
1. **Scanning Milestones**: "First Scan", "10 Receipts", "100 Receipts"
2. **Savings Milestones**: "$100 Tracked", "$500 Tracked", "$1000 Tracked"
3. **Consistency Rewards**: "3 Days in a Row", "Weekly Warrior", "Monthly Master"
4. **Learning Achievements**: "Tax Tip Explorer", "Deduction Detective"

#### 3.6.2. Progress Visualization
- **Primary Metric**: Annual potential tax savings (large, prominent number)
- **Secondary Metrics**: 
  - Monthly scanning streak
  - Number of receipts scanned this month
  - Progress toward next savings milestone

#### 3.6.3. Gamification UI Elements
```
Dashboard Gamification Section:
┌─────────────────────────────────────┐
│ 🎯 This Year's Progress             │
│                                     │
│ Total Potential Savings: $1,247     │
│ ████████░░ 83% to your $1,500 goal │
│                                     │
│ 🔥 7-day scanning streak            │
│ 📊 23 receipts this month           │
│                                     │
│ 🏆 Recent Achievement:              │
│ "Monthly Master" - 30 scans in Nov! │
└─────────────────────────────────────┘
```

#### 3.6.4. Achievement Notification System
- **Immediate Feedback**: Achievement popup after reaching milestone
- **Gentle Reminders**: Weekly summary of progress (not daily nagging)
- **Social Sharing**: Option to share milestones (respecting privacy - no dollar amounts)

### 3.7. Community Contribution Framework Design
**Backlog Link**: Story 1.3: Define Contribution Guidelines
**[Design → Execution]** *This section addresses the open-source community experience.*

#### 3.7.1. Contributor Onboarding Flow
The repository will be designed to welcome first-time contributors:

1. **README Experience**:
   - Clear "Quick Start" section for running the app locally
   - "Contributing" section linking to detailed guidelines
   - "Good First Issues" section highlighting beginner-friendly tasks

2. **CONTRIBUTING.md Structure**:
   - Development environment setup (iOS/Android)
   - Code style guidelines and automated linting
   - Testing requirements and how to run tests
   - Pull request process and review expectations
   - Community code of conduct

#### 3.7.2. Community Feature Integration
- **In-App Attribution**: "About" screen crediting community contributors
- **Development Mode**: Hidden developer options for contributors to test features
- **Feedback Channel**: Easy way for users to suggest features or report bugs

This flow provides an immediate, positive feedback loop right after the user performs the desired action (scanning a receipt).
**[Design → Execution]**
**[Design → QA]** *QA should validate that the flow is intuitive and that the "Reward" screen feels satisfying.*

---

## 4. Design Completeness Review

### 4.1. Vision Alignment Verification
This design addresses all core vision requirements:

✅ **Habit Formation**: Core loop with immediate gratification (Section 3.4)
✅ **Privacy-First**: Local-only architecture with transparent data models (Section 3.1-3.2)  
✅ **Educational Impact**: Contextual learning system integrated (Section 3.5)
✅ **Community Building**: Contributor experience designed (Section 3.7)
✅ **Individual Focus**: UI optimized for primary persona "Freelance Sarah"
✅ **Open Source**: Community-friendly architecture and contribution framework

### 4.2. Product Backlog Coverage
All P0 (Must Have) user stories are fully specified:
- ✅ Story 1.1-1.3: Repository scaffolding detailed in Section 2
- ✅ Story 2.1-2.4: MVP core loop fully designed in Section 3
- ✅ Story 3.2: Educational tooltips system specified in Section 3.5

### 4.3. Risk Mitigation
Key risks identified and addressed:
- **OCR Accuracy**: Native framework approach with user correction flow (Section 3.3.1)
- **User Engagement**: Multi-layered gamification without manipulation (Section 3.6)
- **Community Adoption**: Contributor onboarding experience designed (Section 3.7)

## 5. Handoff & Traceability
- This design document addresses **all P0 user stories** from the Product Backlog.
- **All vision requirements** are translated into specific technical implementations.
- Key risks and testing areas have been flagged for the QA Agent with **[Design → QA]** tags.
- Repository scaffolding requirements are detailed for the Execution Agent with **[Design → Execution]** tags.
- The design is now **complete and ready** for implementation.

---

# System Design

## Architecture Overview
[High-level system architecture]

## Component Designs
[Detailed component specifications]

## Data Models
[Data structures and relationships]

## API Specifications
[API designs and contracts]

## Trade-off Decisions
[Design decisions and rationale]

## Non-functional Requirements
[Performance, security, scalability requirements]

---
*Created by Design Agent | Links: [Product Backlog](product_backlog.md) → [Execution Log](execution_log.md)*
