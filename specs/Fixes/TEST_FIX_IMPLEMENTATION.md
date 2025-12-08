# 測試修復實施方案

## 問題分析

根據測試錯誤,我發現以下問題:

### 1. SettingsViewModel 驗證測試失敗 (8 個)
**根本原因**: SettingsViewModel 使用了 `debounce(for: .milliseconds(300))`,驗證是異步執行的,但測試是同步檢查結果。

**不合理的測試**: 
- 這些測試設計不合理,因為它們沒有考慮 debounce 的異步特性
- 在實際 UI 中,debounce 是正確的做法,可以避免用戶輸入時頻繁驗證

**解決方案**: 
1. **選項 A (推薦)**: 修改 SettingsViewModel,添加同步驗證方法供測試使用
2. **選項 B**: 刪除這些測試,因為 debounce 驗證應該通過 UI 測試來驗證
3. **選項 C**: 修改測試,添加 expectation 等待異步完成

### 2. Camera/Vision 服務連接丟失 (4 個)
**根本原因**: 這些測試需要實際的相機硬體,在模擬器上無法執行。

**不合理的測試**: 
- `testRecognitionReturnsArray` - 需要實際影像輸入
- `testRecognizeTextFromPixelBuffer` - 需要實際 pixel buffer
- `testHistoryPersistAcrossInstances` - testmanagerd 連接問題
- `testSettingsPersistAcrossInstances` - testmanagerd 連接問題

**解決方案**: 
- 這些測試應該被標記為僅在真機上執行,或者完全刪除
- 使用 `#if targetEnvironment(simulator)` 跳過

### 3. Camera Session 測試失敗 (2 個)
**根本原因**: 模擬器上沒有真實的相機輸入/輸出。

**不合理的測試**:
- `testSessionHasVideoInput` - 模擬器無法創建 AVCaptureDeviceInput
- `testSessionHasVideoOutput` - 測試意義不大,只是檢查初始化

**解決方案**: 
- 刪除或跳過這些測試

### 4. History 相關測試 (3 個)
**可能合理的測試**:
- `testHistoryWithDifferentCurrencies` - 可能是測試邏輯錯誤
- `testHistoryRetentionPolicy` - 值錯誤 (54 vs 4),可能是測試或實現問題
- `testConcurrentRecordAddition` - 並發問題 (1 vs 10)

**需要查看具體實現再判斷**

### 5. 其他測試
- `testFormattedOriginalPriceDisplay` - 可能合理,需要修復格式化邏輯
- `testSaveCurrencySettingsUpdatesTimestamp` - 可能合理,需要確保時間戳更新
- `testTextRecognitionPerformance` - 被取消,可能超時,應該刪除或簡化

---

## 修復計劃

### 階段 1: 刪除不合理的測試

#### A. 刪除模擬器無法運行的測試
```swift
// CameraServiceTests.swift - 刪除以下測試:
- testSessionHasVideoInput()
- testSessionHasVideoOutput()

// VisionServiceTests.swift - 刪除以下測試:
- testRecognitionReturnsArray()
- testRecognizeTextFromPixelBuffer()
- testTextRecognitionPerformance()

// StorageServiceTests.swift - 刪除以下測試 (如果是 testmanagerd 問題):
- testHistoryPersistAcrossInstances()
- testSettingsPersistAcrossInstances()
```

#### B. 修改 SettingsViewModelTests.swift
```swift
// 選項 1: 添加輔助方法強制立即驗證
extension SettingsViewModel {
    func validateNow() {
        validateInput()
    }
}

// 選項 2: 在測試中等待 debounce
func testEmptyCurrencyName() {
    viewModel.currencyName = ""
    
    let expectation = self.expectation(description: "Validation completes")
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
        expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1.0)
    
    XCTAssertEqual(viewModel.validationError, .emptyCurrencyName)
}

// 選項 3 (推薦): 重構 SettingsViewModel,分離驗證邏輯
```

### 階段 2: 修復可能合理的測試

詳細修復方案將在查看實際測試代碼後提供。

---

## 建議: 測試重構方案

### 問題 1: Debounce 導致測試不穩定

**建議**: 將驗證邏輯提取為純函數,單獨測試:

```swift
// SettingsViewModel.swift
struct SettingsValidator {
    static func validateCurrencyName(_ name: String) -> ValidationError? {
        if name.isEmpty {
            return .emptyCurrencyName
        }
        if name.count > Constants.maxCurrencyNameLength {
            return .currencyNameTooLong
        }
        if !name.allSatisfy({ $0.isLetter }) {
            return .invalidCurrencyFormat
        }
        return nil
    }
    
    static func validateExchangeRate(_ rateText: String) -> ValidationError? {
        // ... 驗證邏輯
    }
}

class SettingsViewModel: ObservableObject {
    private func validateInput() {
        validationError = SettingsValidator.validateCurrencyName(currencyName)
            ?? SettingsValidator.validateExchangeRate(exchangeRateText)
    }
}

// SettingsValidatorTests.swift (新文件)
class SettingsValidatorTests: XCTestCase {
    func testEmptyCurrencyName() {
        XCTAssertEqual(
            SettingsValidator.validateCurrencyName(""),
            .emptyCurrencyName
        )
    }
    // ... 所有驗證測試移到這裡
}
```

**優點**:
- 測試變成同步的,簡單可靠
- 驗證邏輯可重用
- ViewModel 測試可以 focus 在狀態管理和 UI 交互

### 問題 2: 硬體依賴測試

**建議**: 使用 Protocol-oriented design 和 Mock:

```swift
// CameraServiceProtocol.swift
protocol CameraServiceProtocol {
    var session: AVCaptureSession? { get }
    func startSession()
    func stopSession()
}

// MockCameraService.swift (測試用)
class MockCameraService: CameraServiceProtocol {
    var session: AVCaptureSession?
    var sessionStarted = false
    
    func startSession() {
        sessionStarted = true
    }
    
    func stopSession() {
        sessionStarted = false
    }
}

// CameraViewModel.swift
class CameraViewModel: ObservableObject {
    private let cameraService: CameraServiceProtocol
    
    init(cameraService: CameraServiceProtocol = CameraService()) {
        self.cameraService = cameraService
    }
}

// CameraViewModelTests.swift
func testStartCamera() {
    let mockCamera = MockCameraService()
    let viewModel = CameraViewModel(cameraService: mockCamera)
    
    viewModel.startCamera()
    
    XCTAssertTrue(mockCamera.sessionStarted)
}
```

---

## 立即執行方案

### 方案 A: 快速修復 (1-2 小時)

1. **刪除不合理的測試** (30 分鐘)
   - 刪除所有 Camera/Vision 硬體相關測試 (7 個)
   - 刪除 testmanagerd 連接失敗的測試 (2 個)
   - 總共刪除: 9 個測試

2. **修復 SettingsViewModel 測試** (30 分鐘)
   - 在每個測試中添加 0.4 秒等待
   - 或添加 `validateNow()` 方法

3. **修復其他測試** (30 分鐘)
   - History retention policy
   - Concurrent record addition
   - Formatted price display

**結果**: 剩餘 ~13 個測試,全部通過

### 方案 B: 完整重構 (3-4 小時)

1. **提取驗證邏輯為純函數** (1 小時)
2. **重寫 SettingsValidator 測試** (1 小時)
3. **實現 Protocol-oriented Camera 服務** (1 小時)
4. **修復其他合理測試** (1 小時)

**結果**: 更好的代碼架構,更可靠的測試

---

## 我的建議

**推薦方案**: 混合方案

1. **立即刪除** 9 個不合理的測試 (Camera/Vision 硬體依賴)
2. **快速修復** SettingsViewModel 測試 (添加等待)
3. **後續重構** (當有時間時)

這樣可以:
- ✅ 快速讓測試通過 (1 小時內)
- ✅ 保留合理的測試
- ✅ 為未來重構留下空間
- ✅ 不影響當前開發進度

---

## 下一步

你想要:
1. **方案 A**: 我幫你快速刪除不合理測試,修復剩下的 (1-2 小時)
2. **方案 B**: 完整重構測試架構 (3-4 小時)
3. **先看測試文件**: 我查看所有測試文件,給出更精確的分析

請告訴我你的選擇,我會立即執行。
