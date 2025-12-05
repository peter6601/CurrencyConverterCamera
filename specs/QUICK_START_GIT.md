# 快速開始: Git Commit 指南

## 🎯 目標

1. ✅ 將 Specs 文件加入 .gitignore
2. ✅ 根據功能模組進行分類 commit

## 📋 快速執行步驟

### 方法 1: 使用自動化腳本 (推薦)

```bash
# 進入專案目錄
cd /Users/dindin/Documents/iOS\ Project/CurrencyConverterCamera

# 賦予腳本執行權限
chmod +x git-commit-sequence.sh

# 執行腳本
./git-commit-sequence.sh
```

腳本會:
- 引導你逐步完成每個 commit
- 每步都會詢問是否繼續
- 顯示已知問題的警告
- 自動生成規範的 commit message

---

### 方法 2: 手動執行 (完全控制)

#### Step 1: 添加 .gitignore (忽略 specs 文件)
```bash
git add .gitignore
git commit -m "chore: add comprehensive .gitignore

- Ignore Xcode build artifacts and user settings
- Ignore project specs and planning documents (specs/, PHASE_*.md)
- Keep only essential README.md"
```

#### Step 2: Commit 核心模型
```bash
git add CurrencyConverterCamera/Models/
git commit -m "feat(models): implement core data models

- Add CurrencySettings, ConversionRecord, DetectedNumber
- Implement Codable, Identifiable, Equatable protocols
- Add comprehensive validation rules"
```

#### Step 3: Commit 工具類
```bash
git add CurrencyConverterCamera/Utilities/
git commit -m "feat(utilities): add utility functions and extensions

- Add Constants.swift with app-wide constants
- Add Extensions.swift with Decimal and Date formatting
- Add Logger.swift for debug logging"
```

#### Step 4: Commit Services (按順序)
```bash
# StorageService
git add CurrencyConverterCamera/Services/StorageService.swift
git commit -m "feat(services): implement StorageService with persistence"

# ConversionEngine (如果存在)
git add CurrencyConverterCamera/Services/ConversionEngine.swift
git commit -m "feat(services): implement currency conversion engine"

# CameraService (如果存在)
git add CurrencyConverterCamera/Services/CameraService.swift
git commit -m "feat(services): implement CameraService with AVFoundation"

# VisionService (如果存在)
git add CurrencyConverterCamera/Services/VisionService.swift
git commit -m "feat(services): implement VisionService for text recognition"
```

#### Step 5: Commit ViewModels
```bash
git add CurrencyConverterCamera/ViewModels/
git commit -m "feat(viewmodels): implement ViewModels for MVVM architecture

- SettingsViewModel with validation
- CameraViewModel for detection flow
- HistoryViewModel for history management"
```

#### Step 6: Commit Views
```bash
git add CurrencyConverterCamera/Views/
git commit -m "feat(views): implement SwiftUI UI components

- SettingsView, CameraView, HistoryView
- Reusable components (CurrencyInputField, ExchangeRateField, HistoryRow)"
```

#### Step 7: Commit App 配置
```bash
git add CurrencyConverterCamera/App/
git commit -m "feat(app): configure app entry point and settings"
```

#### Step 8: Commit 資源
```bash
git add CurrencyConverterCamera/Resources/
git commit -m "feat(resources): add localization and assets"
```

#### Step 9: Commit 測試
```bash
git add CurrencyConverterCameraTests/
git commit -m "test: add comprehensive test suite

⚠️  Current Status: 22 test failures
Target: 100% passing before production"
```

---

## ⚠️  重要提醒

### 當前測試狀態
- **22 個測試失敗** (詳見錯誤列表)
- **建議**: 先修復測試,再 commit 相關模組

### 優先修復順序
1. **SettingsViewModel** (8 個測試失敗) - 🔥 Critical
2. **StorageService** (3 個測試失敗) - 🔥 Critical
3. **Camera/Vision Services** (6 個測試失敗) - ⚠️  High
4. **HistoryViewModel** (2 個測試失敗) - ⚠️  High
5. **其他** (3 個測試失敗) - 📝 Medium

---

## 📊 查看 Commit 歷史

```bash
# 查看所有 commits
git log --oneline

# 查看最近 5 個 commits
git log --oneline -5

# 查看帶統計的 commits
git log --stat

# 查看圖形化歷史
git log --oneline --graph --all
```

---

## 🔄 撤銷操作 (如果需要)

```bash
# 撤銷最後一個 commit (保留更改)
git reset --soft HEAD~1

# 修改最後一個 commit message
git commit --amend -m "new message"

# 撤銷 staged 文件
git reset HEAD <file>
```

---

## 📖 更多信息

- **詳細指南**: 查看 `GIT_COMMIT_GUIDE.md`
- **測試修復策略**: 查看 `GIT_COMMIT_GUIDE.md` 中的修復優先順序
- **Commit 規範**: 查看 `GIT_COMMIT_GUIDE.md` 中的 Message 格式

---

## ✅ 完成檢查清單

在完成所有 commits 後:

- [ ] 所有 specs 文件已被 .gitignore 忽略
- [ ] 每個功能模組都有獨立的 commit
- [ ] Commit messages 清晰且描述性強
- [ ] 已知問題在 commit message 中註明
- [ ] 運行 `git log` 查看 commit 歷史
- [ ] 所有代碼都已 commit

下一步:
- [ ] 修復測試失敗 (22 個)
- [ ] 為修復創建新的 commits
- [ ] 確保所有測試通過 (⌘U in Xcode)
- [ ] 最終驗證和清理

---

**祝你 commit 順利! 🚀**
