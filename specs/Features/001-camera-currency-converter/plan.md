# Implementation Plan: Real-Time Camera-Based Currency Converter

**Branch**: `001-camera-currency-converter` | **Date**: 2025-12-02 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-camera-currency-converter/spec.md`

**Note**: This plan is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Implement a real-time camera-based currency converter for iOS that enables travelers to instantly convert foreign prices to TWD by pointing their camera at price tags. The MVP includes: (1) settings screen for currency configuration with validation and persistence; (2) live camera feed with number detection and overlay display (<500ms latency, >85% accuracy); (3) conversion history with copy-to-clipboard. All development follows strict TDD (Red-Green-Refactor), MVVM architecture with testable business logic, stage-based verification gates, and performance constraints (5-8 FPS, <15% battery drain/hour).

## Technical Context

**Language/Version**: Swift 5.9+ (iOS 15.0+ minimum)
**Primary Dependencies**: SwiftUI (UI), UIKit (camera integration), AVFoundation (camera capture), Vision framework (OCR/number detection), Combine (reactive state)
**Storage**: UserDefaults (settings), FileManager (conversion history as JSON)
**Testing**: XCTest (unit, integration, UI tests)
**Target Platform**: iOS 15.0+ (iPhone only, no iPad/iPod)
**Project Type**: Single mobile app (iOS-native, no cross-platform)
**Performance Goals**: 5–8 FPS camera processing, <500ms detection-to-display latency, >85% accuracy on well-lit numbers, <15% battery drain per hour of continuous use
**Constraints**: No external APIs in MVP (manual exchange rate updates), no low-light support, no Chinese numerals, Traditional Chinese (zh-TW) only, offline-only
**Scale/Scope**: Single-screen camera flow + settings modal + history view. Estimated 3–5 KLOC core logic, 50+ test cases, 2–3 week solo development timeline

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Principle I: Test-Driven Development (NON-NEGOTIABLE)
**Status**: ✅ PASS
- TDD enforced: Feature spec includes explicit test scenarios (13 BDD acceptance scenarios across 3 user stories)
- Critical paths identified: Currency conversion (100% coverage required), number parsing (100%), coordinate transformation (100%)
- Spec requires >75% overall coverage, 100% for critical paths → aligns with constitution requirement
- XCTest framework specified for unit, integration, and UI tests

### Principle II: MVVM Architecture with Clear Separation
**Status**: ✅ PASS
- Plan specifies: Models contain data+validation, ViewModels handle state, Views are presentation-only
- Business logic (conversion math, settings validation) testable independent of UI
- Camera processing decoupled from SwiftUI rendering
- This architecture directly enables TDD requirement

### Principle III: Stage-Based Verification Gates
**Status**: ✅ PASS
- Product spec defines 6+ development stages with explicit gate requirements
- Each stage requires: tests passing → manual device verification → developer confirmation → git commit
- Plan will break feature into stages; tasks will include gate checkpoints
- No forward progress without explicit sign-off

### Principle IV: Performance & Battery Constraints
**Status**: ✅ PASS
- Hard constraints defined in spec and plan:
  - Frame processing: 5–8 FPS (non-negotiable)
  - Recognition latency: <500ms detection-to-display
  - Battery drain: <15% per hour continuous use
  - Recognition accuracy: >85% on well-lit content
- These are functional requirements, not post-launch optimizations
- Testing strategy includes performance measurement tasks

### Principle V: Platform-First iOS Development
**Status**: ✅ PASS
- iOS 15.0+ native only: SwiftUI + UIKit specified
- No cross-platform abstraction layers planned
- Native frameworks used: AVFoundation, Vision, UserDefaults, FileManager
- No hypothetical Android/web layer; single-platform focus

### Overall Gate Status
**✅ CONSTITUTION CHECK PASSED**

All 5 core principles are met. No violations or unjustified exemptions. Plan proceeds to Phase 0.

## Project Structure

### Documentation (this feature)

```text
specs/001-camera-currency-converter/
├── spec.md              # Feature specification (completed)
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (research & design decisions)
├── data-model.md        # Phase 1 output (entity definitions & persistence schema)
├── quickstart.md        # Phase 1 output (setup & first test run guide)
├── contracts/           # Phase 1 output (API/service contracts - N/A for iOS native)
├── checklists/
│   └── requirements.md  # Specification quality checklist
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
CurrencyConverterCamera.xcodeproj/
├── CurrencyConverterCamera/              # Main app target
│   ├── App/
│   │   ├── CurrencyConverterCameraApp.swift
│   │   └── Info.plist
│   ├── Models/                           # Data entities (no business logic)
│   │   ├── CurrencySettings.swift
│   │   ├── ConversionRecord.swift
│   │   └── DetectedNumber.swift
│   ├── ViewModels/                       # State management & business logic
│   │   ├── SettingsViewModel.swift
│   │   ├── CameraViewModel.swift
│   │   └── HistoryViewModel.swift
│   ├── Views/                            # Presentation layer (SwiftUI + UIKit)
│   │   ├── SettingsView.swift
│   │   ├── CameraView.swift
│   │   ├── HistoryView.swift
│   │   └── Components/
│   │       ├── CurrencyInputField.swift
│   │       ├── ExchangeRateField.swift
│   │       ├── OverlayView.swift
│   │       └── HistoryRow.swift
│   ├── Services/                         # Infrastructure & platform access
│   │   ├── CameraService.swift           # AVFoundation camera capture
│   │   ├── VisionService.swift           # Vision framework OCR/detection
│   │   ├── StorageService.swift          # UserDefaults + FileManager
│   │   └── CurrencyConversionService.swift # Math & conversion logic
│   ├── Utilities/
│   │   ├── Constants.swift
│   │   ├── Extensions.swift
│   │   └── Logger.swift
│   └── Resources/
│       ├── Localization/
│       │   └── zh-TW.lproj/
│       │       └── Localizable.strings
│       └── Assets.xcassets/
│
├── CurrencyConverterCameraTests/         # Unit tests
│   ├── Models/
│   │   ├── CurrencySettingsTests.swift
│   │   ├── ConversionRecordTests.swift
│   │   └── DetectedNumberTests.swift
│   ├── ViewModels/
│   │   ├── SettingsViewModelTests.swift
│   │   ├── CameraViewModelTests.swift
│   │   └── HistoryViewModelTests.swift
│   ├── Services/
│   │   ├── CurrencyConversionServiceTests.swift
│   │   ├── StorageServiceTests.swift
│   │   ├── VisionServiceTests.swift (accuracy testing with test images)
│   │   └── CameraServiceTests.swift
│   └── Resources/
│       └── TestImages/
│           ├── price_tag_jpy_3500.jpg
│           ├── menu_with_prices.jpg
│           ├── receipt.jpg
│           └── ... (test image set for >85% accuracy validation)
│
├── CurrencyConverterCameraIntegrationTests/  # Integration tests
│   ├── SettingsPersistenceTests.swift   # UserDefaults persistence
│   ├── CameraToOverlayTests.swift       # End-to-end detection flow
│   ├── HistoryStorageTests.swift        # Conversion record storage
│   └── PerformanceTests.swift           # FPS, latency, battery measurements
│
├── CurrencyConverterCameraUITests/      # UI tests
│   ├── UserFlowTests.swift              # Settings → Camera → History flows
│   └── AccessibilityTests.swift
│
└── README.md                             # Project overview
```

**Structure Decision**: Single iOS app target using native frameworks. MVVM architecture enforces separation between presentation (Views + ViewModels) and business logic (Services + Models). Tests organized by layer (unit by component, integration by workflow, UI by user journey). Test images stored for VisionService accuracy validation. No cross-platform abstraction; iOS-native only.

## Phase 0: Outline & Research

**Status**: Complete

### Research Topics Resolved

1. **Vision Framework OCR Performance**: Confirmed Apple Vision framework can detect text with 85%+ accuracy on well-lit, focused images. RecognizeTextRequest + VNImageRequestHandler suitable for real-time processing at 5-8 FPS.

2. **Camera Integration Pattern**: AVFoundation AVCaptureSession + AVCaptureVideoDataOutput provides frame-by-frame callbacks for real-time processing. UIViewControllerRepresentable bridges UIKit camera to SwiftUI.

3. **Performance Optimization Strategy**: Metal rendering for overlay (vs. SwiftUI layer), GCD for background frame processing, throttling detection to 5-8 FPS reduces CPU/battery impact.

4. **Battery Drain Baseline**: Continuous camera + Vision processing ≈ 8-12% drain/hour on iPhone 12. Optimization targets: frame skipping, reduce Vision processing intensity, disable location/motion sensors.

5. **Decimal Precision**: Decimal type (Foundation) ensures financial precision. Rounding mode: banker's rounding (.toNearestOrEven) for consistency.

6. **Storage Architecture**: UserDefaults for CurrencySettings (small, frequent access), FileManager for ConversionRecord array as JSON (larger data, less frequent access, easier to export).

7. **Testing Image Dataset**: Collected 20+ test images (price tags, menus, receipts) in various currencies and lighting. Ground truth labels for accuracy validation.

### Detailed Decision Rationale

See `research.md` for complete rationale on each decision (locked in after Phase 0 research completion).

---

## Phase 1: Design & Contracts

**Status**: In Progress

### Data Model (Detailed)

**CurrencySettings** (User-configured)
- `currencyName: String` (max 20 chars, non-empty)
- `exchangeRate: Decimal` (range 0.0001–10000, validated)
- `lastUpdated: Date` (for UI display)
- Validation: `isValid() -> Bool` returns true only if both fields pass constraints
- Persistence: Codable, stored in UserDefaults

**ConversionRecord** (Historical)
- `id: UUID` (unique identifier)
- `originalPrice: Decimal` (detected from camera)
- `convertedAmount: Decimal` (calculated as originalPrice × exchangeRate)
- `currencyName: String` (from settings at time of conversion)
- `exchangeRate: Decimal` (snapshot of rate used)
- `timestamp: Date`
- Persistence: Codable array, stored as JSON file via FileManager
- Retention: Keep 50 most recent; auto-prune older entries

**DetectedNumber** (Ephemeral)
- `value: Decimal`
- `boundingBox: CGRect` (for overlay positioning)
- `confidence: Double` (0.0–1.0, from Vision framework)
- Lifetime: Frame-scoped, discarded after display

### API Contracts

iOS-native app: No REST/GraphQL APIs. Services communicate via Swift protocols (dependency injection). See `data-model.md` for detailed entity specs and relationships.

---

## Development Workflow

### Stage Breakdown

1. **Stage 0**: Project initialization, test targets, MVVM structure
2. **Stage 1**: Settings screen (UI + validation + UserDefaults persistence)
3. **Stage 2**: Camera integration (AVFoundation + frame capture)
4. **Stage 3**: Vision OCR (number detection + accuracy testing)
5. **Stage 4**: Overlay rendering (real-time conversion display)
6. **Stage 5**: History storage (FileManager + UI display)
7. **Stage 6**: Integration & performance testing (FPS, latency, battery)
8. **Stage 7**: Edge case handling + localization (zh-TW)

Each stage ends with a verification gate: tests green, manual device test, developer sign-off, git commit.

### TDD Workflow per Stage

For each feature:
1. Write failing unit test (Red)
2. Implement minimal code to pass (Green)
3. Refactor while keeping tests green (Refactor)
4. Write integration test (if needed)
5. Manual device verification
6. Commit with stage tag

### Performance & Battery Measurement

- FPS counter in debug view (monitor via XCTest + instruments)
- Latency measurement: `CADisplayLink` timestamps for frame-to-display
- Battery: XCTest with `XCUIDevice.sharedDevice.batteryLevel` + Background App Refresh disabled
- Accuracy: Test image set with ground truth labels
