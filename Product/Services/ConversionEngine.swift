//
//  ConversionEngine.swift
//  CurrencyConverterCamera
//
//  Created by Claude on 2025-12-03.
//

import Foundation

/// Engine for currency conversion calculations
class ConversionEngine {
    // MARK: - Conversion Error

    enum ConversionError: Error, Equatable {
        case invalidPrice
        case invalidRate
        case conversionFailed
    }

    // MARK: - Initialization

    init() {
        AppLogger.debug("ConversionEngine initialized", category: AppLogger.general)
    }

    // MARK: - Conversion

    /// Converts a price from one currency to another using the provided rate
    /// - Parameters:
    ///   - price: The price to convert
    ///   - sourceCurrency: Source currency code (e.g., "USD")
    ///   - targetCurrency: Target currency code (e.g., "JPY")
    ///   - rate: Exchange rate to apply
    /// - Returns: Converted amount
    /// - Throws: ConversionError if inputs are invalid
    func convertPrice(
        _ price: Decimal,
        from sourceCurrency: String,
        to targetCurrency: String,
        using rate: Decimal
    ) throws -> Decimal {
        // Validate inputs
        guard price >= 0 else {
            AppLogger.error("Invalid price: \(price)", error: nil, category: AppLogger.general)
            throw ConversionError.invalidPrice
        }

        guard rate > 0 else {
            AppLogger.error("Invalid rate: \(rate)", error: nil, category: AppLogger.general)
            throw ConversionError.invalidRate
        }

        // If price is 0, return 0
        if price == 0 {
            return Decimal(0)
        }

        // Perform conversion
        let result = price * rate

        AppLogger.debug(
            "Converted \(price) \(sourceCurrency) to \(result) \(targetCurrency) using rate \(rate)",
            category: AppLogger.general
        )

        return result
    }

    // MARK: - Formatting

    /// Formats a decimal amount as a currency string
    /// - Parameters:
    ///   - amount: The amount to format
    ///   - currency: The currency code
    /// - Returns: Formatted currency string
    func formatResult(_ amount: Decimal, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 4

        let numberString = formatter.string(from: amount as NSDecimalNumber) ?? amount.description

        return "\(numberString) \(currency)"
    }

    /// Rounds a decimal to 2 decimal places
    /// - Parameter amount: The amount to round
    /// - Returns: Rounded amount
    func roundToTwoDecimals(_ amount: Decimal) -> Decimal {
        var result = amount
        var source = amount
        NSDecimalRound(&result, &source, 2, .plain)
        return result
    }

    /// Calculates the relative difference between two amounts
    /// - Parameters:
    ///   - original: Original amount
    ///   - converted: Converted amount
    /// - Returns: Percentage difference
    func calculateDifference(_ original: Decimal, _ converted: Decimal) -> Decimal {
        guard original != 0 else { return 0 }
        let difference = converted - original
        return (difference / original) * 100
    }
}

