# Phase 2 Integration Guide - Foundational Infrastructure

This guide explains how to integrate all Phase 2 foundational files into your Xcode project.

## Overview

Phase 2 creates the core data models, persistence layer, and test infrastructure required by all subsequent phases. These files establish the foundation for the camera detection (US1), settings management (US2), and history tracking (US3) features.

**Total Files**: 10 Swift files
**Test Coverage**: 40+ test cases
**Time to Integrate**: 15-20 minutes

---

## File Structure

Create the following folder structure in your Xcode project:

```
CurrencyConverterCamera/
├── Models/
│   ├── CurrencySettings.swift
│   ├── ConversionRecord.swift
│   └── DetectedNumber.swift
├── Services/
│   └── StorageService.swift
└── Utilities/
    ├── Constants.swift
    ├── Extensions.swift
    └── Logger.swift

CurrencyConverterCameraTests/
├── Helpers/
│   └── TestHelper.swift
└── Tests/
    ├── CurrencySettingsTests.swift
    ├── ModelsTests.swift
    └── StorageServiceTests.swift
```

---

## Integration Steps

### Step 1: Create Folder Groups in Xcode

1. Open `CurrencyConverterCamera.xcodeproj` in Xcode
2. In the Project Navigator, select the `CurrencyConverterCamera` target folder
3. Create folder groups (right-click → New Group):
   - `Models`
   - `Services`
   - `Utilities`

4. For test files, select `CurrencyConverterCameraTests` folder
5. Create folder groups:
   - `Helpers`
   - `Tests`

### Step 2: Add Model Files

Copy these files from `/tmp/` to your project:

**File**: `CurrencySettings.swift`
- **Location**: `CurrencyConverterCamera/Models/`
- **Target**: ✓ CurrencyConverterCamera
- **Purpose**: User-configured currency data (name, rate, last update)
- **Tests**: CurrencySettingsTests.swift

**File**: `ConversionRecord.swift`
- **Location**: `CurrencyConverterCamera/Models/`
- **Target**: ✓ CurrencyConverterCamera
- **Purpose**: Historical conversion data (detected price, converted amount, timestamp)
- **Tests**: ModelsTests.swift

**File**: `DetectedNumber.swift`
- **Location**: `CurrencyConverterCamera/Models/`
- **Target**: ✓ CurrencyConverterCamera
- **Purpose**: Vision framework detection results (value, bounding box, confidence)
- **Tests**: ModelsTests.swift

### Step 3: Add Service Files

**File**: `StorageService.swift`
- **Location**: `CurrencyConverterCamera/Services/`
- **Target**: ✓ CurrencyConverterCamera
- **Purpose**: Persistence layer for UserDefaults and FileManager
- **Dependencies**: CurrencySettings, ConversionRecord
- **Tests**: StorageServiceTests.swift
- **Note**: Implements `StorageServiceProtocol` - can be mocked for UI tests

### Step 4: Add Utility Files

**File**: `Constants.swift`
- **Location**: `CurrencyConverterCamera/Utilities/`
- **Target**: ✓ CurrencyConverterCamera
- **Purpose**: App-wide configuration constants
- **No tests**: Used directly throughout codebase

**File**: `Extensions.swift`
- **Location**: `CurrencyConverterCamera/Utilities/`
- **Target**: ✓ CurrencyConverterCamera
- **Purpose**: Helper methods on Foundation types (String, Decimal, Date, CGRect, Array)
- **No tests**: Covered by unit tests of classes using these extensions

**File**: `Logger.swift`
- **Location**: `CurrencyConverterCamera/Utilities/`
- **Target**: ✓ CurrencyConverterCamera
- **Purpose**: Centralized logging with os.log integration
- **No tests**: Verified through debug output during integration testing

### Step 5: Add Test Helper

**File**: `TestHelper.swift`
- **Location**: `CurrencyConverterCameraTests/Helpers/`
- **Target**: ✓ CurrencyConverterCameraTests
- **Purpose**: Factory methods for creating mock objects
- **Usage**: Imported by all test files with `@testable import CurrencyConverterCamera`
- **Coverage**: Used by 40+ test cases

### Step 6: Add Test Files

**File**: `CurrencySettingsTests.swift`
- **Location**: `CurrencyConverterCameraTests/Tests/`
- **Target**: ✓ CurrencyConverterCameraTests
- **Test Cases**: 23
- **Coverage**:
  - Initialization with valid/invalid data
  - Validation rules (currency name, exchange rate bounds)
  - Edge cases (minimum/maximum values, length limits)
  - Codable encoding/decoding
  - Equatable comparisons

**File**: `ModelsTests.swift`
- **Location**: `CurrencyConverterCameraTests/Tests/`
- **Target**: ✓ CurrencyConverterCameraTests
- **Test Cases**: 17 (8 ConversionRecord + 9 DetectedNumber)
- **Coverage**:
  - Model initialization
  - Computed property formatting
  - Confidence thresholds
  - Bounding box validation and coordinate conversion
  - Codable conformance
  - Equatable comparisons

**File**: `StorageServiceTests.swift`
- **Location**: `CurrencyConverterCameraTests/Tests/`
- **Target**: ✓ CurrencyConverterCameraTests
- **Test Cases**: 28
- **Coverage**:
  - Save/load CurrencySettings via UserDefaults
  - Add/load ConversionRecords via FileManager
  - History sorting (most recent first)
  - Retention policy (50 record limit)
  - Data integrity across persistence
  - Concurrent access safety
  - Cleanup functionality

---

## Xcode Integration Checklist

### Import Statements
- [ ] All test files include: `@testable import CurrencyConverterCamera`
- [ ] Models can be imported as: `import CurrencyConverterCamera`

### Build Settings
- [ ] Minimum Deployment Target: iOS 15.0
- [ ] Swift Language Version: 5.9 or later
- [ ] Build Succeeds: `⌘B`

### Target Membership
- [ ] Models/Services/Utilities → CurrencyConverterCamera target only
- [ ] TestHelper.swift → CurrencyConverterCameraTests target only
- [ ] Test files → CurrencyConverterCameraTests target only

---

## Running Phase 2 Tests

### Run All Phase 2 Tests
```bash
cd /Users/dindin/Documents/iOS\ Project/CurrencyConverterCamera

# Run all tests
xcodebuild test -scheme CurrencyConverterCamera

# Run only Phase 2 tests
xcodebuild test -only-testing CurrencyConverterCameraTests/CurrencySettingsTests
xcodebuild test -only-testing CurrencyConverterCameraTests/ModelsTests
xcodebuild test -only-testing CurrencyConverterCameraTests/StorageServiceTests
```

### Run in Xcode
1. Select `CurrencyConverterCamera` scheme (top left)
2. Press `⌘U` to run all tests
3. Or click diamond icon next to test class name

### Expected Results
- **Total Test Cases**: 68 (23 + 17 + 28)
- **Expected Passes**: All 68 tests should pass
- **Code Coverage Target**: >80% for Phase 2 code

---

## Dependency Graph

```
Presentation Layer (Phase 3+)
    ↓
ViewModel Layer (Phase 3+)
    ↓
Service Layer
    ├── StorageService ← Uses Models
    └── (CameraService, VisionService added in Phase 4)
    ↓
Model Layer (Phase 2 - YOUR FOCUS)
    ├── CurrencySettings
    ├── ConversionRecord
    └── DetectedNumber
    ↓
Utility Layer
    ├── Constants
    ├── Extensions
    └── Logger
```

Models and Services in Phase 2 are **completely independent** of UI layers, enabling:
- Easy mocking for UI tests (Phase 6)
- Early testing before UI implementation
- Reusability across different UI frameworks

---

## File Reference

### Models (0 external dependencies)
- **CurrencySettings.swift** (70 lines)
  - Properties: currencyName, exchangeRate, lastUpdated
  - Validation: isValid, validationError
  - Conformances: Codable, Equatable

- **ConversionRecord.swift** (100 lines)
  - Properties: id, originalPrice, convertedAmount, currencyName, exchangeRate, timestamp
  - Computed properties: formattedAmount, formattedOriginalPrice, formattedTimestamp
  - Conformances: Codable, Identifiable, Equatable

- **DetectedNumber.swift** (80 lines)
  - Properties: value, boundingBox, confidence
  - Methods: meetsConfidenceThreshold(), screenBoundingBox(), isValidBoundingBox
  - Conformances: Equatable

### Services (depends on Models)
- **StorageService.swift** (250 lines)
  - Protocol: StorageServiceProtocol
  - Implementation: UserDefaults + FileManager persistence
  - Methods: saveCurrencySettings, loadCurrencySettings, addConversionRecord, loadConversionHistory, clearHistory
  - Error handling: StorageError enum

### Utilities (0-minimal dependencies)
- **Constants.swift** (80 lines)
  - Configuration values for constraints, performance, storage
  - No functional code, pure data definitions

- **Extensions.swift** (180 lines)
  - 5 extension groups: String, Decimal, Date, CGRect, Array<ConversionRecord>
  - 20+ helper methods for common operations

- **Logger.swift** (150 lines)
  - Uses Apple's os.log framework (no external dependencies)
  - 5 log categories, 4 log levels, performance timing

---

## Troubleshooting

### Compiler Error: "No such module 'CurrencyConverterCamera'"
**Cause**: Test files trying to import CurrencyConverterCamera but project not built
**Solution**: Run `⌘B` to build project first, then run tests

### Compiler Error: "Decimal is not convertible to NSNumber"
**Cause**: Decimal type not imported from Foundation
**Solution**: Ensure imports include `import Foundation` (already in all files)

### Test Failure: "Cannot find CurrencySettings in scope"
**Cause**: Test target doesn't have `@testable import CurrencyConverterCamera`
**Solution**: Add @testable import at top of test file

### File Not Found: "conversion_history.json"
**Cause**: TestHelper.cleanup() tries to delete file that doesn't exist
**Solution**: Normal behavior - cleanup() handles missing files gracefully

### Decimal Precision Issues in Tests
**Cause**: Decimal calculations may have rounding artifacts
**Solution**: Tests use direct equality (Decimal conforms to Equatable) - any issues indicate rounding errors in models

---

## Next Steps (Phase 3)

After Phase 2 is complete and all tests pass:

1. **Create Settings UI** (User Story 2)
   - SettingsViewModel with @Published properties
   - SettingsView (SwiftUI)
   - Integration with StorageService

2. **Implement Camera Detection** (User Story 1)
   - CameraManager (AVFoundation)
   - VisionService (Vision framework)
   - ConversionEngine (calculation logic)

3. **Build History View** (User Story 3)
   - HistoryViewModel
   - HistoryView with filtering/sorting
   - ExportViewModel for CSV/PDF export

---

## Phase 2 Completion Checklist

- [ ] All 10 files copied to correct locations
- [ ] All target memberships verified
- [ ] Project builds successfully (`⌘B`)
- [ ] All 68 tests pass (`⌘U`)
- [ ] Code coverage >80% for Phase 2 files
- [ ] No compiler warnings
- [ ] Git commit created: `[Phase 2] feat: core models, storage service, utilities, test infrastructure`

