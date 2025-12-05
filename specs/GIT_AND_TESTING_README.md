# Git Commit 和測試修復完整指南

**專案**: CurrencyConverterCamera  
**日期**: 2025-12-05  
**目標**: 整理 Specs 文件至 .gitignore,並按功能分類進行 git commits

---

## 📚 文件總覽

本指南包含 6 個文件,涵蓋從 .gitignore 到測試修復的完整流程:

| 文件 | 用途 | 優先級 | 適用場景 |
|------|------|--------|----------|
| **QUICK_START_GIT.md** | 🚀 快速開始 | ⭐⭐⭐ | 立即開始執行 |
| **GIT_COMMIT_GUIDE.md** | 📖 詳細指南 | ⭐⭐ | 深入了解策略 |
| **git-commit-sequence.sh** | 🤖 自動化腳本 | ⭐⭐⭐ | 一鍵執行 commits |
| **GIT_WORKFLOW_DIAGRAM.md** | 📊 流程圖 | ⭐ | 視覺化理解 |
| **TEST_FIXES_PRIORITY.md** | 🔧 測試修復清單 | ⭐⭐⭐ | 修復測試失敗 |
| **COMMIT_SUMMARY.md** | 📝 總結報告 | ⭐ | 整體概覽 |

---

## 🎯 核心目標

### 1. .gitignore 配置 ✅
- 忽略所有 specs 和 PHASE 相關文檔
- 保留 README.md
- 忽略 Xcode 構建產物

### 2. 功能模組分類 Commit
- 按 MVVM 架構分層 commit
- 每個 commit 有清晰的功能範圍
- 標註已知問題和測試狀態

### 3. 測試修復優先級
- 22 個測試失敗需要修復
- 分為 Critical、High、Medium 三個優先級
- 估算修復時間: 11.5-17 小時 (3-4 天)

---

## 🚀 快速開始 (5 分鐘)

### 選項 A: 使用自動化腳本 (推薦)

```bash
# 1. 進入專案目錄
cd /Users/dindin/Documents/iOS\ Project/CurrencyConverterCamera

# 2. 賦予執行權限
chmod +x git-commit-sequence.sh

# 3. 運行腳本 (會引導你逐步完成)
./git-commit-sequence.sh
```

腳本會自動:
- ✅ 添加 .gitignore
- ✅ 按順序 commit 所有模組
- ✅ 每步詢問確認
- ✅ 顯示已知問題警告
- ✅ 生成規範的 commit messages

### 選項 B: 手動執行 (完全控制)

查看 **QUICK_START_GIT.md** 了解詳細步驟。

---

## 📋 當前專案狀態

### 測試狀態
```
總測試數: 68+
失敗測試: 22
通過測試: 46+
通過率: ~68%
目標: 100%
```

### 測試失敗分類

#### 🔥 Critical (11 個測試 - 必須立即修復)
- **SettingsViewModel 驗證** (8 個)
  - 空貨幣名稱、格式驗證、長度限制
  - 匯率範圍驗證、錯誤訊息生成
  - **影響**: 無法保存設定,阻塞所有功能
  
- **StorageService 持久化** (3 個)
  - 歷史記錄保留政策 (54 vs 50)
  - 時間戳更新、跨實例持久化
  - **影響**: 數據丟失、歷史不準確

#### ⚠️  High Priority (8 個測試)
- **Camera/Vision 服務** (6 個)
  - testmanagerd 連接丟失
  - 影片輸入/輸出為 0
  - 性能測試被取消
  - **影響**: 核心檢測功能無法工作
  
- **HistoryViewModel** (2 個)
  - 不同貨幣處理
  - 並發記錄添加
  - **影響**: 歷史記錄顯示錯誤

#### 📝 Medium Priority (3 個測試)
- **錯誤訊息** (2 個)
- **UI 格式化** (1 個)
- **影響**: 用戶體驗不佳,但功能可用

---

## 📖 使用指南

### 如果你想... 那麼你應該...

| 需求 | 推薦文件 | 說明 |
|------|---------|------|
| 立即開始 commit | QUICK_START_GIT.md | 簡潔步驟,直接執行 |
| 使用自動化 | git-commit-sequence.sh | 一鍵完成所有 commits |
| 了解詳細策略 | GIT_COMMIT_GUIDE.md | 完整的修復和 commit 策略 |
| 視覺化理解流程 | GIT_WORKFLOW_DIAGRAM.md | 流程圖和對比分析 |
| 修復測試失敗 | TEST_FIXES_PRIORITY.md | 優先級清單和代碼示例 |
| 查看整體概覽 | COMMIT_SUMMARY.md | 總結報告和統計 |

---

## 🔄 推薦工作流程

### Day 1: Git Commit 設置 (1-2 小時)

```
09:00 - 09:30  閱讀 QUICK_START_GIT.md
09:30 - 10:00  運行 git-commit-sequence.sh
10:00 - 10:30  驗證 commits 和 .gitignore
10:30 - 11:00  查看 git log,確認歷史正確
```

**產出**: 所有模組已 commit,specs 文件被忽略

---

### Day 2: 修復 Critical 問題 (4-6 小時)

```
09:00 - 09:30  閱讀 TEST_FIXES_PRIORITY.md Priority 1
09:30 - 11:30  修復 SettingsViewModel (8 tests) - 2 小時
11:30 - 12:30  測試驗證,創建 fix commit
13:30 - 14:30  修復 StorageService (3 tests) - 1 小時
14:30 - 15:00  測試驗證,創建 fix commit
15:00 - 16:00  緩衝時間,處理意外問題
```

**產出**: 11 個 Critical 測試通過,剩餘 11 個失敗

---

### Day 3: 修復 High Priority 問題 (6-9 小時)

```
09:00 - 09:30  閱讀 TEST_FIXES_PRIORITY.md Priority 2
09:30 - 13:30  修復 Camera/Vision 服務 (6 tests) - 4 小時
14:30 - 16:00  修復 HistoryViewModel (2 tests) - 1.5 小時
16:00 - 17:00  測試驗證,創建 fix commits
```

**產出**: 19 個測試通過,剩餘 3 個失敗

---

### Day 4: 修復 Medium Priority 和最終驗證 (2-3 小時)

```
09:00 - 10:00  修復錯誤訊息和 UI 格式化 (3 tests)
10:00 - 11:00  運行完整測試套件,確認 0 failures
11:00 - 11:30  檢查代碼覆蓋率 (>85%)
11:30 - 12:00  最終 commit,更新文檔
```

**產出**: 所有測試通過,代碼質量達標,可交付

---

## 📊 Commit 策略對比

### 選項 A: 先修復再 Commit (推薦用於生產)

**優點**:
- ✅ 每個 commit 都是可工作狀態
- ✅ Commit 歷史乾淨清晰
- ✅ 易於 code review
- ✅ 回滾安全

**缺點**:
- ⏰ 需要更多時間 (3-4 天)
- 🔧 必須先修復所有問題

**Commit 歷史示例**:
```
* feat(resources): add localization and assets
* feat(app): configure app entry point
* feat(views): implement SwiftUI UI components
* feat(viewmodels): implement ViewModels (all tests passing) ✅
* feat(services): implement services (all tests passing) ✅
* feat(utilities): add utility functions and extensions
* feat(models): implement core data models
* chore: add comprehensive .gitignore
```

---

### 選項 B: 先 Commit 再修復 (快速記錄進度)

**優點**:
- 🚀 快速記錄所有進度 (1-2 小時)
- 📝 修復歷史清晰可見
- 🔍 易於追蹤問題演變

**缺點**:
- ⚠️  中間 commits 包含失敗測試
- 🔄 Commit 歷史較長
- 📊 需要更多 fix commits

**Commit 歷史示例**:
```
* fix(views): fix price formatting (1 test fixed)
* fix(viewmodels): fix HistoryViewModel (2 tests fixed)
* fix(services): fix Camera/Vision (6 tests fixed)
* fix(services): fix StorageService (3 tests fixed)
* fix(viewmodels): fix SettingsViewModel (8 tests fixed)
* test: add test suite (⚠️ 22 failures)
* feat(resources): add localization
* feat(app): configure app
* feat(views): implement UI (⚠️ 1 failure)
* feat(viewmodels): implement ViewModels (⚠️ 10 failures)
* feat(services): implement services (⚠️ 11 failures)
* feat(utilities): add utilities
* feat(models): implement models
* chore: add .gitignore
```

---

## ✅ 成功標準

### Git 結構
- [x] `.gitignore` 已創建並 commit
- [ ] Specs 文件被忽略 (驗證: `git status` 不顯示 `specs/`)
- [ ] 每個功能模組有獨立 commit
- [ ] Commit messages 遵循規範格式
- [ ] Commit 歷史清晰易讀

### 代碼質量
- [ ] 所有測試通過 (當前: 22 失敗)
- [ ] 代碼覆蓋率 >85%
- [ ] 無編譯器警告
- [ ] 應用程式可在模擬器運行
- [ ] 所有功能手動驗證通過

### 文檔
- [x] Git commit 指南完整
- [x] 測試修復清單完整
- [x] 自動化腳本可用
- [x] 工作流程圖清晰
- [ ] 最終總結更新

---

## 🛠 常用命令

### Git 操作
```bash
# 查看狀態
git status                    # 當前變更
git status --ignored          # 被忽略的文件

# Commit
git add <file>               # 添加文件
git commit -m "message"      # 創建 commit
git commit --amend           # 修改最後 commit

# 查看歷史
git log --oneline            # 簡潔歷史
git log --graph --all        # 圖形化歷史
git log --stat               # 帶統計
```

### 測試操作 (Xcode)
```
⌘B                          # Build 專案
⌘U                          # 運行所有測試
⌘K                          # Clean Build
⌘9                          # Test Navigator
```

### 測試操作 (Terminal)
```bash
# 運行所有測試
xcodebuild test -scheme CurrencyConverterCamera

# 運行特定測試套件
xcodebuild test -only-testing CurrencyConverterCameraTests/SettingsViewModelTests

# 生成覆蓋率報告
xcodebuild test -enableCodeCoverage YES -scheme CurrencyConverterCamera
```

---

## 📞 故障排除

### 問題: Scripts 無法執行
```bash
# 解決方案: 添加執行權限
chmod +x git-commit-sequence.sh
```

### 問題: Git 顯示 specs 文件
```bash
# 解決方案: 檢查 .gitignore 是否生效
git check-ignore -v specs/product_spec.md

# 如果文件已被追蹤,需要從 git 移除
git rm --cached specs/*.md
git commit -m "chore: remove specs files from git"
```

### 問題: 測試一直失敗
```bash
# 解決方案:
# 1. 清理構建
⌘K in Xcode

# 2. 重置模擬器
xcrun simctl erase all

# 3. 查看具體錯誤
# 點擊失敗的測試,查看 Console 輸出

# 4. 參考 TEST_FIXES_PRIORITY.md
```

### 問題: Commit message 寫錯了
```bash
# 解決方案: 修改最後一個 commit
git commit --amend -m "new correct message"
```

---

## 📚 參考資料

### 專案內文檔
- `QUICK_START_GIT.md` - 快速開始指南
- `GIT_COMMIT_GUIDE.md` - 詳細 commit 策略
- `TEST_FIXES_PRIORITY.md` - 測試修復清單
- `GIT_WORKFLOW_DIAGRAM.md` - 視覺化流程圖
- `COMMIT_SUMMARY.md` - 總結報告
- `git-commit-sequence.sh` - 自動化腳本

### 其他文檔 (如果存在)
- `PHASE_1_SETUP.md` - Phase 1 設置指南
- `PHASE_2_COMPLETION_CHECKLIST.md` - Phase 2 完成清單
- `PHASE_2_TEST_COMMANDS.md` - Phase 2 測試命令
- `quickstart.md` - 專案快速開始

### 外部資源
- [Git 提交訊息規範](https://www.conventionalcommits.org/)
- [XCTest 文檔](https://developer.apple.com/documentation/xctest)
- [Swift 測試最佳實踐](https://www.swiftbysundell.com/articles/testing-swift-code/)

---

## 💡 最佳實踐

### Commit 規範
1. **使用規範的 type**: feat, fix, docs, style, refactor, test, chore
2. **寫清晰的 subject**: 簡潔描述做了什麼
3. **添加 body (可選)**: 詳細說明為什麼這樣做
4. **標註已知問題**: 在 commit message 中註明 failing tests

### 測試修復
1. **一次修復一個問題**: 不要同時修復多個不相關的測試
2. **運行測試驗證**: 每次修復後立即運行相關測試
3. **創建獨立 commit**: 每個修復一個 commit,便於追蹤
4. **寫清晰的 fix message**: 說明修復了什麼測試,如何修復

### 代碼質量
1. **保持測試綠色**: 不要 commit 失敗的測試 (除非明確標註)
2. **維持高覆蓋率**: 目標 >85%,Critical 路徑 100%
3. **無編譯器警告**: 修復所有 warnings
4. **定期 refactor**: Green 後進行重構,保持代碼整潔

---

## 🎉 完成檢查清單

在完成所有工作後,確認以下項目:

### Git 結構
- [ ] `.gitignore` 已創建並正常工作
- [ ] 所有 specs 文件被忽略
- [ ] 每個功能模組有獨立 commit
- [ ] Commit messages 清晰規範
- [ ] Commit 歷史邏輯清晰

### 測試質量
- [ ] 所有 22 個失敗測試已修復
- [ ] 所有測試通過 (0 failures)
- [ ] 代碼覆蓋率 >85%
- [ ] 性能測試通過 (FPS, 延遲, 電池)

### 代碼質量
- [ ] 無編譯器錯誤
- [ ] 無編譯器警告
- [ ] 代碼格式化一致
- [ ] 所有 TODO/FIXME 已解決或記錄

### 功能驗證
- [ ] 應用程式可在模擬器啟動
- [ ] Settings 頁面可用,驗證正常
- [ ] Camera 檢測功能正常 (如已實現)
- [ ] History 顯示和操作正常 (如已實現)

### 文檔
- [ ] README 已更新
- [ ] 所有 commit guides 完整
- [ ] 測試修復文檔更新
- [ ] 工作流程文檔清晰

---

## 🚀 下一步

完成 Git Commits 和測試修復後:

1. **Phase 3**: 實現 UI Views (SettingsView, CameraView, HistoryView)
2. **Phase 4**: 整合測試和端到端測試
3. **Phase 5**: 性能優化和 battery profiling
4. **Phase 6**: 本地化 (zh-TW) 和資源
5. **Phase 7**: App Store 準備和提交

---

## 📝 備註

- 本指南基於 2025-12-05 的專案狀態創建
- 測試失敗數量和類型可能隨專案進展變化
- Commit 策略可根據團隊需求調整
- 修復時間估算基於單人開發,實際時間可能不同

---

## ✉️ 支持

遇到問題?
1. 先查看相關文檔 (QUICK_START, TEST_FIXES_PRIORITY)
2. 檢查 Console 輸出的具體錯誤訊息
3. 參考 TEST_FIXES_PRIORITY.md 中的代碼示例
4. 一步一步來,不要急於求成

**祝你 commit 和修復順利! 💪🚀**

---

**版本**: 1.0  
**創建日期**: 2025-12-05  
**最後更新**: 2025-12-05  
**狀態**: ✅ Ready for use  
**維護者**: Claude AI Assistant
