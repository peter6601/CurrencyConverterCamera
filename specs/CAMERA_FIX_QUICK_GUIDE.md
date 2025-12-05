# 🎥 相機畫面修復 - 快速指南

## ❌ 之前的問題

```
權限 ✅ → Session 運行 ✅ → 綠燈 ✅ → 但畫面是黑的 ❌
```

## ✅ 根本原因

**缺少真正的相機預覽層！**

之前的程式碼只有：
```swift
Rectangle()  // ← 這只是一個黑色形狀！
    .fill(Color.black)
```

## 🔧 解決方案（3 步驟）

### 步驟 1️⃣：新增 CameraPreviewView.swift

創建了新檔案 `CameraPreviewView.swift`，它包裝了 `AVCaptureVideoPreviewLayer`。

### 步驟 2️⃣：更新 CameraView.swift

替換黑色矩形為真正的相機預覽：
```swift
// ✅ 現在使用真正的預覽
CameraPreviewView(session: viewModel.cameraManager.session)
```

### 步驟 3️⃣：公開 CameraManager

在 `CameraViewModel.swift` 中：
```swift
let cameraManager = CameraManager()  // 改為 public
```

## 🚀 測試步驟

1. **Clean Build** (⌘⇧K)
2. **Run** (⌘R)
3. **進入相機頁面**
4. **應該看到：**
   - ✅ 真實的相機畫面（環境）
   - ✅ 右上角的 Detect 開關
   - ✅ 可以移動手機看到不同畫面
   - ✅ 不再是黑屏！

## 📱 預期結果

```
┌─────────────────────────────┐
│ < Settings      [Detect 🔘] │
│                       OFF    │
│                              │
│    🎥 真實的相機畫面          │
│    (可以看到周圍環境)         │
│    (不是黑色！)              │
│                              │
├──────────────────────────────┤
│  Point camera at prices...   │
└──────────────────────────────┘
```

## 🐛 如果還是黑屏

### Debug 清單

在 `CameraView.onAppear` 添加：
```swift
.onAppear {
    print("📷 Is session running: \(viewModel.isSessionRunning)")
    print("📷 Session inputs: \(viewModel.cameraManager.session.inputs)")
    print("📷 Session outputs: \(viewModel.cameraManager.session.outputs)")
    
    viewModel.requestCameraPermission()
    // ...
}
```

### 檢查項目

1. **Info.plist 配置** ✅
   - `NSCameraUsageDescription` 已添加

2. **權限狀態** ✅
   - 動態島有綠燈
   - 權限已授予

3. **Session 配置** ← 檢查這個
   ```swift
   // 在 CameraManager.startSession 確認：
   - 有添加相機輸入？
   - Session 正確啟動？
   - 沒有配置錯誤？
   ```

### 重置測試

如果需要重新測試：
1. 刪除 app
2. Settings > Privacy > Camera > 移除權限
3. 重新安裝
4. 重新測試權限流程

## 📂 檔案變更

### 新檔案 ✨
- `CameraPreviewView.swift` - 相機預覽包裝器

### 修改檔案 🔧
- `CameraView.swift` - 使用預覽視圖
- `CameraViewModel.swift` - 公開 cameraManager

### 文件 📄
- `CAMERA_BLACK_SCREEN_FIX.md` - 詳細技術說明

## 💡 技術重點

### 為什麼需要 UIViewRepresentable？

SwiftUI 無法直接使用 `AVCaptureVideoPreviewLayer`（它是 UIKit 的）。

```
SwiftUI (CameraView)
    ↓
UIViewRepresentable (CameraPreviewView)
    ↓
UIView (PreviewView)
    ↓
AVCaptureVideoPreviewLayer
    ↓
顯示相機畫面 ✅
```

### 關鍵程式碼

```swift
class PreviewView: UIView {
    // 重點：使用 AVCaptureVideoPreviewLayer 作為 layer
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}
```

## 🎉 成功指標

執行後你應該：

- [x] 看到真實的相機畫面
- [x] 可以移動手機改變視角
- [x] Toggle 開關功能正常
- [x] 開啟開關後開始偵測（如果有實作）
- [x] 畫面流暢不卡頓

## 🔄 之前 vs 之後

### 之前 ❌
```swift
Rectangle()           // 只是黑色形狀
    .fill(Color.black)
```

### 之後 ✅
```swift
CameraPreviewView(session: session)  // 真正的相機預覽
    .ignoresSafeArea()
```

## 📊 效能影響

- ✅ **記憶體**：無額外負擔（預覽不複製數據）
- ✅ **CPU**：輕量（直接串流顯示）
- ⚠️ **電池**：相機本身會消耗電池（正常）

## 🎯 結論

問題很簡單：**之前沒有真正顯示相機畫面**。

現在通過：
1. ✅ 創建 `CameraPreviewView`
2. ✅ 連接到 `AVCaptureSession`
3. ✅ 顯示真正的相機串流

**問題解決！** 🎊

---

## 快速命令

```bash
# Clean build
⌘⇧K

# Build and run
⌘R

# View console
⌘⇧C
```

如果看到真實的相機畫面，恭喜！修復成功！🎉📷
