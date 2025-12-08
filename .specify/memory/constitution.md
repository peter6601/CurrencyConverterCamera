<!-- Sync Impact Report
Version: 1.0.0 (NEW)
- Status: Initial creation from template
- All 5 core principles defined
- Added iOS development and performance constraints
- Defined TDD enforcement and testing gates
- Governance procedures documented
-->

# CurrencyConverterCamera Constitution

## Core Principles

### I. Test-Driven Development (NON-NEGOTIABLE)

All feature development MUST follow strict TDD methodology: write failing tests first, then implement to pass, then refactor. The Red-Green-Refactor cycle is mandatory. No code ships without tests. Critical paths (currency conversion, number parsing, coordinate transformation) require 100% test coverage; overall coverage target is >75%.

**Rationale**: Camera-based number recognition and financial calculations require extreme reliability. TDD ensures correctness before deployment and prevents costly bugs in production.

### II. MVVM Architecture with Clear Separation

The project uses Model-View-ViewModel architecture to ensure testable business logic decoupled from UI presentation. Models contain pure data and business rules; ViewModels expose observable state; Views are presentation-only.

**Rationale**: Camera processing, vision pipeline, and financial calculations must be independently testable from SwiftUI rendering to prevent UI-layer regressions.

### III. Stage-Based Verification Gates

After each development stage completes, work MUST pause for: (1) all tests passing, (2) manual verification on simulator/device, (3) developer confirmation, (4) git commit with stage tag. No merging forward without explicit gate clearance.

**Rationale**: Real-time camera performance, battery efficiency, and accuracy metrics require empirical validation—automated tests alone cannot catch frame rate drops, thermal issues, or camera permission edge cases.

### IV. Performance & Battery Constraints

Frame processing: 5-8 FPS minimum with <500ms latency from detection to display. Battery drain: <15% per hour of continuous camera use. These are hard constraints, not guidelines. Optimization is part of core development, not post-launch.

**Rationale**: A camera app that drains battery rapidly or lags is unusable for travelers. Performance is a functional requirement, not a nice-to-have.

### V. Platform-First iOS Development

All code targets iOS 15.0+ using native frameworks (SwiftUI + UIKit for camera). No cross-platform abstraction layers or compatibility shims for hypothetical future platforms. Leverage iOS APIs fully—CoreML, Vision, AVFoundation, CameraKit.

**Rationale**: Optimizing for iOS-native APIs maximizes performance and reduces maintenance burden. Early cross-platform planning for a single-platform app introduces premature complexity.

## Development Workflow & Quality Gates

- **Unit Tests**: Run before every commit; CI enforces 100% pass rate
- **Integration Tests**: Required for all service-to-service communication (API calls, camera to overlay, exchange rate service)
- **UI Tests**: Main user flows (settings → camera → overlay display) tested on simulator minimum once per stage
- **Stage Checkpoints**: Developer confirmation required before proceeding to next stage; staged delivery enables early feedback

## Performance & Constraints

- **Recognition Accuracy**: >85% for clear, well-lit numbers
- **Frame Processing**: 5-8 FPS (non-negotiable)
- **Recognition Latency**: <500ms from detection to display
- **Battery Efficiency**: <15% drain per hour continuous use
- **Test Coverage**: >75% overall; 100% for critical paths
- **Minimum iOS**: iOS 15.0+
- **Primary Language**: Traditional Chinese (zh-TW) with UTF-8 support required

## Governance

This constitution supersedes all other development practices for CurrencyConverterCamera. Amendments require:

1. **Documentation**: Describe the principle change and rationale
2. **Impact Assessment**: Identify affected templates, workflows, and code
3. **Approval**: Explicit acknowledgment of amendment before proceeding
4. **Migration Plan**: Update `.specify/templates/` files and document transition
5. **Version Increment**: Follow semantic versioning (MAJOR for incompatible changes, MINOR for expansions, PATCH for clarifications)

**Compliance Review**: Quarterly or upon significant architectural decision. All PRs/reviews must verify TDD gate compliance and performance constraint adherence. Complexity violations require explicit justification in commit messages.

**Runtime Guidance**: The `.specify/templates/plan-template.md` (Constitution Check), `spec-template.md`, and `tasks-template.md` implement these principles. All generated plans/specs/tasks must reflect current constitution version.

---

**Version**: 1.0.0 | **Ratified**: 2025-12-02 | **Last Amended**: 2025-12-02
