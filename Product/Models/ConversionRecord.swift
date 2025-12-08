//
//  ConversionRecord.swift
//  CurrencyConverterCamera
//
//  Created by Claude on 2025-12-02.
//

import Foundation

/// Represents a single detected and converted price for historical reference.
///
/// Stores the original detected price, the converted amount, and metadata
/// about when the conversion occurred, which currencies were involved, and which rate was used.
/// Implements Identifiable for use in SwiftUI Lists.
struct ConversionRecord: Codable, Identifiable, Equatable {
    /// Unique identifier for this conversion
    var id: UUID

    /// Original price detected from camera (in foreign currency)
    /// Example: 3500 (JPY)
    var originalPrice: Decimal

    /// Converted price to local currency
    /// Calculated as: originalPrice × exchangeRate
    /// Rounded to 2 decimal places
    /// Example: 770.00 (NTD)
    var convertedAmount: Decimal

    /// Foreign currency code at time of conversion (snapshot)
    /// Example: "JPY"
    var foreignCurrency: String

    /// Local currency code at time of conversion (snapshot)
    /// Example: "NTD"
    var localCurrency: String

    /// Exchange rate used for this conversion (snapshot)
    /// Example: 0.22
    /// Stored as snapshot so users can see which rate was used for each conversion
    var exchangeRate: Decimal

    /// Timestamp when conversion was detected and recorded
    var timestamp: Date

    /// Default initializer
    init(
        id: UUID = UUID(),
        originalPrice: Decimal,
        convertedAmount: Decimal,
        foreignCurrency: String,
        localCurrency: String,
        exchangeRate: Decimal,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.originalPrice = originalPrice
        self.convertedAmount = convertedAmount
        self.foreignCurrency = foreignCurrency
        self.localCurrency = localCurrency
        self.exchangeRate = exchangeRate
        self.timestamp = timestamp
    }

    // MARK: - Computed Properties

    /// Formatted converted amount for display
    /// Example: "NTD 770.00"
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "\(localCurrency) "  // e.g. "NTD "
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        let nsDecimal = convertedAmount as NSDecimalNumber
        return formatter.string(from: nsDecimal) ?? "\(localCurrency) 0.00"
    }

    /// Formatted original price with currency name
    /// Example: "JPY 3500"
    var formattedOriginalPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2

        let nsDecimal = originalPrice as NSDecimalNumber
        let amountStr = formatter.string(from: nsDecimal) ?? "0"
        return "\(foreignCurrency) \(amountStr)"
    }

    /// Formatted timestamp for display
    /// Returns relative time (e.g., "2 minutes ago") or absolute time if older
    var formattedTimestamp: String {
        let now = Date()
        let interval = now.timeIntervalSince(timestamp)

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
            return formatter.string(from: timestamp)
        }
    }

    // MARK: - Codable Conformance
    // Default Codable implementation is sufficient
}
