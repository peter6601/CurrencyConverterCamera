//
//  CurrencySettings.swift
//  CurrencyConverterCamera
//
//  Created by Claude on 2025-12-02.
//

import Foundation

/// Represents user-configured currency and exchange rate for conversion calculations.
///
/// This model stores the foreign currency name, local currency name, and exchange rate.
/// All fields are validated before being considered valid for use in conversions.
struct CurrencySettings: Codable, Equatable {
    /// Foreign currency code (e.g., "JPY", "USD", "EUR")
    /// Constraint: max 20 characters, non-empty
    var foreignCurrency: String

    /// Local currency code (e.g., "NTD", "TWD", "HKD")
    /// Constraint: max 20 characters, non-empty
    var localCurrency: String

    /// Exchange rate (foreign currency → local currency)
    /// Constraint: 0.0001 ≤ rate ≤ 10000
    /// Example: 0.22 (1 JPY = 0.22 TWD)
    var exchangeRate: Decimal

    /// Timestamp when settings were last modified
    var lastUpdated: Date

    /// Default initializer
    init(
        foreignCurrency: String, localCurrency: String, exchangeRate: Decimal,
        lastUpdated: Date = Date()
    ) {
        self.foreignCurrency = foreignCurrency
        self.localCurrency = localCurrency
        self.exchangeRate = exchangeRate
        self.lastUpdated = lastUpdated
    }

    /// Computed property: Check if settings are valid for use
    ///
    /// Returns true only if:
    /// - foreignCurrency is non-empty AND <= 20 characters
    /// - localCurrency is non-empty AND <= 20 characters
    /// - exchangeRate is > 0 AND <= 10000
    var isValid: Bool {
        !foreignCurrency.isEmpty && foreignCurrency.count <= 20 && !localCurrency.isEmpty
            && localCurrency.count <= 20 && exchangeRate > 0 && exchangeRate <= 10000
    }

    /// Returns validation error if settings are invalid, nil if valid
    var validationError: ValidationError? {
        if foreignCurrency.isEmpty {
            return .emptyForeignCurrency
        }
        if foreignCurrency.count > 20 {
            return .foreignCurrencyTooLong
        }
        if localCurrency.isEmpty {
            return .emptyLocalCurrency
        }
        if localCurrency.count > 20 {
            return .localCurrencyTooLong
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
        case emptyForeignCurrency
        case foreignCurrencyTooLong
        case emptyLocalCurrency
        case localCurrencyTooLong
        case exchangeRateNotPositive
        case exchangeRateTooLarge

        var description: String {
            switch self {
            case .emptyForeignCurrency:
                return "Foreign currency code cannot be empty"
            case .foreignCurrencyTooLong:
                return "Foreign currency code must be 20 characters or less"
            case .emptyLocalCurrency:
                return "Local currency code cannot be empty"
            case .localCurrencyTooLong:
                return "Local currency code must be 20 characters or less"
            case .exchangeRateNotPositive:
                return "Exchange rate must be greater than 0"
            case .exchangeRateTooLarge:
                return "Exchange rate must be 10000 or less"
            }
        }
    }

    // MARK: - Codable Conformance
    // Default Codable implementation is sufficient since property names match
}
