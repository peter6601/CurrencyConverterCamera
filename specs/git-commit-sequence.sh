#!/bin/bash
# Git Commit Sequence Script
# 此腳本幫助你按照正確順序進行 git commits
# 
# 使用方法:
#   chmod +x git-commit-sequence.sh
#   ./git-commit-sequence.sh

set -e  # 遇到錯誤立即停止

echo "🚀 CurrencyConverterCamera Git Commit Sequence"
echo "=============================================="
echo ""

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 檢查是否在正確的目錄
if [ ! -f "CurrencyConverterCamera.xcodeproj/project.pbxproj" ]; then
    echo -e "${RED}❌ 錯誤: 請在專案根目錄執行此腳本${NC}"
    echo "   正確目錄: /Users/dindin/Documents/iOS Project/CurrencyConverterCamera/"
    exit 1
fi

# 函數: 詢問是否繼續
ask_continue() {
    local message=$1
    echo ""
    echo -e "${BLUE}📝 $message${NC}"
    read -p "   是否繼續? (y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}⏸  已暫停。請修復後重新運行。${NC}"
        exit 0
    fi
}

# 函數: 執行 commit
do_commit() {
    local files=$1
    local message=$2
    
    echo ""
    echo -e "${GREEN}➕ 添加文件: $files${NC}"
    git add $files
    
    echo -e "${GREEN}💾 創建 commit${NC}"
    git commit -m "$message"
    
    echo -e "${GREEN}✅ Commit 完成${NC}"
    echo ""
}

echo "📋 開始 Git Commit 序列..."
echo ""

# ============================================
# Stage 1: .gitignore
# ============================================
echo -e "${YELLOW}=== Stage 1: .gitignore ===${NC}"
ask_continue "將添加 .gitignore 文件並 commit"

do_commit ".gitignore" "chore: add comprehensive .gitignore

- Ignore Xcode build artifacts and user settings
- Ignore CocoaPods, Carthage, SPM dependencies
- Ignore macOS system files
- Ignore project specs and planning documents (specs/, PHASE_*.md)
- Keep only essential README.md"

# ============================================
# Stage 2: 核心數據模型
# ============================================
echo -e "${YELLOW}=== Stage 2: 核心數據模型 ===${NC}"
ask_continue "將 commit Models/ 目錄"

do_commit "CurrencyConverterCamera/Models/" "feat(models): implement core data models

- Add CurrencySettings model with validation
- Add ConversionRecord model for history
- Add DetectedNumber model for Vision results
- Implement Codable, Identifiable, Equatable protocols
- Add comprehensive validation rules"

# ============================================
# Stage 3: 工具類和擴展
# ============================================
echo -e "${YELLOW}=== Stage 3: 工具類和擴展 ===${NC}"
ask_continue "將 commit Utilities/ 目錄"

do_commit "CurrencyConverterCamera/Utilities/" "feat(utilities): add utility functions and extensions

- Add Constants.swift with app-wide constants
- Add Extensions.swift with Decimal and Date formatting
- Add Logger.swift for debug logging
- Define currency validation rules and limits"

# ============================================
# Stage 4: 存儲服務
# ============================================
echo -e "${YELLOW}=== Stage 4: 存儲服務 ===${NC}"
echo -e "${RED}⚠️  警告: StorageService 有已知問題 (3 個測試失敗)${NC}"
echo "   - testHistoryRetentionPolicy: 保留 54 條記錄而非 50"
echo "   - testSaveCurrencySettingsUpdatesTimestamp: 時間戳未更新"
echo "   - testSettingsPersistAcrossInstances: 持久化失敗"
ask_continue "仍要 commit StorageService? (建議先修復)"

do_commit "CurrencyConverterCamera/Services/StorageService.swift" "feat(services): implement StorageService with persistence

- Implement UserDefaults persistence for CurrencySettings
- Implement FileManager persistence for ConversionRecord history
- Add 50-record retention policy
- Add thread-safe history management

⚠️  Known Issues:
- testHistoryRetentionPolicy: Retaining 54 instead of 50 records
- testSaveCurrencySettingsUpdatesTimestamp: Timestamp not updating
- testSettingsPersistAcrossInstances: Persistence failing in tests"

# ============================================
# Stage 5: 轉換引擎
# ============================================
echo -e "${YELLOW}=== Stage 5: 貨幣轉換引擎 ===${NC}"
if [ -f "CurrencyConverterCamera/Services/ConversionEngine.swift" ]; then
    ask_continue "將 commit ConversionEngine"
    
    do_commit "CurrencyConverterCamera/Services/ConversionEngine.swift" "feat(services): implement currency conversion engine

- Add Decimal-based conversion calculation
- Implement banker's rounding to 2 decimal places
- Add conversion validation
- Ensure financial precision"
else
    echo -e "${YELLOW}⏭  跳過: ConversionEngine.swift 不存在${NC}"
fi

# ============================================
# Stage 6: 相機服務
# ============================================
echo -e "${YELLOW}=== Stage 6: 相機服務 ===${NC}"
if [ -f "CurrencyConverterCamera/Services/CameraService.swift" ]; then
    echo -e "${RED}⚠️  警告: CameraService 有已知問題 (2 個測試失敗)${NC}"
    echo "   - testSessionHasVideoInput: 影片輸入為 0"
    echo "   - testSessionHasVideoOutput: 影片輸出為 0"
    ask_continue "仍要 commit CameraService?"
    
    do_commit "CurrencyConverterCamera/Services/CameraService.swift" "feat(services): implement CameraService with AVFoundation

- Integrate AVCaptureSession for camera access
- Add frame capture and throttling (5-8 FPS)
- Handle camera permissions
- Add background/foreground handling

⚠️  Known Issues:
- testSessionHasVideoInput: No video input detected (returns 0)
- testSessionHasVideoOutput: No video output detected (returns 0)"
else
    echo -e "${YELLOW}⏭  跳過: CameraService.swift 不存在${NC}"
fi

# ============================================
# Stage 7: Vision 服務
# ============================================
echo -e "${YELLOW}=== Stage 7: Vision 服務 ===${NC}"
if [ -f "CurrencyConverterCamera/Services/VisionService.swift" ]; then
    echo -e "${RED}⚠️  警告: VisionService 有已知問題 (3 個測試失敗)${NC}"
    echo "   - testRecognitionReturnsArray: 連接丟失"
    echo "   - testRecognizeTextFromPixelBuffer: 連接丟失"
    echo "   - testTextRecognitionPerformance: 測試被取消"
    ask_continue "仍要 commit VisionService?"
    
    do_commit "CurrencyConverterCamera/Services/VisionService.swift" "feat(services): implement VisionService for text recognition

- Integrate Vision framework for OCR
- Add number detection with confidence filtering
- Implement bounding box calculation
- Add accuracy validation (target >85%)

⚠️  Known Issues:
- testRecognitionReturnsArray: Lost connection to testmanagerd
- testRecognizeTextFromPixelBuffer: Lost connection to testmanagerd
- testTextRecognitionPerformance: Testing was canceled"
else
    echo -e "${YELLOW}⏭  跳過: VisionService.swift 不存在${NC}"
fi

# ============================================
# Stage 8: ViewModels
# ============================================
echo -e "${YELLOW}=== Stage 8: ViewModels ===${NC}"
if [ -d "CurrencyConverterCamera/ViewModels" ]; then
    echo -e "${RED}⚠️  警告: SettingsViewModel 有已知問題 (8 個測試失敗)${NC}"
    echo "   建議先修復驗證邏輯再 commit"
    ask_continue "仍要 commit ViewModels?"
    
    do_commit "CurrencyConverterCamera/ViewModels/" "feat(viewmodels): implement ViewModels for MVVM architecture

SettingsViewModel:
- Add @Published properties for currency name and exchange rate
- Implement input validation
- Add validation error messages
- Integrate with StorageService

CameraViewModel:
- Integrate CameraService and VisionService
- Manage detected numbers and overlays
- Handle conversion calculations
- Add background/foreground state management

HistoryViewModel:
- Load and display conversion history
- Implement sorting by timestamp
- Add copy-to-clipboard functionality

⚠️  Known Issues:
- SettingsViewModel: 8 validation tests failing
- HistoryViewModel: 2 concurrency tests failing"
else
    echo -e "${YELLOW}⏭  跳過: ViewModels/ 目錄不存在${NC}"
fi

# ============================================
# Stage 9: Views
# ============================================
echo -e "${YELLOW}=== Stage 9: UI Views ===${NC}"
if [ -d "CurrencyConverterCamera/Views" ]; then
    ask_continue "將 commit Views/"
    
    do_commit "CurrencyConverterCamera/Views/" "feat(views): implement SwiftUI UI components

SettingsView:
- Currency name input with validation feedback
- Exchange rate input with decimal keyboard
- Real-time validation
- Start Scan button with enable/disable logic

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

Reusable Components:
- CurrencyInputField
- ExchangeRateField
- HistoryRow
- OverlayView (Metal-based rendering)"
else
    echo -e "${YELLOW}⏭  跳過: Views/ 目錄不存在${NC}"
fi

# ============================================
# Stage 10: App 配置
# ============================================
echo -e "${YELLOW}=== Stage 10: 應用程式配置 ===${NC}"
if [ -d "CurrencyConverterCamera/App" ]; then
    ask_continue "將 commit App/"
    
    do_commit "CurrencyConverterCamera/App/" "feat(app): configure app entry point and settings

- Add CurrencyConverterCameraApp.swift (app entry point)
- Configure Info.plist with camera permissions
- Add AppState for dependency injection
- Set up navigation between Settings/Camera/History
- Configure launch screen"
else
    echo -e "${YELLOW}⏭  跳過: App/ 目錄不存在${NC}"
fi

# ============================================
# Stage 11: 資源和本地化
# ============================================
echo -e "${YELLOW}=== Stage 11: 資源和本地化 ===${NC}"
if [ -d "CurrencyConverterCamera/Resources" ]; then
    ask_continue "將 commit Resources/"
    
    do_commit "CurrencyConverterCamera/Resources/" "feat(resources): add localization and assets

- Add Traditional Chinese (zh-TW) localization
- Add app icon assets
- Add launch screen assets
- Localize all user-facing strings"
else
    echo -e "${YELLOW}⏭  跳過: Resources/ 目錄不存在${NC}"
fi

# ============================================
# Stage 12: 測試文件
# ============================================
echo -e "${YELLOW}=== Stage 12: 測試文件 ===${NC}"
if [ -d "CurrencyConverterCameraTests" ]; then
    echo -e "${RED}⚠️  警告: 當前有 22 個測試失敗${NC}"
    ask_continue "仍要 commit 測試文件?"
    
    do_commit "CurrencyConverterCameraTests/" "test: add comprehensive test suite

Unit Tests:
- CurrencySettingsTests (23 tests)
- ModelsTests (17 tests)  
- StorageServiceTests (28 tests)
- ViewModelTests
- ServicesTests

Integration Tests:
- Camera to overlay flow tests
- Settings persistence tests
- History storage tests
- Performance measurement tests

Test Infrastructure:
- TestHelper with mock data generators
- Test image dataset (20+ labeled images)
- Performance measurement utilities

⚠️  Current Status: 22 test failures
Target: 100% passing before production"
else
    echo -e "${YELLOW}⏭  跳過: CurrencyConverterCameraTests/ 目錄不存在${NC}"
fi

# ============================================
# 完成
# ============================================
echo ""
echo -e "${GREEN}🎉 Git Commit 序列完成!${NC}"
echo ""
echo "📊 統計:"
echo "   - 總共創建了多個結構化 commits"
echo "   - 每個 commit 都有清晰的功能範圍"
echo "   - 已知問題都在 commit message 中註明"
echo ""
echo "📝 下一步:"
echo "   1. 查看 commit 歷史: git log --oneline"
echo "   2. 修復已知的測試失敗 (22 個)"
echo "   3. 創建修復 commits"
echo "   4. 確保所有測試通過 (⌘U in Xcode)"
echo ""
echo -e "${BLUE}💡 提示: 查看 GIT_COMMIT_GUIDE.md 了解詳細的修復策略${NC}"
echo ""
