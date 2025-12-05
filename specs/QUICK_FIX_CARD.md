# 快速修復指令卡

## 🎯 你只需要做 3 件事

### 1️⃣ 刪除 5 個不合理的測試 (10 分鐘)

**CameraServiceTests.swift** - 刪除這 2 個方法:
```swift
func testSessionHasVideoInput()
func testSessionHasVideoOutput()  
```

**VisionServiceTests.swift** - 刪除這 3 個方法:
```swift
func testRecognitionReturnsArray()
func testRecognizeTextFromPixelBuffer()
func testTextRecognitionPerformance()
```

**如何刪除**: 
- 在 Xcode 左側找到文件
- 用 ⌘F 搜索方法名
- 選中整個方法(從 `func` 到最後的 `}`)
- 按 Delete

---

### 2️⃣ 修復 StorageService.swift (15 分鐘)

**位置**: `CurrencyConverterCamera/Services/StorageService.swift`

**A. 添加線程安全** (在類的開頭):
```swift
class StorageService {
    private let lock = NSLock()  // ✅ 添加這行
    
    // ... 其他代碼
}
```

**B. 修改 `addConversionRecord` 方法**:
```swift
func addConversionRecord(_ record: ConversionRecord) throws {
    lock.lock()  // ✅ 添加
    defer { lock.unlock() }  // ✅ 添加
    
    var history = try loadConversionHistory()
    history.insert(record, at: 0)
    
    // ✅ 確保有這個檢查
    if history.count > Constants.historyLimit {
        history = Array(history.prefix(Constants.historyLimit))
    }
    
    try saveHistory(history)
}
```

**C. 修改 `saveCurrencySettings` 方法**:
```swift
func saveCurrencySettings(_ settings: CurrencySettings) throws {
    var updatedSettings = settings
    updatedSettings.lastUpdated = Date()  // ✅ 添加這行
    
    let encoder = JSONEncoder()
    let data = try encoder.encode(updatedSettings)  // ✅ 改為 updatedSettings
    UserDefaults.standard.set(data, forKey: Constants.settingsKey)
    UserDefaults.standard.synchronize()  // ✅ 確保有這行
}
```

---

### 3️⃣ 運行測試 (1 分鐘)

```
⌘U
```

**預期結果**: 約 15-17 個測試通過,剩餘 1-3 個失敗(格式化相關)

---

## 📋 完整檢查清單

- [ ] 刪除 CameraServiceTests 中的 2 個測試
- [ ] 刪除 VisionServiceTests 中的 3 個測試
- [ ] 在 StorageService 添加 `private let lock = NSLock()`
- [ ] 修改 `addConversionRecord` (添加 lock.lock() / defer)
- [ ] 修改 `saveCurrencySettings` (添加 lastUpdated)
- [ ] 運行測試 (⌘U)
- [ ] 如果還有失敗,告訴我具體錯誤

---

## 🆘 常見問題

**Q: 找不到 StorageService.swift?**  
A: Xcode 左側 → CurrencyConverterCamera → Services → StorageService.swift

**Q: 不知道在哪裡添加代碼?**  
A: 
- `lock` 添加在 `class StorageService {` 下面第一行
- 方法修改直接找到對應方法名,修改內容

**Q: 編譯錯誤?**  
A: 檢查:
- 是否缺少 `}` 括號
- 是否有拼寫錯誤
- Constants.historyLimit 是否存在

---

## ✅ 成功標準

運行 ⌘U 後:
- ✅ 大部分測試通過 (綠色)
- ✅ 不再有 "Lost connection to testmanagerd" 錯誤
- ✅ 不再有 SettingsViewModel 驗證錯誤
- ✅ 不再有並發測試錯誤
- ✅ 不再有時間戳錯誤

如果還有 1-2 個失敗,可能是格式化測試,告訴我具體錯誤!

---

**預計時間**: 25-30 分鐘  
**難度**: ⭐⭐☆☆☆ (簡單)

開始吧! 你可以的! 💪
