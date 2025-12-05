# 問題修復總結

## 2025-12-03 更新

### 修復的問題

#### 1. 相機畫面黑屏問題 ❌➡️✅

**問題：** 相機畫面一直是黑色的，沒有顯示畫面

**原因：**
- Info.plist 缺少必要的相機權限描述（`NSCameraUsageDescription`）
- 權限請求時機不當
- 未正確處理權限授權後的相機啟動

**解決方案：**

1. **添加 Info.plist 配置**（最重要！）
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>We need camera access to detect prices from images</string>
   ```
   
   ⚠️ **沒有這個設定，app 會在請求相機權限時崩潰或無法使用相機**

2. **改進權限請求流程**
   - `CameraView.onAppear` 中主動調用 `requestCameraPermission()`
   - 在權限授予後延遲 0.5 秒再啟動相機
   - 避免權限未授予時啟動相機

3. **CameraManager 改進**
   - 在 `requestCameraPermission()` 中，權限授予後通知 delegate
   - Delegate 收到授權狀態更新後自動啟動相機

4. **添加 Session 狀態監控**
   - CameraViewModel 新增 `isSessionRunning` 屬性
   - 使用 Combine 監聽 CameraManager 的 session 狀態
   - UI 可以根據 session 狀態顯示不同內容

**修改的檔案：**
- `CameraView.swift` - 改進 onAppear 邏輯
- `CameraViewModel.swift` - 新增 isSessionRunning 監控
- `CameraManager.swift` - 改進權限授予後的回調
- 新增 `INFO_PLIST_SETUP.md` - 詳細的配置說明

---

#### 2. Switch 開關位置優化 ❌➡️✅

**問題：** Switch 開關在畫面中央，遮擋了相機視野

**解決方案：**

1. **移到右上角**
   - 使用 VStack + HStack + Spacer() 定位
   - 添加 `.padding(.top, 60)` 避開返回按鈕
   - 添加 `.padding(.trailing, 16)` 與右邊緣保持距離

2. **簡化 UI**
   - 標籤從 "Price Detection" 簡化為 "Detect"
   - 使用較小的字體 (.subheadline)
   - 半透明黑色背景 (opacity: 0.7)
   - 圓角設計 (cornerRadius: 20)

3. **狀態指示**
   - 在 Toggle 下方顯示小的 "ON"/"OFF" 文字
   - ON 時為綠色，OFF 時為灰色
   - 使用 .caption2 較小字體

4. **Loading 指示器移到底部**
   - 偵測進行中時，顯示在畫面底部
   - 避免遮擋中央視野

**UI 佈局：**
```
┌─────────────────────────┐
│ < Settings    [Detect 🔘] │ ← 右上角
│                    ON/OFF │
│                           │
│    相機預覽畫面             │
│                           │
│                           │
│    [Detecting...]         │ ← 底部（當偵測時）
└─────────────────────────┘
```

**修改的檔案：**
- `CameraView.swift` - 重新設計 cameraPreviewArea

---

#### 3. Settings 頁面鍵盤處理 ❌➡️✅

**問題：** 鍵盤彈出時，按鈕會被推到上方，壓縮編輯區域

**解決方案：**

1. **固定按鈕位置**
   - 使用 `GeometryReader` 計算可用空間
   - ScrollView 只佔據上方空間（geometry.size.height - 150）
   - 按鈕固定在底部，不受鍵盤影響

2. **點擊其他地方關閉鍵盤**
   - 背景 `LinearGradient` 添加 `.onTapGesture`
   - Header 區域添加 `.onTapGesture`
   - ScrollView 添加 `.onTapGesture`
   - 按鈕點擊時先調用 `hideKeyboard()`

3. **實作 hideKeyboard() 輔助方法**
   ```swift
   private func hideKeyboard() {
       UIApplication.shared.sendAction(
           #selector(UIResponder.resignFirstResponder), 
           to: nil, from: nil, for: nil
       )
   }
   ```

4. **防止視圖被推動**
   - 添加 `.ignoresSafeArea(.keyboard)` 修飾符
   - 在 ScrollView 底部添加額外空間（180pt）防止內容被遮住

**修改的檔案：**
- `InitialSetupView.swift` - 完全重構鍵盤處理邏輯

---

## 測試檢查清單

### Info.plist 配置 ✅
- [ ] 在 Xcode Target Info 中添加 "Privacy - Camera Usage Description"
- [ ] 或在 Info.plist 中添加 NSCameraUsageDescription
- [ ] Clean Build Folder (⌘⇧K)
- [ ] 重新建置專案

### 相機功能測試 📷
- [ ] 第一次進入相機頁面時看到權限請求彈窗
- [ ] 授予權限後，相機畫面正常顯示（不是黑屏）
- [ ] 可以看到右上角的 Detect 開關
- [ ] Toggle 開關可以正常切換
- [ ] 開啟開關後，看到 "ON" 綠色文字
- [ ] 關閉開關後，看到 "OFF" 灰色文字
- [ ] 開啟開關後，底部顯示 "Point camera at price tags..."
- [ ] 關閉開關後，底部顯示 "Price Detection is Off"

### Settings 頁面測試 ⚙️
- [ ] 點擊 Currency Code 輸入框，鍵盤彈出
- [ ] 按鈕保持在底部，不會往上推
- [ ] ScrollView 區域可以正常滾動
- [ ] 點擊背景任何地方，鍵盤收起
- [ ] 點擊 Header 區域，鍵盤收起
- [ ] 點擊按鈕前，鍵盤會先收起
- [ ] 內容不會被按鈕遮住

### 權限流程測試 🔐
- [ ] 拒絕權限時，顯示 "Camera Access Denied" 畫面
- [ ] 有 "Open Settings" 按鈕可以跳轉到系統設定
- [ ] 從設定授予權限後，返回 app 可以正常使用相機
- [ ] 重新啟動 app，不會重複請求權限

### 導航流程測試 🧭
- [ ] Settings 頁面可以正確載入已儲存的設定
- [ ] 儲存設定後，"Continue to Camera" 按鈕變為綠色可用
- [ ] 點擊 "Continue to Camera" 正確進入相機頁面
- [ ] 相機頁面左上角有 "< Settings" 返回按鈕
- [ ] 點擊返回按鈕可以回到 Settings 頁面

---

## 實機 vs 模擬器

### 建議使用實機測試 📱
某些 Mac 的 iOS 模擬器不支援相機功能，建議在實體 iPhone 或 iPad 上測試。

### 模擬器限制
- 某些模擬器會顯示黑屏（即使權限正確）
- 模擬器可能使用 Mac 的攝影機（如果有）
- 效能可能不如實機

---

## 如果還有問題

### 1. 相機仍然黑屏
```swift
// 在 CameraView.onAppear 中添加 debug：
.onAppear {
    let status = AVCaptureDevice.authorizationStatus(for: .video)
    print("📷 Camera status: \(status.rawValue)")
    // 3 = authorized, 其他值表示未授權
    
    viewModel.requestCameraPermission()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        print("📷 Permission denied: \(viewModel.cameraPermissionDenied)")
        print("📷 Session running: \(viewModel.isSessionRunning)")
        
        if !viewModel.cameraPermissionDenied {
            viewModel.startCamera()
        }
    }
}
```

### 2. 權限彈窗沒有出現
- 刪除 app 重新安裝
- 重置模擬器：Device > Erase All Content and Settings
- 檢查 Info.plist 是否正確添加 NSCameraUsageDescription

### 3. 按鈕還是被鍵盤推動
- 確認有添加 `.ignoresSafeArea(.keyboard)`
- 檢查是否使用了 GeometryReader
- 確認按鈕區域不在 ScrollView 內部

---

## 程式碼變更摘要

### InitialSetupView.swift
```swift
✅ 添加 hideKeyboard() 方法
✅ 使用 GeometryReader 固定按鈕位置
✅ 背景和可點擊區域添加 .onTapGesture
✅ 添加 .ignoresSafeArea(.keyboard)
✅ 按鈕動作中先調用 hideKeyboard()
```

### CameraView.swift
```swift
✅ Switch 移到右上角（VStack + HStack + Spacer）
✅ 簡化 UI 標籤為 "Detect"
✅ 添加小的 ON/OFF 狀態指示
✅ Loading 指示器移到底部
✅ onAppear 中主動請求權限
✅ 延遲 0.5 秒後啟動相機
```

### CameraViewModel.swift
```swift
✅ 添加 @Published var isSessionRunning
✅ 使用 Combine 監聽 CameraManager.isSessionRunning
✅ 確保權限授予後正確啟動相機
```

### CameraManager.swift
```swift
✅ requestCameraPermission() 中添加 delegate 回調
✅ 授予權限後通知 delegate
```

### 新增檔案
```
✅ INFO_PLIST_SETUP.md - 詳細的 Info.plist 配置說明
✅ FIXES_SUMMARY.md - 本檔案，問題修復總結
```

---

## 下一步

1. **必須在 Info.plist 添加相機權限描述**
2. Clean Build Folder (⌘⇧K)
3. 重新建置並在實機上測試
4. 檢查 Console log 確認相機狀態
5. 測試所有功能是否正常運作

---

## 備註

所有修改都已完成，主要問題是 **Info.plist 缺少相機權限描述**。添加後重新建置，相機應該就能正常顯示畫面了。

如果還有其他問題，請檢查：
1. Console log 中的權限狀態
2. 是否在實機而非模擬器測試
3. 系統設定中的相機權限狀態
