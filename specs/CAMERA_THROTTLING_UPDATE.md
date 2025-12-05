# 相機價格檢測節流更新

## 更新日期
2025-12-04

## 更新內容

### 問題
原本的實現會對相機捕獲的每一幀進行處理，這會導致：
1. 過度消耗 CPU 和電池
2. UI 更新過於頻繁
3. 用戶體驗不佳（數字跳動太快）

### 解決方案
在 `CameraViewModel` 中實現節流機制（Throttling），限制處理頻率為每秒一次。

### 修改的文件

#### 1. CameraViewModel.swift

**新增屬性：**
```swift
private var lastProcessingTime: Date?
private let processingInterval: TimeInterval = 1.0  // 每秒處理一次
```

**更新 processFrame 方法：**
```swift
private func processFrame(_ pixelBuffer: CVPixelBuffer) {
    // ... 現有的檢查 ...
    
    // 節流控制：檢查是否距離上次處理已經過了 1 秒
    let now = Date()
    if let lastTime = lastProcessingTime {
        let timeSinceLastProcessing = now.timeIntervalSince(lastTime)
        if timeSinceLastProcessing < processingInterval {
            // 還不到 1 秒，跳過這一幀
            return
        }
    }
    
    guard !isProcessing else { return }

    // 更新最後處理時間
    lastProcessingTime = now
    
    // ... 繼續處理 ...
}
```

### 工作原理

1. **記錄時間戳**：每次開始處理幀時，記錄當前時間到 `lastProcessingTime`
2. **時間檢查**：下次收到新幀時，計算與上次處理的時間差
3. **跳過處理**：如果時間差小於 1 秒，直接跳過該幀
4. **繼續處理**：如果已經過了 1 秒或更久，則處理該幀

### 優點

1. ✅ **節省資源**：減少 CPU 和 GPU 使用，延長電池壽命
2. ✅ **提升體驗**：檢測結果更穩定，不會頻繁跳動
3. ✅ **保持響應**：1 秒的間隔足夠快，用戶不會感覺延遲
4. ✅ **簡單實現**：使用原生 Date API，無需引入額外框架

### 可調整參數

如果需要調整處理頻率，只需修改 `processingInterval` 的值：
```swift
private let processingInterval: TimeInterval = 1.0  // 改為其他值，如 0.5（每半秒）或 2.0（每兩秒）
```

### 測試建議

1. 打開相機並啟用檢測
2. 對準一個價格標籤
3. 觀察檢測框和轉換金額的更新頻率
4. 確認大約每秒更新一次

### 相關文件

- `CameraViewModel.swift` - 主要更新文件
- `DetectionOverlayView.swift` - 顯示檢測結果的 UI
- `CameraManager.swift` - 相機幀捕獲（未修改）

## 後續優化建議

1. 可以考慮添加一個設置選項，讓用戶自己調整處理頻率
2. 在低電量模式下自動降低處理頻率
3. 根據檢測信心度動態調整頻率（高信心度時降低頻率）
