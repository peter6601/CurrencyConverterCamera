# Warning Fixes Summary

## 修正日期：2025-12-05

本文檔記錄了所有修正的編譯器警告。

---

## 修正的文件和警告

### 1. CameraViewModel.swift (2個警告)

#### 警告 1: 未使用的變數 `processingQueue`
**問題**: 宣告了 `processingQueue` 但從未使用
```swift
// 修正前
private var processingQueue = DispatchQueue(label: "com.currencyconvertercamera.processing", attributes: .concurrent)

// 修正後
// 移除未使用的變數
```

#### 警告 2: 不必要的複雜型別轉換
**問題**: 使用了複雜的閉包來轉換 confidence 值
```swift
// 修正前
confidence: {
    if let number = firstDetection.confidence as? NSNumber {
        return number.doubleValue
    } else if let decimal = firstDetection.confidence as? Decimal {
        return NSDecimalNumber(decimal: decimal).doubleValue
    } else if let doubleValue = firstDetection.confidence as? Double {
        return doubleValue
    } else {
        return 0.0
    }
}()

// 修正後
confidence: firstDetection.confidence  // 已經是 Double 類型
```

---

### 2. CurrencyConverterCameraApp.swift (2個警告)

#### 警告 1: 不必要的 do-catch 塊
**問題**: `loadCurrencySettings()` 不會拋出錯誤，但使用了 `try`
```swift
// 修正前
func loadCurrencySettings() {
    do {
        if let settings = try storageService.loadCurrencySettings() {
            // ...
        }
    } catch {
        // ...
    }
}

// 修正後
func loadCurrencySettings() {
    if let settings = storageService.loadCurrencySettings() {
        // ...
    }
}
```

#### 警告 2: 不必要的 try 關鍵字
**問題**: `loadConversionHistory()` 不會拋出錯誤
```swift
// 修正前
self.conversionHistory = try storageService.loadConversionHistory()

// 修正後
self.conversionHistory = storageService.loadConversionHistory()
```

---

### 3. SettingsViewModel.swift (1個警告)

#### 警告: 不必要的 do-catch 塊
**問題**: `loadCurrencySettings()` 不會拋出錯誤
```swift
// 修正前
func loadSettings() {
    do {
        if let settings = try storageService.loadCurrencySettings() {
            // ...
        }
    } catch {
        // ...
    }
}

// 修正後
func loadSettings() {
    if let settings = storageService.loadCurrencySettings() {
        // ...
    }
}
```

---

### 4. InitialSetupView.swift (3個警告)

#### 警告 1-2: 使用舊版 onChange API
**問題**: iOS 17+ 應該使用新的 onChange API（包含 oldValue 參數）
```swift
// 修正前
.onChange(of: currencyName) { newValue in
    // ...
}

// 修正後
.onChange(of: currencyName) { _, newValue in
    // ...
}
```

#### 警告 3: 強制解包
**問題**: 在 `isValid` 計算屬性中使用強制解包
```swift
// 修正前
var isValid: Bool {
    let rateValid = !exchangeRateText.isEmpty && 
                    Decimal(string: exchangeRateText) != nil && 
                    Decimal(string: exchangeRateText)! > 0  // 強制解包!
    return currencyValid && rateValid
}

// 修正後
var isValid: Bool {
    let currencyValid = !currencyName.isEmpty && 
                        currencyName.count <= 20 && 
                        currencyName.allSatisfy { $0.isLetter }
    guard let rate = Decimal(string: exchangeRateText) else {
        return false
    }
    let rateValid = !exchangeRateText.isEmpty && rate > 0
    return currencyValid && rateValid
}
```

---

### 5. CameraView.swift (1個警告)

#### 警告: 使用舊版 onChange API
```swift
// 修正前
.onChange(of: isConversionEnabled) { enabled in
    viewModel.isConversionEnabled = enabled
}

// 修正後
.onChange(of: isConversionEnabled) { _, enabled in
    viewModel.isConversionEnabled = enabled
}
```

---

### 6. StorageServiceTests.swift (約20個警告)

#### 警告類型 1: 不必要的 try 關鍵字
**問題**: `loadCurrencySettings()` 和 `loadConversionHistory()` 不會拋出錯誤
```swift
// 修正前
let loaded = try storageService.loadCurrencySettings()
let history = try storageService.loadConversionHistory()

// 修正後
let loaded = storageService.loadCurrencySettings()
let history = storageService.loadConversionHistory()
```

#### 警告類型 2: 強制解包
**問題**: 使用 `!` 強制解包可選值
```swift
// 修正前
XCTAssertEqual(loaded!.currencyName, "USD")
XCTAssertTrue(loaded!.isValid)

// 修正後
XCTAssertEqual(loaded?.currencyName, "USD")
XCTAssertTrue(loaded?.isValid ?? false)

// 或使用 guard
guard let loadedSettings = loaded else {
    XCTFail("Failed to load settings")
    return
}
XCTAssertTrue(loadedSettings.isValid)
```

#### 警告類型 3: 未修改的變數
**問題**: 變數宣告為 `var` 但從未修改
```swift
// 修正前
var historyBefore = try storageService.loadConversionHistory()

// 修正後
let historyBefore = storageService.loadConversionHistory()
```

#### 警告類型 4: 不必要的 throws 聲明
**問題**: 測試方法標記為 `throws` 但不會拋出錯誤
```swift
// 修正前
func testLoadHistoryWhenEmpty() throws {
    let history = try storageService.loadConversionHistory()
    XCTAssertEqual(history.count, 0)
}

// 修正後
func testLoadHistoryWhenEmpty() {
    let history = storageService.loadConversionHistory()
    XCTAssertEqual(history.count, 0)
}
```

---

### 7. CameraManagerTests.swift (約5個警告)

#### 警告 1: 未使用的變數
```swift
// 修正前
let originalStatus = AVCaptureDevice.authorizationStatus(for: .video)
// originalStatus 從未使用

// 修正後
// 移除未使用的變數
```

#### 警告 2: Combine 訂閱未被保留
**問題**: Combine 訂閱需要被保留，否則會立即被釋放
```swift
// 修正前
let cancellable = cameraManager.$authorizationStatus.sink { ... }
// ...
cancellable.cancel()

// 修正後
// 在類別中添加
var cancellables: Set<AnyCancellable>!

// 在 setUp() 中
cancellables = Set<AnyCancellable>()

// 使用
cameraManager.$authorizationStatus
    .sink { ... }
    .store(in: &cancellables)
```

#### 警告 3: 測試輔助類別應該是 final
```swift
// 修正前
class MockCameraManagerDelegate: CameraManagerDelegate { }

// 修正後
final class MockCameraManagerDelegate: CameraManagerDelegate { }
```

---

## 修正統計

| 文件 | 警告數量 | 主要類型 |
|------|---------|---------|
| CameraViewModel.swift | 2 | 未使用變數、不必要的型別轉換 |
| CurrencyConverterCameraApp.swift | 2 | 不必要的 try/do-catch |
| SettingsViewModel.swift | 1 | 不必要的 do-catch |
| InitialSetupView.swift | 3 | 舊版 API、強制解包 |
| CameraView.swift | 1 | 舊版 API |
| StorageServiceTests.swift | ~20 | try、強制解包、var/let |
| CameraManagerTests.swift | ~5 | 未使用變數、Combine 訂閱 |
| **總計** | **~34** | |

---

## 修正原則

### 1. 移除不必要的錯誤處理
- 如果函數不會拋出錯誤，移除 `try`、`throws` 和 `do-catch`

### 2. 避免強制解包
- 使用 `?` 可選鏈而不是 `!` 強制解包
- 使用 `guard` 或 `if let` 來安全解包

### 3. 使用正確的變數宣告
- 如果變數不會被修改，使用 `let` 而不是 `var`

### 4. 使用最新的 API
- iOS 17+ 的 `.onChange(of:)` 需要兩個參數：`oldValue` 和 `newValue`

### 5. 正確管理 Combine 訂閱
- 使用 `Set<AnyCancellable>` 來保留訂閱
- 使用 `.store(in:)` 而不是手動 `.cancel()`

### 6. 測試最佳實踐
- 測試輔助類別應該標記為 `final`
- 移除未使用的變數和不必要的錯誤處理

---

## 驗證

修正後的代碼應該：
✅ 無編譯器警告
✅ 所有測試通過
✅ 遵循 Swift 最佳實踐
✅ 代碼更安全、更清晰

---

## 注意事項

1. **StorageService 的設計**: `loadCurrencySettings()` 和 `loadConversionHistory()` 被設計為不拋出錯誤，而是返回可選值或空陣列。這是有意的設計決策，使調用方代碼更簡潔。

2. **iOS 版本兼容性**: `.onChange` 的修正假設目標是 iOS 17+。如果需要支援更早的版本，可能需要使用條件編譯。

3. **測試策略**: 移除不必要的 `throws` 聲明使測試更清晰，因為這些測試實際上不會拋出錯誤。

4. **Combine 記憶體管理**: 正確使用 `Set<AnyCancellable>` 防止訂閱被提前釋放，這是 Combine 使用的重要最佳實踐。
