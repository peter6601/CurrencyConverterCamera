//
//  ConversionRecord.swift
//  CurrencyConverterCamera
//
//  Created by Claude on 2025-12-02.
//

import Foundation

/// Represents a single detected and converted price for historical reference.
///
/// Stores the original detected price, the converted TWD amount, and metadata
/// about when the conversion occurred and which rate was used.
/// Implements Identifiable for use in SwiftUI Lists.
struct ConversionRecord: Codable, Identifiable, Equatable {
    /// Unique identifier for this conversion
    var id: UUID

    /// Original price detected from camera (in foreign currency)
    /// Example: 3500 (JPY)
    var originalPrice: Decimal

    /// Converted price to TWD
    /// Calculated as: originalPrice × exchangeRate
    /// Rounded to 2 decimal places
    /// Example: 770.00 (TWD)
    var convertedAmount: Decimal

    /// Foreign currency name at time of conversion (snapshot)
    /// Example: "JPY"
    var currencyName: String

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
        currencyName: String,
        exchangeRate: Decimal,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.originalPrice = originalPrice
        self.convertedAmount = convertedAmount
        self.currencyName = currencyName
        self.exchangeRate = exchangeRate
        self.timestamp = timestamp
    }

    // MARK: - Computed Properties

    /// Formatted converted amount for display
    /// Example: "NT$ 770.00"
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "NT$ "
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        let nsDecimal = convertedAmount as NSDecimalNumber
        return formatter.string(from: nsDecimal) ?? "NT$ 0.00"
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
        return "\(currencyName) \(amountStr)"
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

    enum CodingKeys: String, CodingKey {
        case id
        case originalPrice
        case convertedAmount
        case currencyName
        case exchangeRate
        case timestamp
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        originalPrice = try container.decode(Decimal.self, forKey: .originalPrice)
        convertedAmount = try container.decode(Decimal.self, forKey: .convertedAmount)
        currencyName = try container.decode(String.self, forKey: .currencyName)
        exchangeRate = try container.decode(Decimal.self, forKey: .exchangeRate)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(originalPrice, forKey: .originalPrice)
        try container.encode(convertedAmount, forKey: .convertedAmount)
        try container.encode(currencyName, forKey: .currencyName)
        try container.encode(exchangeRate, forKey: .exchangeRate)
        try container.encode(timestamp, forKey: .timestamp)
    }
}
