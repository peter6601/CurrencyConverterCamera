# CurrencyConverterCamera

## 專案簡介 (Project Overview)

CurrencyConverterCamera 是一款專為旅行者設計的 iOS應用程式，利用即時相機影像辨識（OCR）技術，讓使用者只需將手機鏡頭對準外幣價格標籤或菜單，即可在螢幕上即時顯示換算成的本國貨幣（如 TWD）價格。這解決了旅行時手動輸入計算機、切換匯率應用程式的繁瑣過程，提供流暢的購物與點餐體驗。

**核心目標**：即時、準確、直覺的價格換算體驗。

## 功能特色 (Key Features)

*   **即時影像辨識 (Real-time Vision)**：利用 Vision Framework 快速辨識畫面中的數字價格。
*   **照片掃描模式 (Photo Scan)**：支援從相簿匯入現有照片，即時偵測並換算價格（包含對於手寫風格或紅色價格的強化辨識）。
*   **自動匯率換算 (Automatic Conversion)**：支援自訂外幣與本幣代號，依據設定匯率即時轉換價格。
*   **AR 價格疊加 (AR Overlay)**：在相機預覽畫面上直接疊加顯示換算後的價格，直覺對照。
*   **離線支援**：基本的辨識與換算功能在無網路環境下（如飛航模式）依然可用（需預先設定匯率）。
*   **高品質開發**：採用 TDD (測試驅動開發) 方法論，確保核心功能的準確性與穩定性。
*   **MVVM 架構**：清晰的程式架構，易於維護與擴充。
*   **多國語言支援 (Localization)**：完整支援繁體中文 (Traditional Chinese) 與英文 (English)，採用 Apple 最新 String Catalog 技術進行管理。

## 系統需求 (Requirements)

*   **iOS 版本**：iOS 17.0 或以上
*   **裝置**：iPhone (支援相機功能)
*   **開發環境**：Xcode 26+
*   **語言**：Swift 5+ (SwiftUI + UIKit)

## 安裝與執行 (Installation & Usage)

1.  **取得專案程式碼**：
    ```bash
    git clone https://github.com/peter6601/CurrencyConverterCamera.git
    cd CurrencyConverterCamera
    ```

2.  **開啟專案**：
    雙擊 `CurrencyConverterCamera.xcodeproj` 檔案開啟 Xcode。

3.  **執行測試 (Optional)**：
    此專案採用 TDD 開發，你可以與執行測試來驗證功能：
    *   按下 `Cmd + U` 執行 Unit Tests 與 Integration Tests。

4.  **執行應用程式**：
    *   連接 iPhone 實體裝置 (推薦) 或使用 Simulator。
    *   按下 `Cmd + R` 建置並執行。
    *   **注意**：模擬器 (Simulator) 無法完全模擬相機功能，建議使用實機測試以獲得完整體驗。

## 使用說明 (User Guide)

1.  **初始設定 (Initial Setup)**：首次開啟 App，請輸入「外幣代號」（如 JPY）、「本幣代號」（如 TWD）以及當前「匯率」。
2.  **開啟相機**：點擊開啟相機按鈕，將相機對準含有價格數字的物品（如標價牌、菜單）。
3.  **相片掃描**：在設定頁面可選擇「選擇照片」功能，匯入相簿中的價格照片進行辨識（特別優化日本賣場價格標籤支援）。
4.  **即時換算**：App 會自動框選畫面中的價格，並在旁邊顯示換算後的本幣金額。

## 相關文件 (Documentation)

更多詳細的開發規格與技術文件，請參閱 `specs/` 資料夾：
*   `specs/Core/product_spec.md`: 完整產品規格書
*   `specs/Core/INITIALIZATION_FLOW.md`: 系統初始化流程
*   `specs/Phases/PHASE_2_README.md`: 基礎建設與架構說明
