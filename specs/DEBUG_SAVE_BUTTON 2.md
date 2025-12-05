# 除錯指南：Save Settings 按鈕無法啟用 Continue to Camera

## 問題描述

填寫完所有內容並按下 "Save Settings" 後，"Continue to Camera" 按鈕仍然是灰色無法點擊。

## 問題分析

"Continue to Camera" 按鈕的啟用條件是：
```swift
.disabled(appState.currencySettings == nil)
```

如果按鈕一直無法啟用，表示 `appState.currencySettings` 在儲存後仍然是 `nil`。

## 已修復的問題

### 1. 使用錯誤的 StorageService 實例

**之前的錯誤程式碼：**
```swift
try StorageService().saveCurrencySettings(settings)  // ❌ 創建新實例
appState.currencySettings = settings  // ❌ 手動設定
```

**修復後：**
```swift
appState.saveCurrencySettings(settings)  // ✅ 使用 AppState 的方法
```

這樣可以確保：
- 使用相同的 StorageService 實例
- 正確更新 appState.currencySettings
- 錯誤處理一致

### 2. 添加除錯資訊

現在在按鈕上方會顯示當前狀態：
- 🟢 "Saved: JPY" - 設定已儲存
- 🟠 "No settings saved yet" - 尚未儲存

### 3. 添加 Console Log

執行時會在 Xcode console 看到：
```
🔵 Save button pressed
🔵 Currency: 'JPY'
🔵 Exchange Rate: '0.22'
🔵 Starting save process...
🔵 Parsed rate: 0.22
🔵 Created settings: JPY - 0.22
🔵 Settings valid: true
🔵 Calling appState.saveCurrencySettings...
✅ Settings saved successfully!
✅ appState.currencySettings: JPY
```

## 測試步驟

1. **開啟 Xcode Console**
   - View > Debug Area > Activate Console (⌘⇧C)

2. **填寫設定**
   - Currency Code: 輸入 "JPY"（或任何貨幣代碼）
   - Exchange Rate: 輸入 "0.22"（或任何有效匯率）

3. **點擊 Save Settings**
   - 觀察按鈕上方的狀態指示器
   - 查看 Console 的 log 輸出

4. **檢查結果**
   - 🟢 如果看到 "Saved: JPY" → 成功！
   - 🟢 "Continue to Camera" 按鈕應該變成綠色
   - 🟢 可以點擊進入相機頁面

## 可能的問題和解決方案

### 問題 1: Console 顯示 "🔴 Validation error"

**檢查：**
- Currency Code 是否只包含字母？
- Currency Code 是否不超過 20 個字元？
- Exchange Rate 是否大於 0？
- Exchange Rate 是否在 0.0001 到 10000 之間？

**解決：**
- 確保輸入符合所有驗證規則
- 查看 validation error 的具體訊息

### 問題 2: Console 顯示 "🔴 Failed to parse exchange rate"

**原因：**
- Exchange Rate 的格式不正確

**解決：**
- 使用數字和小數點，例如：`0.22` 或 `31.35`
- 不要包含貨幣符號或其他字元
- 使用英文小數點 `.` 而非逗號 `,`

### 問題 3: Console 顯示 "🔴 Settings validation failed"

**檢查：**
```swift
Settings valid: false
```

**可能原因：**
- Currency name 為空
- Currency name 超過 20 字元
- Exchange rate <= 0
- Exchange rate > 10000

**解決：**
- 查看具體的 validation error 訊息
- 調整輸入內容

### 問題 4: Console 顯示 "🔴 AppState error"

**原因：**
- 儲存到 UserDefaults 失敗
- 編碼錯誤

**解決：**
1. 檢查 Console 的完整錯誤訊息
2. 嘗試清除 UserDefaults：
```swift
// 在 saveSettings 開頭添加
UserDefaults.standard.removeObject(forKey: "currencySettings")
UserDefaults.standard.synchronize()
```
3. 重新安裝 app

### 問題 5: 狀態指示器沒有更新

**可能原因：**
- SwiftUI 沒有偵測到 appState 的變化

**解決：**
1. 確認 AppState 是 `ObservableObject`
2. 確認 `currencySettings` 有 `@Published` 修飾
3. 確認 `@Environment(\.appState)` 正確設定

## 手動測試流程

### 測試 1: 基本儲存流程

```
1. 輸入: JPY
2. 輸入: 0.22
3. 點擊 Save Settings
4. 期望:
   - 狀態顯示 "Saved: JPY" ✅
   - Continue to Camera 變綠色 ✅
   - Console 顯示成功訊息 ✅
```

### 測試 2: 驗證錯誤

```
1. 輸入: JPY123 (包含數字)
2. 輸入: 0.22
3. 點擊 Save Settings
4. 期望:
   - 顯示驗證錯誤 ❌
   - Save Settings 按鈕變灰 ❌
```

### 測試 3: 重新開啟 app

```
1. 儲存設定後關閉 app
2. 重新開啟 app
3. 期望:
   - 自動載入之前的設定 ✅
   - Currency Code 顯示 "JPY" ✅
   - Exchange Rate 顯示 "0.22" ✅
   - 狀態顯示 "Saved: JPY" ✅
   - Continue to Camera 是綠色可用 ✅
```

## Debug 版本 vs Release 版本

如果在 Debug 版本可以正常運作，但 Release 版本不行：

1. 檢查 Optimization Level
2. 確認 UserDefaults 沒有被清除
3. 檢查是否有 compiler optimization 問題

## 暫時的解決方法

如果問題持續，可以暫時移除儲存檢查：

```swift
// 暫時允許直接進入相機（開發用）
Button(action: {
    onContinueToCamera()  // 直接導航
}) {
    HStack {
        Image(systemName: "camera.fill")
        Text("Continue to Camera")
            .fontWeight(.semibold)
    }
}
.frame(maxWidth: .infinity)
.padding()
.background(Color.green)  // 永遠是綠色
.foregroundColor(.white)
.cornerRadius(8)
// .disabled(appState.currencySettings == nil)  // 暫時註解掉
```

**⚠️ 記得在問題解決後恢復這個檢查！**

## 聯絡資訊

如果以上方法都無法解決問題，請提供：

1. Xcode Console 的完整 log
2. 使用的輸入值（Currency Code 和 Exchange Rate）
3. iOS 版本和裝置類型
4. 是否在模擬器或實機上測試

---

## 快速檢查清單

執行時請逐項檢查：

- [ ] Xcode Console 已開啟
- [ ] 輸入 Currency Code（只包含字母）
- [ ] 輸入 Exchange Rate（數字，使用 `.` 不是 `,`）
- [ ] 點擊 Save Settings
- [ ] 查看 Console log 是否有錯誤
- [ ] 查看狀態指示器是否顯示 "Saved: XXX"
- [ ] Continue to Camera 按鈕是否變綠色
- [ ] 可以點擊 Continue to Camera

如果所有項目都是 ✅，問題已解決！
如果有任何項目是 ❌，查看對應的錯誤訊息進行除錯。
