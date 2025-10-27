# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.2] - 2025-10-26

### Added
- Country selector in the user profile to support Australian (ATO) and US (IRS) tax rules.
- Country-specific deduction guidance with refreshed educational tips per tax authority.
- Clear, descriptive labels for income brackets and filing statuses to help users choose the right option.

### Changed
- Tax savings calculations now apply country-aware marginal rates and filing adjustments.
- Persisted user profile data includes the selected tax country with a database migration for existing installs.

### Added
- **Educational Content System** (Story 3.2 - Educational Tooltips)
  - Created comprehensive educational tip model with 8 categorized tips
  - Implemented `EducationalTipCard` widget for displaying tips
  - Added `EducationalTipDialog` for focused tip viewing
  - Built `EducationalTipsSheet` bottom sheet showing all available tips
  - Integrated "Tip of the Day" on dashboard (dismissible)
  - Added educational tips to receipt reward screen
  - Tips cover: business meals, home office, equipment, mileage, supplies, professional services, education, and record keeping

- **Enhanced Gamification System** (Story 2.4 - Basic Gamification)
  - Expanded achievement system from 4 to 13 achievements
  - Added progressive scanning milestones: 1, 5, 10, 25, 50, 100 receipts
  - Added progressive savings milestones: $50, $100, $250, $500, $1K, $2K, $5K
  - Implemented achievement unlock notifications with celebratory dialog
  - Created beautiful achievement notification UI with animations
  - Added achievement snackbar variant for less intrusive notifications
  - Enhanced achievements screen with progress tracking and visual indicators
  - Improved achievement service to return newly unlocked achievements

- **Dashboard Enhancements**
  - Added progress bars showing advancement toward next savings milestone
  - Integrated lightbulb icon for quick access to tax tips
  - Added "Tip of the Day" card with dismiss functionality
  - Enhanced visual hierarchy with improved card designs
  - Added milestone progress indicators with percentage display
  - Improved empty state messaging with visual icons
  - Enhanced recent receipts display with better formatting
  - Added tooltips for all action buttons
- **Receipt Workflow**
  - Introduced a review screen to confirm totals, vendor, and category before saving
  - Persisted vendor/category metadata and surfaced it on reward and history screens
  - Added full receipt history view with pull-to-refresh and chronological sorting

- **Receipt Scanner Improvements**
  - Redesigned reward screen with more engaging visual feedback
  - Added larger success icon with circular background
  - Integrated educational tip on reward screen for contextual learning
  - Improved layout with better spacing and visual hierarchy
  - Enhanced button styling with icons and better labels
  - Added "Estimate Only" disclaimer on reward screen

- **Testing**
  - Created comprehensive tests for educational tip model
  - Added widget tests for educational tip components
  - Enhanced achievement model tests to cover all 13 achievements
  - Added tests for progressive milestone validation
  - Created tests for unique achievement IDs
  - Total test coverage expanded significantly

### Changed
- **Achievement Service**
  - Refactored to return list of newly unlocked achievements
  - Added `clearNewlyUnlocked()` method for managing notification state
  - Enhanced achievement checking logic to support all 13 achievements
  - Improved notification system integration
- **Receipt Persistence**
  - Database queries now return receipts ordered by newest first for consistent UI state
  - Dashboard refreshes automatically after returning from the receipt history view
- **Achievement Initialization**
  - Service now guarantees achievements are loaded before any unlock logic runs, preventing race conditions on first launch

- **Dashboard Screen**
  - Restructured layout for better information hierarchy
  - Enhanced gamification section with progress visualization
  - Improved receipt list with avatar icons and better formatting
  - Added helper methods for progress bar rendering
  - Implemented dynamic milestone calculation

- **Achievements Screen**
  - Complete redesign with gradient header
  - Added overall progress indicator
  - Enhanced achievement cards with unlock dates
  - Improved visual distinction between locked/unlocked achievements
  - Added relative time formatting for unlock dates

- **UI/UX Improvements**
  - Elevated card designs for better visual depth
  - Consistent color scheme using Material Design 3
  - Improved spacing and padding throughout the app
  - Better empty states with helpful guidance
  - Enhanced button styling with icons
- **Documentation**
  - Populated execution log and QA plan with actionable detail
  - Governance traceability report updated to reflect resolved scaffolding gates

### Removed
- Deprecated TypeScript/Swift prototype scaffolding under `src/` and `tests/`
- Dropped unused dependencies `flutter_secure_storage` and `shared_preferences` from the Flutter app configuration

### Technical Improvements
- Created new `features/educational` module for educational content
- Organized educational tips by category for future filtering
- Implemented reusable educational UI components
- Enhanced state management for achievement notifications
- Improved code organization and modularity
- Added comprehensive inline documentation

### Documentation
- Updated README with detailed feature list
- Added emoji icons for better visual appeal
- Documented all 13 achievements
- Listed all 8 educational tip categories
- Updated feature completion status

## [1.0.0] - Initial Release

### Added
- Initial project scaffolding with Flutter 3.24.4
- Core data models (Receipt, UserProfile, Achievement)
- SQLite database integration with `sqflite`
- Receipt scanning with camera integration
- OCR text recognition using Google ML Kit
- Tax calculation service with income bracket support
- User profile management with filing status
- Basic achievement system
- Dashboard with savings display
- Receipt scanner screen
- Profile configuration screen
- Unit and widget test foundation
- CI/CD pipeline with GitHub Actions
- Project documentation in `docs/` folder

### Privacy & Security
- Local-only data storage (no cloud sync)
- Secure storage for user profile information
- All data processing done on-device
- No external API calls or data sharing
- Full user control over data

---

## Future Enhancements (Planned)

### Post-MVP Features
- **Expense Categorization** (Story 3.1)
  - Predefined expense categories
  - Smart category suggestions based on vendor
  - Category-based filtering and reporting

- **Data Export** (Story 3.3)
  - CSV export for spreadsheet analysis
  - PDF report generation for tax professionals
  - Year-end summary reports
  - Email/share functionality

- **Enhanced Gamification**
  - Streak tracking (daily, weekly, monthly)
  - Scanning consistency achievements
  - Social sharing of milestones (privacy-respecting)
  - Custom goal setting

- **Advanced Features**
  - Receipt image editing and annotation
  - Multi-year tracking and comparison
  - Expense search and filtering
  - Backup and restore functionality
  - Receipt tagging system

- **Educational Enhancements**
  - Interactive tax deduction calculator
  - State-specific deduction guides
  - Tax filing checklist
  - Integration with tax preparation timeline

---

*For detailed technical specifications, see the `docs/design.md` file.*
*For product requirements, see the `docs/product_backlog.md` file.*
