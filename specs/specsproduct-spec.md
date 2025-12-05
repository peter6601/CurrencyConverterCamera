# Currency Converter Camera - Product Specification

## Document Metadata
- **Version**: 1.0.0
- **Last Updated**: December 2, 2024
- **Platform**: iOS (iPhone only)
- **Minimum iOS Version**: iOS 15.0+
- **Primary Language**: Traditional Chinese (zh-TW)
- **Development Framework**: SwiftUI + UIKit (for camera)
- **Development Methodology**: TDD (Test-Driven Development)
- **Architecture Pattern**: MVVM (Model-View-ViewModel)

本規格定義了即時相機貨幣轉換器應用的完整開發流程。

完整規格請參考原始 `/repo/product_spec.md` 文件。

## 快速導航

- [產品概述](#產品概述)
- [開發階段](#開發階段)
- [測試要求](#測試要求)
- [技術架構](#技術架構)

## 產品概述

創建一個基於相機的實時貨幣轉換器，幫助旅行者通過手機相機即時了解外幣價格對應的台幣價值。

### 目標用戶
- **主要**：前往日本、韓國、美國、歐洲的台灣旅客
- **次要**：瀏覽國際電商網站的線上購物者
- **第三**：需要快速比價的商務旅客

### 成功指標
- 識別準確度: >85% (清晰光線下)
- 識別延遲: <500ms
- 幀處理率: 5-8 FPS
- 電池效率: <每小時15%電量消耗
- 測試覆蓋率: >75%整體，關鍵路徑100%

## 開發階段

### 階段 0: 項目初始化 (15分鐘)
- 創建 Xcode 項目
- 配置測試目標
- 設置文件夾結構

### 階段 1: 設置頁面 (1.5小時)
- 匯率輸入與驗證
- 數據持久化
- 表單驗證

### 階段 2: 相機導航 (30分鐘)
- 按鈕與導航流程
- 設置數據傳遞

### 階段 3: 相機預覽 (2小時)
- AVFoundation 整合
- 權限處理
- 生命週期管理

### 階段 4: 文字識別 (2.5小時)
- Vision Framework OCR
- 幀處理節流
- 信心度篩選

### 階段 5: 數字解析 (1.5小時)
- 數字提取與解析
- 格式支持(逗號、小數點)
- Decimal 類型轉換

### 階段 6: 貨幣轉換 (1小時)
- 匯率計算
- 格式化輸出
- 千位分隔符

### 階段 7: 實時疊加顯示 (3小時)
- 座標轉換
- 防閃爍穩定機制
- 生產就緒優化

**總預估時間**: 12-15小時

## 測試要求

### 測試覆蓋率
- 整體覆蓋率 >75%
- 關鍵路徑 100%

### 測試策略
```
單元測試 (70%)
├── Models
├── ViewModels  
├── Services
└── Utilities

整合測試 (20%)
├── Service-to-Service
├── ViewModel-to-Service
└── 端到端管道

UI 測試 (10%)
├── 導航流程
├── 用戶互動
└── 權限處理
```

## 技術架構

### 架構模式
- MVVM (Model-View-ViewModel)
- Service Layer (業務邏輯)
- Repository Pattern (數據持久化)
- Delegate Pattern (相機回調)

### 系統框架
- SwiftUI (UI層)
- UIKit (相機相關)
- AVFoundation (相機捕捉)
- Vision (文字識別)
- Combine (響應式編程)

## 相關文檔

- [數據模型](./data-model.md)
- [階段實現指南](./phase-guides/)
- [問題修復](./fixes/)
- [功能更新](./updates/)
- [測試文檔](./testing/)

---

最後更新：2025-12-05
