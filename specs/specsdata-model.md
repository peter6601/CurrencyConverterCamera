# 數據模型規格 - 即時相機貨幣轉換器

**日期**: 2025-12-02  
**階段**: Phase 1 (設計)  
**功能**: 001-camera-currency-converter

---

## 實體定義

### 1. CurrencySettings (貨幣設定)

**用途**: 存儲用戶配置的貨幣名稱和匯率，用於轉換計算。

**欄位**:
- `currencyName: String` — 外幣名稱 (例如："JPY", "USD", "EUR")
  - 限制條件: 最多 20 字元，不可為空
  - 類型: 用戶可編輯的 TextField 輸入

- `exchangeRate: Decimal` — 匯率 (外幣 → 台幣)
  - 限制條件: 0.0001 ≤ 匯率 ≤ 10000
  - 範例: 0.22 (1 JPY = 0.22 TWD)
  - 類型: Decimal (金融精度)
  - 驗證: 必須 > 0

- `lastUpdated: Date` (可選)
  - 設定最後修改時間戳
  - 用於 UI 顯示和匯出

**計算屬性**:
- `isValid() -> Bool`: 當 currencyName 非空且 exchangeRate 在有效範圍內時返回 true

**驗證規則**:
- currencyName: 不可為空；必須 ≤20 字元
- exchangeRate: 必須 > 0 且 ≤ 10000
- 如果任一驗證失敗，`isValid()` 返回 false，UI 禁用「開始掃描」按鈕

**持久化**:
- 存儲位置: UserDefaults
- 格式: Codable (Swift 自動 JSON 序列化)
- Key: `"currencySettings"`
- 啟動時恢復: 是，使用之前的值預填充表單
- 生命週期: 跨應用重啟持久化，僅當用戶明確更改時更新

---

### 2. ConversionRecord (轉換記錄)

**用途**: 存儲檢測和轉換的價格歷史記錄，供用戶參考。

**欄位**:
- `id: UUID` — 唯一標識符
  - 創建時自動生成
  - 用於去重（如需要）

- `originalPrice: Decimal` — 從相機檢測的價格（外幣）
  - 範例: 3500 (JPY)
  - 精度: 2 位小數

- `convertedAmount: Decimal` — 轉換後的台幣價格
  - 計算: originalPrice × exchangeRate
  - 範例: 770.00 (TWD)
  - 精度: 2 位小數，銀行家捨入

- `currencyName: String` — 轉換時的貨幣名稱（快照）
  - 快照原因: 即使用戶更改設定也保留原始匯率
  - 範例: "JPY"

- `exchangeRate: Decimal` — 此次轉換使用的匯率（快照）
  - 快照原因: 顯示使用了哪個匯率
  - 範例: 0.22

- `timestamp: Date` — 檢測和記錄轉換的時間
  - 格式: ISO 8601 (JSON 中序列化為字符串)
  - 用於排序（最近的優先）

**關係**:
- 創建自: CurrencySettings (在檢測時複製 currencyName 和 exchangeRate)
- 關聯: 用戶設備歷史記錄（一台設備 = 一個歷史文件）

**持久化**:
- 存儲位置: FileManager (JSON 文件在 app 的 Documents 目錄)
- 格式: Codable 數組: `[ConversionRecord]`
- 文件路徑: `Documents/conversion_history.json`

**保留策略**:
- 保留最近 50 條記錄
- 當數量超過 50 時自動清除最舊記錄
- 啟動時: 加載完整歷史，僅保留最近 50 條

**計算屬性**:
- `formattedAmount() -> String`: 返回台幣符號 + 金額 (例如: "NT$ 770.00")
- `formattedOriginalPrice() -> String`: 返回貨幣 + 金額 (例如: "JPY 3500")
- `formattedTimestamp() -> String`: 相對時間 (例如: "2 分鐘前") 或絕對時間 (例如: "14:30")

---

### 3. DetectedNumber (檢測到的數字)

**用途**: 相機幀中檢測到的數字的短暫表示（用於疊加渲染）。

**欄位**:
- `value: Decimal` — 檢測到的數值
  - 範例: 3500
  - 來源: Vision framework 文字識別
  - 精度: 可能是整數或小數；標準化為 Decimal

- `boundingBox: CGRect` — 檢測到數字的屏幕座標
  - `origin`: 左上角 (x, y)
  - `size`: 寬度和高度
  - 用途: 疊加定位（在此位置繪製轉換後的價格）
  - 座標系統: Vision framework 標準化 (0.0–1.0)，需要轉換為屏幕座標

- `confidence: Double` — Vision framework 信心度分數 (0.0–1.0)
  - 1.0 = 高信心，0.0 = 低信心
  - 篩選: 僅當信心度 > 0.5 時顯示疊加（可調閾值）
  - 用途: 準確度測量和調試

**生命週期**:
- 創建期間: 每個幀處理（Vision 檢測）
- 銷毀後: 幀處理完成且疊加渲染（通常每幀 33–200ms）
- 範圍: 僅單個幀；不持久化
- 記憶體: 短暫，無永久存儲

**關係**:
- 來源: VisionService (從相機幀檢測文字)
- 使用者: CameraViewModel (決定哪些數字要疊加)
- 轉換為: ConversionRecord (當用戶確認檢測或基於時間自動保存)

---

## 數據庫架構 (FileManager JSON)

### 文件結構
**文件**: `Documents/conversion_history.json`  
**格式**: ConversionRecord 對象的 JSON 數組

```json
[
  {
    "id": "550E8400-E29B-41D4-A716-446655440000",
    "originalPrice": "3500",
    "convertedAmount": "770.00",
    "currencyName": "JPY",
    "exchangeRate": "0.22",
    "timestamp": "2025-12-02T14:30:00Z"
  }
]
```

### 序列化
- 數字序列化為字符串 (Decimal → String → JSON)
- 日期序列化為 ISO 8601 字符串 (Date → String → JSON)
- 標準 Codable 實現處理序列化/反序列化

---

## 關係與依賴

### CurrencySettings → ConversionRecord
- 檢測發生時，CurrencySettings (currencyName, exchangeRate) 被複製到 ConversionRecord
- 快照策略: 即使用戶稍後更改設定也保留歷史匯率
- 原因: 用戶可以追蹤每次轉換使用了什麼匯率

### CurrencySettings → CameraViewModel
- CameraViewModel 在每次幀處理時讀取當前設定
- 實時更新疊加轉換顯示
- 監聽: 使用 Combine @Published 屬性訂閱設定更改

### DetectedNumber → ConversionRecord
- 當檢測到數字並且用戶確認時，DetectedNumber 轉換為 ConversionRecord
- 提取欄位: originalPrice, boundingBox (顯示後丟棄)
- 新增欄位: id, convertedAmount, currencyName, exchangeRate (來自當前設定), timestamp

---

## 驗證與限制

### CurrencySettings 驗證
```swift
struct CurrencySettings: Codable {
    var currencyName: String
    var exchangeRate: Decimal

    func validate() throws {
        guard !currencyName.isEmpty else {
            throw ValidationError.emptyCurrencyName
        }
        guard currencyName.count <= 20 else {
            throw ValidationError.currencyNameTooLong
        }
        guard exchangeRate > 0 else {
            throw ValidationError.rateNotPositive
        }
        guard exchangeRate <= 10000 else {
            throw ValidationError.rateTooLarge
        }
    }

    var isValid: Bool {
        (try? validate()) != nil
    }
}
```

---

## 狀態轉換與生命週期

### CurrencySettings 生命週期
```
[應用啟動]
    ↓
[從 UserDefaults 加載]
    ↓
[在 SettingsView 中顯示]
    ↓
[用戶編輯欄位] ← 用戶確認有效輸入 → [保存到 UserDefaults]
    ↓
[用於所有後續檢測]
    ↓
[應用後台/終止]
    ↓
[在 UserDefaults 中持久化]
```

### ConversionRecord 生命週期
```
[Vision 檢測數字] → [創建 DetectedNumber]
    ↓
[CameraViewModel 接收 DetectedNumber]
    ↓
[使用當前 CurrencySettings 計算轉換]
    ↓
[創建 ConversionRecord] → [自動附加到歷史]
    ↓
[寫入 FileManager] → [如果數量 > 50 則清除]
    ↓
[在 HistoryView 中顯示] ← 用戶點擊查看/複製
    ↓
[持久化直到自動清除或用戶清除歷史]
```

---

## 類型定義 (Swift)

```swift
// Models/CurrencySettings.swift
import Foundation

struct CurrencySettings: Codable, Equatable {
    var currencyName: String
    var exchangeRate: Decimal
    var lastUpdated: Date = Date()

    var isValid: Bool {
        !currencyName.isEmpty &&
        currencyName.count <= 20 &&
        exchangeRate > 0 &&
        exchangeRate <= 10000
    }
}

// Models/ConversionRecord.swift
import Foundation

struct ConversionRecord: Codable, Identifiable {
    var id: UUID = UUID()
    var originalPrice: Decimal
    var convertedAmount: Decimal
    var currencyName: String
    var exchangeRate: Decimal
    var timestamp: Date = Date()

    var formattedAmount: String {
        return String(format: "NT$ %.2f", NSDecimalNumber(decimal: convertedAmount).doubleValue)
    }

    var formattedOriginalPrice: String {
        return "\(currencyName) \(originalPrice)"
    }
}

// Models/DetectedNumber.swift
import Foundation
import CoreGraphics

struct DetectedNumber {
    var value: Decimal
    var boundingBox: CGRect
    var confidence: Double
}
```

---

## 測試策略

### 單元測試
- **CurrencySettingsTests**: 驗證邏輯（有效/無效輸入）
- **ConversionRecordTests**: 格式化函數，Codable 序列化
- **DetectedNumberTests**: 構造函數，屬性訪問

### 整合測試
- **StorageServiceTests**: 通過 UserDefaults 保存/加載 CurrencySettings
- **HistoryStorageTests**: 保存/加載 ConversionRecord 數組，保留策略（保留 50 條最近記錄）
- **CodableTests**: 邊緣情況的 JSON 序列化/反序列化（Decimal 精度，Date 格式）

### 準確度測試
- **VisionServiceTests**: 加載測試圖像，比較檢測值與真實值，測量準確度 %

---

最後更新：2025-12-05
