//
//  CurrencySettings.swift
//  CurrencyConverterCamera
//
//  Created by Claude on 2025-12-02.
//

import Foundation

/// Represents user-configured currency and exchange rate for conversion calculations.
///
/// This model stores the foreign currency name and exchange rate (foreign → TWD).
/// All fields are validated before being considered valid for use in conversions.
struct CurrencySettings: Codable, Equatable {
    /// Foreign currency name (e.g., "JPY", "USD", "EUR")
    /// Constraint: max 20 characters, non-empty
    var currencyName: String

    /// Exchange rate (foreign currency → TWD)
    /// Constraint: 0.0001 ≤ rate ≤ 10000
    /// Example: 0.22 (1 JPY = 0.22 TWD)
    var exchangeRate: Decimal

    /// Timestamp when settings were last modified
    var lastUpdated: Date

    /// Default initializer
    init(currencyName: String, exchangeRate: Decimal, lastUpdated: Date = Date()) {
        self.currencyName = currencyName
        self.exchangeRate = exchangeRate
        self.lastUpdated = lastUpdated
    }

    /// Computed property: Check if settings are valid for use
    ///
    /// Returns true only if both:
    /// - currencyName is non-empty AND ≤20 characters
    /// - exchangeRate is > 0 AND ≤ 10000
    var isValid: Bool {
        !currencyName.isEmpty &&
        currencyName.count <= 20 &&
        exchangeRate > 0 &&
        exchangeRate <= 10000
    }

    /// Returns validation error if settings are invalid, nil if valid
    var validationError: ValidationError? {
        if currencyName.isEmpty {
            return .emptyCurrencyName
        }
        if currencyName.count > 20 {
            return .currencyNameTooLong
        }
        if exchangeRate <= 0 {
            return .exchangeRateNotPositive
        }
        if exchangeRate > 10000 {
            return .exchangeRateTooLarge
        }
        return nil
    }

    /// Validation errors for CurrencySettings
    enum ValidationError: Error, Equatable {
        case emptyCurrencyName
        case currencyNameTooLong
        case exchangeRateNotPositive
        case exchangeRateTooLarge

        var description: String {
            switch self {
            case .emptyCurrencyName:
                return "Currency name cannot be empty"
            case .currencyNameTooLong:
                return "Currency name must be 20 characters or less"
            case .exchangeRateNotPositive:
                return "Exchange rate must be greater than 0"
            case .exchangeRateTooLarge:
                return "Exchange rate must be 10000 or less"
            }
        }
    }

    // MARK: - Codable Conformance

    enum CodingKeys: String, CodingKey {
        case currencyName
        case exchangeRate
        case lastUpdated
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currencyName = try container.decode(String.self, forKey: .currencyName)
        exchangeRate = try container.decode(Decimal.self, forKey: .exchangeRate)
        lastUpdated = try container.decode(Date.self, forKey: .lastUpdated)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(currencyName, forKey: .currencyName)
        try container.encode(exchangeRate, forKey: .exchangeRate)
        try container.encode(lastUpdated, forKey: .lastUpdated)
    }
}
