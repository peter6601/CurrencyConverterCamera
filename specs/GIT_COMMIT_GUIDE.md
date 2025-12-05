# Git Commit Guide - CurrencyConverterCamera 專案

此文件根據專案功能進行分類,指導如何進行結構化的 git commit。

## 當前狀態分析

根據測試錯誤報告,以下模組需要修復:

### 🔴 失敗的測試 (22 個錯誤)

#### 1. SettingsViewModel 驗證問題 (8 errors)
- `testEmptyCurrencyName()` - 驗證空貨幣名稱
- `testCurrencyNameWithNumbers()` - 驗證數字格式
- `testCurrencyNameTooLong()` - 驗證名稱長度
- `testInvalidExchangeRateFormat()` - 驗證匯率格式
- `testExchangeRateZero()` - 驗證零匯率
- `testExchangeRateTooSmall()` - 驗證最小匯率
- `testExchangeRateTooLarge()` - 驗證最大匯率
- `testValidationErrorMessage()` - 驗證錯誤訊息

#### 2. History 服務問題 (3 errors)
- `testHistoryWithDifferentCurrencies()` - 不同貨幣記錄
- `testHistoryRetentionPolicy()` - 保留政策 (應保留 50 筆,實際 54 筆)
- `testConcurrentRecordAddition()` - 並發添加問題

#### 3. StorageService 問題 (2 errors)
- `testSaveCurrencySettingsUpdatesTimestamp()` - 時間戳更新
- `testSettingsPersistAcrossInstances()` - 持久化問題

#### 4. Camera/Vision 服務問題 (6 errors)
- `testRecognitionReturnsArray()` - 連接丟失
- `testRecognizeTextFromPixelBuffer()` - 連接丟失
- `testHistoryPersistAcrossInstances()` - 連接丟失
- `testSessionHasVideoInput()` - 影片輸入為 0
- `testSessionHasVideoOutput()` - 影片輸出為 0
- `testTextRecognitionPerformance()` - 測試被取消

#### 5. UI 顯示問題 (1 error)
- `testFormattedOriginalPriceDisplay()` - 價格格式化顯示

#### 6. 錯誤訊息問題 (2 errors)
- `testExchangeRateTooLargeErrorMessage()` - 匯率過大訊息
- `testExchangeRateTooSmallErrorMessage()` - 匯率過小訊息

---

## Git Commit 策略

### 階段 1: 忽略規格文件
```bash
# 1. 首先添加 .gitignore
git add .gitignore
git commit -m "chore: add comprehensive .gitignore

- Ignore Xcode build artifacts and user settings
- Ignore CocoaPods, Carthage, SPM dependencies
- Ignore macOS system files
- Ignore project specs and planning documents (specs/, PHASE_*.md)
- Keep only essential README.md"
```

### 階段 2: 核心數據模型 (Models)
```bash
git add CurrencyConverterCamera/Models/
git commit -m "feat(models): implement core data models

- Add CurrencySettings model with validation
- Add ConversionRecord model for history
- Add DetectedNumber model for Vision results
- Implement Codable, Identifiable, Equatable protocols
- Add comprehensive validation rules"
```

### 階段 3: 工具類和擴展 (Utilities)
```bash
git add CurrencyConverterCamera/Utilities/
git commit -m "feat(utilities): add utility functions and extensions

- Add Constants.swift with app-wide constants
- Add Extensions.swift with Decimal and Date formatting
- Add Logger.swift for debug logging
- Define currency validation rules and limits"
```

### 階段 4: 存儲服務 (StorageService)
```bash
git add CurrencyConverterCamera/Services/StorageService.swift
git commit -m "feat(services): implement StorageService with persistence

- Implement UserDefaults persistence for CurrencySettings
- Implement FileManager persistence for ConversionRecord history
- Add 50-record retention policy
- Add thread-safe history management

⚠️  Known Issues:
- testHistoryRetentionPolicy: Retaining 54 instead of 50 records
- testSaveCurrencySettingsUpdatesTimestamp: Timestamp not updating
- testSettingsPersistAcrossInstances: Persistence failing in tests"
```

### 階段 5: 相機服務 (CameraService)
```bash
git add CurrencyConverterCamera/Services/CameraService.swift
git commit -m "feat(services): implement CameraService with AVFoundation

- Integrate AVCaptureSession for camera access
- Add frame capture and throttling (5-8 FPS)
- Handle camera permissions
- Add background/foreground handling

⚠️  Known Issues:
- testSessionHasVideoInput: No video input detected (returns 0)
- testSessionHasVideoOutput: No video output detected (returns 0)"
```

### 階段 6: Vision 服務 (VisionService)
```bash
git add CurrencyConverterCamera/Services/VisionService.swift
git commit -m "feat(services): implement VisionService for text recognition

- Integrate Vision framework for OCR
- Add number detection with confidence filtering
- Implement bounding box calculation
- Add accuracy validation (target >85%)

⚠️  Known Issues:
- testRecognitionReturnsArray: Lost connection to testmanagerd
- testRecognizeTextFromPixelBuffer: Lost connection to testmanagerd
- testTextRecognitionPerformance: Testing was canceled"
```

### 階段 7: 貨幣轉換服務 (ConversionEngine)
```bash
git add CurrencyConverterCamera/Services/ConversionEngine.swift
git commit -m "feat(services): implement currency conversion engine

- Add Decimal-based conversion calculation
- Implement banker's rounding to 2 decimal places
- Add conversion validation
- Ensure financial precision"
```

### 階段 8: SettingsViewModel (需要修復)
```bash
# ⚠️  不要現在 commit - 需要先修復驗證問題

# 修復後再 commit:
git add CurrencyConverterCamera/ViewModels/SettingsViewModel.swift
git commit -m "feat(viewmodels): implement SettingsViewModel with validation

- Add @Published properties for currency name and exchange rate
- Implement comprehensive input validation
- Add validation error messages
- Integrate with StorageService for persistence

Fixes:
- Fix empty currency name validation
- Fix currency name format validation (no numbers allowed)
- Fix currency name length validation (max 20 chars)
- Fix exchange rate range validation (0.0001 - 10000)
- Fix validation error message generation"
```

### 階段 9: CameraViewModel
```bash
git add CurrencyConverterCamera/ViewModels/CameraViewModel.swift
git commit -m "feat(viewmodels): implement CameraViewModel for detection flow

- Integrate CameraService and VisionService
- Manage detected numbers and overlays
- Handle conversion calculations
- Add background/foreground state management"
```

### 階段 10: HistoryViewModel (需要修復)
```bash
# ⚠️  修復後再 commit

git add CurrencyConverterCamera/ViewModels/HistoryViewModel.swift
git commit -m "feat(viewmodels): implement HistoryViewModel for history management

- Load and display conversion history
- Implement sorting by timestamp (newest first)
- Add copy-to-clipboard functionality
- Integrate with StorageService

Fixes:
- Fix retention policy to keep exactly 50 records (not 54)
- Fix concurrent record addition thread safety
- Fix different currency handling in history"
```

### 階段 11: UI Views
```bash
git add CurrencyConverterCamera/Views/
git commit -m "feat(views): implement SwiftUI UI components

SettingsView:
- Currency name input field with validation
- Exchange rate input field with decimal keyboard
- Real-time validation feedback
- \"Start Scan\" button with enable/disable logic

CameraView:
- Camera preview integration
- Real-time number detection overlay
- Tap-to-highlight functionality
- Permission handling UI

HistoryView:
- Conversion history list
- Copy-to-clipboard buttons
- Clear history functionality
- Empty state messaging

Components:
- CurrencyInputField (reusable component)
- ExchangeRateField (reusable component)
- HistoryRow (reusable component)
- OverlayView (Metal-based overlay rendering)

⚠️  Known Issues:
- testFormattedOriginalPriceDisplay: Display format failing"
```

### 階段 12: 測試文件
```bash
git add CurrencyConverterCameraTests/
git commit -m "test: add comprehensive test suite

Unit Tests:
- CurrencySettingsTests (23 tests)
- ModelsTests (17 tests)
- StorageServiceTests (28 tests)
- ViewModelTests (SettingsViewModel, CameraViewModel, HistoryViewModel)
- ServicesTests (CameraService, VisionService, ConversionEngine)

Integration Tests:
- Camera to overlay flow tests
- Settings persistence tests
- History storage tests
- Performance measurement tests

Test Infrastructure:
- TestHelper with mock data generators
- Test image dataset (20+ labeled images)
- Performance measurement utilities

Current Status: 22 test failures (see GIT_COMMIT_GUIDE.md for details)
Target: 100% passing before production"
```

### 階段 13: 應用程式入口和配置
```bash
git add CurrencyConverterCamera/App/
git commit -m "feat(app): configure app entry point and settings

- Add CurrencyConverterCameraApp.swift (app entry point)
- Configure Info.plist with camera permissions
- Add AppState for dependency injection
- Set up navigation between Settings/Camera/History
- Configure launch screen and app icon"
```

### 階段 14: 資源和本地化
```bash
git add CurrencyConverterCamera/Resources/
git commit -m "feat(resources): add localization and assets

- Add Traditional Chinese (zh-TW) localization
- Add app icon assets
- Add launch screen assets
- Localize all user-facing strings

Localized strings:
- Settings screen labels
- Validation error messages
- Camera overlay text
- History view labels"
```

---

## 修復策略優先順序

### 🔥 Critical (必須立即修復)
1. **SettingsViewModel 驗證** - 8 個測試失敗
   - 文件: `CurrencyConverterCamera/ViewModels/SettingsViewModel.swift`
   - 問題: 驗證邏輯未正確實現
   - 影響: 無法保存有效設定,阻塞所有後續功能

2. **StorageService 持久化** - 3 個測試失敗
   - 文件: `CurrencyConverterCamera/Services/StorageService.swift`
   - 問題: 歷史記錄保留政策、時間戳、持久化
   - 影響: 數據丟失、歷史記錄不準確

### ⚠️  High Priority (高優先級)
3. **Camera/Vision 服務連接** - 6 個測試失敗
   - 文件: `CameraService.swift`, `VisionService.swift`
   - 問題: testmanagerd 連接丟失、影片輸入輸出為空
   - 影響: 核心檢測功能無法工作

4. **History ViewModel** - 2 個測試失敗
   - 文件: `HistoryViewModel.swift`
   - 問題: 並發添加、不同貨幣處理
   - 影響: 歷史記錄顯示錯誤

### 📝 Medium Priority (中優先級)
5. **錯誤訊息** - 2 個測試失敗
   - 文件: `SettingsViewModel.swift`
   - 問題: 錯誤訊息未生成
   - 影響: 用戶體驗不佳

6. **UI 顯示格式** - 1 個測試失敗
   - 文件: `ConversionRecord.swift` 或 `Extensions.swift`
   - 問題: 價格格式化邏輯
   - 影響: 顯示不正確但功能正常

---

## 建議的工作流程

### 第 1 天: 基礎設施和修復驗證
```bash
# 1. 添加 .gitignore
git add .gitignore
git commit -m "chore: add .gitignore"

# 2. Commit 核心模型 (無測試失敗)
git add CurrencyConverterCamera/Models/
git commit -m "feat(models): implement core data models"

# 3. Commit 工具類 (無測試失敗)
git add CurrencyConverterCamera/Utilities/
git commit -m "feat(utilities): add utility functions"

# 4. 修復 SettingsViewModel 驗證問題
# ... 修復代碼 ...
git add CurrencyConverterCamera/ViewModels/SettingsViewModel.swift
git commit -m "fix(viewmodels): fix SettingsViewModel validation logic

Fixes:
- testEmptyCurrencyName: Now correctly returns validation error
- testCurrencyNameWithNumbers: Rejects currency names with numbers
- testCurrencyNameTooLong: Enforces 20 character limit
- testInvalidExchangeRateFormat: Validates decimal format
- testExchangeRateZero: Rejects zero exchange rate
- testExchangeRateTooSmall: Enforces minimum 0.0001
- testExchangeRateTooLarge: Enforces maximum 10000
- testValidationErrorMessage: Generates correct error messages"
```

### 第 2 天: 存儲和歷史修復
```bash
# 5. 修復 StorageService
# ... 修復代碼 ...
git add CurrencyConverterCamera/Services/StorageService.swift
git commit -m "fix(services): fix StorageService persistence issues

Fixes:
- testHistoryRetentionPolicy: Now correctly keeps exactly 50 records
- testSaveCurrencySettingsUpdatesTimestamp: Timestamp updates on save
- testSettingsPersistAcrossInstances: Proper persistence across app restarts"

# 6. 修復 HistoryViewModel
# ... 修復代碼 ...
git add CurrencyConverterCamera/ViewModels/HistoryViewModel.swift
git commit -m "fix(viewmodels): fix HistoryViewModel concurrency and currency handling

Fixes:
- testHistoryWithDifferentCurrencies: Correctly handles multiple currencies
- testConcurrentRecordAddition: Thread-safe concurrent additions"
```

### 第 3 天: Camera/Vision 服務
```bash
# 7. 修復 Camera/Vision 服務
# ... 修復代碼 ...
git add CurrencyConverterCamera/Services/CameraService.swift
git add CurrencyConverterCamera/Services/VisionService.swift
git commit -m "fix(services): fix Camera and Vision service integration

Fixes:
- testSessionHasVideoInput: Properly initialize video input
- testSessionHasVideoOutput: Properly initialize video output
- testRecognitionReturnsArray: Fix testmanagerd connection
- testRecognizeTextFromPixelBuffer: Fix buffer processing
- testTextRecognitionPerformance: Add proper test timeout handling"
```

### 第 4 天: UI 和最終整合
```bash
# 8. Commit UI Views
git add CurrencyConverterCamera/Views/
git commit -m "feat(views): implement UI components"

# 9. 修復 UI 顯示格式
# ... 修復代碼 ...
git add CurrencyConverterCamera/Models/ConversionRecord.swift
git commit -m "fix(models): fix price formatting display

Fixes:
- testFormattedOriginalPriceDisplay: Correct currency formatting"

# 10. Commit 測試文件
git add CurrencyConverterCameraTests/
git commit -m "test: add comprehensive test suite

All tests now passing (0 failures)"

# 11. 最終整合
git add CurrencyConverterCamera/App/
git add CurrencyConverterCamera/Resources/
git commit -m "feat: complete app integration

- Add app entry point and configuration
- Add localization resources
- All features integrated and tested
- All 68+ tests passing"
```

---

## 驗證 Checklist

在每個 commit 之前:

- [ ] 代碼編譯成功 (`⌘B` in Xcode)
- [ ] 相關測試通過 (`⌘U` for specific test suite)
- [ ] 無編譯器警告
- [ ] 代碼格式化正確
- [ ] Commit message 清晰且描述性強
- [ ] 如果有已知問題,在 commit message 中註明

最終驗證:
- [ ] 所有測試通過 (0 failures)
- [ ] 代碼覆蓋率 >85%
- [ ] 應用程式可在模擬器上運行
- [ ] 所有功能手動測試通過

---

## Commit Message 格式規範

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type (類型)
- `feat`: 新功能
- `fix`: Bug 修復
- `docs`: 文檔更改
- `style`: 代碼格式 (不影響功能)
- `refactor`: 重構 (既不是新功能也不是 bug 修復)
- `test`: 添加或修改測試
- `chore`: 構建過程或輔助工具的變動

### Scope (範圍)
- `models`: 數據模型
- `services`: 服務層
- `viewmodels`: 視圖模型
- `views`: UI 視圖
- `utilities`: 工具類
- `app`: 應用程式配置
- `resources`: 資源文件

### Examples

```bash
# 好的 commit
git commit -m "feat(models): implement CurrencySettings with validation"
git commit -m "fix(services): resolve StorageService retention policy bug"
git commit -m "test: add comprehensive unit tests for SettingsViewModel"

# 不好的 commit
git commit -m "update code"  # 太模糊
git commit -m "fix bug"      # 沒有說明修復了什麼
git commit -m "WIP"          # Work In Progress 不應該 commit 到主分支
```

---

## 總結

1. **先 commit .gitignore** - 忽略 specs 和 PHASE 文件
2. **按功能模組分類 commit** - 不要一次 commit 所有內容
3. **修復測試失敗後再 commit** - 保證每個 commit 都是可工作的狀態
4. **寫清晰的 commit message** - 包含修復的問題和影響
5. **遵循優先順序** - 先修復 Critical,再修復 High Priority

這樣的 commit 歷史將清晰展示專案開發過程,便於:
- Code review
- Bug 追蹤
- 回滾到特定功能點
- 團隊協作
- 未來維護

---

**當前狀態**: 22 個測試失敗,需要修復後再進行 feature commits
**目標狀態**: 0 個測試失敗,所有功能模組獨立 commit
**預估時間**: 3-4 天完成所有修復和 commits
