# Contributing to Gamified Tax Deduction Tracker

Thank you for your interest in contributing! This guide will help you get started with contributing to our open-source project.

## 🎯 Our Mission

We're building a privacy-first, gamified tax deduction tracker that helps people develop healthy financial habits. Every contribution, no matter how small, helps make tax compliance more accessible and engaging.

## 🌟 How to Contribute

### 🐛 Reporting Bugs

1. **Check existing issues** to avoid duplicates
2. **Use the bug report template** when creating new issues
3. **Include details**: OS version, device type, steps to reproduce
4. **Add screenshots** or screen recordings when applicable

### 💡 Suggesting Features

1. **Check the [Product Backlog](docs/product_backlog.md)** first
2. **Create a feature request** using our template
3. **Explain the user problem** you're trying to solve
4. **Consider privacy implications** - all features must work locally

### 🔧 Code Contributions

#### Getting Started

1. **Fork the repository**
2. **Clone your fork locally**
3. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

#### Development Environment Setup

##### Flutter Development
- **Requirements**: Flutter 3.24.4+, Dart SDK 3.0.0+
- **Setup**:
  ```bash
  # Clone and install dependencies
  git clone https://github.com/cmwen/gamify-tax-deduction.git
  cd gamify-tax-deduction
  flutter pub get
  
  # Run the app
  flutter run
  
  # Run tests
  flutter test
  
  # Build for platforms
  flutter build apk --debug  # Android
  flutter build ios --no-codesign  # iOS (requires macOS)
  ```

#### Code Style Guidelines

##### Swift (iOS)
- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use **SwiftLint** for consistent formatting
- **Run linting**: `swiftlint` in the iOS project directory
- **Auto-fix**: `swiftlint --fix` where possible

##### Kotlin (Android)
- Follow [Kotlin Coding Conventions](https://kotlinlang.org/docs/coding-conventions.html)
- Use **ktlint** for consistent formatting
- **Run linting**: `./gradlew ktlintCheck`
- **Auto-fix**: `./gradlew ktlintFormat`

#### Testing Requirements

All code contributions must include appropriate tests:

##### iOS Tests
- **Unit Tests**: For business logic and data models
- **UI Tests**: For critical user flows
- **Run tests**: `xcodebuild test -scheme GamifiedTaxDeduction`

##### Android Tests
- **Unit Tests**: For ViewModels and repositories
- **Instrumentation Tests**: For UI components
- **Run tests**: `./gradlew test && ./gradlew connectedAndroidTest`

#### Pull Request Process

1. **Update documentation** if you've changed APIs
2. **Add tests** for new functionality
3. **Ensure all tests pass** locally
4. **Run linting** and fix any issues
5. **Create a pull request** with:
   - Clear title and description
   - Link to related issues
   - Screenshots for UI changes
   - Test results

### 📝 Documentation Contributions

- **Fix typos** and improve clarity
- **Add examples** to existing documentation
- **Create guides** for common tasks
- **Update outdated information**

## 🏗️ Architecture Overview

Understanding our architecture will help you contribute more effectively:

### Project Structure
```
src/
├── app/              # Main application entry points
├── features/         # Feature modules (UserProfile, ReceiptScanner, etc.)
├── core/            # Shared business logic and models
└── platform/        # Platform-specific implementations
    ├── ios/         # Swift/SwiftUI implementation
    └── android/     # Kotlin/Jetpack Compose implementation
```

### Key Principles
- **Local-First**: All data stays on the device
- **Privacy-Centric**: No tracking, analytics, or cloud storage
- **Native Performance**: Platform-specific implementations for optimal UX
- **Test-Driven**: Comprehensive test coverage for reliability

## 🎯 Good First Issues

New to the project? Look for issues labeled [`good first issue`](https://github.com/cmwen/gamify-tax-deduction/labels/good%20first%20issue):

- Documentation improvements
- UI polish and accessibility
- Unit test additions
- Bug fixes in isolated components
- Adding educational content

## 💬 Community Guidelines

### Code of Conduct
- **Be respectful** and inclusive
- **Help others learn** - we welcome all skill levels
- **Focus on constructive feedback**
- **Respect different perspectives** and approaches

### Communication
- **GitHub Issues**: For bugs, features, and technical discussions
- **GitHub Discussions**: For general questions and community chat
- **Pull Request Reviews**: For code-specific feedback

## 🚀 Development Workflow

### Branching Strategy
- `main`: Stable, production-ready code
- `feature/*`: New features and enhancements
- `fix/*`: Bug fixes
- `docs/*`: Documentation updates

### Commit Guidelines
Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add receipt scanning functionality
fix: resolve OCR accuracy on blurry images
docs: update contributing guidelines
test: add unit tests for tax calculation
```

### Release Process
1. **Feature Complete**: All planned features implemented and tested
2. **Quality Assurance**: Comprehensive testing across devices
3. **Documentation**: User guides and API docs updated
4. **Community Review**: Final review period for feedback
5. **Release**: Tagged release with changelog

## 🔧 Technical Setup Details

### Prerequisites Checklist
- [ ] Git installed and configured
- [ ] iOS: Xcode 13.0+ (for iOS development)
- [ ] Android: Android Studio + SDK 24+ (for Android development)
- [ ] Code editor with Swift/Kotlin support (if contributing to shared code)

### First-Time Setup
1. **Fork and clone** the repository
2. **Install dependencies** for your target platform
3. **Run initial build** to ensure everything works
4. **Run tests** to validate your environment
5. **Check linting** setup and configuration

### Common Issues
- **Build failures**: Check Xcode/Android Studio versions
- **Dependency issues**: Clear build cache and rebuild
- **Test failures**: Ensure simulator/emulator is running
- **Linting errors**: Run auto-fix commands first

## 📊 Metrics and Quality

We track these quality metrics:
- **Test Coverage**: Aim for >80% coverage
- **Build Success Rate**: All PRs must pass CI
- **Code Review Response**: Target <24 hour initial response
- **Documentation Coverage**: All public APIs documented

## 🎉 Recognition

Contributors are recognized in:
- **In-app credits**: "About" screen lists all contributors
- **Release notes**: Highlighting significant contributions
- **GitHub achievements**: Issue and PR participation
- **Community highlights**: Featuring great contributions

## ❓ Questions?

- **Technical questions**: Open a [GitHub Issue](https://github.com/cmwen/gamify-tax-deduction/issues)
- **General discussion**: Use [GitHub Discussions](https://github.com/cmwen/gamify-tax-deduction/discussions)
- **Contribution ideas**: Check our [Project Board](https://github.com/cmwen/gamify-tax-deduction/projects)

---

Thank you for contributing to making tax compliance more accessible and engaging! 🎯