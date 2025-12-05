# 修復：相機權限正常但畫面仍是黑色

## 問題描述

- ✅ 相機權限請求彈窗出現
- ✅ 使用者授予權限
- ✅ 動態島顯示綠燈（相機正在使用）
- ✅ `isSessionRunning` 為 true
- ❌ **但畫面仍然是黑色的**

## 根本原因

程式碼中只有一個黑色的 `Rectangle` placeholder，**沒有實際的相機預覽層（AVCaptureVideoPreviewLayer）**。

### 之前的錯誤程式碼

```swift
// ❌ 只是一個黑色矩形，不是真正的相機預覽
Rectangle()
    .fill(Color.black)
    .overlay(...)
```

這只是一個黑色的形狀，不會顯示相機的畫面。

## 解決方案

### 1. 創建 CameraPreviewView（新檔案）

創建了 `CameraPreviewView.swift`，它是一個 `UIViewRepresentable`，包裝了 `AVCaptureVideoPreviewLayer`：

```swift
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    class PreviewView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            layer as! AVCaptureVideoPreviewLayer
        }
    }
}
```

**關鍵點：**
- 使用 `AVCaptureVideoPreviewLayer` 作為 layer class
- 連接到 `AVCaptureSession`
- 設定 `videoGravity` 為 `.resizeAspectFill`

### 2. 更新 CameraView.swift

將黑色矩形替換為真正的相機預覽：

```swift
private var cameraPreviewArea: some View {
    ZStack {
        // ✅ Real camera preview
        if viewModel.isSessionRunning {
            CameraPreviewView(session: viewModel.cameraManager.session)
                .ignoresSafeArea()
        } else {
            // Placeholder when camera is starting
            Rectangle()
                .fill(Color.black)
                .overlay(
                    VStack {
                        Text("📷 Camera Preview")
                        Text("Starting camera...")
                    }
                )
        }
        
        // ... Toggle switch, overlays, etc.
    }
}
```

### 3. 公開 CameraManager

將 `CameraViewModel` 中的 `cameraManager` 從 private 改為 public：

```swift
// Before:
private let cameraManager = CameraManager()

// After:
let cameraManager = CameraManager()  // Public for preview access
```

這樣 `CameraView` 才能訪問 `session`。

## 技術細節

### AVCaptureVideoPreviewLayer 工作原理

1. **Session 連接**：
   - `AVCaptureSession` 管理相機輸入
   - `AVCaptureVideoPreviewLayer` 顯示預覽
   - 通過 `layer.session = session` 連接兩者

2. **Layer Class**：
   ```swift
   override class var layerClass: AnyClass {
       AVCaptureVideoPreviewLayer.self
   }
   ```
   這告訴 UIKit 使用 `AVCaptureVideoPreviewLayer` 而非普通的 `CALayer`

3. **Video Gravity**：
   - `.resizeAspectFill`：填滿整個視圖，保持長寬比
   - 可能會裁切部分內容以填滿螢幕

### SwiftUI 整合

使用 `UIViewRepresentable` 將 UIKit 的 `AVCaptureVideoPreviewLayer` 整合到 SwiftUI：

```swift
struct CameraPreviewView: UIViewRepresentable {
    // SwiftUI → UIKit 橋接
    func makeUIView(context: Context) -> PreviewView
    func updateUIView(_ uiView: PreviewView, context: Context)
}
```

## 測試結果

執行後應該看到：

1. **相機權限請求** → 授予權限
2. **動態島綠燈** → 相機正在使用
3. **✅ 真實的相機畫面** → 可以看到周圍環境
4. **右上角的 Toggle 開關** → 控制偵測
5. **畫面清晰可見** → 不再是黑屏

## 架構圖

```
CameraView (SwiftUI)
    ↓
CameraViewModel
    ↓
CameraManager (AVFoundation)
    ↓
AVCaptureSession ←─┐
                    │
CameraPreviewView   │
    ↓               │
PreviewView (UIView)│
    ↓               │
AVCaptureVideoPreviewLayer
    ↓               │
    └───────────────┘
    (連接到 session)
```

## 檔案清單

### 新建檔案
- ✅ `CameraPreviewView.swift` - 相機預覽視圖包裝器

### 修改檔案
- ✅ `CameraView.swift` - 使用真正的預覽視圖
- ✅ `CameraViewModel.swift` - 公開 cameraManager

## 常見問題

### Q: 為什麼不能直接在 SwiftUI 中使用 AVCaptureVideoPreviewLayer？

A: `AVCaptureVideoPreviewLayer` 是 UIKit/AppKit 的類別，需要通過 `UIViewRepresentable` 橋接到 SwiftUI。

### Q: 如果畫面還是黑色？

檢查：
1. Info.plist 有 `NSCameraUsageDescription` ✅
2. 權限已授予 ✅
3. `isSessionRunning` 為 true ✅
4. **Session 正確配置和啟動** ← 檢查這個
5. **相機輸入正確添加到 session** ← 檢查這個

Debug：
```swift
.onAppear {
    print("📷 Session running: \(viewModel.isSessionRunning)")
    print("📷 Session inputs: \(viewModel.cameraManager.session.inputs.count)")
    print("📷 Session outputs: \(viewModel.cameraManager.session.outputs.count)")
}
```

### Q: 畫面方向不對？

預覽層會自動處理方向，但如果有問題：
```swift
videoPreviewLayer.connection?.videoOrientation = .portrait
```

### Q: 畫面模糊或低品質？

檢查 session preset：
```swift
session.sessionPreset = .high  // 或 .hd1920x1080
```

## 效能考量

1. **記憶體使用**：
   - 預覽層不會複製畫面數據
   - 直接顯示來自 session 的串流

2. **CPU 使用**：
   - 預覽本身很輕量
   - 主要負載來自文字辨識（Vision framework）

3. **電池消耗**：
   - 相機使用會消耗電池
   - 不需要時記得調用 `stopCamera()`

## 後續優化

可以考慮添加：

1. **縮放功能**：
   ```swift
   @State private var zoomFactor: CGFloat = 1.0
   // 添加 pinch gesture
   ```

2. **手電筒控制**：
   ```swift
   if let device = AVCaptureDevice.default(for: .video) {
       try? device.lockForConfiguration()
       device.torchMode = .on
       device.unlockForConfiguration()
   }
   ```

3. **對焦控制**：
   ```swift
   // Tap to focus
   let focusPoint = CGPoint(x: 0.5, y: 0.5)
   device.focusPointOfInterest = focusPoint
   device.focusMode = .autoFocus
   ```

---

## 總結

問題的核心是：**沒有顯示實際的相機預覽層**。

解決方案很簡單：
1. 創建 `CameraPreviewView` 包裝 `AVCaptureVideoPreviewLayer`
2. 在 `CameraView` 中使用它
3. 連接到 `CameraManager` 的 session

現在應該可以看到真實的相機畫面了！📷✨
