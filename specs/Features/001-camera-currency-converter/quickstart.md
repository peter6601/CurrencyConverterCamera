# Quickstart: Real-Time Camera-Based Currency Converter

**Date**: 2025-12-02
**Phase**: Phase 1 (Design)
**Feature**: 001-camera-currency-converter

This guide walks you through setting up the development environment and running the first test.

---

## Prerequisites

- **Xcode**: 14.0 or later
- **macOS**: 12.0 or later (for Xcode)
- **iOS Target**: iPhone with iOS 15.0+ (simulator or device)
- **Swift**: 5.9+ (included in Xcode)
- **Git**: Already initialized on this repo

---

## Project Setup (One-Time)

### 1. Open Xcode Project
```bash
cd /Users/dindin/Documents/iOS\ Project/CurrencyConverterCamera
open CurrencyConverterCamera.xcodeproj
```

If project doesn't exist yet, create it:
```bash
# Create new iOS app project
xcode-select --install  # Install Xcode command line tools if needed
```

### 2. Verify Project Structure
Confirm folder structure matches plan.md:
```
CurrencyConverterCamera/
├── App/
├── Models/
├── ViewModels/
├── Views/
├── Services/
├── Utilities/
└── Resources/

CurrencyConverterCameraTests/
├── Models/
├── ViewModels/
├── Services/
└── Resources/
    └── TestImages/
```

If missing, create folders via Xcode:
- Right-click project → New Group → Name (e.g., "Models")
- Drag folders to ensure they match source tree

### 3. Configure Build Settings
1. Select project in Xcode navigator
2. Select target "CurrencyConverterCamera"
3. Build Settings tab:
   - `SWIFT_VERSION`: 5.9
   - `IPHONEOS_DEPLOYMENT_TARGET`: 15.0
4. Repeat for test targets

### 4. Verify Test Targets Exist
Xcode → Product → Scheme:
- `CurrencyConverterCamera` (main app)
- `CurrencyConverterCameraTests` (unit tests)
- `CurrencyConverterCameraIntegrationTests` (integration tests, optional for Phase 0)
- `CurrencyConverterCameraUITests` (UI tests, optional for Phase 0)

If missing, create:
1. File → New → Target
2. Select "Unit Testing Bundle"
3. Name it `CurrencyConverterCameraTests`
4. Link to main app target

---

## Running Your First Test

### Stage 0: Sanity Check

#### Step 1: Create Test File
1. File → New → File
2. Select "Swift File"
3. Name: `ExampleTests.swift`
4. Choose target: `CurrencyConverterCameraTests`

#### Step 2: Write Sanity Test
```swift
// ExampleTests.swift
import XCTest
@testable import CurrencyConverterCamera

class ExampleTests: XCTestCase {
    func testSanityCheck() {
        XCTAssertEqual(1 + 1, 2, "Sanity check failed")
    }

    func testProjectCompiles() {
        XCTAssertTrue(true, "Project compiles successfully")
    }
}
```

#### Step 3: Run Tests
```bash
# From command line (recommended for CI/CD)
xcodebuild test \
  -scheme CurrencyConverterCamera \
  -destination 'platform=iOS Simulator,name=iPhone 14'

# Or use Xcode UI
# Product → Test (⌘U)
```

#### Expected Output
```
Test Suite 'ExampleTests' started at ...
Test Case '-[CurrencyConverterCameraTests.ExampleTests testSanityCheck]' started.
Test Case '-[CurrencyConverterCameraTests.ExampleTests testSanityCheck]' passed (0.001 seconds).
Test Case '-[CurrencyConverterCameraTests.ExampleTests testProjectCompiles]' started.
Test Case '-[CurrencyConverterCameraTests.ExampleTests testProjectCompiles]' passed (0.001 seconds).
Test Suite 'ExampleTests' finished at ... (Executed 2 tests with 0 failures (0 expected failures) in 0.002 seconds)
```

#### Gate: Stage 0 Complete ✅
- [ ] Project compiles without errors
- [ ] All tests pass (green) when running `xcodebuild test`
- [ ] Simulator can launch app (blank screen is acceptable)
- [ ] Git repository initialized with proper .gitignore
- [ ] Folder structure matches specification

---

## Development Workflow

### TDD Cycle for Each Feature

1. **Red**: Write failing test
   ```swift
   // SettingsViewModelTests.swift
   func testSettingsValidation_EmptyCurrency_IsInvalid() {
       let settings = CurrencySettings(currencyName: "", exchangeRate: 0.22)
       XCTAssertFalse(settings.isValid)
   }
   ```
   Run: `xcodebuild test` → Should FAIL (red)

2. **Green**: Implement minimal code to pass
   ```swift
   // Models/CurrencySettings.swift
   var isValid: Bool {
       !currencyName.isEmpty && exchangeRate > 0
   }
   ```
   Run: `xcodebuild test` → Should PASS (green)

3. **Refactor**: Improve code while keeping tests green
   ```swift
   var isValid: Bool {
       !currencyName.isEmpty &&
       currencyName.count <= 20 &&
       exchangeRate > 0 &&
       exchangeRate <= 10000
   }
   ```
   Run: `xcodebuild test` → Should still PASS

4. **Verify**: Manual device test
   - Launch app on simulator/device
   - Interact with feature
   - Verify behavior matches test scenarios

5. **Commit**: Git commit with stage tag
   ```bash
   git add -A
   git commit -m "[Stage 1] feat: settings validation logic"
   ```

---

## Common Commands

### Run All Tests
```bash
xcodebuild test \
  -scheme CurrencyConverterCamera \
  -destination 'platform=iOS Simulator,name=iPhone 14'
```

### Run Specific Test File
```bash
xcodebuild test \
  -scheme CurrencyConverterCamera \
  -only-testing CurrencyConverterCameraTests/CurrencySettingsTests \
  -destination 'platform=iOS Simulator,name=iPhone 14'
```

### Run Tests with Coverage
```bash
xcodebuild test \
  -scheme CurrencyConverterCamera \
  -enableCodeCoverage YES \
  -destination 'platform=iOS Simulator,name=iPhone 14'
```

### Launch App on Simulator
```bash
xcodebuild build \
  -scheme CurrencyConverterCamera \
  -destination 'platform=iOS Simulator,name=iPhone 14' \
  -configuration Debug

# Then launch
xcrun simctl launch booted com.yourcompany.CurrencyConverterCamera
```

### Check Test Coverage
```bash
# Generate coverage report
xcodebuild test \
  -scheme CurrencyConverterCamera \
  -enableCodeCoverage YES \
  -destination 'platform=iOS Simulator,name=iPhone 14'

# Coverage data in Derived Data
# Xcode → Window → Organizer → Coverage tab
```

---

## Debugging Tips

### Print Debug Info in Tests
```swift
func testExampleDebug() {
    let settings = CurrencySettings(currencyName: "JPY", exchangeRate: 0.22)
    print("Settings: \(settings)")
    XCTAssertTrue(settings.isValid)
}
```

Run: `xcodebuild test -v` (verbose mode shows print statements)

### Use Xcode Debugger
1. Click line number to set breakpoint
2. Run test: Product → Test (⌘U)
3. When breakpoint hit, inspect variables in Debug area
4. Step through code with debugger controls

### Check App Logs
```bash
# Read simulator logs
xcrun simctl spawn booted log stream --predicate 'process == "CurrencyConverterCamera"'
```

---

## Performance Measurement (Phase 6 Preview)

### Measure Test Execution Time
```swift
func testPerformanceExample() {
    self.measure {
        let settings = CurrencySettings(currencyName: "JPY", exchangeRate: 0.22)
        _ = settings.isValid
    }
}
```

### Monitor FPS (Camera Stage)
Use Xcode Instruments:
1. Product → Profile (⌘I)
2. Select "Core Animation"
3. Look for "Color Blended Layers" and "Render" metrics

### Monitor Battery Usage
Use Xcode Instruments:
1. Product → Profile (⌘I)
2. Select "System Trace"
3. Monitor CPU, GPU, and Energy Impact

---

## Troubleshooting

### Compilation Error: "Product depends on itself"
**Solution**: Check Xcode build phases for duplicate references. Remove duplicate files.

### Test Fails: "Module not found 'CurrencyConverterCamera'"
**Solution**: Add `@testable import CurrencyConverterCamera` at top of test file.

### Simulator Won't Run
**Solution**: Delete simulator and recreate:
```bash
xcrun simctl delete all
xcrun simctl create CurrencyConverter iPhone\ 14
```

### Tests Hang
**Solution**: Set timeout in test class:
```swift
override func setUp() {
    super.setUp()
    continueAfterFailure = false
}
```

---

## Next Steps

1. **Stage 1**: Implement SettingsViewModel and SettingsView (see plan.md)
2. **Run Tests**: `xcodebuild test` after each feature
3. **Manual Verification**: Launch on simulator after each stage
4. **Gate Approval**: Developer confirmation before moving to next stage
5. **Commit**: Stage completion commit

For detailed feature breakdown, see `/specs/001-camera-currency-converter/plan.md` Stage 1-7 descriptions.

---

## Additional Resources

- [Swift Language Guide](https://docs.swift.org/swift-book)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [AVFoundation Guide](https://developer.apple.com/documentation/avfoundation)
- [Vision Framework](https://developer.apple.com/documentation/vision)

