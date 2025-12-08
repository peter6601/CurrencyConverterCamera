# Currency Converter Camera App - Updated Specification

## 更新日期：2025-12-03

## 應用程式流程更新

### 核心變更

原本的應用程式會在第一次啟動時顯示 Initial Setup，之後就直接進入主畫面的 TabView。

**新的流程設計：**

1. **永遠先顯示 Settings 頁面**
   - 應用程式啟動時，第一個畫面永遠是 Settings 頁面（InitialSetupView）
   - 不再使用 TabView 架構

2. **自動載入已儲存的設定**
   - 如果使用者之前有填寫並儲存過設定，重新開啟 app 時會自動載入顯示
   - 使用者可以看到之前的設定值並修改

3. **導航到相機頁面**
   - Settings 頁面有兩個按鈕：
     - "Save Settings"：儲存當前的設定
     - "Continue to Camera"：切換到相機頁面（只有在設定已儲存後才可用）
   - 相機頁面有返回按鈕可回到 Settings

4. **相機頁面的 Switch 開關**
   - 相機頁面包含一個 "Price Detection" Toggle Switch
   - **開關開啟（ON）**：
     - 相機會進行價格偵測
     - 會使用 Vision framework 辨識價格
     - 會進行貨幣轉換計算
     - 顯示偵測結果和轉換金額
   - **開關關閉（OFF）**：
     - 相機只顯示畫面
     - 不進行任何文字辨識
     - 不進行價格偵測或轉換
     - 顯示 "Price Detection is Off" 訊息

## 檔案結構

### 主要檔案

1. **ContentView.swift** - 主要容器
   - 管理 Settings 和 Camera 頁面之間的導航
   - 使用 `@State` 追蹤當前顯示的頁面
   - 提供返回按鈕

2. **InitialSetupView.swift** - Settings 頁面
   - 顯示貨幣設定表單
   - 自動載入已儲存的設定
   - 提供 "Save Settings" 和 "Continue to Camera" 按鈕
   - 接受 `onContinueToCamera` callback

3. **CameraView.swift** - 相機頁面
   - 顯示相機畫面
   - 包含 Toggle Switch 控制偵測功能
   - 根據開關狀態顯示不同的 UI

4. **CameraViewModel.swift** - 相機邏輯
   - 新增 `isConversionEnabled` 屬性
   - 根據開關狀態決定是否處理畫面

5. **CurrencyConverterCameraApp.swift** - App 入口
   - AppState 移除 `needsInitialSetup` 屬性
   - 簡化初始化邏輯

## 使用者體驗流程

### 首次使用

```
1. 開啟 App
   ↓
2. 看到 Settings 頁面（空白表單）
   ↓
3. 填寫貨幣代碼和匯率
   ↓
4. 點擊 "Save Settings"
   ↓
5. "Continue to Camera" 按鈕變為可用（綠色）
   ↓
6. 點擊 "Continue to Camera"
   ↓
7. 進入 Camera 頁面
   ↓
8. 開啟 "Price Detection" 開關
   ↓
9. 開始偵測價格
```

### 重新開啟 App

```
1. 開啟 App
   ↓
2. 看到 Settings 頁面（已填入之前的設定）
   ↓
3. 可選擇：
   a. 修改設定後點 "Save Settings"
   b. 直接點 "Continue to Camera"
   ↓
4. 進入 Camera 頁面
   ↓
5. 開啟/關閉 "Price Detection" 開關
```

### 在相機頁面

```
1. 相機顯示即時畫面
   ↓
2. Toggle Switch 預設為 OFF
   ↓
3. 使用者選擇：
   
   選項 A：開啟 Switch
   ↓
   - 相機開始偵測價格
   - 顯示偵測到的數字
   - 顯示轉換結果
   - 可儲存結果
   
   選項 B：關閉 Switch
   ↓
   - 相機只顯示畫面
   - 顯示 "Price Detection is Off"
   - 不進行任何偵測
```

## UI 元件規格

### Settings 頁面（InitialSetupView）

**標題區域：**
- Icon: SF Symbol "gear.circle.fill"（藍色，64pt）
- 主標題: "Currency Settings"
- 副標題: "Configure your currency exchange rate"

**表單區域：**
- Currency Code 輸入框
  - 標籤: "Currency Code" with icon
  - Placeholder: "e.g., JPY, USD, EUR"
  - 限制: 20 字元，只能輸入字母
  
- Exchange Rate 輸入框
  - 標籤: "Exchange Rate" with icon
  - Placeholder: "e.g., 0.22 or 31.35"
  - 鍵盤類型: 數字鍵盤
  - 範圍: 0.0001 - 10000

**按鈕區域：**
- "Save Settings" 按鈕
  - 藍色（有效時）/ 灰色（無效時）
  - 顯示儲存進度
  
- "Continue to Camera" 按鈕
  - 綠色（設定已儲存）/ 灰色（設定未儲存）
  - Icon: "camera.fill"
  - 只有在設定已儲存後才可用

### Camera 頁面（CameraView）

**頂部導航：**
- "< Settings" 返回按鈕
  - 半透明黑色背景
  - 白色文字
  - 圓角設計

**相機預覽區域：**
- 全螢幕相機畫面
- 中央顯示：
  - "📷 Camera Preview" 標題
  - Toggle Switch 控制項：
    - 標籤: "Price Detection"
    - 顏色: 綠色（開啟時）
    - 放在半透明黑色容器中
  - 狀態文字:
    - "Detection Active"（綠色，開啟時）
    - "Detection Paused"（灰色，關閉時）

**偵測結果區域：**

當開關 **關閉** 時：
- Icon: "pause.circle.fill"（灰色，40pt）
- 標題: "Price Detection is Off"
- 說明: "Enable the switch above to start detecting prices"

當開關 **開啟** 且有偵測結果時：
- 標題: "Detection Result"
- 偵測價格和轉換金額
- 信心度百分比
- 時間戳記
- "Save Result" 按鈕

## 技術實作細節

### ContentView 導航邏輯

```swift
enum MainView {
    case settings
    case camera
}

@State private var selectedView: MainView = .settings

// 在 InitialSetupView 中：
InitialSetupView(onContinueToCamera: {
    selectedView = .camera
})

// 在 CameraView 中：
// 提供返回按鈕切換回 .settings
```

### CameraViewModel 開關邏輯

```swift
@Published var isConversionEnabled = false

private func processFrame(_ pixelBuffer: CVPixelBuffer) {
    guard isConversionEnabled else {
        // 只更新畫面，不進行偵測
        return
    }
    
    // 進行文字辨識和轉換...
}
```

### InitialSetupView 自動載入

```swift
.onAppear {
    if let settings = appState.currencySettings {
        currencyName = settings.currencyName
        exchangeRateText = String(describing: settings.exchangeRate)
    }
}
```

## 資料持久化

### 儲存機制保持不變

- **CurrencySettings**: 使用 UserDefaults
- **ConversionHistory**: 使用 JSON 檔案

### AppState 簡化

移除 `needsInitialSetup` 屬性，因為現在永遠先顯示 Settings 頁面。

## 優點

1. **更簡單的架構**：移除 TabView，使用簡單的頁面切換
2. **更清楚的流程**：使用者總是知道在哪裡可以修改設定
3. **更好的控制**：使用者可以明確控制何時要進行價格偵測
4. **節省資源**：關閉開關時不進行昂貴的 Vision API 呼叫
5. **更好的隱私**：使用者可以在不需要時關閉偵測功能

## 注意事項

1. 相機權限仍然在 CameraView 出現時請求
2. Switch 的預設狀態是 OFF，需要使用者手動開啟
3. 返回 Settings 頁面時，相機會自動停止
4. Settings 的修改會即時同步到 AppState

## 未來可能的增強

1. 記住使用者上次的 Switch 狀態
2. 新增快捷鍵或手勢來快速切換開關
3. 在相機頁面新增快速編輯設定的選項
4. 新增偵測歷史記錄頁面（可以從 Settings 或 Camera 進入）
