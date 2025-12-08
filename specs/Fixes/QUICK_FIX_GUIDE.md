# 快速修復指南

## 🚨 最重要的修復

### 相機黑屏問題 - 必須配置 Info.plist

#### 步驟 1: 添加相機權限描述

**方法 A: 使用 Xcode UI**
1. 選擇你的專案 Target
2. 點擊 "Info" 標籤
3. 點擊 "+" 添加新項目
4. 選擇 **"Privacy - Camera Usage Description"**
5. 輸入：`We need camera access to detect prices from images`

**方法 B: 直接編輯 Info.plist**
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to detect prices from images</string>
```

#### 步驟 2: 重新建置
1. Clean Build Folder: ⌘⇧K
2. Build: ⌘B
3. Run: ⌘R

#### 步驟 3: 測試
- 第一次打開相機會看到權限請求彈窗
- 授予權限後應該能看到相機畫面（不再是黑屏）

---

## ✅ 完成的所有修復

### 1. 相機權限和黑屏修復 ✅
- 添加 Info.plist 配置說明
- 改進權限請求流程
- 添加 session 狀態監控
- 權限授予後自動啟動相機

### 2. Switch 開關位置優化 ✅
- 移到右上角，不遮擋視野
- 簡化 UI：標籤改為 "Detect"
- 添加小的 ON/OFF 狀態指示
- Loading 指示器移到底部

### 3. Settings 頁面鍵盤處理 ✅
- 按鈕固定在底部，不受鍵盤影響
- 點擊任何地方都能關閉鍵盤
- ScrollView 不會被壓縮
- 添加 hideKeyboard() 輔助方法

---

## 📱 新的 UI 佈局

### Camera View（相機頁面）
```
┌─────────────────────────────┐
│ < Settings       [Detect 🔘] │ ← Right top corner
│                       ON/OFF  │
│                               │
│     📷 Camera Preview         │
│                               │
│                               │
│    [Detecting...] ⏳          │ ← Bottom (when detecting)
├───────────────────────────────┤
│  Detection Result             │
│  Detected: ¥1000              │
│  Converted: NT$220            │
└───────────────────────────────┘
```

### Settings View（設定頁面）
```
┌─────────────────────────────┐
│     ⚙️ Currency Settings     │
├───────────────────────────────┤
│  ┌─────────────────────────┐ │
│  │ 🔤 Currency Code        │ │
│  │ [JPY____________]  ⌨️   │ │ ← Keyboard can appear
│  │                         │ │
│  │ 📈 Exchange Rate        │ │
│  │ [0.22___________]       │ │
│  └─────────────────────────┘ │
│                               │
│  (Scrollable area)            │
│                               │
├───────────────────────────────┤
│  [💾 Save Settings]   (Fixed) │ ← Always at bottom
│  [📷 Continue to Camera]      │
└───────────────────────────────┘
```

---

## 🔍 測試檢查

### 必測項目
- [ ] **相機畫面正常顯示**（最重要！）
- [ ] 第一次使用看到權限請求彈窗
- [ ] Switch 開關在右上角
- [ ] Switch 可以正常切換
- [ ] 點擊設定頁面任何地方關閉鍵盤
- [ ] 鍵盤彈出時按鈕保持在底部

### 功能測試
- [ ] 儲存設定後可以進入相機
- [ ] 開啟 Switch 後開始偵測
- [ ] 關閉 Switch 後停止偵測
- [ ] 返回設定頁面會自動載入之前的設定

---

## 💡 開發提示

### Debug 相機問題
在 `CameraView.swift` 的 `onAppear` 中添加：
```swift
.onAppear {
    let status = AVCaptureDevice.authorizationStatus(for: .video)
    print("📷 Camera permission: \(status.rawValue)")
    // 3 = authorized ✅
    // 0 = not determined ⚠️
    // 2 = denied ❌
}
```

### Debug 鍵盤問題
在 `hideKeyboard()` 中添加：
```swift
private func hideKeyboard() {
    print("⌨️ Hiding keyboard")
    UIApplication.shared.sendAction(...)
}
```

---

## 🐛 常見問題

### Q: 相機還是黑屏？
A: 
1. 確認 Info.plist 有 NSCameraUsageDescription
2. Clean Build Folder (⌘⇧K)
3. 刪除 app 重新安裝
4. 檢查系統設定 > 隱私權 > 相機
5. 使用實機測試（某些模擬器不支援）

### Q: 權限彈窗沒出現？
A:
1. 重置模擬器
2. 刪除 app 重新安裝
3. 檢查 Console log

### Q: 鍵盤還是會推動按鈕？
A:
1. 確認有 `.ignoresSafeArea(.keyboard)`
2. 確認使用了 GeometryReader
3. 確認按鈕在 VStack 最外層，不在 ScrollView 內

---

## 📂 修改的檔案清單

```
✅ InitialSetupView.swift       - 鍵盤處理優化
✅ CameraView.swift              - Switch 位置和權限請求
✅ CameraViewModel.swift         - Session 狀態監控
✅ CameraManager.swift           - 權限授予回調
📄 INFO_PLIST_SETUP.md          - Info.plist 配置說明
📄 FIXES_SUMMARY.md             - 詳細修復總結
📄 QUICK_FIX_GUIDE.md           - 本快速指南
```

---

## ⚡️ 最快的測試流程

1. **在 Xcode 中添加相機權限描述**（30 秒）
2. **Clean Build (⌘⇧K)**（5 秒）
3. **Run on Device (⌘R)**（30 秒）
4. **授予相機權限**（5 秒）
5. **✅ 應該能看到相機畫面了！**

---

## 🎉 完成後的體驗

- 📱 Settings 頁面流暢好用，鍵盤不會干擾
- 📷 相機畫面清晰顯示
- 🎚️ Switch 開關在右上角不礙眼
- ✨ 整體 UI 乾淨專業

如果還有問題，請查看 **FIXES_SUMMARY.md** 獲取更詳細的資訊！
