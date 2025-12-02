# Phase 1: Project Setup - Detailed Instructions

**Goal**: Establish the Xcode project structure, MVVM architecture foundation, and first passing test
**Duration**: ~30 minutes
**Tasks**: T001-T013

---

## Complete Setup Checklist

### Step 1: Create Xcode Project (T001)

**Actions**:
1. Open **Xcode** on your Mac
2. File → New → Project (or Cmd+Shift+N)
3. Select **iOS** tab
4. Choose **App** template
5. Configure settings:
   ```
   Product Name:          CurrencyConverterCamera
   Team:                  (Select your team or leave blank)
   Organization Identifier: com.example (or your domain)
   Bundle Identifier:     (auto-filled)
   Language:              Swift
   User Interface:        SwiftUI
   ☐ Use Core Data        (UNCHECK)
   ☐ Include Tests        (UNCHECK - we'll add targets manually)
   ☐ Host Application     (UNCHECK)
   ```
6. Click **Create**
7. Save location: `/Users/dindin/Documents/iOS Project/PriceConvert/`
   - Check "Create git repository on my Mac"

**Verification**:
- ✅ Project opens in Xcode
- ✅ Project name shows as `CurrencyConverterCamera`
- ✅ Git repository initialized

---

### Step 2: Add Test Targets (T002, T003, T004)

**In Xcode**, add three test targets:

**T002: Add Unit Test Target**
1. Select project in navigator (top-left)
2. Click **Targets** tab
3. Click **+** button at bottom-left
4. Search for "Unit Testing Bundle"
5. Click **Next**
6. Configure:
   ```
   Product Name: CurrencyConverterCameraTests
   Language: Swift
   ```
7. Click **Finish**
8. When prompted: "Would you like to configure an additional scheme?" → Click **Finish** again

**T003: Add Integration Test Target**
1. Repeat steps 1-3
2. Search for "Unit Testing Bundle" (same template)
3. Configure:
   ```
   Product Name: CurrencyConverterCameraIntegrationTests
   Language: Swift
   ```
4. Click **Finish** → **Finish**

**T004: Add UI Test Target**
1. Repeat steps 1-3
2. Search for "UI Testing Bundle"
3. Configure:
   ```
   Product Name: CurrencyConverterCameraUITests
   Language: Swift
   ```
4. Click **Finish** → **Finish**

**Verification** (in Xcode):
- ✅ Under Targets, you should see 4 targets:
  - CurrencyConverterCamera (main app)
  - CurrencyConverterCameraTests (unit tests)
  - CurrencyConverterCameraIntegrationTests (integration tests)
  - CurrencyConverterCameraUITests (UI tests)

---

### Step 3: Create MVVM Folder Structure (T005, T006)

**In Xcode Navigator**, organize files into groups:

**Main App Structure (T005)**:

Right-click `CurrencyConverterCamera` folder → **New Group** and create:
- **App** group
- **Models** group
- **ViewModels** group
- **Views** group
- **Services** group
- **Utilities** group

Move existing files:
- Drag `CurrencyConverterCameraApp.swift` → into **App** group
- Drag `ContentView.swift` → into **Views** group
- Keep `Preview Content` at root

**Test Structure (T006)**:

Right-click `CurrencyConverterCameraTests` folder → **New Group** and create:
- **Models** group
- **ViewModels** group
- **Services** group
- **Resources** group
  - Inside **Resources**, create **TestImages** group

Repeat for `CurrencyConverterCameraIntegrationTests`:
- Create the same structure

**Final Structure** (in Xcode Navigator):
```
CurrencyConverterCamera
├── App
│   └── CurrencyConverterCameraApp.swift
├── Models
├── ViewModels
├── Views
│   └── ContentView.swift
├── Services
├── Utilities
├── Resources
│   └── Assets (auto-created)
└── Preview Content

CurrencyConverterCameraTests
├── Models
├── ViewModels
├── Services
└── Resources
    └── TestImages

CurrencyConverterCameraIntegrationTests
├── Models
├── ViewModels
├── Services
└── Resources
```

---

### Step 4: Create Source Files from Templates

**T007: Create Sanity Test**

1. In Xcode, right-click `CurrencyConverterCameraTests` folder
2. File → New → File (or Cmd+N)
3. Choose **Swift File**
4. Name: `ExampleTests.swift`
5. Choose target: `CurrencyConverterCameraTests` (check this checkbox!)
6. Create
7. Copy the content from `/tmp/ExampleTests.swift` into this file

**T009: Update App Entry Point**

1. Click `CurrencyConverterCameraApp.swift` in the **App** group
2. Replace its content with content from `/tmp/CurrencyConverterCameraApp.swift`

**Update ContentView**

1. Click `ContentView.swift` in the **Views** group
2. Replace content with content from `/tmp/ContentView.swift`

---

### Step 5: Verify Build Settings (T001 Continued)

**In Xcode**:
1. Select project → Build Settings
2. Search for "Minimum Deployments Target"
3. Verify all targets set to **iOS 15.0** (or higher)
4. Search for "Swift Language Version"
5. Verify all targets set to **Swift 5.9** or higher

---

### Step 6: Run Tests - Gate Verification (T010-T013)

**T010: Run Tests**

In Xcode:
1. Product → Test (or Cmd+U)
2. Watch the test output in the bottom panel

**Expected Output**:
```
Test Suite 'CurrencyConverterCameraTests' started at ...
Test Case '-[CurrencyConverterCameraTests.ExampleTests testSanityCheck]' started.
Test Case '-[CurrencyConverterCameraTests.ExampleTests testSanityCheck]' passed (0.001 seconds).
Test Case '-[CurrencyConverterCameraTests.ExampleTests testProjectCompiles]' started.
Test Case '-[CurrencyConverterCameraTests.ExampleTests testProjectCompiles]' passed (0.001 seconds).
Test Case '-[CurrencyConverterCameraTests.ExampleTests testBasicAssertion]' started.
Test Case '-[CurrencyConverterCameraTests.ExampleTests testBasicAssertion]' passed (0.001 seconds).
Test Suite 'CurrencyConverterCameraTests' finished at ... (Executed 3 tests with 0 failures (0 expected failures) in 0.003 seconds)
```

**Gate Status**: ✅ **PASS** - All 3 tests pass with 0 failures

**T011: Launch on Simulator**

1. Select simulator: Product → Destination (choose iPhone 14 or similar)
2. Product → Run (or Cmd+R)
3. Simulator launches app
4. App displays: Globe icon + "Currency Converter Camera" text
5. No errors in console

**Gate Status**: ✅ **PASS** - App launches, displays blank screen without errors

**T012: Verify Git Repository**

In Terminal:
```bash
cd /Users/dindin/Documents/iOS\ Project/PriceConvert
git status
```

Expected output shows `.gitignore` file and recent commits.

**Gate Status**: ✅ **PASS** - Git repo initialized with proper .gitignore

---

### Step 7: Commit Phase 1 (T013)

In Terminal:
```bash
cd /Users/dindin/Documents/iOS\ Project/PriceConvert
git add -A
git commit -m "[Stage 0] feat: project initialization with MVVM structure and test targets

- Created Xcode project: CurrencyConverterCamera
- Added 3 test targets: Unit, Integration, UI
- Organized MVVM folder structure: App, Models, ViewModels, Views, Services, Utilities
- Created first sanity test (ExampleTests.swift) - 3/3 passing
- Configured build settings for iOS 15.0+, Swift 5.9+
- App launches successfully on simulator

✅ Phase 1 Gate: ALL TESTS PASS"
```

---

## Summary - Phase 1 Complete

### Completed Tasks
- ✅ T001: Xcode project created
- ✅ T002: Unit Test target added
- ✅ T003: Integration Test target added
- ✅ T004: UI Test target added
- ✅ T005: Main app MVVM folder structure created
- ✅ T006: Test folder structure created
- ✅ T007: First sanity test created (3 tests passing)
- ✅ T008: .gitignore configured (created earlier)
- ✅ T009: App entry point created
- ✅ T010: Tests run successfully (0 failures)
- ✅ T011: App launches on simulator
- ✅ T012: Git repository verified
- ✅ T013: Phase 0 completion commit made

### Metrics
- **Test Count**: 3 passing
- **Test Pass Rate**: 100%
- **Build Status**: ✅ Success
- **Git Status**: ✅ Committed
- **Phase Duration**: ~30 minutes

### Next Phase: Phase 2
When ready, proceed to Phase 2 to create:
- Shared models: CurrencySettings, ConversionRecord, DetectedNumber
- Storage service with UserDefaults + FileManager persistence
- Test infrastructure (test images, helpers)
- Utility functions (Constants, Extensions, Logger)

---

## Troubleshooting

### Issue: Tests don't run
**Solution**:
1. Check that ExampleTests.swift is in the correct target: `CurrencyConverterCameraTests`
2. In File Inspector (right panel), verify Target Membership shows both main app and test target

### Issue: App won't build
**Solution**:
1. Product → Clean Build Folder (Cmd+Shift+K)
2. Product → Build (Cmd+B)
3. Check for red error messages in the Issue Navigator

### Issue: Simulator won't launch
**Solution**:
1. Quit simulator: Cmd+Q
2. In Xcode, select Product → Destination → iPhone 14 (or similar)
3. Product → Run again

---

## Files Reference

All source files mentioned in this guide have been created in `/tmp/`:
- `/tmp/CurrencyConverterCameraApp.swift`
- `/tmp/ContentView.swift`
- `/tmp/ExampleTests.swift`

Copy content from these files into Xcode when creating the files in steps 4-5.

