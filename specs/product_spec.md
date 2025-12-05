# Product Specification: Currency Converter Camera

## Document Metadata
- **Version**: 1.0.0
- **Last Updated**: December 2, 2024
- **Platform**: iOS (iPhone only)
- **Minimum iOS Version**: iOS 15.0+
- **Primary Language**: Traditional Chinese (zh-TW)
- **Development Framework**: SwiftUI + UIKit (for camera)
- **Development Methodology**: TDD (Test-Driven Development)
- **Architecture Pattern**: MVVM (Model-View-ViewModel)

---

## 1. Product Overview

### 1.1 Product Vision
Create a real-time camera-based currency converter that helps travelers instantly understand foreign prices in TWD (New Taiwan Dollar) by pointing their phone camera at price tags and menus.

### 1.2 Problem Statement
When traveling abroad or shopping internationally, users struggle to quickly convert foreign currency prices to TWD. Traditional calculator apps require:
1. Manual number entry
2. App switching
3. Exchange rate lookup
4. Interruption of shopping flow

### 1.3 Target Users
- **Primary**: Taiwanese travelers visiting Japan, Korea, USA, Europe
- **Secondary**: Online shoppers browsing international e-commerce sites
- **Tertiary**: Business travelers needing quick price comparisons

### 1.4 Success Metrics
- Recognition accuracy: >85% for clear, well-lit numbers
- Recognition latency: <500ms from detection to display
- Frame processing: 5-8 FPS (frames per second)
- Battery efficiency: <15% battery drain per hour of continuous use
- Test coverage: >75% overall, 100% for critical paths

---

## 2. Development Philosophy: Test-Driven Development (TDD)

### 2.1 TDD Workflow
This project follows strict TDD methodology:

1. **Red**: Write failing test first
2. **Green**: Write minimal code to pass test
3. **Refactor**: Optimize code while keeping tests green
4. **Verify**: Manual testing on simulator/device
5. **Commit**: Version control checkpoint

### 2.2 Testing Requirements
- **Unit Test Coverage**: >75% overall
- **Critical Path Coverage**: 100% (currency conversion, number parsing, coordinate transformation)
- **Integration Tests**: All service-to-service interactions
- **UI Tests**: Main user flows (settings → camera → overlay display)

### 2.3 Stage-by-Stage Verification
**CRITICAL**: After completing each stage, development MUST PAUSE for:
1. Running all tests (must be green)
2. Manual verification on simulator
3. Developer confirmation before proceeding
4. Git commit with stage completion tag

### 2.4 Test Organization
```
Tests/
├── UnitTests/
│   ├── Models/
│   ├── ViewModels/
│   ├── Services/
│   └── Utilities/
├── IntegrationTests/
│   └── ServiceIntegrationTests/
├── UITests/
│   └── UserFlowTests/
└── Resources/
    └── TestImages/
```

---

## 3. Development Stages (TDD-Driven)

### Stage 0: Project Initialization & TDD Setup
**Goal**: Establish testable project architecture

**Duration**: 15 minutes

#### Deliverables
- ✅ Create Xcode project (SwiftUI App template)
- ✅ Configure Unit Test target
- ✅ Configure UI Test target
- ✅ Create MVVM folder structure
- ✅ Setup first sanity test
- ✅ Configure .gitignore

#### Test Requirements
```swift
// ExampleTests.swift
import XCTest
@testable import CurrencyConverterCamera

class ExampleTests: XCTestCase {
    func testSanityCheck() {
        XCTAssertEqual(1 + 1, 2, "Sanity check failed")
    }
    
    func testProjectCompiles() {
        // This test passing means the project compiles
        XCTAssertTrue(true)
    }
}
```

#### Folder Structure
```
CurrencyConverterCamera/
├── App/
│   ├── CurrencyConverterCameraApp.swift
│   └── Info.plist
├── Models/
├── Views/
│   ├── SettingsView.swift
│   ├── CameraView.swift
│   └── Components/
├── ViewModels/
│   ├── SettingsViewModel.swift
│   └── CameraViewModel.swift
├── Services/
│   ├── CameraService.swift
│   ├── VisionService.swift
│   └── StorageService.swift
├── Utilities/
│   ├── Constants.swift
│   └── Extensions/
└── Tests/
    ├── UnitTests/
    ├── IntegrationTests/
    └── UITests/
```

#### Acceptance Criteria
- [ ] Project compiles successfully without errors
- [ ] All tests pass (green) when running Cmd+U
- [ ] Simulator can launch app (blank screen is acceptable)
- [ ] Git repository initialized with proper .gitignore
- [ ] Folder structure matches specification

#### Manual Verification Steps
1. Open Xcode → Create new project
2. Add test targets
3. Run `Cmd + U` → Verify all tests pass
4. Run `Cmd + R` → Verify app launches
5. Check folder structure
6. Initialize Git repository

---

### Stage 1: Settings Page - Exchange Rate Input & Persistence
**Goal**: Complete settings UI with data validation and local storage

**Duration**: 1.5 hours

#### 1.1 Functional Requirements
1. **Input Fields**:
   - Currency name (TextField, max 20 characters)
   - Exchange rate (TextField, decimal keyboard, range: 0.0001~10000)
2. **Persistence**: Store settings in `UserDefaults`
3. **Validation**:
   - Exchange rate must be > 0 and <= 10000
   - Currency name cannot be empty
   - Display error messages for invalid input
4. **Button State**: "Start Scan" button disabled until validation passes

#### 1.2 Data Models

```swift
// Models/CurrencySettings.swift
import Foundation

struct CurrencySettings: Codable, Equatable {
    var currencyName: String
    var exchangeRate: Decimal
    
    var isValid: Bool {
        !currencyName.isEmpty && 
        exchangeRate > 0 && 
        exchangeRate <= 10000
    }
    
    var validationError: ValidationError? {
        if currencyName.isEmpty {
            return .emptyName
        }
        if exchangeRate <= 0 {
            return .invalidRate
        }
        if exchangeRate > 10000 {
            return .rateTooLarge
        }
        return nil
    }
}

enum ValidationError: LocalizedError {
    case emptyName
    case invalidRate
    case rateTooLarge
    
    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "請輸入幣別名稱"
        case .invalidRate:
            return "匯率必須大於 0"
        case .rateTooLarge:
            return "匯率不可超過 10000"
        }
    }
}
```

#### 1.3 TDD Test Cases

**Test 1: Model Layer Tests**
```swift
// Tests/UnitTests/Models/CurrencySettingsTests.swift
import XCTest
@testable import CurrencyConverterCamera

class CurrencySettingsTests: XCTestCase {
    
    func testValidSettings() {
        // Given
        let settings = CurrencySettings(
            currencyName: "JPY",
            exchangeRate: 0.2
        )
        
        // Then
        XCTAssertTrue(settings.isValid)
        XCTAssertNil(settings.validationError)
    }
    
    func testInvalidSettings_EmptyName() {
        // Given
        let settings = CurrencySettings(
            currencyName: "",
            exchangeRate: 0.2
        )
        
        // Then
        XCTAssertFalse(settings.isValid)
        XCTAssertEqual(settings.validationError, .emptyName)
    }
    
    func testInvalidSettings_NegativeRate() {
        // Given
        let settings = CurrencySettings(
            currencyName: "JPY",
            exchangeRate: -0.5
        )
        
        // Then
        XCTAssertFalse(settings.isValid)
        XCTAssertEqual(settings.validationError, .invalidRate)
    }
    
    func testInvalidSettings_ZeroRate() {
        // Given
        let settings = CurrencySettings(
            currencyName: "JPY",
            exchangeRate: 0
        )
        
        // Then
        XCTAssertFalse(settings.isValid)
        XCTAssertEqual(settings.validationError, .invalidRate)
    }
    
    func testInvalidSettings_RateTooLarge() {
        // Given
        let settings = CurrencySettings(
            currencyName: "JPY",
            exchangeRate: 10001
        )
        
        // Then
        XCTAssertFalse(settings.isValid)
        XCTAssertEqual(settings.validationError, .rateTooLarge)
    }
    
    func testValidSettings_BoundaryValues() {
        // Given
        let minRate = CurrencySettings(currencyName: "JPY", exchangeRate: 0.0001)
        let maxRate = CurrencySettings(currencyName: "JPY", exchangeRate: 10000)
        
        // Then
        XCTAssertTrue(minRate.isValid)
        XCTAssertTrue(maxRate.isValid)
    }
    
    func testCodable_EncodeDecode() {
        // Given
        let settings = CurrencySettings(currencyName: "JPY", exchangeRate: 0.2)
        
        // When
        let encoded = try? JSONEncoder().encode(settings)
        let decoded = try? JSONDecoder().decode(CurrencySettings.self, from: encoded!)
        
        // Then
        XCTAssertNotNil(encoded)
        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded, settings)
    }
}
```

**Test 2: Storage Service Tests**
```swift
// Tests/UnitTests/Services/StorageServiceTests.swift
import XCTest
@testable import CurrencyConverterCamera

class StorageServiceTests: XCTestCase {
    
    var storageService: StorageService!
    let testKey = "test_currency_settings"
    
    override func setUp() {
        super.setUp()
        storageService = StorageService(userDefaultsKey: testKey)
        storageService.clearSettings()
    }
    
    override func tearDown() {
        storageService.clearSettings()
        super.tearDown()
    }
    
    func testSaveAndLoadSettings() {
        // Given
        let settings = CurrencySettings(
            currencyName: "JPY",
            exchangeRate: 0.2
        )
        
        // When
        storageService.save(settings)
        let loaded = storageService.loadSettings()
        
        // Then
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.currencyName, "JPY")
        XCTAssertEqual(loaded?.exchangeRate, 0.2)
    }
    
    func testLoadSettings_WhenNoData() {
        // When
        let loaded = storageService.loadSettings()
        
        // Then
        XCTAssertNil(loaded)
    }
    
    func testUpdateSettings() {
        // Given
        let settings1 = CurrencySettings(currencyName: "JPY", exchangeRate: 0.2)
        let settings2 = CurrencySettings(currencyName: "USD", exchangeRate: 30.0)
        
        // When
        storageService.save(settings1)
        storageService.save(settings2)
        let loaded = storageService.loadSettings()
        
        // Then
        XCTAssertEqual(loaded?.currencyName, "USD")
        XCTAssertEqual(loaded?.exchangeRate, 30.0)
    }
    
    func testClearSettings() {
        // Given
        let settings = CurrencySettings(currencyName: "JPY", exchangeRate: 0.2)
        storageService.save(settings)
        
        // When
        storageService.clearSettings()
        let loaded = storageService.loadSettings()
        
        // Then
        XCTAssertNil(loaded)
    }
    
    func testPersistenceAcrossInstances() {
        // Given
        let settings = CurrencySettings(currencyName: "JPY", exchangeRate: 0.2)
        storageService.save(settings)
        
        // When - Create new instance
        let newService = StorageService(userDefaultsKey: testKey)
        let loaded = newService.loadSettings()
        
        // Then
        XCTAssertEqual(loaded?.currencyName, "JPY")
        XCTAssertEqual(loaded?.exchangeRate, 0.2)
    }
}
```

**Test 3: ViewModel Tests**
```swift
// Tests/UnitTests/ViewModels/SettingsViewModelTests.swift
import XCTest
import Combine
@testable import CurrencyConverterCamera

class SettingsViewModelTests: XCTestCase {
    
    var viewModel: SettingsViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        viewModel = SettingsViewModel()
        cancellables = []
    }
    
    override func tearDown() {
        viewModel.storageService.clearSettings()
        cancellables = nil
        super.tearDown()
    }
    
    func testInitialState() {
        // Then
        XCTAssertEqual(viewModel.currencyName, "")
        XCTAssertEqual(viewModel.exchangeRate, "")
        XCTAssertFalse(viewModel.isValid)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testValidation_ValidInput() {
        // When
        viewModel.currencyName = "JPY"
        viewModel.exchangeRate = "0.2"
        
        // Then
        XCTAssertTrue(viewModel.isValid)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testValidation_EmptyName() {
        // When
        viewModel.currencyName = ""
        viewModel.exchangeRate = "0.2"
        
        // Then
        XCTAssertFalse(viewModel.isValid)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "請輸入幣別名稱")
    }
    
    func testValidation_EmptyRate() {
        // When
        viewModel.currencyName = "JPY"
        viewModel.exchangeRate = ""
        
        // Then
        XCTAssertFalse(viewModel.isValid)
    }
    
    func testValidation_InvalidRate_NonNumeric() {
        // When
        viewModel.currencyName = "JPY"
        viewModel.exchangeRate = "abc"
        
        // Then
        XCTAssertFalse(viewModel.isValid)
    }
    
    func testValidation_InvalidRate_Negative() {
        // When
        viewModel.currencyName = "JPY"
        viewModel.exchangeRate = "-0.5"
        
        // Then
        XCTAssertFalse(viewModel.isValid)
        XCTAssertEqual(viewModel.errorMessage, "匯率必須大於 0")
    }
    
    func testValidation_InvalidRate_Zero() {
        // When
        viewModel.currencyName = "JPY"
        viewModel.exchangeRate = "0"
        
        // Then
        XCTAssertFalse(viewModel.isValid)
    }
    
    func testSaveSettings() {
        // Given
        viewModel.currencyName = "JPY"
        viewModel.exchangeRate = "0.2"
        
        // When
        viewModel.saveSettings()
        
        // Then
        XCTAssertTrue(viewModel.isSaved)
        
        let loaded = viewModel.storageService.loadSettings()
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.currencyName, "JPY")
    }
    
    func testLoadSettings() {
        // Given
        let settings = CurrencySettings(currencyName: "JPY", exchangeRate: 0.2)
        viewModel.storageService.save(settings)
        
        // When
        viewModel.loadSettings()
        
        // Then
        XCTAssertEqual(viewModel.currencyName, "JPY")
        XCTAssertEqual(viewModel.exchangeRate, "0.2")
    }
    
    func testLoadSettings_WhenNoData() {
        // When
        viewModel.loadSettings()
        
        // Then
        XCTAssertEqual(viewModel.currencyName, "")
        XCTAssertEqual(viewModel.exchangeRate, "")
    }
    
    func testReactiveValidation() {
        // Given
        let expectation = XCTestExpectation(description: "Validation updates")
        var validationResults: [Bool] = []
        
        viewModel.$isValid
            .sink { isValid in
                validationResults.append(isValid)
                if validationResults.count == 3 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        viewModel.currencyName = "JPY"
        viewModel.exchangeRate = "0.2"
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(validationResults.last, true)
    }
}
```

#### 1.4 UI Design Specifications

**Layout**:
```
┌─────────────────────────────────┐
│                                 │
│      幣值轉換相機                │
│   Currency Converter Camera     │
│                                 │
│  ┌───────────────────────────┐  │
│  │ 幣別名稱 Currency Name      │  │
│  │ [例如：日幣 / JPY]         │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │ 對台幣匯率 Exchange Rate    │  │
│  │ [例如：0.2]                │  │
│  │ 💡 日幣 ¥100 = 台幣 $20    │  │
│  └───────────────────────────┘  │
│                                 │
│  ⚠️ [Error Message Area]        │
│                                 │
│  ┌───────────────────────────┐  │
│  │    開始掃描 Start Scan 📷  │  │ <- Disabled initially
│  └───────────────────────────┘  │
│                                 │
└─────────────────────────────────┘
```

**Styling Guidelines**:
```swift
// Utilities/Constants.swift
enum DesignSystem {
    enum Colors {
        static let primary = Color.blue
        static let error = Color.red
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
    }
    
    enum Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 20
        static let xlarge: CGFloat = 32
    }
    
    enum Typography {
        static let title = Font.system(size: 28, weight: .bold)
        static let body = Font.system(size: 16, weight: .regular)
        static let caption = Font.system(size: 14, weight: .regular)
    }
    
    enum ButtonStyle {
        static let height: CGFloat = 50
        static let cornerRadius: CGFloat = 12
    }
}
```

#### 1.5 Implementation Files Structure
```
Models/
├── CurrencySettings.swift
└── ValidationError.swift

ViewModels/
├── SettingsViewModel.swift

Views/
├── SettingsView.swift

Services/
├── StorageService.swift

Utilities/
├── Constants.swift

Tests/UnitTests/
├── Models/
│   └── CurrencySettingsTests.swift
├── ViewModels/
│   └── SettingsViewModelTests.swift
└── Services/
    └── StorageServiceTests.swift
```

#### 1.6 Acceptance Criteria

**Functional Acceptance**:
- [ ] Can input currency name (text field)
- [ ] Can input exchange rate (decimal keyboard appears)
- [ ] Rate field only accepts numbers and decimal point
- [ ] "Start Scan" button is disabled when fields are invalid
- [ ] "Start Scan" button is enabled when both fields are valid
- [ ] Error message displays for empty currency name
- [ ] Error message displays for invalid rate (≤0 or non-numeric)
- [ ] Error message displays for rate > 10000
- [ ] Settings persist after app restart
- [ ] Settings persist after app termination

**Test Acceptance**:
- [ ] All unit tests pass (green) - 100% pass rate
- [ ] Test coverage >80% for Stage 1 code
- [ ] No compilation warnings or errors
- [ ] Manual test scenarios passed

**Manual Verification Steps**:
1. Launch app
2. Verify initial state (empty fields, button disabled)
3. Enter "日幣" in currency name field
4. Verify decimal keyboard appears for rate field
5. Enter "0.2" in exchange rate field
6. Verify "Start Scan" button becomes enabled
7. Clear currency name → Verify button becomes disabled
8. Enter currency name again → Verify button becomes enabled
9. Enter "abc" in rate field → Verify error message
10. Enter "-1" in rate field → Verify error message
11. Force quit app → Relaunch → Verify settings retained

---

### Stage 2: Camera Button & Navigation Flow
**Goal**: Implement navigation from settings to camera page

**Duration**: 30 minutes

#### 2.1 Functional Requirements
1. "Start Scan" button enabled only when validation passes
2. Tapping button navigates to camera page
3. Camera page shows placeholder view initially
4. Back button returns to settings page
5. Settings data passed to camera view

#### 2.2 TDD Test Cases

**Test 1: ViewModel Navigation Tests**
```swift
// Tests/UnitTests/ViewModels/SettingsViewModelTests.swift (additions)

func testNavigationTriggered_WhenValidInput() {
    // Given
    viewModel.currencyName = "JPY"
    viewModel.exchangeRate = "0.2"
    
    // When
    let canNavigate = viewModel.canNavigateToCamera
    
    // Then
    XCTAssertTrue(canNavigate)
}

func testNavigationBlocked_WhenInvalidInput() {
    // Given
    viewModel.currencyName = ""
    viewModel.exchangeRate = "0.2"
    
    // When
    let canNavigate = viewModel.canNavigateToCamera
    
    // Then
    XCTAssertFalse(canNavigate)
}

func testNavigationPassesSettings() {
    // Given
    viewModel.currencyName = "JPY"
    viewModel.exchangeRate = "0.2"
    
    // When
    let settings = viewModel.createCameraSettings()
    
    // Then
    XCTAssertNotNil(settings)
    XCTAssertEqual(settings?.currencyName, "JPY")
    XCTAssertEqual(settings?.exchangeRate, 0.2)
}
```

**Test 2: UI Navigation Tests**
```swift
// Tests/UITests/NavigationUITests.swift
import XCTest

class NavigationUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testNavigationFromSettingsToCamera() {
        // Given
        let currencyField = app.textFields["currency_name_field"]
        let rateField = app.textFields["exchange_rate_field"]
        let scanButton = app.buttons["start_scan_button"]
        
        // When
        currencyField.tap()
        currencyField.typeText("JPY")
        
        rateField.tap()
        rateField.typeText("0.2")
        
        scanButton.tap()
        
        // Then
        XCTAssertTrue(app.navigationBars["Camera"].exists)
    }
    
    func testBackNavigationFromCamera() {
        // Given - Navigate to camera
        let currencyField = app.textFields["currency_name_field"]
        let rateField = app.textFields["exchange_rate_field"]
        
        currencyField.tap()
        currencyField.typeText("JPY")
        rateField.tap()
        rateField.typeText("0.2")
        app.buttons["start_scan_button"].tap()
        
        // When
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        // Then
        XCTAssertTrue(app.staticTexts["幣值轉換相機"].exists)
    }
    
    func testSettingsRetainedAfterNavigation() {
        // Given
        let currencyField = app.textFields["currency_name_field"]
        let rateField = app.textFields["exchange_rate_field"]
        
        currencyField.tap()
        currencyField.typeText("JPY")
        rateField.tap()
        rateField.typeText("0.2")
        
        // When - Navigate and return
        app.buttons["start_scan_button"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        // Then
        XCTAssertEqual(currencyField.value as? String, "JPY")
        XCTAssertEqual(rateField.value as? String, "0.2")
    }
    
    func testNavigationBarDisplaysCurrency() {
        // Given
        let currencyField = app.textFields["currency_name_field"]
        let rateField = app.textFields["exchange_rate_field"]
        
        currencyField.tap()
        currencyField.typeText("JPY")
        rateField.tap()
        rateField.typeText("0.2")
        
        // When
        app.buttons["start_scan_button"].tap()
        
        // Then
        XCTAssertTrue(app.staticTexts["JPY → TWD"].exists)
    }
}
```

#### 2.3 UI Design Specifications

**Camera Page (Placeholder Version)**:
```
┌─────────────────────────────────┐
│ ← JPY → TWD                     │  <- Navigation Bar
├─────────────────────────────────┤
│                                 │
│                                 │
│           📷                    │
│                                 │
│     Camera Preview Area         │
│   (Implemented in Stage 3)      │
│                                 │
│                                 │
│                                 │
└─────────────────────────────────┘
```

#### 2.4 Implementation Files
```
Views/
├── CameraView.swift              (New - placeholder)

ViewModels/
├── CameraViewModel.swift         (New - basic structure)

Tests/UITests/
├── NavigationUITests.swift       (New)
```

#### 2.5 Acceptance Criteria

**Functional Acceptance**:
- [ ] Tapping "Start Scan" navigates to camera page
- [ ] Camera page shows navigation bar with currency display
- [ ] Back button returns to settings page
- [ ] Settings data retained after navigation
- [ ] Navigation animation is smooth (no lag)

**Test Acceptance**:
- [ ] All UI tests pass
- [ ] Navigation flow works on simulator
- [ ] No memory leaks (verify with Instruments)

**Manual Verification Steps**:
1. Complete Stage 1 setup
2. Enter valid settings (JPY, 0.2)
3. Tap "Start Scan"
4. Verify navigation occurs
5. Verify navigation bar shows "JPY → TWD"
6. Tap back button
7. Verify return to settings
8. Verify settings still display correctly

---

### Stage 3: Custom Camera Preview (AVFoundation)
**Goal**: Implement real camera preview functionality

**Duration**: 2 hours

#### 3.1 Functional Requirements
1. Display live camera feed using AVFoundation
2. Handle camera permission requests properly
3. Manage camera lifecycle (start/stop/pause)
4. Adapt to different screen sizes
5. Handle app backgrounding/foregrounding
6. Display permission denied alert with settings link

#### 3.2 TDD Test Cases

**Test 1: CameraService Tests**
```swift
// Tests/UnitTests/Services/CameraServiceTests.swift
import XCTest
import AVFoundation
@testable import CurrencyConverterCamera

class CameraServiceTests: XCTestCase {
    
    var cameraService: CameraService!
    
    override func setUp() {
        super.setUp()
        cameraService = CameraService()
    }
    
    override func tearDown() {
        cameraService.stopSession()
        cameraService = nil
        super.tearDown()
    }
    
    func testInitialState() {
        // Then
        XCTAssertFalse(cameraService.isRunning)
        XCTAssertEqual(cameraService.authorizationStatus, .notDetermined)
    }
    
    func testCaptureSessionCreation() {
        // When
        let success = cameraService.setupSession()
        
        // Then
        XCTAssertNotNil(cameraService.captureSession)
    }
    
    func testStartSession_UpdatesRunningState() {
        // Given
        _ = cameraService.setupSession()
        
        // When
        cameraService.startSession()
        
        // Then
        let expectation = XCTestExpectation(description: "Session starts")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(self.cameraService.isRunning)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testStopSession_UpdatesRunningState() {
        // Given
        _ = cameraService.setupSession()
        cameraService.startSession()
        
        // When
        cameraService.stopSession()
        
        // Then
        XCTAssertFalse(cameraService.isRunning)
    }
    
    func testSessionRestartable() {
        // Given
        _ = cameraService.setupSession()
        
        // When
        cameraService.startSession()
        cameraService.stopSession()
        cameraService.startSession()
        
        // Then
        let expectation = XCTestExpectation(description: "Session restarts")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(self.cameraService.isRunning)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDelegateReceivesFrames() {
        // Given
        let delegate = MockCameraServiceDelegate()
        cameraService.delegate = delegate
        _ = cameraService.setupSession()
        
        // When
        cameraService.startSession()
        
        // Then
        let expectation = XCTestExpectation(description: "Delegate receives frames")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertTrue(delegate.frameCount > 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3.0)
    }
}

class MockCameraServiceDelegate: CameraServiceDelegate {
    var frameCount = 0
    var lastError: Error?
    
    func didCaptureFrame(_ image: UIImage) {
        frameCount += 1
    }
    
    func didEncounterError(_ error: Error) {
        lastError = error
    }
}
```

**Test 2: CameraViewModel Tests**
```swift
// Tests/UnitTests/ViewModels/CameraViewModelTests.swift
import XCTest
import Combine
@testable import CurrencyConverterCamera

class CameraViewModelTests: XCTestCase {
    
    var viewModel: CameraViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        let settings = CurrencySettings(currencyName: "JPY", exchangeRate: 0.2)
        viewModel = CameraViewModel(settings: settings)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testInitialState() {
        // Then
        XCTAssertFalse(viewModel.isCameraRunning)
        XCTAssertFalse(viewModel.showPermissionAlert)
        XCTAssertEqual(viewModel.settings.currencyName, "JPY")
    }
    
    func testPermissionDenied_ShowsAlert() {
        // Given
        viewModel.showPermissionAlert = false
        
        // When
        viewModel.handlePermissionDenied()
        
        // Then
        XCTAssertTrue(viewModel.showPermissionAlert)
        XCTAssertEqual(viewModel.alertMessage, "需要相機權限才能使用此功能")
    }
    
    func testPermissionGranted_StartsCamera() {
        // Given
        let expectation = expectation(description: "Camera starts")
        
        // When
        viewModel.handlePermissionGranted()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(self.viewModel.isCameraRunning)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testAppBackground_StopsCamera() {
        // Given
        viewModel.startCamera()
        
        // When
        NotificationCenter.default.post(
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        // Then
        XCTAssertFalse(viewModel.isCameraRunning)
    }
    
    func testAppForeground_RestartsCamera() {
        // Given
        viewModel.startCamera()
        NotificationCenter.default.post(
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        // When
        NotificationCenter.default.post(
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        // Then
        let expectation = XCTestExpectation(description: "Camera restarts")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(self.viewModel.isCameraRunning)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
}
```

#### 3.3 Technical Architecture

**CameraService Implementation**:
```swift
// Services/CameraService.swift
protocol CameraServiceDelegate: AnyObject {
    func didCaptureFrame(_ image: UIImage)
    func didEncounterError(_ error: Error)
}

class CameraService: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var isRunning = false
    @Published var authorizationStatus: AVAuthorizationStatus = .notDetermined
    
    // MARK: - Properties
    weak var delegate: CameraServiceDelegate?
    private(set) var captureSession: AVCaptureSession?
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private var videoDataOutput: AVCaptureVideoDataOutput?
    private let videoDataOutputQueue = DispatchQueue(
        label: "camera.video.output.queue",
        qos: .userInitiated
    )
    
    // MARK: - Public Methods
    func requestPermission(completion: @escaping (Bool) -> Void) { }
    func setupSession() -> Bool { }
    func startSession() { }
    func stopSession() { }
    
    // MARK: - Private Methods
    private func configureCaptureSession() -> Bool { }
    private func addVideoInput() -> Bool { }
    private func addVideoOutput() -> Bool { }
}

extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        // Process frame and notify delegate
    }
}
```

**UIViewRepresentable Wrapper**:
```swift
// Views/Components/CameraPreviewRepresentable.swift
struct CameraPreviewRepresentable: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> CameraPreviewView {
        let view = CameraPreviewView()
        view.session = session
        return view
    }
    
    func updateUIView(_ uiView: CameraPreviewView, context: Context) {
        // Update if needed
    }
}

// Views/Components/CameraPreviewView.swift
class CameraPreviewView: UIView {
    var session: AVCaptureSession? {
        didSet {
            guard let session = session else { return }
            previewLayer.session = session
        }
    }
    
    private var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
    
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = bounds
    }
}
```

#### 3.4 Info.plist Configuration
Add camera usage description:
```xml
<key>NSCameraUsageDescription</key>
<string>需要使用相機來辨識價格標籤上的數字</string>
```

#### 3.5 Implementation Files
```
Services/
├── CameraService.swift                  (New)

Views/Components/
├── CameraPreviewRepresentable.swift     (New)
├── CameraPreviewView.swift              (New)

Tests/UnitTests/Services/
├── CameraServiceTests.swift             (New)

Tests/UnitTests/ViewModels/
├── CameraViewModelTests.swift           (New)
```

#### 3.6 Acceptance Criteria

**Functional Acceptance**:
- [ ] Camera permission dialog appears on first launch
- [ ] Live camera preview displays after authorization
- [ ] Preview fills entire screen with aspect fill
- [ ] Camera stops when returning to settings page
- [ ] Camera restarts when re-entering camera view
- [ ] Camera stops when app enters background
- [ ] Camera resumes when app returns to foreground
- [ ] Permission denied alert shows with settings link
- [ ] Preview is smooth at 30fps

**Test Acceptance**:
- [ ] All unit tests pass (100%)
- [ ] Test on physical device (required for camera)
- [ ] No memory leaks (verified with Instruments)
- [ ] CPU usage <30% during camera operation

**Manual Verification Steps**:
1. Launch app → Enter settings
2. Navigate to camera → Grant permission
3. Verify live preview appears
4. Tap back → Return to settings
5. Re-enter camera → Verify preview restarts
6. Press home → Return to app → Verify preview resumes
7. Test on multiple devices:
   - iPhone SE (2nd gen) - 4.7"
   - iPhone 12 - 6.1"
   - iPhone 15 Pro - 6.1"

**Device Testing Checklist**:
| Device | iOS | Screen | Permission | Preview | Lifecycle | Status |
|--------|-----|--------|-----------|---------|-----------|--------|
| iPhone SE | 15.0 | 4.7" | [ ] | [ ] | [ ] | [ ] |
| iPhone 12 | 16.0 | 6.1" | [ ] | [ ] | [ ] | [ ] |
| iPhone 15 Pro | 17.0 | 6.1" | [ ] | [ ] | [ ] | [ ] |

---

### Stage 4: Vision Framework Text Recognition
**Goal**: Enable camera to recognize text in frames

**Duration**: 2.5 hours

#### 4.1 Functional Requirements
1. Integrate Vision Framework for OCR
2. Recognize text from camera frames
3. Throttle recognition frequency to 5-8 FPS
4. Display all recognized text in debug mode
5. Filter results by confidence threshold (>0.6)
6. Handle recognition errors gracefully

#### 4.2 Data Models

```swift
// Models/RecognizedText.swift
struct RecognizedText: Identifiable {
    let id = UUID()
    let text: String
    let confidence: Float
    let boundingBox: CGRect
    let timestamp: Date
    
    var isHighConfidence: Bool {
        confidence > 0.8
    }
}
```

#### 4.3 TDD Test Cases

**Test 1: VisionService Tests**
```swift
// Tests/UnitTests/Services/VisionServiceTests.swift
import XCTest
import Vision
@testable import CurrencyConverterCamera

class VisionServiceTests: XCTestCase {
    
    var visionService: VisionService!
    
    override func setUp() {
        super.setUp()
        visionService = VisionService()
    }
    
    func testRecognizeText_FromClearImage() {
        // Given
        guard let testImage = UIImage(named: "test_clear_number", in: Bundle(for: type(of: self)), compatibleWith: nil) else {
            XCTFail("Test image not found")
            return
        }
        let expectation = expectation(description: "Recognition completes")
        
        // When
        visionService.recognizeText(from: testImage) { results in
            // Then
            XCTAssertFalse(results.isEmpty, "Should recognize some text")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    
    func testRecognitionConfidence_AboveThreshold() {
        // Given
        guard let testImage = UIImage(named: "test_clear_number", in: Bundle(for: type(of: self)), compatibleWith: nil) else {
            XCTFail("Test image not found")
            return
        }
        let expectation = expectation(description: "High confidence")
        
        // When
        visionService.recognizeText(from: testImage) { results in
            // Then
            for result in results {
                XCTAssertGreaterThan(result.confidence, 0.5, "Confidence should be above threshold")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    
    func testRecognizeText_FromBlurryImage() {
        // Given
        guard let testImage = UIImage(named: "test_blurry_text", in: Bundle(for: type(of: self)), compatibleWith: nil) else {
            XCTFail("Test image not found")
            return
        }
        let expectation = expectation(description: "Recognition completes")
        
        // When
        visionService.recognizeText(from: testImage) { results in
            // Then
            // May return empty or low confidence results
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    
    func testRecognizeMultipleTexts() {
        // Given
        guard let testImage = UIImage(named: "test_multiple_prices", in: Bundle(for: type(of: self)), compatibleWith: nil) else {
            XCTFail("Test image not found")
            return
        }
        let expectation = expectation(description: "Multiple texts")
        
        // When
        visionService.recognizeText(from: testImage) { results in
            // Then
            XCTAssertGreaterThan(results.count, 1, "Should recognize multiple texts")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    
    func testBoundingBoxReturned() {
        // Given
        guard let testImage = UIImage(named: "test_clear_number", in: Bundle(for: type(of: self)), compatibleWith: nil) else {
            XCTFail("Test image not found")
            return
        }
        let expectation = expectation(description: "Bounding box")
        
        // When
        visionService.recognizeText(from: testImage) { results in
            // Then
            for result in results {
                XCTAssertFalse(result.boundingBox.isEmpty, "Bounding box should not be empty")
                XCTAssertGreaterThan(result.boundingBox.width, 0)
                XCTAssertGreaterThan(result.boundingBox.height, 0)
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
}
```

**Test 2: Frame Throttling Tests**
```swift
// Tests/UnitTests/ViewModels/CameraViewModelTests.swift (additions)

func testFrameThrottling() {
    // Given
    viewModel.lastProcessedTime = Date()
    
    // When
    let shouldProcess = viewModel.shouldProcessFrame()
    
    // Then
    XCTAssertFalse(shouldProcess, "Should not process frame too quickly")
}

func testFrameProcessing_AfterThrottleInterval() {
    // Given
    viewModel.lastProcessedTime = Date().addingTimeInterval(-0.2) // 200ms ago
    
    // When
    let shouldProcess = viewModel.shouldProcessFrame()
    
    // Then
    XCTAssertTrue(shouldProcess, "Should process frame after interval")
}

func testThrottleInterval_Configurable() {
    // Given
    viewModel.throttleInterval = 0.1 // 100ms = 10 FPS
    viewModel.lastProcessedTime = Date().addingTimeInterval(-0.15)
    
    // When
    let shouldProcess = viewModel.shouldProcessFrame()
    
    // Then
    XCTAssertTrue(shouldProcess)
}

func testRecognizedTextsUpdated() {
    // Given
    let mockImage = UIImage()
    let expectation = expectation(description: "Texts updated")
    
    viewModel.$recognizedTexts
        .dropFirst()
        .sink { texts in
            XCTAssertFalse(texts.isEmpty)
            expectation.fulfill()
        }
        .store(in: &cancellables)
    
    // When
    viewModel.processFrame(mockImage)
    
    // Then
    waitForExpectations(timeout: 2)
}
```

#### 4.4 Technical Implementation

**VisionService Architecture**:
```swift
// Services/VisionService.swift
class VisionService {
    private let recognitionQueue = DispatchQueue(
        label: "vision.recognition.queue",
        qos: .userInitiated
    )
    
    func recognizeText(
        from image: UIImage,
        completion: @escaping ([RecognizedText]) -> Void
    ) {
        guard let cgImage = image.cgImage else {
            completion([])
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            guard error == nil,
                  let observations = request.results as? [VNRecognizedTextObservation]
            else {
                completion([])
                return
            }
            
            let results = observations.compactMap { observation -> RecognizedText? in
                guard let candidate = observation.topCandidates(1).first else {
                    return nil
                }
                
                // Filter by confidence
                guard candidate.confidence > 0.6 else {
                    return nil
                }
                
                return RecognizedText(
                    text: candidate.string,
                    confidence: candidate.confidence,
                    boundingBox: observation.boundingBox,
                    timestamp: Date()
                )
            }
            
            DispatchQueue.main.async {
                completion(results)
            }
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        request.recognitionLanguages = ["en-US", "zh-Hans", "zh-Hant"]
        
        recognitionQueue.async {
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }
}
```

**Integration with CameraViewModel**:
```swift
// ViewModels/CameraViewModel.swift (additions)
extension CameraViewModel: CameraServiceDelegate {
    func didCaptureFrame(_ image: UIImage) {
        guard shouldProcessFrame() else { return }
        
        lastProcessedTime = Date()
        processFrame(image)
    }
    
    func didEncounterError(_ error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = error.localizedDescription
        }
    }
}

private extension CameraViewModel {
    func processFrame(_ image: UIImage) {
        visionService.recognizeText(from: image) { [weak self] results in
            self?.recognizedTexts = results
        }
    }
    
    func shouldProcessFrame() -> Bool {
        guard let lastTime = lastProcessedTime else {
            return true
        }
        return Date().timeIntervalSince(lastTime) >= throttleInterval
    }
}
```

#### 4.5 Debug UI Display

```swift
// Views/CameraView.swift - Debug Overlay
struct DebugOverlay: View {
    let recognizedTexts: [RecognizedText]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("🔍 Recognition Results:")
                .font(.headline)
            
            ScrollView {
                ForEach(recognizedTexts) { text in
                    HStack {
                        Text(text.text)
                            .font(.body)
                        Spacer()
                        Text(String(format: "%.2f", text.confidence))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .foregroundColor(.white)
        .frame(maxHeight: 200)
    }
}
```

#### 4.6 Test Resources Setup

Create test images in the project:
```
Tests/Resources/
├── test_clear_number.png       (Contains "1000")
├── test_blurry_text.png        (Blurry text)
├── test_multiple_prices.png    (Multiple price tags)
└── test_mixed_text.png         (Numbers and text mixed)
```

#### 4.7 Implementation Files
```
Services/
├── VisionService.swift                  (New)

Models/
├── RecognizedText.swift                 (New)

Tests/UnitTests/Services/
├── VisionServiceTests.swift             (New)

Tests/Resources/
├── test_clear_number.png                (New)
├── test_blurry_text.png                 (New)
├── test_multiple_prices.png             (New)
└── test_mixed_text.png                  (New)
```

#### 4.8 Acceptance Criteria

**Functional Acceptance**:
- [ ] Camera recognizes text in frames
- [ ] Debug overlay shows all recognized text
- [ ] Recognition frequency controlled at 5-8 FPS
- [ ] Confidence scores displayed for each result
- [ ] Camera preview remains smooth (no lag)
- [ ] Recognition works with printed text
- [ ] Recognition handles multiple texts simultaneously

**Test Acceptance**:
- [ ] All unit tests pass
- [ ] Test with multiple test images
- [ ] CPU usage <40% during recognition
- [ ] Memory usage stable (no leaks)

**Manual Verification Steps**:
1. Navigate to camera view
2. Point camera at printed text/numbers
3. Verify debug overlay shows recognized text
4. Verify confidence scores displayed
5. Test with various materials:
   - Printed paper
   - Phone screen
   - Product packaging
6. Test with multiple texts visible
7. Monitor CPU/memory in Xcode

**Performance Metrics**:
| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Recognition FPS | 5-8 | [ ] | [ ] |
| CPU Usage | <40% | [ ] | [ ] |
| Memory | <150MB | [ ] | [ ] |
| Latency | <500ms | [ ] | [ ] |

---

### Stage 5: Number Filtering & Parsing
**Goal**: Extract and parse numeric values from recognized text

**Duration**: 1.5 hours

#### 5.1 Functional Requirements
1. Filter recognized text to extract only numbers
2. Support comma separators (1,000)
3. Support decimal points (99.99)
4. Parse to Decimal type (avoid floating-point errors)
5. Extract multiple numbers from mixed text
6. Ignore non-numeric characters

#### 5.2 Data Models

```swift
// Models/RecognizedNumber.swift
struct RecognizedNumber: Identifiable, Equatable {
    let id = UUID()
    let value: Decimal
    let originalText: String
    let boundingBox: CGRect
    let confidence: Float
    let timestamp: Date
    
    static func == (lhs: RecognizedNumber, rhs: RecognizedNumber) -> Bool {
        lhs.id == rhs.id
    }
}
```

#### 5.3 TDD Test Cases

**Test 1: NumberParser Tests**
```swift
// Tests/UnitTests/Utilities/NumberParserTests.swift
import XCTest
@testable import CurrencyConverterCamera

class NumberParserTests: XCTestCase {
    
    var parser: NumberParser!
    
    override func setUp() {
        super.setUp()
        parser = NumberParser()
    }
    
    func testParseSimpleInteger() {
        // Given
        let text = "1000"
        
        // When
        let result = parser.parse(text)
        
        // Then
        XCTAssertEqual(result, 1000)
    }
    
    func testParseNumberWithComma() {
        // Given
        let text = "1,000"
        
        // When
        let result = parser.parse(text)
        
        // Then
        XCTAssertEqual(result, 1000)
    }
    
    func testParseNumberWithMultipleCommas() {
        // Given
        let text = "1,234,567"
        
        // When
        let result = parser.parse(text)
        
        // Then
        XCTAssertEqual(result, 1234567)
    }
    
    func testParseDecimalNumber() {
        // Given
        let text = "99.99"
        
        // When
        let result = parser.parse(text)
        
        // Then
        XCTAssertEqual(result, 99.99)
    }
    
    func testParseNumberWithCommaAndDecimal() {
        // Given
        let text = "12,345.67"
        
        // When
        let result = parser.parse(text)
        
        // Then
        XCTAssertEqual(result, 12345.67)
    }
    
    func testParseInvalidText_ReturnsNil() {
        // Given
        let texts = ["Hello", "ABC", "日本語", "!@#$"]
        
        // When & Then
        for text in texts {
            let result = parser.parse(text)
            XCTAssertNil(result, "Should return nil for '\(text)'")
        }
    }
    
    func testParseMixedText_ExtractsNumber() {
        // Given
        let text = "¥1,000"
        
        // When
        let results = parser.extractNumbers(from: text)
        
        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first, 1000)
    }
    
    func testParseMultipleNumbers() {
        // Given
        let text = "Price: $100 or €85.50"
        
        // When
        let results = parser.extractNumbers(from: text)
        
        // Then
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0], 100)
        XCTAssertEqual(results[1], 85.50)
    }
    
    func testParseSmallDecimal() {
        // Given
        let text = "0.99"
        
        // When
        let result = parser.parse(text)
        
        // Then
        XCTAssertEqual(result, 0.99)
    }
    
    func testParseZero() {
        // Given
        let text = "0"
        
        // When
        let result = parser.parse(text)
        
        // Then
        XCTAssertEqual(result, 0)
    }
    
    func testIsValidNumber() {
        // Given
        let validTexts = ["100", "1,000", "99.99", "12,345.67"]
        let invalidTexts = ["abc", "¥", "日本", "1.2.3"]
        
        // When & Then
        for text in validTexts {
            XCTAssertTrue(parser.isValidNumber(text), "'\(text)' should be valid")
        }
        
        for text in invalidTexts {
            XCTAssertFalse(parser.isValidNumber(text), "'\(text)' should be invalid")
        }
    }
    
    func testDecimalPrecision() {
        // Given
        let text = "123.456789"
        
        // When
        let result = parser.parse(text)
        
        // Then
        XCTAssertEqual(result, 123.456789)
    }
    
    func testParseNumberWithLeadingZeros() {
        // Given
        let text = "00100"
        
        // When
        let result = parser.parse(text)
        
        // Then
        XCTAssertEqual(result, 100)
    }
}
```

**Test 2: VisionService Filtering Tests**
```swift
// Tests/UnitTests/Services/VisionServiceTests.swift (additions)

func testFilterOnlyNumbers() {
    // Given
    let recognizedTexts = [
        RecognizedText(text: "1000", confidence: 0.9, boundingBox: .zero, timestamp: Date()),
        RecognizedText(text: "日本製", confidence: 0.8, boundingBox: .zero, timestamp: Date()),
        RecognizedText(text: "¥500", confidence: 0.95, boundingBox: .zero, timestamp: Date()),
        RecognizedText(text: "Special", confidence: 0.85, boundingBox: .zero, timestamp: Date())
    ]
    
    // When
    let filtered = visionService.filterNumbers(from: recognizedTexts)
    
    // Then
    XCTAssertEqual(filtered.count, 2, "Should extract 1000 and 500")
}

func testFilterNumbers_PreservesOriginalText() {
    // Given
    let recognizedTexts = [
        RecognizedText(text: "¥1,000", confidence: 0.9, boundingBox: .zero, timestamp: Date())
    ]
    
    // When
    let filtered = visionService.filterNumbers(from: recognizedTexts)
    
    // Then
    XCTAssertEqual(filtered.first?.originalText, "¥1,000")
    XCTAssertEqual(filtered.first?.value, 1000)
}

func testFilterNumbers_PreservesBoundingBox() {
    // Given
    let boundingBox = CGRect(x: 0.5, y: 0.5, width: 0.2, height: 0.1)
    let recognizedTexts = [
        RecognizedText(text: "1000", confidence: 0.9, boundingBox: boundingBox, timestamp: Date())
    ]
    
    // When
    let filtered = visionService.filterNumbers(from: recognizedTexts)
    
    // Then
    XCTAssertEqual(filtered.first?.boundingBox, boundingBox)
}
```

**Test 3: Integration Tests**
```swift
// Tests/IntegrationTests/NumberExtractionIntegrationTests.swift
import XCTest
@testable import CurrencyConverterCamera

class NumberExtractionIntegrationTests: XCTestCase {
    
    var visionService: VisionService!
    var numberParser: NumberParser!
    
    override func setUp() {
        super.setUp()
        visionService = VisionService()
        numberParser = NumberParser()
    }
    
    func testCompleteNumberExtractionPipeline() {
        // Given
        guard let testImage = UIImage(named: "test_price_tag", in: Bundle(for: type(of: self)), compatibleWith: nil) else {
            XCTFail("Test image not found")
            return
        }
        let expectation = expectation(description: "Complete pipeline")
        
        // When
        visionService.recognizeText(from: testImage) { recognizedTexts in
            let numbers = self.visionService.filterNumbers(from: recognizedTexts)
            
            // Then
            XCTAssertFalse(numbers.isEmpty, "Should extract at least one number")
            for number in numbers {
                XCTAssertGreaterThan(number.value, 0, "Parsed value should be positive")
                XCTAssertFalse(number.originalText.isEmpty, "Original text should be preserved")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
}
```

#### 5.4 Technical Implementation

**NumberParser Architecture**:
```swift
// Utilities/NumberParser.swift
class NumberParser {
    // Regex pattern: matches numbers with optional commas and decimal point
    private let numberPattern = #"[\d,]+\.?\d*"#
    private lazy var numberRegex: NSRegularExpression? = {
        try? NSRegularExpression(pattern: numberPattern, options: [])
    }()
    
    /// Parse a single number string to Decimal
    func parse(_ text: String) -> Decimal? {
        // Remove commas
        let cleaned = text.replacingOccurrences(of: ",", with: "")
        
        // Remove leading zeros (but keep "0" and "0.x")
        let trimmed = cleaned.replacingOccurrences(of: "^0+(?!\\.|$)", with: "", options: .regularExpression)
        
        // Convert to Decimal
        return Decimal(string: trimmed)
    }
    
    /// Extract all numbers from a text string
    func extractNumbers(from text: String) -> [Decimal] {
        guard let regex = numberRegex else { return [] }
        
        let range = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, range: range)
        
        return matches.compactMap { match -> Decimal? in
            guard let range = Range(match.range, in: text) else { return nil }
            let numberString = String(text[range])
            return parse(numberString)
        }
    }
    
    /// Check if a string is a valid number
    func isValidNumber(_ text: String) -> Bool {
        return parse(text) != nil
    }
}
```

**VisionService Extension for Number Filtering**:
```swift
// Services/VisionService.swift (additions)
extension VisionService {
    func filterNumbers(from recognizedTexts: [RecognizedText]) -> [RecognizedNumber] {
        let parser = NumberParser()
        
        return recognizedTexts.compactMap { recognized -> RecognizedNumber? in
            let numbers = parser.extractNumbers(from: recognized.text)
            
            // Take the first (or largest) number found
            guard let value = numbers.first else { return nil }
            
            return RecognizedNumber(
                value: value,
                originalText: recognized.text,
                boundingBox: recognized.boundingBox,
                confidence: recognized.confidence,
                timestamp: recognized.timestamp
            )
        }
    }
}
```

#### 5.5 Debug UI Update

Update debug overlay to show parsed numbers:
```swift
struct DebugOverlay: View {
    let recognizedNumbers: [RecognizedNumber]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🔍 Recognized Numbers:")
                .font(.headline)
            
            if recognizedNumbers.isEmpty {
                Text("No numbers detected")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ForEach(recognizedNumbers) { number in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(number.originalText)
                                .font(.body)
                            Text("Value: \(number.value.description)")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        Spacer()
                        Text(String(format: "%.2f", number.confidence))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .foregroundColor(.white)
        .frame(maxHeight: 200)
    }
}
```

#### 5.6 Implementation Files
```
Utilities/
├── NumberParser.swift                   (New)

Models/
├── RecognizedNumber.swift               (New)

Tests/UnitTests/Utilities/
├── NumberParserTests.swift              (New)

Tests/IntegrationTests/
├── NumberExtractionIntegrationTests.swift (New)
```

#### 5.7 Acceptance Criteria

**Functional Acceptance**:
- [ ] Correctly parses integers (1000)
- [ ] Correctly parses numbers with commas (1,000)
- [ ] Correctly parses decimals (99.99)
- [ ] Correctly parses mixed format (12,345.67)
- [ ] Extracts numbers from mixed text ("¥1,000" → 1000)
- [ ] Ignores non-numeric text ("日本製")
- [ ] Debug overlay shows parsed numbers
- [ ] Original text preserved for debugging

**Test Acceptance**:
- [ ] All unit tests pass (100%)
- [ ] Test coverage >85% for parsing logic
- [ ] Integration tests pass
- [ ] No false positives in number extraction

**Manual Verification Steps**:
1. Point camera at price tag "¥1,000"
2. Verify debug shows: Original "¥1,000", Value 1000
3. Test with various formats:
   - "100" → 100
   - "1,234" → 1234
   - "99.99" → 99.99
   - "12,345.67" → 12345.67
4. Test with mixed text:
   - "Price: $100" → 100
   - "¥500 日本製" → 500
5. Verify non-numbers ignored:
   - "Special Offer" → (empty)
   - "日本製" → (empty)

**Test Cases Coverage**:
| Input | Expected Output | Status |
|-------|----------------|--------|
| "1000" | 1000 | [ ] |
| "1,000" | 1000 | [ ] |
| "99.99" | 99.99 | [ ] |
| "12,345.67" | 12345.67 | [ ] |
| "¥1,000" | 1000 | [ ] |
| "ABC123" | 123 | [ ] |
| "日本製" | nil | [ ] |

---

### Stage 6: Currency Conversion Calculation
**Goal**: Convert recognized numbers to TWD using exchange rate

**Duration**: 1 hour

#### 6.1 Functional Requirements
1. Read exchange rate from settings
2. Calculate TWD equivalent using Decimal (avoid floating-point errors)
3. Format output with thousand separators
4. Support decimal precision (2 places)
5. Handle very small and very large amounts
6. Display formatted results in debug UI

#### 6.2 Data Models

```swift
// Models/ConvertedNumber.swift
struct ConvertedNumber: Identifiable {
    let id = UUID()
    let originalValue: Decimal
    let convertedValue: Decimal
    let formattedOriginal: String
    let formattedConverted: String
    let boundingBox: CGRect
    let timestamp: Date
}
```

#### 6.3 TDD Test Cases

**Test 1: CurrencyConverter Tests**
```swift
// Tests/UnitTests/Services/CurrencyConverterTests.swift
import XCTest
@testable import CurrencyConverterCamera

class CurrencyConverterTests: XCTestCase {
    
    var converter: CurrencyConverter!
    
    override func setUp() {
        super.setUp()
        converter = CurrencyConverter(exchangeRate: 0.2)
    }
    
    func testConvertSimpleAmount() {
        // Given
        let amount: Decimal = 1000
        
        // When
        let result = converter.convert(amount)
        
        // Then
        XCTAssertEqual(result, 200)
    }
    
    func testConvertDecimalAmount() {
        // Given
        let amount: Decimal = 1000.50
        
        // When
        let result = converter.convert(amount)
        
        // Then
        XCTAssertEqual(result, 200.1)
    }
    
    func testConvertSmallAmount() {
        // Given
        let amount: Decimal = 0.5
        
        // When
        let result = converter.convert(amount)
        
        // Then
        XCTAssertEqual(result, 0.1)
    }
    
    func testConvertLargeAmount() {
        // Given
        let amount: Decimal = 999999
        
        // When
        let result = converter.convert(amount)
        
        // Then
        XCTAssertEqual(result, 199999.8)
    }
    
    func testConvertZero() {
        // Given
        let amount: Decimal = 0
        
        // When
        let result = converter.convert(amount)
        
        // Then
        XCTAssertEqual(result, 0)
    }
    
    func testNoFloatingPointError() {
        // Given
        let amount: Decimal = 0.1
        converter = CurrencyConverter(exchangeRate: 0.3)
        
        // When
        let result = converter.convert(amount)
        
        // Then
        // Using Decimal should give exact result
        XCTAssertEqual(result, 0.03)
    }
    
    func testDifferentExchangeRates() {
        // Given
        let amount: Decimal = 100
        let rates: [Decimal] = [0.2, 0.5, 1.0, 30.0, 0.001]
        
        for rate in rates {
            // When
            converter = CurrencyConverter(exchangeRate: rate)
            let result = converter.convert(amount)
            
            // Then
            XCTAssertEqual(result, amount * rate, "Failed for rate: \(rate)")
        }
    }
}
```

**Test 2: CurrencyFormatter Tests**
```swift
// Tests/UnitTests/Utilities/CurrencyFormatterTests.swift
import XCTest
@testable import CurrencyConverterCamera

class CurrencyFormatterTests: XCTestCase {
    
    var formatter: CurrencyFormatter!
    
    override func setUp() {
        super.setUp()
        formatter = CurrencyFormatter()
    }
    
    func testFormatInteger() {
        // Given
        let amount: Decimal = 200
        
        // When
        let result = formatter.format(amount)
        
        // Then
        XCTAssertEqual(result, "NT$ 200")
    }
    
    func testFormatWithThousandsSeparator() {
        // Given
        let amount: Decimal = 12345
        
        // When
        let result = formatter.format(amount)
        
        // Then
        XCTAssertEqual(result, "NT$ 12,345")
    }
    
    func testFormatWithDecimal() {
        // Given
        let amount: Decimal = 1234.56
        
        // When
        let result = formatter.format(amount)
        
        // Then
        XCTAssertEqual(result, "NT$ 1,234.56")
    }
    
    func testFormatSmallDecimal() {
        // Given
        let amount: Decimal = 0.5
        
        // When
        let result = formatter.format(amount)
        
        // Then
        XCTAssertEqual(result, "NT$ 0.50")
    }
    
    func testFormatZero() {
        // Given
        let amount: Decimal = 0
        
        // When
        let result = formatter.format(amount)
        
        // Then
        XCTAssertEqual(result, "NT$ 0")
    }
    
    func testFormatLargeNumber() {
        // Given
        let amount: Decimal = 1234567.89
        
        // When
        let result = formatter.format(amount)
        
        // Then
        XCTAssertEqual(result, "NT$ 1,234,567.89")
    }
    
    func testFormatRoundsToTwoDecimalPlaces() {
        // Given
        let amount: Decimal = 123.456789
        
        // When
        let result = formatter.format(amount)
        
        // Then
        XCTAssertEqual(result, "NT$ 123.46") // Rounded
    }
    
    func testFormatNegativeNumber() {
        // Given
        let amount: Decimal = -100
        
        // When
        let result = formatter.format(amount)
        
        // Then
        XCTAssertEqual(result, "NT$ -100")
    }
}
```

**Test 3: Integration Tests**
```swift
// Tests/UnitTests/ViewModels/CameraViewModelTests.swift (additions)

func testConvertRecognizedNumbers() {
    // Given
    viewModel.settings = CurrencySettings(currencyName: "JPY", exchangeRate: 0.2)
    let recognizedNumbers = [
        RecognizedNumber(
            value: 1000,
            originalText: "¥1000",
            boundingBox: .zero,
            confidence: 0.9,
            timestamp: Date()
        ),
        RecognizedNumber(
            value: 500,
            originalText: "¥500",
            boundingBox: .zero,
            confidence: 0.95,
            timestamp: Date()
        )
    ]
    
    // When
    let converted = viewModel.convertNumbers(recognizedNumbers)
    
    // Then
    XCTAssertEqual(converted.count, 2)
    XCTAssertEqual(converted[0].convertedValue, 200)
    XCTAssertEqual(converted[1].convertedValue, 100)
}

func testConvertedNumbersFormatted() {
    // Given
    viewModel.settings = CurrencySettings(currencyName: "JPY", exchangeRate: 0.2)
    let recognizedNumbers = [
        RecognizedNumber(
            value: 12345.67,
            originalText: "¥12,345.67",
            boundingBox: .zero,
            confidence: 0.9,
            timestamp: Date()
        )
    ]
    
    // When
    let converted = viewModel.convertNumbers(recognizedNumbers)
    
    // Then
    XCTAssertEqual(converted.first?.formattedConverted, "NT$ 2,469.13")
}
```

#### 6.4 Technical Implementation

**CurrencyConverter Service**:
```swift
// Services/CurrencyConverter.swift
class CurrencyConverter {
    let exchangeRate: Decimal
    
    init(exchangeRate: Decimal) {
        self.exchangeRate = exchangeRate
    }
    
    /// Convert foreign currency to TWD
    func convert(_ amount: Decimal) -> Decimal {
        return amount * exchangeRate
    }
    
    /// Convert with rounding to 2 decimal places
    func convertAndRound(_ amount: Decimal) -> Decimal {
        let result = amount * exchangeRate
        let rounded = (result * 100).rounded() / 100
        return rounded
    }
}
```

**CurrencyFormatter Utility**:
```swift
// Utilities/CurrencyFormatter.swift
class CurrencyFormatter {
    private let numberFormatter: NumberFormatter
    
    init() {
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.groupingSeparator = ","
        numberFormatter.decimalSeparator = "."
    }
    
    /// Format amount as TWD string
    func format(_ amount: Decimal) -> String {
        let nsNumber = NSDecimalNumber(decimal: amount)
        let formatted = numberFormatter.string(from: nsNumber) ?? "0"
        return "NT$ \(formatted)"
    }
    
    /// Format as foreign currency
    func formatForeign(_ amount: Decimal, currencySymbol: String = "¥") -> String {
        let nsNumber = NSDecimalNumber(decimal: amount)
        let formatted = numberFormatter.string(from: nsNumber) ?? "0"
        return "\(currencySymbol) \(formatted)"
    }
}
```

#### 6.5 Debug UI Update

Update debug overlay to show conversion results:
```swift
struct DebugOverlay: View {
    let convertedNumbers: [ConvertedNumber]
    let currencyName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("💱 Conversion Results:")
                .font(.headline)
            
            if convertedNumbers.isEmpty {
                Text("No numbers to convert")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ForEach(convertedNumbers) { number in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(currencyName) \(number.formattedOriginal)")
                            .font(.body)
                            .foregroundColor(.white)
                        
                        HStack {
                            Text("→")
                            Text(number.formattedConverted)
                                .font(.body)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.vertical, 4)
                    Divider()
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .foregroundColor(.white)
        .frame(maxHeight: 250)
    }
}
```

#### 6.6 Implementation Files
```
Services/
├── CurrencyConverter.swift              (New)

Utilities/
├── CurrencyFormatter.swift              (New)

Models/
├── ConvertedNumber.swift                (New)

Tests/UnitTests/Services/
├── CurrencyConverterTests.swift         (New)

Tests/UnitTests/Utilities/
├── CurrencyFormatterTests.swift         (New)
```

#### 6.7 Acceptance Criteria

**Functional Acceptance**:
- [ ] Correctly calculates conversion (1000 × 0.2 = 200)
- [ ] Supports decimal calculations (1000.50 × 0.2 = 200.1)
- [ ] Formats with thousand separators (12,345)
- [ ] Formats with decimal places (1,234.56)
- [ ] No floating-point errors (uses Decimal)
- [ ] Debug overlay shows conversion results
- [ ] Displays both original and converted amounts

**Test Acceptance**:
- [ ] All unit tests pass (100%)
- [ ] Test coverage >90% for conversion logic
- [ ] Integration tests pass
- [ ] Manual calculation verification matches

**Manual Verification Steps**:
1. Set exchange rate to 0.2 (JPY)
2. Point camera at "¥1000"
3. Verify debug shows:
   - Original: "¥ 1,000"
   - Converted: "NT$ 200"
4. Test various amounts:
   - ¥100 → NT$ 20
   - ¥500 → NT$ 100
   - ¥12,345.67 → NT$ 2,469.13
5. Verify calculations with calculator app

**Calculation Verification**:
| Original | Rate | Expected TWD | Actual | Status |
|----------|------|--------------|--------|--------|
| ¥1,000 | 0.2 | NT$ 200 | [ ] | [ ] |
| ¥500 | 0.2 | NT$ 100 | [ ] | [ ] |
| ¥12,345.67 | 0.2 | NT$ 2,469.13 | [ ] | [ ] |
| ¥99.99 | 0.2 | NT$ 20.00 | [ ] | [ ] |

---

### Stage 7: Real-time Overlay Display (Final Stage)
**Goal**: Display converted TWD amounts overlaid on camera view

**Duration**: 3 hours

#### 7.1 Functional Requirements
1. Display overlays at correct positions (matching detected numbers)
2. Semi-transparent background with white text
3. Anti-flicker mechanism (3-frame confirmation)
4. Support multiple simultaneous overlays (max 10)
5. Auto-fade when number no longer detected (1 second timeout)
6. Remove all debug UI elements
7. Production-ready polish

#### 7.2 Data Models

```swift
// Models/OverlayData.swift
struct OverlayData: Identifiable {
    let id = UUID()
    let text: String
    let frame: CGRect  // Screen coordinates
    let timestamp: Date
    
    var isExpired: Bool {
        Date().timeIntervalSince(timestamp) > 1.0
    }
}
```

#### 7.3 TDD Test Cases

**Test 1: CoordinateConverter Tests**
```swift
// Tests/UnitTests/Utilities/CoordinateConverterTests.swift
import XCTest
@testable import CurrencyConverterCamera

class CoordinateConverterTests: XCTestCase {
    
    var converter: CoordinateConverter!
    let viewSize = CGSize(width: 375, height: 667)
    
    override func setUp() {
        super.setUp()
        converter = CoordinateConverter(viewSize: viewSize)
    }
    
    func testConvertVisionToScreen_Center() {
        // Given (Vision coordinates: origin at bottom-left)
        let visionRect = CGRect(x: 0.5, y: 0.5, width: 0.2, height: 0.1)
        
        // When
        let screenRect = converter.convertToScreen(visionRect)
        
        // Then
        // Center of screen should be around (187.5, 333.5)
        XCTAssertTrue(screenRect.midX > 150 && screenRect.midX < 250)
        XCTAssertTrue(screenRect.midY > 250 && screenRect.midY < 450)
    }
    
    func testConvertVisionToScreen_TopLeft() {
        // Given
        let visionRect = CGRect(x: 0, y: 1, width: 0.1, height: 0.1)
        
        // When
        let screenRect = converter.convertToScreen(visionRect)
        
        // Then
        // Top-left in screen coordinates
        XCTAssertEqual(screenRect.origin.x, 0, accuracy: 1)
        XCTAssertLessThan(screenRect.origin.y, 100)
    }
    
    func testConvertVisionToScreen_BottomRight() {
        // Given
        let visionRect = CGRect(x: 0.9, y: 0, width: 0.1, height: 0.1)
        
        // When
        let screenRect = converter.convertToScreen(visionRect)
        
        // Then
        // Bottom-right in screen coordinates
        XCTAssertGreaterThan(screenRect.origin.x, 300)
        XCTAssertGreaterThan(screenRect.origin.y, 550)
    }
    
    func testDimensionsScaledCorrectly() {
        // Given
        let visionRect = CGRect(x: 0.5, y: 0.5, width: 0.2, height: 0.1)
        
        // When
        let screenRect = converter.convertToScreen(visionRect)
        
        // Then
        XCTAssertEqual(screenRect.width, viewSize.width * 0.2, accuracy: 1)
        XCTAssertEqual(screenRect.height, viewSize.height * 0.1, accuracy: 1)
    }
}
```

**Test 2: StabilizationBuffer Tests**
```swift
// Tests/UnitTests/Utilities/StabilizationBufferTests.swift
import XCTest
@testable import CurrencyConverterCamera

class StabilizationBufferTests: XCTestCase {
    
    var buffer: StabilizationBuffer!
    
    override func setUp() {
        super.setUp()
        buffer = StabilizationBuffer(requiredFrames: 3)
    }
    
    func testStabilization_NotEnoughFrames() {
        // Given
        let number = createMockNumber(value: 1000)
        
        // When
        buffer.add(number)
        buffer.add(number)
        let isStable = buffer.isStable(number)
        
        // Then
        XCTAssertFalse(isStable, "Only 2 frames, should not be stable")
    }
    
    func testStabilization_EnoughFrames() {
        // Given
        let number = createMockNumber(value: 1000)
        
        // When
        buffer.add(number)
        buffer.add(number)
        buffer.add(number)
        let isStable = buffer.isStable(number)
        
        // Then
        XCTAssertTrue(isStable, "3 frames, should be stable")
    }
    
    func testStabilization_DifferentValues() {
        // Given
        let number1 = createMockNumber(value: 1000)
        let number2 = createMockNumber(value: 2000)
        
        // When
        buffer.add(number1)
        buffer.add(number2)
        buffer.add(number1)
        let isStable = buffer.isStable(number1)
        
        // Then
        XCTAssertFalse(isStable, "Values inconsistent, should not be stable")
    }
    
    func testStabilization_SimilarValues() {
        // Given (1% tolerance)
        let number1 = createMockNumber(value: 1000)
        let number2 = createMockNumber(value: 1005) // 0.5% difference
        
        // When
        buffer.add(number1)
        buffer.add(number2)
        buffer.add(number1)
        let isStable = buffer.isStable(number1)
        
        // Then
        XCTAssertTrue(isStable, "Values within tolerance, should be stable")
    }
    
    func testCleanupOldEntries() {
        // Given
        let number = createMockNumber(value: 1000)
        buffer.add(number)
        
        // When
        Thread.sleep(forTimeInterval: 1.5) // Wait 1.5 seconds
        buffer.cleanup()
        
        // Then
        XCTAssertFalse(buffer.contains(number), "Old entry should be removed")
    }
    
    func testMultipleNumbersTrackedSeparately() {
        // Given
        let number1 = createMockNumber(value: 1000, position: CGRect(x: 0.3, y: 0.5, width: 0.1, height: 0.05))
        let number2 = createMockNumber(value: 500, position: CGRect(x: 0.7, y: 0.3, width: 0.1, height: 0.05))
        
        // When
        buffer.add(number1)
        buffer.add(number1)
        buffer.add(number1)
        buffer.add(number2)
        buffer.add(number2)
        
        // Then
        XCTAssertTrue(buffer.isStable(number1), "Number 1 should be stable")
        XCTAssertFalse(buffer.isStable(number2), "Number 2 should not be stable yet")
    }
    
    // Helper
    private func createMockNumber(value: Decimal, position: CGRect = .zero) -> RecognizedNumber {
        RecognizedNumber(
            value: value,
            originalText: "\(value)",
            boundingBox: position,
            confidence: 0.9,
            timestamp: Date()
        )
    }
}
```

**Test 3: Overlay Generation Tests**
```swift
// Tests/UnitTests/ViewModels/CameraViewModelTests.swift (additions)

func testGenerateOverlays() {
    // Given
    viewModel.settings = CurrencySettings(currencyName: "JPY", exchangeRate: 0.2)
    let stableNumbers = [
        RecognizedNumber(
            value: 1000,
            originalText: "¥1000",
            boundingBox: CGRect(x: 0.3, y: 0.5, width: 0.2, height: 0.1),
            confidence: 0.9,
            timestamp: Date()
        ),
        RecognizedNumber(
            value: 500,
            originalText: "¥500",
            boundingBox: CGRect(x: 0.6, y: 0.3, width: 0.15, height: 0.08),
            confidence: 0.95,
            timestamp: Date()
        )
    ]
    
    // When
    let overlays = viewModel.generateOverlays(from: stableNumbers)
    
    // Then
    XCTAssertEqual(overlays.count, 2)
    XCTAssertEqual(overlays[0].text, "NT$ 200")
    XCTAssertEqual(overlays[1].text, "NT$ 100")
}

func testOverlayExpiration() {
    // Given
    let overlay = OverlayData(
        text: "NT$ 200",
        frame: .zero,
        timestamp: Date().addingTimeInterval(-2.0) // 2 seconds ago
    )
    
    // When
    let isExpired = overlay.isExpired
    
    // Then
    XCTAssertTrue(isExpired, "Overlay should expire after 1 second")
}

func testMaximumOverlays() {
    // Given
    viewModel.settings = CurrencySettings(currencyName: "JPY", exchangeRate: 0.2)
    var numbers: [RecognizedNumber] = []
    for i in 0..<15 {
        numbers.append(RecognizedNumber(
            value: Decimal(i * 100),
            originalText: "\(i * 100)",
            boundingBox: CGRect(x: 0.1 * Double(i), y: 0.1, width: 0.1, height: 0.05),
            confidence: 0.9,
            timestamp: Date()
        ))
    }
    
    // When
    let overlays = viewModel.generateOverlays(from: numbers)
    
    // Then
    XCTAssertLessThanOrEqual(overlays.count, 10, "Should limit to 10 overlays")
}
```

#### 7.4 Technical Implementation

**CoordinateConverter Utility**:
```swift
// Utilities/CoordinateConverter.swift
class CoordinateConverter {
    let viewSize: CGSize
    
    init(viewSize: CGSize) {
        self.viewSize = viewSize
    }
    
    /// Convert Vision coordinates (origin bottom-left) to UIKit coordinates (origin top-left)
    func convertToScreen(_ visionRect: CGRect) -> CGRect {
        let x = visionRect.origin.x * viewSize.width
        let y = (1 - visionRect.origin.y - visionRect.height) * viewSize.height
        let width = visionRect.width * viewSize.width
        let height = visionRect.height * viewSize.height
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
```

**StabilizationBuffer Implementation**:
```swift
// Utilities/StabilizationBuffer.swift
class StabilizationBuffer {
    private var buffer: [UUID: [RecognizedNumber]] = [:]
    private let requiredFrames: Int
    private let valueTolerance: Decimal = 0.01 // 1%
    private let positionTolerance: CGFloat = 0.1 // 10% of screen
    
    init(requiredFrames: Int = 3) {
        self.requiredFrames = requiredFrames
    }
    
    func add(_ number: RecognizedNumber) {
        let key = findSimilarKey(for: number) ?? number.id
        
        if buffer[key] == nil {
            buffer[key] = []
        }
        buffer[key]?.append(number)
        
        // Keep only recent frames
        if buffer[key]!.count > requiredFrames {
            buffer[key]?.removeFirst()
        }
    }
    
    func isStable(_ number: RecognizedNumber) -> Bool {
        guard let key = findSimilarKey(for: number),
              let entries = buffer[key] else {
            return false
        }
        
        return entries.count >= requiredFrames
    }
    
    func getStableNumbers() -> [RecognizedNumber] {
        return buffer.compactMap { _, entries in
            entries.count >= requiredFrames ? entries.last : nil
        }
    }
    
    func cleanup() {
        let now = Date()
        buffer = buffer.filter { _, entries in
            guard let lastEntry = entries.last else { return false }
            return now.timeIntervalSince(lastEntry.timestamp) < 1.0
        }
    }
    
    func contains(_ number: RecognizedNumber) -> Bool {
        return findSimilarKey(for: number) != nil
    }
    
    private func findSimilarKey(for number: RecognizedNumber) -> UUID? {
        for (key, entries) in buffer {
            guard let last = entries.last else { continue }
            
            // Check value similarity
            let valueDiff = abs(last.value - number.value) / max(last.value, number.value)
            if valueDiff > valueTolerance { continue }
            
            // Check position similarity
            let centerDistance = distance(last.boundingBox.center, number.boundingBox.center)
            if centerDistance > positionTolerance { continue }
            
            return key
        }
        return nil
    }
    
    private func distance(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        let dx = p1.x - p2.x
        let dy = p1.y - p2.y
        return sqrt(dx*dx + dy*dy)
    }
}

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}
```

**OverlayView Component**:
```swift
// Views/Components/OverlayView.swift
struct OverlayView: View {
    let text: String
    let frame: CGRect
    @State private var opacity: Double = 0
    
    var body: some View {
        Text(text)
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.75))
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
            )
            .position(x: frame.midX, y: frame.midY)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.2)) {
                    opacity = 1
                }
            }
    }
}
```

**CameraView Final Implementation**:
```swift
// Views/CameraView.swift
struct CameraView: View {
    @StateObject var viewModel: CameraViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Camera Preview
                if let session = viewModel.cameraService.captureSession {
                    CameraPreviewRepresentable(session: session)
                        .edgesIgnoringSafeArea(.all)
                }
                
                // Overlays
                ForEach(viewModel.overlays) { overlay in
                    OverlayView(text: overlay.text, frame: overlay.frame)
                }
                
                // Permission Alert
                if viewModel.showPermissionAlert {
                    PermissionAlertView(
                        message: viewModel.alertMessage,
                        onOpenSettings: {
                            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(settingsUrl)
                            }
                        },
                        onDismiss: {
                            dismiss()
                        }
                    )
                }
            }
            .onAppear {
                viewModel.viewSize = geometry.size
                viewModel.startCamera()
            }
            .onDisappear {
                viewModel.stopCamera()
            }
        }
        .navigationTitle("\(viewModel.settings.currencyName) → TWD")
        .navigationBarTitleDisplayMode(.inline)
    }
}
```

#### 7.5 Implementation Files
```
Utilities/
├── CoordinateConverter.swift            (New)
├── StabilizationBuffer.swift            (New)

Views/Components/
├── OverlayView.swift                    (New)
├── PermissionAlertView.swift            (New)

Models/
├── OverlayData.swift                    (New)

Tests/UnitTests/Utilities/
├── CoordinateConverterTests.swift       (New)
├── StabilizationBufferTests.swift       (New)
```

#### 7.6 Final UI Design

```
┌─────────────────────────────────┐
│ ← JPY → TWD                     │  <- Navigation Bar
├─────────────────────────────────┤
│                                 │
│      📷 Camera Preview          │
│                                 │
│         ¥1000                   │
│        ┌─────────┐               │
│        │NT$ 200  │  ← Overlay   │
│        └─────────┘               │
│                                 │
│    ¥500                         │
│   ┌────────┐                    │
│   │NT$ 100 │                    │
│   └────────┘                    │
│                                 │
└─────────────────────────────────┘
```

#### 7.7 Acceptance Criteria

**Functional Acceptance**:
- [ ] Overlays display at correct positions
- [ ] Overlay styling matches design (semi-transparent, white text)
- [ ] No flickering (stabilization working)
- [ ] Multiple overlays supported (max 10)
- [ ] Overlays fade out when number disappears
- [ ] All debug UI removed
- [ ] Smooth 30fps camera preview
- [ ] Production-ready polish

**Test Acceptance**:
- [ ] All unit tests pass (100%)
- [ ] Integration tests pass
- [ ] Overall test coverage >75%
- [ ] Performance metrics met

**Manual Verification Steps**:
1. Complete full flow:
   - Launch app
   - Enter JPY, 0.2
   - Navigate to camera
   - Point at price "¥1000"
   - Verify overlay shows "NT$ 200"
2. Test multiple prices simultaneously
3. Test rapid camera movement
4. Test low-light conditions
5. Test various price formats
6. Verify smooth performance

**Complete User Flow Test**:
| Step | Action | Expected Result | Status |
|------|--------|----------------|--------|
| 1 | Launch app | Settings page shows | [ ] |
| 2 | Enter "日幣", "0.2" | Button enabled | [ ] |
| 3 | Tap "Start Scan" | Navigate to camera | [ ] |
| 4 | Grant permission | Camera preview shows | [ ] |
| 5 | Point at "¥1000" | Overlay "NT$ 200" | [ ] |
| 6 | Move to "¥500" | Overlay "NT$ 100" | [ ] |
| 7 | Multiple prices | Both overlays show | [ ] |
| 8 | Move away | Overlays fade out | [ ] |
| 9 | Return to settings | Settings retained | [ ] |
| 10 | Force quit & reopen | Settings still saved | [ ] |

**Performance Verification**:
| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Frame Rate | 30 FPS | [ ] | [ ] |
| Recognition FPS | 5-8 | [ ] | [ ] |
| CPU Usage | <40% | [ ] | [ ] |
| Memory | <150MB | [ ] | [ ] |
| Battery (1hr) | <15% | [ ] | [ ] |
| Latency | <500ms | [ ] | [ ] |

---

## 4. Quality Assurance & Testing

### 4.1 Test Coverage Requirements
- **Overall Coverage**: >75%
- **Critical Paths**: 100%
  - Currency conversion calculation
  - Number parsing
  - Coordinate transformation
  - Data persistence

### 4.2 Testing Strategy
```
Unit Tests (70%)
├── Models
├── ViewModels
├── Services
└── Utilities

Integration Tests (20%)
├── Service-to-Service
├── ViewModel-to-Service
└── End-to-End Pipelines

UI Tests (10%)
├── Navigation Flows
├── User Interactions
└── Permission Handling
```

### 4.3 Performance Testing
- Profile with Instruments (Leaks, Time Profiler)
- Test on minimum spec device (iPhone SE 2nd gen)
- Monitor battery usage over 30 minutes
- Stress test with 10 simultaneous overlays

### 4.4 Device Testing Matrix
| Device | iOS | Res | Camera | Status |
|--------|-----|-----|--------|--------|
| iPhone SE 2 | 15.0 | 750×1334 | Required | [ ] |
| iPhone 12 | 16.0 | 1170×2532 | Required | [ ] |
| iPhone 15 Pro | 17.0 | 1179×2556 | Required | [ ] |

---

## 5. Technical Constraints & Requirements

### 5.1 Development Environment
- macOS 14.0+
- Xcode 15.0+
- Swift 5.9+
- SwiftUI 4.0+

### 5.2 Dependencies
- **System Frameworks Only**:
  - SwiftUI
  - UIKit (for camera)
  - AVFoundation
  - Vision
  - Combine

### 5.3 Architecture Patterns
- **MVVM** for view layer
- **Service Layer** for business logic
- **Repository Pattern** for data persistence
- **Delegate Pattern** for camera callbacks

### 5.4 Code Quality Standards
- SwiftLint configuration
- Documentation for public APIs
- Meaningful variable names
- Maximum function length: 50 lines
- Maximum file length: 400 lines

---

## 6. Risk Management

### 6.1 Technical Risks
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Vision accuracy low | Medium | High | Implement manual adjustment mode |
| Battery drain high | Medium | High | Aggressive throttling, pause feature |
| Permission denied | Low | Medium | Clear rationale, settings link |
| Performance issues | Medium | High | Target older devices, optimize early |

### 6.2 Schedule Risks
| Risk | Mitigation |
|------|------------|
| Stage takes longer | Pause and reassess, adjust timeline |
| Bug discovered late | Comprehensive testing at each stage |
| Scope creep | Strict adherence to stage requirements |

---

## 7. Success Criteria & Completion Checklist

### 7.1 Technical Success
- [ ] All stages completed
- [ ] All tests pass (green)
- [ ] Test coverage >75%
- [ ] No memory leaks
- [ ] Performance targets met
- [ ] Works on all tested devices

### 7.2 Functional Success
- [ ] User can input exchange rate
- [ ] Settings persist across launches
- [ ] Camera shows live preview
- [ ] Numbers are recognized accurately (>85%)
- [ ] Overlays display correctly
- [ ] Conversion calculations accurate
- [ ] Smooth user experience (30fps)

### 7.3 Production Readiness
- [ ] No critical or high bugs
- [ ] Error handling comprehensive
- [ ] Permission flows polished
- [ ] UI matches design specs
- [ ] Code documented
- [ ] Git history clean (atomic commits)

---

## 8. Timeline Summary

| Stage | Duration | Cumulative |
|-------|----------|------------|
| Stage 0 | 15 min | 15 min |
| Stage 1 | 1.5 hrs | 1h 45m |
| Stage 2 | 30 min | 2h 15m |
| Stage 3 | 2 hrs | 4h 15m |
| Stage 4 | 2.5 hrs | 6h 45m |
| Stage 5 | 1.5 hrs | 8h 15m |
| Stage 6 | 1 hr | 9h 15m |
| Stage 7 | 3 hrs | **12h 15m** |

**Total Estimated Time**: 12-15 hours (7-10 work sessions)

---

## 9. Appendix

### 9.1 Number Format Support
**Phase 1 (Current)**:
- ✅ 100
- ✅ 1,000
- ✅ 1,000.50
- ✅ 0.99
- ✅ 12345

**Not Supported (Future)**:
- ❌ 1.000,50 (European format)
- ❌ ¥1000 (currency symbols mixed with numbers)
- ❌ 一千 (Chinese characters)

### 9.2 Glossary
- **TDD**: Test-Driven Development
- **MVVM**: Model-View-ViewModel
- **OCR**: Optical Character Recognition
- **FPS**: Frames Per Second
- **TWD**: Taiwan Dollar (New Taiwan Dollar)
- **Vision**: Apple's computer vision framework
- **AVFoundation**: Apple's audiovisual framework

### 9.3 References
- [Apple Vision Framework](https://developer.apple.com/documentation/vision)
- [AVFoundation Guide](https://developer.apple.com/documentation/avfoundation)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [TDD Best Practices](https://www.swiftbysundell.com/articles/test-driven-development-in-swift/)

---

## Document Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-12-02 | Initial specification with 7 TDD stages |

---

**END OF SPECIFICATION**
