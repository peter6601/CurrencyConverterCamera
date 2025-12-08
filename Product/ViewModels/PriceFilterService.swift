//
//  PriceFilterService.swift
//  CurrencyConverterCamera
//
//  Created by Claude on 2025-12-09.
//

import Foundation
import CoreGraphics

/// Service for intelligently filtering price detections
class PriceFilterService {
    
    // MARK: - Singleton
    
    static let shared = PriceFilterService()
    
    private init() {}
    
    // MARK: - Smart Filtering
    
    /// 智能过滤：只保留看起来像价格的数字
    func filterPrices(_ detections: [DetectedNumber], mode: FilterMode = .balanced) -> [DetectedNumber] {
        let filtered = detections.filter { detection in
            isValidPrice(detection, mode: mode)
        }
        
        // 按数值大小排序，通常最大的价格是主要商品价格
        return filtered.sorted { a, b in
            let aValue = NSDecimalNumber(decimal: a.value).doubleValue
            let bValue = NSDecimalNumber(decimal: b.value).doubleValue
            return aValue > bValue
        }
    }
    
    // MARK: - Filter Mode
    
    enum FilterMode {
        case strict     // 严格模式：只保留高度可能的价格
        case balanced   // 平衡模式：平衡准确率和召回率
        case lenient    // 宽松模式：保留更多可能的价格
    }
    
    // MARK: - Private Validation
    
    private func isValidPrice(_ detection: DetectedNumber, mode: FilterMode) -> Bool {
        let value = NSDecimalNumber(decimal: detection.value).doubleValue
        
        // 规则 1: 价格范围检查
        let (minPrice, maxPrice) = priceRange(for: mode)
        guard value >= minPrice && value <= maxPrice else {
            AppLogger.debug(
                "❌ Filtered (range): \(value) not in [\(minPrice), \(maxPrice)]",
                category: AppLogger.general
            )
            return false
        }
        
        // 规则 2: 过滤常见容量数字（药品/保健品）
        if isCommonCapacity(value) {
            AppLogger.debug(
                "❌ Filtered (capacity): \(value)",
                category: AppLogger.general
            )
            return false
        }
        
        // 规则 3: 价格结尾检查（日本/台湾常见）
        // 对于有价格结尾的数字，放宽其他限制
        let hasPriceEnding = hasPriceLikeEnding(Int(value))
        
        if mode == .strict || mode == .balanced {
            if !hasPriceEnding && value < 1000 {
                AppLogger.debug(
                    "❌ Filtered (ending): \(value) doesn't look like a price",
                    category: AppLogger.general
                )
                return false
            }
        }
        
        // 规则 4: 边界框大小检查（价格文字通常较大）
        // 但是对于明显的价格（有价格结尾且在合理范围内），放宽大小限制
        let minHeight = minimumTextHeight(for: mode)
        let isLikelyPrice = hasPriceEnding && value >= 100 && value <= 100_000
        
        if detection.boundingBox.height < minHeight && !isLikelyPrice {
            AppLogger.debug(
                "❌ Filtered (size): \(value), height: \(detection.boundingBox.height) < \(minHeight)",
                category: AppLogger.general
            )
            return false
        }
        
        // 规则 5: 过滤掉看起来像日期或编号的数字
        if looksLikeDateOrCode(value) {
            AppLogger.debug(
                "❌ Filtered (date/code): \(value)",
                category: AppLogger.general
            )
            return false
        }
        
        AppLogger.debug(
            "✅ Valid price: \(value), hasPriceEnding: \(hasPriceEnding), isLikelyPrice: \(isLikelyPrice)",
            category: AppLogger.general
        )
        return true
    }
    
    // MARK: - Helper Methods
    
    private func priceRange(for mode: FilterMode) -> (min: Double, max: Double) {
        switch mode {
        case .strict:
            return (50, 500_000)    // 严格：50 ~ 50万
        case .balanced:
            return (10, 1_000_000)  // 平衡：10 ~ 100万
        case .lenient:
            return (1, 10_000_000)  // 宽松：1 ~ 1000万
        }
    }
    
    private func minimumTextHeight(for mode: FilterMode) -> Double {
        switch mode {
        case .strict:
            return 0.025    // 2.5% of screen height
        case .balanced:
            return 0.015    // 1.5% of screen height
        case .lenient:
            return 0.008    // 0.8% of screen height
        }
    }
    
    /// 检查是否为常见容量数字
    private func isCommonCapacity(_ value: Double) -> Bool {
        // 常见药品/保健品容量：30, 60, 90, 120, 180, 270, 360 粒
        let commonCapacities: Set<Int> = [30, 60, 90, 120, 180, 270, 360]
        
        // 精确匹配
        if commonCapacities.contains(Int(value)) {
            return true
        }
        
        // 容忍度 ±3
        for capacity in commonCapacities {
            if abs(value - Double(capacity)) <= 3 {
                return true
            }
        }
        
        return false
    }
    
    /// 检查是否有价格常见的结尾
    private func hasPriceLikeEnding(_ value: Int) -> Bool {
        let lastDigit = value % 10
        let lastTwoDigits = value % 100
        
        // 日本/台湾常见价格结尾
        // 80: 980, 1980, 4980
        // 90: 990, 1990
        // 00: 1000, 2000, 5000
        // 50: 250, 350, 1050
        // 8/9: 98, 198, 298
        
        return lastTwoDigits == 80 || lastTwoDigits == 90 || 
               lastTwoDigits == 0 || lastTwoDigits == 50 ||
               lastTwoDigits == 98 || lastTwoDigits == 99 ||
               lastDigit == 8 || lastDigit == 9 || lastDigit == 0
    }
    
    /// 检查是否看起来像日期或产品编号
    private func looksLikeDateOrCode(_ value: Double) -> Bool {
        let intValue = Int(value)
        
        // 可能是年份：2020-2030
        if intValue >= 2020 && intValue <= 2030 {
            return true
        }
        
        // 可能是月日：0101-1231 (MMDD格式)
        if intValue >= 101 && intValue <= 1231 {
            let month = intValue / 100
            let day = intValue % 100
            if month >= 1 && month <= 12 && day >= 1 && day <= 31 {
                return true
            }
        }
        
        // 可能是批号或序列号的模式
        // 例如：12345, 54321 (五位连续数字，变化平滑)
        if intValue >= 10000 && intValue <= 99999 {
            let digits = String(intValue).compactMap { Int(String($0)) }
            if isSequentialOrRepetitive(digits) {
                return true
            }
        }
        
        return false
    }
    
    /// 检查数字是否为连续或重复模式
    private func isSequentialOrRepetitive(_ digits: [Int]) -> Bool {
        guard digits.count >= 4 else { return false }
        
        // 检查重复：1111, 2222, 5555
        let uniqueDigits = Set(digits)
        if uniqueDigits.count == 1 {
            return true
        }
        
        // 检查连续递增：1234, 2345
        var isIncreasing = true
        for i in 0..<(digits.count - 1) {
            if digits[i + 1] != digits[i] + 1 {
                isIncreasing = false
                break
            }
        }
        
        // 检查连续递减：4321, 5432
        var isDecreasing = true
        for i in 0..<(digits.count - 1) {
            if digits[i + 1] != digits[i] - 1 {
                isDecreasing = false
                break
            }
        }
        
        return isIncreasing || isDecreasing
    }
}
