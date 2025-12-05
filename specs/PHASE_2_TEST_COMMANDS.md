# Phase 2 Test Execution Quick Reference

All Phase 2 files are ready in `/tmp/` and can be copied into your Xcode project. Use these commands to run tests.

## Prerequisites

1. Copy all files from `/tmp/` to your Xcode project (see PHASE_2_INTEGRATION_GUIDE.md)
2. Run `⌘B` to build the project successfully
3. Ensure no compiler errors or warnings

## Run All Phase 2 Tests

### Via Xcode UI (Recommended for Development)
```
1. Open CurrencyConverterCamera.xcodeproj in Xcode
2. Select CurrencyConverterCamera scheme (top toolbar)
3. Press ⌘U to run all tests
4. View results in Test Navigator (⌘9)
```

### Via Terminal (for CI/CD)
```bash
cd /Users/dindin/Documents/iOS\ Project/CurrencyConverterCamera

# Build and run all tests
xcodebuild test -scheme CurrencyConverterCamera

# Build and run with coverage
xcodebuild test -scheme CurrencyConverterCamera -enableCodeCoverage YES
```

---

## Run Individual Test Suites

### CurrencySettings Tests (23 cases)
```bash
# Via terminal
xcodebuild test -only-testing CurrencyConverterCameraTests/CurrencySettingsTests

# Via Xcode: Click diamond ◆ next to class name in editor
```

### Models Tests (17 cases)
```bash
# Via terminal
xcodebuild test -only-testing CurrencyConverterCameraTests/ModelsTests

# ConversionRecord only
xcodebuild test -only-testing CurrencyConverterCameraTests/ModelsTests/ConversionRecordTests

# DetectedNumber only
xcodebuild test -only-testing CurrencyConverterCameraTests/ModelsTests/DetectedNumberTests
```

### Storage Service Tests (28 cases)
```bash
# Via terminal
xcodebuild test -only-testing CurrencyConverterCameraTests/StorageServiceTests
```

---

## Run Specific Test Methods

### Example: Test currency validation
```bash
xcodebuild test -only-testing CurrencyConverterCameraTests/CurrencySettingsTests/testIsInvalidWithEmptyCurrency
```

### Pattern for other tests
```bash
xcodebuild test -only-testing CurrencyConverterCameraTests/{TestClass}/{testMethod}
```

---

## Expected Results

### Test Count
- Total: **68 test cases**
- CurrencySettingsTests: 23
- ModelsTests: 17 (8 ConversionRecord + 9 DetectedNumber)
- StorageServiceTests: 28

### Expected Outcome
- ✅ All 68 tests should **PASS**
- ⚠️ No warnings during compilation
- 📊 Code coverage >85%

### Test Execution Time
- Single test suite: 2-3 seconds
- All Phase 2 tests: 5-8 seconds
- Full project tests: 10-15 seconds (varies by machine)

---

## Viewing Code Coverage

### In Xcode
1. Run tests with coverage: `xcodebuild test -enableCodeCoverage YES`
2. Product → Scheme → Edit Scheme → Test → Options
3. Check "Gather coverage data" ✓
4. Run tests (`⌘U`)
5. View → Navigators → Show Coverage Navigator (or ⌘9)

### Via Terminal (generates report)
```bash
xcodebuild test \
  -scheme CurrencyConverterCamera \
  -enableCodeCoverage YES \
  -derivedDataPath build

# Coverage data in: build/Logs/Test/*.xcresult
```

---

## Troubleshooting Tests

### Error: "Cannot find CurrencySettings in scope"
**Problem**: Test file can't import models
**Solution**:
```swift
// Add at top of test file (already in provided files)
@testable import CurrencyConverterCamera
```

### Error: "setUp or tearDown failed"
**Problem**: TestHelper.cleanup() failing
**Solution**: Normal behavior - cleanup() handles missing files. Check logs for details.

### Test Timeout
**Problem**: Test takes >10 seconds
**Likely cause**: StorageService tests creating 50+ records
**Solution**: Expected behavior. No action needed.

### Flaky Tests
**Problem**: Test passes sometimes, fails other times
**Cause**: None expected - all tests are deterministic
**Action**: Report this as a bug if it occurs

### Coverage <85%
**Problem**: Code coverage below target
**Likely cause**: Unreachable error handling code
**Solution**: Check coverage report for untested lines

---

## Test Failure Recovery

### If Tests Fail

1. **Check build errors** (`⌘B`)
   - Fix any compiler errors first

2. **Run single failing test**
   - Click diamond icon next to test method
   - Read failure message in debug console

3. **Check TestHelper**
   - Verify TestHelper.swift is in correct target
   - Ensure @testable import statement

4. **Verify data consistency**
   - Run `TestHelper.cleanup()` manually in setUp
   - Check Documents directory for orphaned test files

5. **Reset test environment**
   ```bash
   # Clear UserDefaults
   defaults delete com.yourapp.test 2>/dev/null || true

   # Remove test files
   rm -f ~/Documents/conversion_history.json
   ```

---

## Performance Profiling

### Profile Test Execution
```bash
xcodebuild test \
  -scheme CurrencyConverterCamera \
  -enablePerformanceTestsDiagnostics YES
```

### Identify Slow Tests
```bash
# Run with verbose output
xcodebuild test -verbose -scheme CurrencyConverterCamera 2>&1 | grep "Executed"
```

---

## Continuous Integration Setup

### GitHub Actions Example
```yaml
name: Phase 2 Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Phase 2 Tests
        run: xcodebuild test -scheme CurrencyConverterCamera
      - name: Check Coverage
        run: echo "Coverage >85% required"
```

### Local Pre-commit Hook
```bash
#!/bin/bash
# .git/hooks/pre-commit

# Run Phase 2 tests before commit
xcodebuild test -scheme CurrencyConverterCamera || {
  echo "Phase 2 tests failed. Commit aborted."
  exit 1
}
```

---

## Quick Verification Checklist

After copying files and before proceeding to Phase 3:

- [ ] All 10 files copied to correct locations
- [ ] Project builds cleanly (`⌘B`)
- [ ] All 68 tests pass (`⌘U`)
- [ ] Code coverage >85% (check Coverage Navigator)
- [ ] No compiler warnings
- [ ] No test warnings
- [ ] Ready to commit Phase 2

---

## Next Steps After Phase 2

Once all Phase 2 tests pass:

1. **Create git commit**
   ```bash
   git add .
   git commit -m "[Phase 2] feat: core models, storage service, utilities, test infrastructure"
   ```

2. **Proceed to Phase 3**
   - User Story 2: Settings Management UI
   - Create SettingsViewModel with @Published properties
   - Create SettingsView (SwiftUI)
   - Write UI tests for settings flow

3. **Review Phase 3 tasks** in tasks.md
   - T028-T046: Settings view implementation
   - Follows same TDD pattern: tests first, implementation second

---

## File References

All Phase 2 files located in `/tmp/`:
- Production: 7 files (models, services, utilities)
- Tests: 4 files (test helper + 3 test suites)
- Docs: 3 files (integration guide, summary, this file)

See PHASE_2_FILES_SUMMARY.md for complete listing.

