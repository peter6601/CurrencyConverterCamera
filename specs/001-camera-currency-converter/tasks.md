# Tasks: Real-Time Camera-Based Currency Converter

**Input**: Design documents from `specs/001-camera-currency-converter/`
**Prerequisites**: plan.md, spec.md, data-model.md, research.md, quickstart.md

**Tests**: The feature specification (spec.md) requests TDD methodology with >75% overall coverage and 100% coverage on critical paths. Tests are REQUIRED and organized per user story.

**Organization**: Tasks are grouped by user story (P1, P2) to enable independent implementation and testing. Each user story is a complete, independently deployable increment.

---

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies between tasks marked [P])
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- **Include exact file paths** in all descriptions
- **TDD approach**: Write failing test first → implement → refactor

## Path Conventions

**iOS mobile app** (from plan.md):
- Main app code: `CurrencyConverterCamera/` folder
- Unit tests: `CurrencyConverterCameraTests/`
- Integration tests: `CurrencyConverterCameraIntegrationTests/`
- UI tests: `CurrencyConverterCameraUITests/`
- Models, ViewModels, Views, Services, Utilities subdirectories per structure

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization, MVVM structure, XCTest targets

**Duration**: 15 minutes (from product_spec.md Stage 0)

### Sanity Check & Project Verification

- [ ] T001 Create Xcode project from SwiftUI template with name `CurrencyConverterCamera`
- [ ] T002 Add Unit Test target `CurrencyConverterCameraTests` to project
- [ ] T003 Add Integration Test target `CurrencyConverterCameraIntegrationTests` (optional Phase 0, required by Phase 6)
- [ ] T004 Add UI Test target `CurrencyConverterCameraUITests` to project
- [ ] T005 [P] Create folder structure in `CurrencyConverterCamera/App/`, `Models/`, `ViewModels/`, `Views/`, `Services/`, `Utilities/`, `Resources/`
- [ ] T006 [P] Create test folder structure: `CurrencyConverterCameraTests/Models/`, `ViewModels/`, `Services/`, `Resources/TestImages/`
- [ ] T007 Create first sanity test in `CurrencyConverterCameraTests/ExampleTests.swift` (1 + 1 = 2, project compiles)
- [ ] T008 Configure `.gitignore` for Xcode (Pods/, .swiftpm/, etc.)
- [ ] T009 Create `CurrencyConverterCamera/App/CurrencyConverterCameraApp.swift` app entry point

**Gate Checkpoint**:
- [ ] T010 Run `xcodebuild test` → all tests pass (green)
- [ ] T011 Launch simulator → app displays blank screen without errors
- [ ] T012 Verify git repository initialized with proper .gitignore
- [ ] T013 Commit Stage 0 completion: `git commit -m "[Stage 0] feat: project initialization and test targets"`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST complete before ANY user story implementation

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### Shared Models & Validation Logic (Required by all stories)

- [ ] T014 [P] Create `CurrencyConverterCamera/Models/CurrencySettings.swift` with struct: currencyName (String), exchangeRate (Decimal), lastUpdated (Date), isValid() computed property
- [ ] T015 [P] Create `CurrencyConverterCamera/Models/ConversionRecord.swift` with struct: id (UUID), originalPrice (Decimal), convertedAmount (Decimal), currencyName (String), exchangeRate (Decimal), timestamp (Date), formattedAmount() and formattedOriginalPrice() computed properties
- [ ] T016 [P] Create `CurrencyConverterCamera/Models/DetectedNumber.swift` with struct: value (Decimal), boundingBox (CGRect), confidence (Double)

### Shared Services Infrastructure

- [ ] T017 Create `CurrencyConverterCamera/Services/StorageService.swift` protocol/class with methods: saveCurrencySettings(), loadCurrencySettings(), addConversionRecord(), loadConversionHistory(), clearHistory()
- [ ] T018 Implement UserDefaults persistence in `StorageService` for CurrencySettings (key: "currencySettings")
- [ ] T019 Implement FileManager persistence in `StorageService` for ConversionRecord array as JSON (`Documents/conversion_history.json`)
- [ ] T020 Implement retention policy in `StorageService`: keep 50 most recent ConversionRecords, auto-prune older ones

### Shared Utilities & Extensions

- [ ] T021 [P] Create `CurrencyConverterCamera/Utilities/Constants.swift` with app-wide constants (max currency name length = 20, exchange rate range 0.0001–10000, history limit = 50)
- [ ] T022 [P] Create `CurrencyConverterCamera/Utilities/Extensions.swift` with String and Decimal extension helpers (formatCurrency, validateExchangeRate)
- [ ] T023 [P] Create `CurrencyConverterCamera/Utilities/Logger.swift` for debug logging

### Shared Test Infrastructure

- [ ] T024 Create test image dataset in `CurrencyConverterCameraTests/Resources/TestImages/` with 20+ labeled images (JPY price tags, USD menus, EUR receipts, edge cases with ground truth labels for accuracy validation)
- [ ] T025 Create `CurrencyConverterCameraTests/TestHelper.swift` with utility functions for creating mock CurrencySettings, ConversionRecords for testing

**Checkpoint**: Foundation complete
- [ ] T026 Run `xcodebuild test` → all foundational tests pass
- [ ] T027 Commit Phase 2 completion: `git commit -m "[Phase 2] feat: core models, storage service, utilities, test infrastructure"`

---

## Phase 3: User Story 2 - Configure Exchange Rate Before Using App (Priority: P1) 🎯 MVP Blocker

**Goal**: Implement settings screen with currency name and exchange rate input, validation, and UserDefaults persistence. Settings must be configured before camera access is enabled.

**Independent Test**: (1) Launch app → settings screen displayed, (2) Enter valid currency name and rate (0.22) → "Start Scan" button enabled, (3) Enter invalid data (rate = 0 or >10000) → error message, button disabled, (4) Settings persist across app restart

**Why First**: This is a hard blocker—no conversions possible without configured exchange rate. Core MVP feature.

### Tests for User Story 2 (TDD - Write FIRST, ensure FAIL before implementation)

- [ ] T028 [P] [US2] Unit test `CurrencyConverterCameraTests/Models/CurrencySettingsTests.swift`: test isValid property (valid: name="JPY", rate=0.22; invalid: name="", rate=0, rate=10001, name too long)
- [ ] T029 [P] [US2] Unit test `CurrencyConverterCameraTests/Services/StorageServiceTests.swift`: test saveCurrencySettings() → loadCurrencySettings() round-trip
- [ ] T030 [P] [US2] Unit test `CurrencyConverterCameraTests/ViewModels/SettingsViewModelTests.swift`: test updateCurrencyName(), updateExchangeRate(), saveSettings() with valid/invalid inputs
- [ ] T031 [US2] Integration test `CurrencyConverterCameraIntegrationTests/SettingsPersistenceTests.swift`: save settings → kill app → relaunch → verify settings restored from UserDefaults
- [ ] T032 [US2] UI test `CurrencyConverterCameraUITests/UserFlowTests.swift`: launch app → tap settings fields → enter JPY/0.22 → "Start Scan" enabled → quit and relaunch → verify values pre-filled

### Implementation for User Story 2

- [ ] T033 [P] [US2] Create `CurrencyConverterCamera/ViewModels/SettingsViewModel.swift` with @Published properties: currencyName (String), exchangeRate (String), error (String?), isValid (computed). Methods: updateCurrencyName(), updateExchangeRate(), saveSettings() → calls StorageService
- [ ] T034 [US2] Create `CurrencyConverterCamera/Views/SettingsView.swift` (SwiftUI): form with TextField for currency name (max 20 chars) and rate (decimal keyboard 0.0001–10000). "Start Scan" button disabled until isValid. Display validation errors. MVVM binding to SettingsViewModel
- [ ] T035 [US2] Create `CurrencyConverterCamera/Views/Components/CurrencyInputField.swift` (SwiftUI reusable component): TextField with validation feedback for currency name
- [ ] T036 [US2] Create `CurrencyConverterCamera/Views/Components/ExchangeRateField.swift` (SwiftUI reusable component): TextField with decimal keyboard, validation feedback, range display (0.0001–10000)
- [ ] T037 [US2] Add validation logic to `CurrencySettingsViewModel`: currencyName length ≤20, exchangeRate > 0 and ≤10000, both required to enable "Start Scan"
- [ ] T038 [US2] Update `CurrencyConverterCameraApp.swift` to show SettingsView as initial screen on first launch (check UserDefaults for existing settings)
- [ ] T039 [US2] Implement app state wrapper in `CurrencyConverterCamera/App/AppState.swift` (@EnvironmentObject) to manage current CurrencySettings and pass through dependency injection

**Checkpoint**: User Story 2 complete
- [ ] T040 Run `xcodebuild test -only-testing CurrencyConverterCameraTests` → all US2 unit tests pass
- [ ] T040b Run `xcodebuild test -only-testing CurrencyConverterCameraIntegrationTests` → persistence test passes
- [ ] T040c Launch simulator → app shows settings screen → enter JPY/0.22 → "Start Scan" enabled → quit and relaunch → settings pre-filled
- [ ] T040d Commit User Story 2 completion: `git commit -m "[Stage 1] feat: settings screen with validation and UserDefaults persistence (US2)"`

---

## Phase 4: User Story 1 - Traveler Converts Price Tag at Foreign Merchant (Priority: P1) 🎯 MVP Core

**Goal**: Implement real-time camera feed with number detection, overlay display, and conversion calculation. User points camera at price tag → app detects numbers within 500ms and displays converted TWD price overlaid.

**Independent Test**: (1) Settings configured with JPY/0.22, (2) Point camera at price tag with clear numbers → overlay displays within 500ms, (3) Accuracy >85% on well-lit test images, (4) Tap to highlight specific number → shows conversion, (5) Performance: 5–8 FPS sustained, battery <15%/hour

**Why After US2**: Requires configured CurrencySettings to function. Depends on Phase 2 foundational models.

### Tests for User Story 1 (TDD - Write FIRST)

- [ ] T041 [P] [US1] Unit test `CurrencyConverterCameraTests/Services/CurrencyConversionServiceTests.swift`: test conversion math (3500 JPY × 0.22 = 770.00 TWD), Decimal precision, banker's rounding
- [ ] T042 [P] [US1] Unit test `CurrencyConverterCameraTests/ViewModels/CameraViewModelTests.swift`: test detectedNumbers state management, conversion calculation, overlay positioning
- [ ] T043 [P] [US1] Unit test `CurrencyConverterCameraTests/Services/VisionServiceTests.swift`: accuracy test on 20+ test images (>85% on well-lit, calculate accuracy %)
- [ ] T044 [US1] Integration test `CurrencyConverterCameraIntegrationTests/CameraToOverlayTests.swift`: full flow (frame capture → Vision detection → conversion calculation → overlay render), latency <500ms
- [ ] T045 [US1] Integration test `CurrencyConverterCameraIntegrationTests/PerformanceTests.swift`: FPS measurement (5–8 FPS over 5 min), battery drain measurement (<15%/hr), latency histogram
- [ ] T046 [US1] UI test `CurrencyConverterCameraUITests/UserFlowTests.swift`: launch settings → configure JPY/0.22 → tap "Start Scan" → camera shows → point at test price tag → verify overlay appears, number highlighted, conversion correct

### Implementation for User Story 1

#### Camera Services

- [ ] T047 [P] [US1] Create `CurrencyConverterCamera/Services/CameraService.swift` (Swift class) wrapping AVFoundation: set up AVCaptureSession, camera frame delegate, handle permissions, frame-by-frame callbacks at 5–8 FPS throttling
- [ ] T048 [P] [US1] Create `CurrencyConverterCamera/Services/VisionService.swift` (Swift class) wrapping Vision framework: VNRecognizeTextRequest, process CMSampleBuffer → DetectedNumber array (value, boundingBox, confidence), accuracy filtering (confidence > 0.5)

#### Conversion Logic

- [ ] T049 [P] [US1] Create `CurrencyConverterCamera/Services/CurrencyConversionService.swift`: method convertPrice(Decimal, rate: Decimal) -> Decimal using banker's rounding to 2 places
- [ ] T050 [P] [US1] Create unit tests in `CurrencyConverterCameraTests/Services/CurrencyConversionServiceTests.swift`: 10+ test cases covering Decimal precision, rounding edge cases

#### Camera UI & ViewModel

- [ ] T051 [US1] Create `CurrencyConverterCamera/ViewModels/CameraViewModel.swift` (@ObservedObject): manages camera state, detected numbers, overlays. Methods: startCamera(), stopCamera(), processFrame(CMSampleBuffer), updateOverlays(). Reads current CurrencySettings via AppState
- [ ] T052 [US1] Create `CurrencyConverterCamera/Views/CameraView.swift` (SwiftUI): main camera interface. Uses CameraService via UIViewControllerRepresentable to bridge UIKit camera to SwiftUI. Displays camera feed with real-time overlay
- [ ] T053 [US1] Create `CurrencyConverterCamera/Views/Components/OverlayView.swift` (UIKit/Metal): renders DetectedNumber overlays with conversion price. Metal CAMetalLayer for performance (not SwiftUI layer which would block UI thread)
- [ ] T054 [US1] Create camera permission request logic in `CameraViewModel`: AVCaptureDevice.requestAccess(), show error if denied, guide to Settings

#### Integration & Navigation

- [ ] T055 [US1] Update `CurrencyConverterCameraApp.swift`: post-settings, navigate to CameraView. Implement tab/modal navigation between Settings and Camera
- [ ] T056 [US1] Add background/foreground handling in `CameraViewModel`: pause camera processing on `.scenePhase = .background`, resume on `.active`
- [ ] T057 [US1] Implement error handling (blurry camera, focus issues, permission denied) with user-friendly error messages in OverlayView

#### Performance Optimization

- [ ] T058 [US1] Implement frame throttling in `CameraService`: process 1 of every 3 frames → 30 FPS camera → 10 FPS Vision processing (achieve 5–8 FPS latency target)
- [ ] T059 [US1] Add timing instrumentation in `CameraViewModel` for latency measurement: `CADisplayLink` timestamps from frame capture to overlay render
- [ ] T060 [US1] Optimize Vision processing: crop frame to foreground ROI (region of interest) to reduce processing burden
- [ ] T061 [US1] Add battery monitoring: monitor CPU/GPU wake frequency, log battery drain via XCTest

**Checkpoint**: User Story 1 complete
- [ ] T062 Run `xcodebuild test -only-testing CurrencyConverterCameraTests` → all US1 unit tests pass (esp. VisionServiceTests showing >85% accuracy)
- [ ] T062b Run `xcodebuild test -only-testing CurrencyConverterCameraIntegrationTests` → latency <500ms, FPS 5–8, battery <15%/hr
- [ ] T062c Launch simulator → settings configured with JPY/0.22 → tap "Start Scan" → camera initializes → point at test price tag → overlay appears within 500ms with correct conversion → tap to highlight
- [ ] T062d Commit User Story 1 completion: `git commit -m "[Stages 2-4] feat: real-time camera detection, conversion overlay, performance optimization (US1)"`

---

## Phase 5: User Story 3 - View Conversion History & Quick Reference (Priority: P2)

**Goal**: Implement history view displaying recent conversions with copy-to-clipboard functionality. After conversions detected, user can review history and copy amounts for reference.

**Independent Test**: (1) Perform 5+ conversions, (2) Open history view → list displays all conversions sorted by timestamp (most recent first), (3) Tap conversion → display details (original + converted amount, rate used, timestamp), (4) Tap copy button → amount copied to clipboard, confirmation appears, (5) History >50 entries → oldest auto-pruned

**Why After US1**: Depends on ConversionRecord persistence (Phase 2) and conversion detection (US1) to populate history.

### Tests for User Story 3 (TDD - Write FIRST)

- [ ] T063 [P] [US3] Unit test `CurrencyConverterCameraTests/ViewModels/HistoryViewModelTests.swift`: test loadHistory(), deleteRecord(), clear(), retention policy (keep 50 most recent)
- [ ] T064 [P] [US3] Unit test `CurrencyConverterCameraTests/Services/StorageServiceTests.swift` (addition): test history loading, retention (auto-prune), order (most recent first)
- [ ] T065 [US3] Integration test `CurrencyConverterCameraIntegrationTests/HistoryStorageTests.swift`: add 60 records → verify oldest 10 auto-pruned, only 50 kept, sorted descending by timestamp
- [ ] T066 [US3] UI test `CurrencyConverterCameraUITests/UserFlowTests.swift` (addition): perform 5+ conversions → tap history → verify all appear with correct data → tap copy → verify clipboard contains amount

### Implementation for User Story 3

#### History ViewModel & Storage

- [ ] T067 [P] [US3] Create `CurrencyConverterCamera/ViewModels/HistoryViewModel.swift`: @Published var conversionRecords: [ConversionRecord], methods loadHistory(), deleteRecord(id:), clearHistory(). Calls StorageService
- [ ] T068 [P] [US3] Update `StorageService` for history operations: addConversionRecord() called after each detection, loadConversionHistory() returns sorted array

#### History UI

- [ ] T069 [US3] Create `CurrencyConverterCamera/Views/HistoryView.swift` (SwiftUI): List of ConversionRecords, each row shows formatted original price + converted amount + timestamp. Header shows "No conversions yet" if empty. Clear All button at bottom
- [ ] T070 [US3] Create `CurrencyConverterCamera/Views/Components/HistoryRow.swift` (SwiftUI reusable): displays one ConversionRecord with copyable converted amount, tap to expand details
- [ ] T071 [US3] Implement copy-to-clipboard in HistoryRow: `UIPasteboard.general.string = formattedAmount`, show toast confirmation "Copied: NT$ 770.00"

#### History Entry Persistence After Detection

- [ ] T072 [US1-extension] [US3] After each number detection in `CameraViewModel`, create ConversionRecord and save via `StorageService.addConversionRecord()` (happens automatically after conversion calculation)
- [ ] T073 [US3] Update navigation in `CurrencyConverterCameraApp.swift`: add History tab or history button accessible from camera view

#### Edge Cases

- [ ] T074 [US3] Handle edge case: user clears history → next refresh shows empty view with "No conversions yet"
- [ ] T075 [US3] Handle edge case: history >50 → auto-prune oldest before adding new record (happens in StorageService.addConversionRecord())

**Checkpoint**: User Story 3 complete
- [ ] T076 Run `xcodebuild test -only-testing CurrencyConverterCameraTests` → all US3 unit tests pass
- [ ] T076b Run `xcodebuild test -only-testing CurrencyConverterCameraIntegrationTests` → history storage tests pass, retention verified
- [ ] T076c Launch simulator → configure settings → perform 5+ conversions → tap history → verify all 5 appear with correct data, sorted recent first → tap copy → verify toast shows, clipboard contains amount
- [ ] T076d Commit User Story 3 completion: `git commit -m "[Stage 5] feat: conversion history with copy-to-clipboard (US3)"`

---

## Phase 6: Integration & Performance Testing (Cross-Cutting)

**Purpose**: Validate all user stories work together, meet performance constraints, handle edge cases

**⚠️ CRITICAL GATE**: Must pass all performance targets before proceeding

### Cross-Story Integration Tests

- [ ] T077 Integration test `CurrencyConverterCameraIntegrationTests/FullAppFlowTests.swift`: (1) Settings configured → (2) Camera detects prices → (3) History records conversions → (4) Copy from history works
- [ ] T078 Integration test for app backgrounding: start camera → app to background → camera pauses → app to foreground → camera resumes (T056 behavior validated)

### Performance & Battery Validation

- [ ] T079 [US1] Performance test `CurrencyConverterCameraIntegrationTests/PerformanceTests.swift`: measure and validate 5–8 FPS sustained (CADisplayLink frame counter over 5+ minutes)
- [ ] T080 [US1] Latency test: Vision detection latency histogram, verify <500ms for 95th percentile, capture via `CADisplayLink` timestamps
- [ ] T081 [US1] Battery drain measurement: 1-hour continuous camera session, measure battery% before/after, verify <15% drain
- [ ] T082 [US1] Accuracy regression test: run VisionServiceTests on full 20+ image dataset, verify >85% on well-lit subset, track accuracy over time

### Code Coverage Validation

- [ ] T083 Generate code coverage report: `xcodebuild test -enableCodeCoverage YES`, verify >75% overall coverage
- [ ] T084 Verify 100% coverage on critical paths: CurrencyConversionService (all test cases), VisionService accuracy logic, StorageService persistence

### Device Testing (Physical iPhone if available, simulator otherwise)

- [ ] T085 Manual testing on iPhone 12+: repeat full user flow (settings → camera → overlay → history) on physical device, verify all performance targets met
- [ ] T086 Accessibility testing: verify all UI elements accessible (font sizes, colors, tappable areas meet guidelines)

### Gate Verification

- [ ] T087 All unit tests pass: `xcodebuild test -only-testing CurrencyConverterCameraTests` → 100% pass rate
- [ ] T088 All integration tests pass: `xcodebuild test -only-testing CurrencyConverterCameraIntegrationTests` → 100% pass rate, performance constraints validated
- [ ] T089 All UI tests pass: `xcodebuild test -only-testing CurrencyConverterCameraUITests` → 100% pass rate
- [ ] T090 Code coverage: >75% overall, 100% critical paths (generate report in Xcode Organizer)
- [ ] T091 Commit Phase 6 completion: `git commit -m "[Stage 6] feat: full integration testing and performance validation (all constraints met)"`

---

## Phase 7: Edge Cases & Localization (Final Polish)

**Purpose**: Handle error scenarios, edge cases, and localize to Traditional Chinese (zh-TW)

### Edge Case Handling (from spec.md edge cases section)

- [ ] T092 [US1] Implement blur/focus detection: if VisionService confidence <0.5, show overlay message "Unable to detect numbers—ensure good lighting and focus"
- [ ] T093 [US1] Implement manual number adjustment: if user taps detected number, allow inline editing to correct detected value before conversion
- [ ] T094 [US2] Implement exchange rate mid-conversion handling: if user changes rate while camera active, apply new rate immediately to subsequent detections and show toast "Exchange rate updated"
- [ ] T095 [US1-extension] Implement permission revocation handling: if app loses camera permission mid-use, stop detection, show alert "Camera permission denied. Go to Settings to re-enable", provide button to open Settings
- [ ] T096 [US1] Implement low battery warning: if device battery <5%, show warning banner "Low battery. Charging recommended" (allow continued use)
- [ ] T097 [US1] Implement non-price text dismissal: if user taps detected number that's not a price (detected as false positive), show option "Not a price? Dismiss"

### Localization to Traditional Chinese (zh-TW)

- [ ] T098 Create `CurrencyConverterCamera/Resources/Localization/zh-TW.lproj/Localizable.strings` with all user-facing text:
  - Settings labels: "貨幣名稱" (Currency Name), "匯率" (Exchange Rate), "開始掃描" (Start Scan)
  - Validation messages: "貨幣名稱不能為空" (Currency name cannot be empty), "匯率必須在 0.0001 到 10000 之間" (Rate must be between...)
  - Overlay: "無法偵測數字。確保光線充足且清晰" (Unable to detect numbers...)
  - History: "轉換記錄" (Conversion History), "複製" (Copy), "已複製" (Copied), "無轉換記錄" (No conversions yet)
  - Errors: Camera permission, low battery, etc.

- [ ] T099 Update all SwiftUI Views and ViewModels to use NSLocalizedString() for text strings (SettingsView, CameraView, HistoryView, error messages)
- [ ] T100 Test localization: change device language to zh_TW in simulator → launch app → verify all text displays in Traditional Chinese

### Final Quality & Documentation

- [ ] T101 Add code comments to critical paths (CurrencyConversionService, VisionService, overlay rendering) explaining algorithm and performance considerations
- [ ] T102 Update `README.md` in project root with: feature overview, setup instructions (from quickstart.md), architecture diagram (MVVM layers), performance targets, testing strategy
- [ ] T103 Review all TODOs and FIXMEs in codebase → resolve or document with justification
- [ ] T104 Lint check: `swiftformat` or `swiftlint` on all Swift files, fix warnings

### Final Gate Verification

- [ ] T105 Run full test suite: `xcodebuild test` → all tests pass across Unit, Integration, UI
- [ ] T106 Launch simulator with zh_TW locale → verify all text Chinese, all features functional
- [ ] T107 Final code review: MVVM architecture enforced, TDD cycle followed, performance targets met, no dead code
- [ ] T108 Commit final polish: `git commit -m "[Stage 7] feat: edge case handling, zh-TW localization, final polish"`

---

## Dependency Graph & Parallel Execution Strategy

### Phase Execution Order (Sequential - Blocking)

```
Phase 1: Setup
  ↓ (must complete)
Phase 2: Foundational (Models, Services, Test Infrastructure)
  ↓ (must complete before any story)
Phase 3: User Story 2 (Settings - BLOCKER for US1)
  ↓ (must complete before US1)
Phase 4: User Story 1 (Camera - Core MVP, can proceed with US3 in parallel)
  ├─ Phase 5: User Story 3 (History - can proceed in parallel with US1 Phase 6 testing)
  ↓
Phase 6: Integration & Performance Testing (Cross-story validation)
  ↓
Phase 7: Edge Cases & Localization (Final polish)
```

### Parallel Execution Opportunities (Within Phases)

#### Within Phase 1 (Setup):
- **T005-T006** [P]: Create folder structures (parallel, independent)
- **T002-T004**: Add test targets (parallel, independent)

#### Within Phase 2 (Foundational):
- **T014-T016** [P]: Create all models (parallel, independent files)
- **T021-T023** [P]: Create utilities (parallel, independent files)

#### Within Phase 4 (User Story 1 - Camera):
- **T041-T045** [P]: Write all US1 tests (parallel, independent test files)
- **T047-T050** [P]: Create CameraService, VisionService, ConversionService (parallel, independent files)

#### Within Phase 5 (User Story 3 - History):
- **T063-T065** [P]: Write all US3 tests (parallel, independent test files)
- **T067-T068** [P]: Create HistoryViewModel, update StorageService (parallel, independent methods)

### Parallel Execution Example (Phase 4)

If working solo or with a team:

**Day 1 - Morning (Tests first per TDD)**:
```
Developer A: T041 (ConversionServiceTests)
Developer B: T042 (CameraViewModelTests)
Developer C: T043 (VisionServiceTests - accuracy)
Developer D: T044-T045 (Integration/Performance tests)
→ All tests written FIRST, ensure they FAIL
```

**Day 1 - Afternoon (Implementation)**:
```
Developer A: T049 (CurrencyConversionService implementation)
Developer B: T051 (CameraViewModel implementation)
Developer C: T047-T048 (CameraService + VisionService)
Developer D: T052-T057 (UI components + integration)
```

**Day 2 (Integration & Validation)**:
```
All: T058-T062 (Performance tuning, latency measurement, gate verification)
→ Run full test suite, measure FPS/latency/battery, device testing
```

---

## Independent Test Criteria per User Story

### User Story 1: Camera Conversion (P1)
**Independent Test Passed When**:
- ✅ App can initialize camera with permission request
- ✅ Vision detects numbers on well-lit test images with >85% accuracy
- ✅ Detected numbers converted correctly using CurrencySettings rate
- ✅ Overlay displays converted price within <500ms latency
- ✅ Camera runs at 5–8 FPS sustained
- ✅ Battery drain <15%/hour continuous use
- ✅ User can tap number to highlight/see conversion
- ✅ All US1 unit + integration + UI tests pass

### User Story 2: Settings Configuration (P1)
**Independent Test Passed When**:
- ✅ App launches showing settings form (currency name + exchange rate)
- ✅ Invalid input (empty currency, rate ≤0 or >10000) rejected with error message
- ✅ "Start Scan" button disabled until valid data entered
- ✅ Valid data (e.g., JPY, 0.22) enables "Start Scan" button
- ✅ Settings saved to UserDefaults
- ✅ App restart → settings pre-populated from UserDefaults
- ✅ All US2 unit + integration + UI tests pass
- ✅ **Dependency**: Must complete before US1 can be tested (camera requires settings)

### User Story 3: History (P2)
**Independent Test Passed When**:
- ✅ Conversions automatically recorded after each detection
- ✅ History view displays all conversions sorted by timestamp (most recent first)
- ✅ Each history entry shows: original price, converted amount, timestamp
- ✅ Copy button copies converted amount to clipboard
- ✅ Copy shows toast confirmation "Copied: NT$ 770.00"
- ✅ History >50 entries → oldest auto-pruned
- ✅ Clear All button removes all records
- ✅ All US3 unit + integration + UI tests pass
- ✅ **Dependency**: Depends on US1 (needs conversions to populate history)

---

## MVP Scope & Incremental Delivery

### MVP Definition (Minimum Viable Product)
**Includes**: User Story 1 (Camera conversion) + User Story 2 (Settings configuration)
**Excludes**: User Story 3 (History), Edge cases, Localization

**MVP Milestones**:
1. Phase 1 Complete: Project setup, sanity test passes
2. Phase 2 Complete: Foundational models + services ready
3. Phase 3 Complete: Settings screen working, data persists
4. Phase 4 Complete: Camera detection + overlay working, performance targets met
→ **MVP SHIP-READY** (Users can configure currency and convert prices)

### Post-MVP (Incrementally Deliverable)
- Phase 5: History feature (P2, nice-to-have but independent)
- Phase 6: Full integration + performance validation across all features
- Phase 7: Edge cases + localization (polish for App Store submission)

---

## Summary

**Total Tasks**: 108
- **Phase 1 (Setup)**: 13 tasks
- **Phase 2 (Foundational)**: 12 tasks
- **Phase 3 (US2 Settings)**: 13 tasks
- **Phase 4 (US1 Camera)**: 22 tasks
- **Phase 5 (US3 History)**: 15 tasks
- **Phase 6 (Integration & Performance)**: 15 tasks
- **Phase 7 (Edge Cases & Localization)**: 18 tasks

**Parallel Opportunities**: ~40 tasks can run in parallel (marked [P])
**Critical Path**: Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 6 (Phases 3 & 5 can overlap after Phase 2)
**Estimated Timeline**: 2–3 weeks solo development with strict TDD + stage gates
**Test Coverage Target**: >75% overall, 100% critical paths (currency conversion, Vision accuracy, persistence)
**MVP Completion**: Phases 1-4 complete (~55 tasks, ~1.5 weeks)

---

## Format Validation Checklist

- ✅ All tasks follow strict format: `- [ ] [TaskID] [P?] [Story?] Description`
- ✅ Task IDs sequential (T001–T108)
- ✅ [P] marker only on parallelizable tasks
- ✅ [Story] label on all user story phase tasks (US1, US2, US3)
- ✅ All descriptions include exact file paths
- ✅ Dependencies documented (e.g., "depends on T012, T013")
- ✅ Gate checkpoints explicit (Test Gate, Manual Device Verification, Commit)
- ✅ Phase structure follows: Setup → Foundational → User Stories → Integration → Polish
- ✅ Each user story independently testable with clear acceptance criteria
- ✅ TDD approach enforced (tests written first per spec.md request)

