# Info.plist 配置說明

## 相機權限配置

為了讓應用程式能夠使用相機，你需要在 `Info.plist` 中添加相機使用說明。

### 方法 1: 使用 Xcode 介面

1. 在 Xcode 中選擇你的專案
2. 選擇 Target
3. 點擊 "Info" 標籤
4. 點擊 "+" 按鈕添加新項目
5. 選擇或輸入 `Privacy - Camera Usage Description`
6. 在 Value 欄位輸入：`We need camera access to detect prices from images`

### 方法 2: 直接編輯 Info.plist

如果你有 `Info.plist` 檔案，直接在其中添加：

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to detect prices from images</string>
```

### 完整的 Info.plist 範例

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- 相機權限說明 -->
    <key>NSCameraUsageDescription</key>
    <string>We need camera access to detect prices from images</string>
    
    <!-- 如果需要存取相簿（未來功能） -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>We need photo library access to load images for price detection</string>
</dict>
</plist>
```

### 中文版本（如果你的 app 支援中文）

你也可以提供本地化的說明：

```xml
<key>NSCameraUsageDescription</key>
<string>我們需要使用相機來偵測圖片中的價格</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>我們需要存取照片庫來載入圖片進行價格偵測</string>
```

## 重要提醒

1. **必須添加這個設定**：沒有 `NSCameraUsageDescription`，app 會在請求相機權限時崩潰
2. **說明要清楚**：告訴使用者為什麼需要相機權限
3. **重新建置**：添加後需要重新建置並安裝 app
4. **測試權限流程**：
   - 第一次執行時會看到權限請求彈窗
   - 如果拒絕權限，app 會顯示 "Camera Access Denied" 畫面
   - 可以從 Settings app 重新授予權限

## 檢查是否正確設定

在 Xcode 中：
1. 選擇你的 Target
2. Build Settings > Info.plist File
3. 確認指向正確的 Info.plist 檔案路徑

## 如果相機仍然是黑畫面

可能的原因：

1. **Info.plist 沒有正確配置** - 檢查上述設定
2. **模擬器問題** - 某些模擬器不支援相機，請在實機測試
3. **權限被拒絕** - 檢查 iPhone 的 Settings > Privacy > Camera
4. **相機正在被其他 app 使用** - 關閉其他使用相機的 app
5. **Build 問題** - 清理 build folder (⌘⇧K) 並重新建置

## 除錯步驟

1. 查看 Xcode console 的 log 訊息
2. 檢查 `CameraViewModel` 的 `cameraPermissionDenied` 狀態
3. 確認 `AVCaptureDevice.authorizationStatus` 的值
4. 確認 `CameraManager.isSessionRunning` 變為 true

## 在程式碼中檢查

你可以在 `CameraView` 的 `onAppear` 中添加除錯訊息：

```swift
.onAppear {
    let status = AVCaptureDevice.authorizationStatus(for: .video)
    print("📷 Camera permission status: \(status.rawValue)")
    // 0 = notDetermined
    // 1 = restricted
    // 2 = denied
    // 3 = authorized
    
    viewModel.requestCameraPermission()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        if !viewModel.cameraPermissionDenied {
            viewModel.startCamera()
            print("📷 Starting camera...")
        } else {
            print("⚠️ Camera permission denied")
        }
    }
}
```
