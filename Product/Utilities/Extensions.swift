//
//  Extensions.swift
//  CurrencyConverterCamera
//
//  Created by Claude on 2025-12-02.
//

import CoreGraphics
import Foundation

// MARK: - String Extensions

extension String {
    /// Validate if string is a valid currency name
    /// - Returns: true if non-empty and ≤ 20 characters
    var isValidCurrencyName: Bool {
        !self.isEmpty && self.count <= Constants.maxCurrencyNameLength
    }

    /// Trim whitespace and newlines
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Check if string contains only alphanumeric characters
    var isAlphanumeric: Bool {
        !isEmpty && allSatisfy { $0.isLetter || $0.isNumber }
    }
}

// MARK: - Decimal Extensions

extension Decimal {
    /// Validate if Decimal is a valid exchange rate
    /// - Returns: true if > 0 and ≤ 10000
    var isValidExchangeRate: Bool {
        self > 0 && self <= Constants.maxExchangeRate
    }

    /// Round Decimal to specified number of decimal places
    /// - Parameter places: Number of decimal places (default: 2)
    /// - Returns: Rounded Decimal
    func rounded(to places: Int = 2) -> Decimal {
        var result = self
        var rounded = Decimal()
        NSDecimalRound(&rounded, &result, places, .plain)
        return rounded
    }

    /// Convert Decimal to formatted currency string
    /// - Parameter currencySymbol: Symbol to display (default: "NT$ ")
    /// - Returns: Formatted string (e.g., "NT$ 770.00")
    func formattedAsCurrency(symbol: String = "NT$ ") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = symbol
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        let nsDecimal = self as NSDecimalNumber
        return formatter.string(from: nsDecimal) ?? symbol + "0.00"
    }

    /// Convert Decimal to Double for calculations
    var doubleValue: Double {
        Double(truncating: self as NSDecimalNumber)
    }

    /// Convert Decimal to Int for integer operations
    var intValue: Int {
        Int(truncating: self as NSDecimalNumber)
    }
}

// MARK: - Date Extensions

extension Date {
    /// Get relative time description
    /// - Returns: String like "2 minutes ago" or "3 hours ago"
    var relativeTimeString: String {
        let now = Date()
        let interval = now.timeIntervalSince(self)

        if interval < 60 {
            return "just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) minute\(minutes > 1 ? "s" : "") ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours) hour\(hours > 1 ? "s" : "") ago"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: self)
        }
    }

    /// Check if date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /// Check if date is yesterday
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
}

// MARK: - CGRect Extensions

extension CGRect {
    /// Convert from Vision-normalized coordinates (0-1) to screen coordinates
    /// - Parameter screenSize: Size of the display area
    /// - Returns: Adjusted CGRect in screen space
    func toScreenCoordinates(screenSize: CGSize) -> CGRect {
        CGRect(
            x: self.minX * screenSize.width,
            y: self.minY * screenSize.height,
            width: self.width * screenSize.width,
            height: self.height * screenSize.height
        )
    }

    /// Check if bounding box is valid (non-zero size, within [0,1] bounds)
    var isValidNormalizedBox: Bool {
        self.width > 0 && self.height > 0 && self.minX >= 0 && self.minY >= 0 && self.maxX <= 1.0
            && self.maxY <= 1.0
    }

    /// Get center point of bounding box
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }

    /// Expand bounding box by percentage
    /// - Parameter percentage: Expansion percentage (0.1 = 10%)
    /// - Returns: Expanded CGRect
    func expanded(by percentage: CGFloat) -> CGRect {
        let dWidth = width * percentage
        let dHeight = height * percentage
        return CGRect(
            x: minX - dWidth / 2,
            y: minY - dHeight / 2,
            width: width + dWidth,
            height: height + dHeight
        )
    }
}

// MARK: - Array Extensions

extension Array where Element == ConversionRecord {
    /// Filter records by currency name
    /// - Parameter currency: Currency name to filter (foreign currency)
    /// - Returns: Records matching the currency
    func filterByCurrency(_ currency: String) -> [ConversionRecord] {
        filter { $0.foreignCurrency == currency }
    }

    /// Filter records by date range
    /// - Parameters:
    ///   - from: Start date (inclusive)
    ///   - to: End date (inclusive)
    /// - Returns: Records within the date range
    func filterByDateRange(from: Date, to: Date) -> [ConversionRecord] {
        filter { $0.timestamp >= from && $0.timestamp <= to }
    }

    /// Calculate total converted amount
    /// - Returns: Sum of all convertedAmount values
    var totalConverted: Decimal {
        reduce(0) { $0 + $1.convertedAmount }
    }

    /// Get average converted amount
    /// - Returns: Average of convertedAmount values
    var averageConverted: Decimal {
        guard !isEmpty else { return 0 }
        return totalConverted / Decimal(count)
    }
}
