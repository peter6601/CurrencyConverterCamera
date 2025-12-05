# Quick Start: Phase 1 Setup (5-Minute Overview)

## What You Need to Do

### 1️⃣ Create Xcode Project (5 min)
- Xcode → New Project
- iOS → App template
- Product Name: `CurrencyConverterCamera`
- Language: Swift
- UI: SwiftUI
- Save to `/Users/dindin/Documents/iOS Project/CurrencyConverterCamera/`

### 2️⃣ Add Three Test Targets (10 min)
In Xcode Targets tab, add:
1. **Unit Testing Bundle** → `CurrencyConverterCameraTests`
2. **Unit Testing Bundle** → `CurrencyConverterCameraIntegrationTests`
3. **UI Testing Bundle** → `CurrencyConverterCameraUITests`

### 3️⃣ Create Folder Structure (5 min)
In Xcode Navigator, create groups:
- **App** - drag `CurrencyConverterCameraApp.swift` here
- **Models**
- **ViewModels**
- **Views** - drag `ContentView.swift` here
- **Services**
- **Utilities**
- **Resources/TestImages** (in test targets)

### 4️⃣ Add Three Swift Files (5 min)
Copy content from `/tmp/` into Xcode:
1. **ExampleTests.swift** → `CurrencyConverterCameraTests/`
2. **CurrencyConverterCameraApp.swift** → `CurrencyConverterCamera/App/`
3. **ContentView.swift** → `CurrencyConverterCamera/Views/`

### 5️⃣ Run Tests (2 min)
- Cmd+U (or Product → Test)
- Verify: **3/3 tests pass** ✅

### 6️⃣ Launch App (2 min)
- Cmd+R (or Product → Run)
- Simulator shows app with globe icon ✅

### 7️⃣ Commit (2 min)
```bash
cd /Users/dindin/Documents/iOS\ Project/CurrencyConverterCamera
git add -A
git commit -m "[Stage 0] feat: project initialization with MVVM structure and test targets"
```

---

## File Locations

| File | Location | Template |
|------|----------|----------|
| CurrencyConverterCameraApp.swift | App/ | `/tmp/CurrencyConverterCameraApp.swift` |
| ContentView.swift | Views/ | `/tmp/ContentView.swift` |
| ExampleTests.swift | CurrencyConverterCameraTests/ | `/tmp/ExampleTests.swift` |

---

## Expected Results

✅ **Tests**: 3/3 passing
✅ **App**: Launches with globe icon + "Currency Converter Camera" text
✅ **Build**: Clean build, 0 warnings
✅ **Git**: Committed with stage tag

---

## What's Next?

Phase 1 establishes the foundation. Next phases will add:
- **Phase 2**: Core models (CurrencySettings, ConversionRecord)
- **Phase 3**: Settings screen with validation
- **Phase 4**: Camera integration & Vision framework
- **Phase 5**: History view
- **Phase 6**: Performance testing
- **Phase 7**: Edge cases & localization

---

## Full Setup Guide

For detailed step-by-step instructions, see: `PHASE_1_SETUP.md`

