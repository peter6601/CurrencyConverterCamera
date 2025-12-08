# 相機黑屏問題修復

**日期**: 2025-12-04  
**類型**: Bug Fix  
**優先級**: 🔴 Critical  
**影響範圍**: CameraView, CameraPreviewView

---

## 問題描述

### 症狀

- ✅ 相機權限請求彈窗正常出現
- ✅ 用戶授予權限
- ✅ 動態島顯示綠燈（相機正在使用）
- ✅ `isSessionRunning` 為 true
- ❌ **但畫面仍然是黑色的**

### 用戶影響

- 用戶無法看到相機預覽
- 無法使用核心功能（價格識別）
- 導致應用無法使用

---

## 根本原因

### 問題分析

程式碼中只有一個黑色的 `Rectangle` placeholder，**沒有實際的相機預覽層（AVCaptureVideoPreviewLayer）**。

### 錯誤代碼

```swift
// ❌ 只是一個黑色矩形，不是真正的相機預覽
ZStack {
    Rectangle()
        .fill(Color.black)
        .overlay(
            VStack {
                Text("📷 Camera Preview")
                    .foregroundColor(.gray)
                Text("Starting camera...")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        )
    
    // ... overlay views ...
}
```

### 為什麼會黑屏？

1. `Rectangle().fill(Color.black)` 只是一個形狀，不會顯示相機內容
2. 缺少 `AVCaptureVideoPreviewLayer` 來實際渲染相機串流
3. SwiftUI 無法直接使用 `AVCaptureVideoPreviewLayer`（需要 `UIViewRepresentable` 橋接）

---

## 解決方案

### 1. 創建 CameraPreviewView

**新文件**: `Views/Components/CameraPreviewView.swift`

```swift
import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: PreviewView, context: Context) {
        // 不需要更新
    }
    
    // MARK: - Preview View
    
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

**關鍵技術點**:

1. **UIViewRepresentable**: 橋接 UIKit 到 SwiftUI
2. **Layer Class Override**: 使用 `AVCaptureVideoPreviewLayer` 作為 layer
3. **Session 連接**: 將預覽層連接到 `AVCaptureSession`
4. **Video Gravity**: 設定為 `.resizeAspectFill` 填滿螢幕

### 2. 更新 CameraView

**修改**: `Views/CameraView.swift`

```swift
private var cameraPreviewArea: some View {
    ZStack {
        // ✅ 真實的相機預覽
        if viewModel.isSessionRunning {
            CameraPreviewView(session: viewModel.cameraManager.session)
                .ignoresSafeArea()
        } else {
            // 相機啟動中的佔位符
            Rectangle()
                .fill(Color.black)
                .overlay(
                    VStack {
                        Text("📷 Camera Preview")
                            .foregroundColor(.gray)
                        Text("Starting camera...")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                )
        }
        
        // ... Toggle switch, overlays, loading indicator ...
    }
    .frame(maxHeight: .infinity)
}
```

### 3. 公開 CameraManager

**修改**: `ViewModels/CameraViewModel.swift`

```swift
// Before ❌
private let cameraManager = CameraManager()

// After ✅
let cameraManager = CameraManager()  // Public for preview access
```

**原因**: `CameraView` 需要訪問 `session` 屬性來連接預覽層。

---

## 技術細節

### AVCaptureVideoPreviewLayer 工作原理

```
AVCaptureSession (管理相機輸入)
    │
    ├─> AVCaptureDeviceInput (相機設備)
    │
    ├─> AVCaptureVideoDataOutput (幀輸出)
    │
    └─> AVCaptureVideoPreviewLayer (預覽顯示)
            ↑
            │
    連接到 session.session
```

### 為什麼需要 Layer Class Override？

```swift
override class var layerClass: AnyClass {
    AVCaptureVideoPreviewLayer.self
}
```

- UIView 預設使用 `CALayer`
- 需要告訴 UIKit 使用 `AVCaptureVideoPreviewLayer`
- 這樣 `layer` 屬性會自動成為預覽層

### SwiftUI 橋接

```
SwiftUI (CameraView)
    ↓
UIViewRepresentable (CameraPreviewView)
    ↓
UIView (PreviewView)
    ↓
AVCaptureVideoPreviewLayer
    ↓
AVCaptureSession
```

---

## 測試驗證

### 測試步驟

1. **啟動應用**
   - 進入設置頁面
   - 輸入有效的貨幣設定（例如：JPY, 0.2）
   - 點擊「開始掃描」

2. **權限授予**
   - 權限請求彈窗出現
   - 點擊「允許」

3. **驗證預覽**
   - ✅ 動態島顯示綠燈
   - ✅ 看到真實的相機畫面
   - ✅ 畫面清晰可見（不是黑屏）
   - ✅ 畫面填滿螢幕

4. **功能測試**
   - 啟用檢測開關
   - 對準價格標籤
   - 驗證檢測框顯示
   - 驗證轉換金額顯示

### Debug 檢查清單

如果還是黑屏，檢查：

```swift
// 在 CameraView.onAppear 中添加調試輸出
.onAppear {
    print("📷 Session running: \(viewModel.isSessionRunning)")
    print("📷 Session inputs: \(viewModel.cameraManager.session.inputs.count)")
    print("📷 Session outputs: \(viewModel.cameraManager.session.outputs.count)")
    print("📷 Authorization: \(viewModel.cameraManager.authorizationStatus)")
}
```

預期輸出：
```
📷 Session running: true
📷 Session inputs: 1
📷 Session outputs: 1
📷 Authorization: authorized
```

---

## 修改的文件

### 新增文件

1. **CameraPreviewView.swift**
   - 位置: `Views/Components/CameraPreviewView.swift`
   - 用途: 包裝 `AVCaptureVideoPreviewLayer` 供 SwiftUI 使用
   - 行數: ~30 行

### 修改文件

1. **CameraView.swift**
   - 修改: `cameraPreviewArea` computed property
   - 變更: 使用 `CameraPreviewView` 替代黑色 Rectangle
   - 影響行數: ~10 行

2. **CameraViewModel.swift**
   - 修改: `cameraManager` 存取控制
   - 變更: `private let` → `let`
   - 影響行數: 1 行

### 代碼差異

```diff
// CameraView.swift
private var cameraPreviewArea: some View {
    ZStack {
-       Rectangle()
-           .fill(Color.black)
-           .overlay(...)
        
+       if viewModel.isSessionRunning {
+           CameraPreviewView(session: viewModel.cameraManager.session)
+               .ignoresSafeArea()
+       } else {
+           Rectangle()
+               .fill(Color.black)
+               .overlay(...)
+       }
        
        // ... overlays ...
    }
}

// CameraViewModel.swift
- private let cameraManager = CameraManager()
+ let cameraManager = CameraManager()  // Public for preview access
```

---

## 性能考量

### 記憶體

- **預覽層**: 不複製畫面數據，直接顯示串流
- **影響**: 記憶體使用輕量，約 10-20 MB

### CPU

- **預覽**: 非常輕量，主要由硬體處理
- **瓶頸**: Vision Framework OCR 處理（已通過節流優化）

### 電池

- **相機使用**: 每小時約 10-15% 電量消耗
- **優化**: 在不使用時調用 `stopCamera()`

---

## 後續優化建議

### 1. 縮放功能

```swift
// 添加縮放手勢
struct CameraPreviewView: UIViewRepresentable {
    @Binding var zoomFactor: CGFloat
    
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        // 添加 UIPinchGestureRecognizer
        return view
    }
}
```

### 2. 手電筒控制

```swift
func toggleTorch() {
    guard let device = AVCaptureDevice.default(for: .video) else { return }
    
    try? device.lockForConfiguration()
    device.torchMode = device.torchMode == .on ? .off : .on
    device.unlockForConfiguration()
}
```

### 3. 對焦控制

```swift
func focusAt(point: CGPoint) {
    guard let device = AVCaptureDevice.default(for: .video) else { return }
    
    try? device.lockForConfiguration()
    if device.isFocusPointOfInterestSupported {
        device.focusPointOfInterest = point
        device.focusMode = .autoFocus
    }
    device.unlockForConfiguration()
}
```

### 4. 畫質設定

```swift
// 允許用戶選擇畫質
enum CameraQuality {
    case low    // .medium
    case medium // .high
    case high   // .hd1920x1080
    
    var sessionPreset: AVCaptureSession.Preset {
        switch self {
        case .low: return .medium
        case .medium: return .high
        case .high: return .hd1920x1080
        }
    }
}
```

---

## 常見問題 (FAQ)

### Q: 為什麼不能直接在 SwiftUI 中使用 AVCaptureVideoPreviewLayer？

**A**: `AVCaptureVideoPreviewLayer` 是 UIKit/AppKit 的類別，SwiftUI 無法直接使用。需要通過 `UIViewRepresentable` (iOS) 或 `NSViewRepresentable` (macOS) 橋接。

### Q: 如果畫面方向不對怎麼辦？

**A**: 預覽層會自動處理方向，但如果有問題可以設定：

```swift
if let connection = videoPreviewLayer.connection {
    connection.videoOrientation = .portrait
}
```

### Q: 畫面模糊或低品質？

**A**: 檢查 session preset 設定：

```swift
// 在 CameraManager 配置時
if session.canSetSessionPreset(.high) {
    session.sessionPreset = .high
}

// 更高品質
if session.canSetSessionPreset(.hd1920x1080) {
    session.sessionPreset = .hd1920x1080
}
```

### Q: 相機預覽延遲？

**A**: 檢查：
1. 是否在主線程更新 UI
2. Vision Framework 處理是否阻塞（已通過節流優化）
3. 設備性能（在老設備上測試）

---

## 相關文檔

- [相機節流更新](../updates/camera-throttling-update.md) - 性能優化
- [產品規格](../product-spec.md) - 完整規格
- [快速修復指南](./camera-fix-quick-guide.md) - 常見問題修復

---

## 總結

### 問題

沒有實際的相機預覽層，只有黑色矩形佔位符。

### 解決方案

1. ✅ 創建 `CameraPreviewView` 包裝 `AVCaptureVideoPreviewLayer`
2. ✅ 在 `CameraView` 中使用它
3. ✅ 公開 `CameraManager` 的 session

### 結果

- 用戶可以看到真實的相機畫面
- 核心功能（價格識別）可以正常使用
- 用戶體驗大幅改善

---

**狀態**: ✅ 已修復並測試  
**優先級**: 🔴 Critical  
**最後更新**: 2025-12-05
