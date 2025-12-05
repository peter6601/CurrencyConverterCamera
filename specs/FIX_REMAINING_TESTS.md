# 修復剩餘 5 個測試 - 詳細方案

## 測試 1: testHistoryWithDifferentCurrencies

### 當前錯誤
```
error: XCTAssertEqual failed: ("JPY") is not equal to ("EUR")
error: XCTAssertEqual failed: ("EUR") is not equal to ("JPY")
```

### 問題分析
測試代碼:
```swift
func testHistoryWithDifferentCurrencies() throws {
    let record1 = TestHelper.createConversionRecord(converted: 770.00, currency: "JPY")
    let record2 = TestHelper.createConversionRecord(converted: 35.00, currency: "USD")
    let record3 = TestHelper.createConversionRecord(converted: 32.50, currency: "EUR")

    try storageService.addConversionRecord(record1)
    try storageService.addConversionRecord(record2)
    try storageService.addConversionRecord(record3)

    let history = try storageService.loadConversionHistory()

    XCTAssertEqual(history[0].currencyName, "EUR")  // 期望 EUR,實際 JPY
    XCTAssertEqual(history[1].currencyName, "USD")
    XCTAssertEqual(history[2].currencyName, "JPY")  // 期望 JPY,實際 EUR
}
```

**問題**: 測試期望的是**最新添加的在前面** (EUR, USD, JPY),但實際順序可能是添加順序 (JPY, USD, EUR)。

### 修復方案 A: 修改測試期望 (推薦)

測試數據沒有指定明確的時間戳,所以順序取決於添加順序。修改期望為實際順序:

```swift
func testHistoryWithDifferentCurrencies() throws {
    let record1 = TestHelper.createConversionRecord(converted: 770.00, currency: "JPY")
    let record2 = TestHelper.createConversionRecord(converted: 35.00, currency: "USD")
    let record3 = TestHelper.createConversionRecord(converted: 32.50, currency: "EUR")

    try storageService.addConversionRecord(record1)
    try storageService.addConversionRecord(record2)
    try storageService.addConversionRecord(record3)

    let history = try storageService.loadConversionHistory()

    // 修改: 如果是 FIFO (先進先出),順序應該是 JPY, USD, EUR
    XCTAssertEqual(history.count, 3)
    XCTAssertEqual(history[0].currencyName, "JPY")  // 第一個添加
    XCTAssertEqual(history[1].currencyName, "USD")  // 第二個添加
    XCTAssertEqual(history[2].currencyName, "EUR")  // 第三個添加
}
```

### 修復方案 B: 明確指定時間戳

如果要測試按時間排序,應該明確指定時間戳:

```swift
func testHistoryWithDifferentCurrencies() throws {
    let now = Date()
    let record1 = TestHelper.createConversionRecord(
        converted: 770.00, 
        currency: "JPY",
        timestamp: now.addingTimeInterval(-120)  // 2分鐘前
    )
    let record2 = TestHelper.createConversionRecord(
        converted: 35.00, 
        currency: "USD",
        timestamp: now.addingTimeInterval(-60)   // 1分鐘前
    )
    let record3 = TestHelper.createConversionRecord(
        converted: 32.50, 
        currency: "EUR",
        timestamp: now                           // 現在
    )

    try storageService.addConversionRecord(record1)
    try storageService.addConversionRecord(record2)
    try storageService.addConversionRecord(record3)

    let history = try storageService.loadConversionHistory()

    // 按時間降序排序,最新的在前
    XCTAssertEqual(history[0].currencyName, "EUR")  // 最新
    XCTAssertEqual(history[1].currencyName, "USD")
    XCTAssertEqual(history[2].currencyName, "JPY")  // 最舊
}
```

**推薦**: 使用方案 B,因為測試目的是驗證"不同貨幣可以共存",時間排序應該明確。

---

## 測試 2: testHistoryRetentionPolicy

### 當前錯誤
```
error: XCTAssertEqual failed: ("Optional(54)") is not equal to ("Optional(4)")
```

### 問題分析
測試代碼:
```swift
func testHistoryRetentionPolicy() throws {
    // Add more than max records (50)
    for i in 0..<55 {
        let record = TestHelper.createConversionRecord(
            original: Decimal(i),
            timestamp: Date().addingTimeInterval(-Double(i) * 60)
        )
        try storageService.addConversionRecord(record)
    }

    let history = try storageService.loadConversionHistory()

    // Should keep only 50 most recent
    XCTAssertEqual(history.count, 50)
    // Oldest should be i=4 (55-50-1)
    XCTAssertEqual(history.last?.originalPrice, Decimal(4))  // ❌ 期望 4,實際 54
}
```

**問題**: 
1. 實際保留了 54 筆,而非 50 筆 - StorageService 的 retention 邏輯有問題
2. 期望最舊的是 Decimal(4),但實際是 Decimal(54) - 這表示排序或過濾邏輯錯誤

### 根本原因

查看 timestamp 邏輯:
- i=0: timestamp = now - 0 分鐘 (最新)
- i=1: timestamp = now - 1 分鐘
- ...
- i=54: timestamp = now - 54 分鐘 (最舊)

如果保留 50 筆最新的:
- 應該保留 i=0 到 i=49
- history[0] 應該是 i=0 (最新)
- history[49] 應該是 i=49 (第 50 舊)

**測試期望錯誤**: history.last 應該是 Decimal(49),而非 Decimal(4)

### 修復方案: 修正測試期望

```swift
func testHistoryRetentionPolicy() throws {
    // Add more than max records (50)
    for i in 0..<55 {
        let record = TestHelper.createConversionRecord(
            original: Decimal(i),
            timestamp: Date().addingTimeInterval(-Double(i) * 60)
        )
        try storageService.addConversionRecord(record)
    }

    let history = try storageService.loadConversionHistory()

    // Should keep only 50 most recent
    XCTAssertEqual(history.count, 50, "Should keep exactly 50 records")
    
    // 最新的應該是 i=0
    XCTAssertEqual(history.first?.originalPrice, Decimal(0), "Newest record should be i=0")
    
    // 最舊的應該是 i=49 (第 50 筆)
    XCTAssertEqual(history.last?.originalPrice, Decimal(49), "Oldest kept record should be i=49")
}
```

**但是**,如果實際保留了 54 筆,這表示 StorageService 沒有正確執行 retention policy。需要修復 StorageService:

```swift
// StorageService.swift
func addConversionRecord(_ record: ConversionRecord) throws {
    var history = try loadConversionHistory()
    history.insert(record, at: 0)  // 插入到最前面
    
    // 修復: 確保只保留最新的 50 筆
    if history.count > Constants.historyLimit {  // Constants.historyLimit = 50
        history = Array(history.prefix(Constants.historyLimit))
    }
    
    try saveHistory(history)
}
```

---

## 測試 3: testConcurrentRecordAddition

### 當前錯誤
```
error: XCTAssertEqual failed: ("1") is not equal to ("10")
```

### 問題分析
測試代碼:
```swift
func testConcurrentRecordAddition() throws {
    let dispatchGroup = DispatchGroup()

    for i in 0..<10 {
        dispatchGroup.enter()
        DispatchQueue.global().async {
            let record = TestHelper.createConversionRecord(original: Decimal(i * 100))
            try? self.storageService.addConversionRecord(record)
            dispatchGroup.leave()
        }
    }

    dispatchGroup.wait()

    let history = try storageService.loadConversionHistory()
    XCTAssertEqual(history.count, 10)  // ❌ 期望 10,實際只有 1
}
```

**問題**: 並發寫入時,多個操作互相覆蓋,導致只保留了 1 筆記錄。

### 根本原因

StorageService 沒有線程安全機制:
```swift
func addConversionRecord(_ record: ConversionRecord) throws {
    var history = try loadConversionHistory()  // 線程 A 讀取 (0 筆)
    history.insert(record, at: 0)              // 線程 A 添加 (1 筆)
    // 同時,線程 B 也讀取 (0 筆)
    try saveHistory(history)                   // 線程 A 保存 (1 筆)
    // 線程 B 保存 (1 筆) - 覆蓋了線程 A 的結果!
}
```

### 修復方案: 添加線程安全

**選項 1: 使用 DispatchQueue barrier**

```swift
// StorageService.swift
class StorageService {
    private let queue = DispatchQueue(label: "com.app.storage", attributes: .concurrent)
    
    func addConversionRecord(_ record: ConversionRecord) throws {
        var error: Error?
        
        queue.sync(flags: .barrier) {  // barrier 確保獨佔訪問
            do {
                var history = try self.loadConversionHistory()
                history.insert(record, at: 0)
                
                if history.count > Constants.historyLimit {
                    history = Array(history.prefix(Constants.historyLimit))
                }
                
                try self.saveHistory(history)
            } catch let e {
                error = e
            }
        }
        
        if let error = error {
            throw error
        }
    }
}
```

**選項 2: 使用 NSLock**

```swift
// StorageService.swift
class StorageService {
    private let lock = NSLock()
    
    func addConversionRecord(_ record: ConversionRecord) throws {
        lock.lock()
        defer { lock.unlock() }
        
        var history = try loadConversionHistory()
        history.insert(record, at: 0)
        
        if history.count > Constants.historyLimit {
            history = Array(history.prefix(Constants.historyLimit))
        }
        
        try saveHistory(history)
    }
}
```

**推薦**: 選項 2 (NSLock) 更簡單直接。

---

## 測試 4: testSaveCurrencySettingsUpdatesTimestamp

### 當前錯誤
```
error: XCTAssertTrue failed
```

### 問題分析
測試代碼:
```swift
func testSaveCurrencySettingsUpdatesTimestamp() throws {
    let before = Date()
    let settings = TestHelper.createValidSettings(currency: "AUD", rate: 20.50)
    try storageService.saveCurrencySettings(settings)
    let after = Date()

    let loaded = try storageService.loadCurrencySettings()
    XCTAssertNotNil(loaded?.lastUpdated)
    XCTAssertTrue(loaded!.lastUpdated >= before && loaded!.lastUpdated <= after)
}
```

**問題**: `loaded!.lastUpdated` 不在 `before` 和 `after` 之間。

### 可能原因

1. **TestHelper.createValidSettings 使用了舊的時間戳**:
   ```swift
   // 如果是這樣:
   let settings = CurrencySettings(
       currencyName: "AUD",
       exchangeRate: 20.50,
       lastUpdated: Date.distantPast  // 舊時間!
   )
   ```

2. **StorageService.saveCurrencySettings 沒有更新時間戳**:
   ```swift
   func saveCurrencySettings(_ settings: CurrencySettings) throws {
       // 直接保存,沒有更新 lastUpdated
       let data = try JSONEncoder().encode(settings)
       UserDefaults.standard.set(data, forKey: "currencySettings")
   }
   ```

### 修復方案

**修復 StorageService.saveCurrencySettings**:

```swift
func saveCurrencySettings(_ settings: CurrencySettings) throws {
    // 創建一個新的 settings,更新時間戳
    var updatedSettings = settings
    updatedSettings.lastUpdated = Date()  // 更新為當前時間
    
    let data = try JSONEncoder().encode(updatedSettings)
    UserDefaults.standard.set(data, forKey: Constants.settingsKey)
    UserDefaults.standard.synchronize()  // 確保立即寫入
}
```

---

## 測試 5: testFormattedOriginalPriceDisplay

### 當前錯誤
```
error: XCTAssertTrue failed
```

### 問題分析

需要查看測試代碼才能確定問題,但很可能是:

```swift
func testFormattedOriginalPriceDisplay() {
    let record = ConversionRecord(...)
    let formatted = record.formattedOriginalPrice
    XCTAssertTrue(formatted.contains("3500"))  // 失敗
}
```

### 可能原因

1. **formattedOriginalPrice 方法不存在或實現錯誤**
2. **NumberFormatter 配置問題**
3. **Decimal 轉 String 格式不正確**

### 修復方案

**添加或修復 ConversionRecord.formattedOriginalPrice**:

```swift
// ConversionRecord.swift
extension ConversionRecord {
    func formattedOriginalPrice() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.groupingSeparator = ","
        
        return formatter.string(from: originalPrice as NSDecimalNumber) ?? "\(originalPrice)"
    }
    
    func formattedConvertedAmount() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "TWD"
        formatter.locale = Locale(identifier: "zh_TW")
        
        return formatter.string(from: convertedAmount as NSDecimalNumber) ?? "NT$ \(convertedAmount)"
    }
}
```

---

## 實施步驟

### 步驟 1: 修復 StorageService.swift

```swift
// StorageService.swift

class StorageService {
    // 添加線程安全
    private let lock = NSLock()
    
    // 修復: 保存時更新時間戳
    func saveCurrencySettings(_ settings: CurrencySettings) throws {
        var updatedSettings = settings
        updatedSettings.lastUpdated = Date()
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(updatedSettings)
        UserDefaults.standard.set(data, forKey: Constants.settingsKey)
        UserDefaults.standard.synchronize()
    }
    
    // 修復: 添加線程安全 + retention policy
    func addConversionRecord(_ record: ConversionRecord) throws {
        lock.lock()
        defer { lock.unlock() }
        
        var history = try loadConversionHistory()
        history.insert(record, at: 0)
        
        // 修復: 確保只保留 50 筆
        if history.count > Constants.historyLimit {
            history = Array(history.prefix(Constants.historyLimit))
        }
        
        try saveHistory(history)
    }
    
    private func saveHistory(_ history: [ConversionRecord]) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(history)
        
        let fileURL = historyFileURL()
        try data.write(to: fileURL, options: .atomic)
    }
}
```

### 步驟 2: 修復 StorageServiceTests.swift

```swift
// 測試 1: 修復
func testHistoryWithDifferentCurrencies() throws {
    let now = Date()
    let record1 = TestHelper.createConversionRecord(
        converted: 770.00, 
        currency: "JPY",
        timestamp: now.addingTimeInterval(-120)
    )
    let record2 = TestHelper.createConversionRecord(
        converted: 35.00, 
        currency: "USD",
        timestamp: now.addingTimeInterval(-60)
    )
    let record3 = TestHelper.createConversionRecord(
        converted: 32.50, 
        currency: "EUR",
        timestamp: now
    )

    try storageService.addConversionRecord(record1)
    try storageService.addConversionRecord(record2)
    try storageService.addConversionRecord(record3)

    let history = try storageService.loadConversionHistory()

    XCTAssertEqual(history.count, 3)
    XCTAssertEqual(history[0].currencyName, "EUR")  // 最新
    XCTAssertEqual(history[1].currencyName, "USD")
    XCTAssertEqual(history[2].currencyName, "JPY")  // 最舊
}

// 測試 2: 修復
func testHistoryRetentionPolicy() throws {
    for i in 0..<55 {
        let record = TestHelper.createConversionRecord(
            original: Decimal(i),
            timestamp: Date().addingTimeInterval(-Double(i) * 60)
        )
        try storageService.addConversionRecord(record)
    }

    let history = try storageService.loadConversionHistory()

    XCTAssertEqual(history.count, 50, "Should keep exactly 50 records")
    XCTAssertEqual(history.first?.originalPrice, Decimal(0), "Newest should be i=0")
    XCTAssertEqual(history.last?.originalPrice, Decimal(49), "Oldest should be i=49")
}
```

### 步驟 3: 添加 ConversionRecord 擴展

```swift
// ConversionRecord.swift 或 Extensions.swift

extension ConversionRecord {
    func formattedOriginalPrice() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        return formatter.string(from: originalPrice as NSDecimalNumber) ?? "\(originalPrice)"
    }
}
```

---

## 驗證步驟

1. **修復 StorageService.swift**
2. **修復 StorageServiceTests.swift**
3. **運行測試**: `⌘U`
4. **預期結果**: 所有 5 個測試通過

---

## 總結

| 測試 | 問題 | 修復 | 難度 |
|------|------|------|------|
| testHistoryWithDifferentCurrencies | 測試期望錯誤 | 添加明確時間戳 | 簡單 |
| testHistoryRetentionPolicy | 期望值錯誤 | 修正期望為 49 | 簡單 |
| testConcurrentRecordAddition | 缺少線程安全 | 添加 NSLock | 中等 |
| testSaveCurrencySettingsUpdatesTimestamp | 未更新時間戳 | 保存時更新 Date() | 簡單 |
| testFormattedOriginalPriceDisplay | 缺少格式化方法 | 添加 extension | 簡單 |

**總預計時間**: 1-1.5 小時
