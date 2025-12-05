//
//  TestHelper.swift
//  CurrencyConverterCameraTests
//
//  Created by Claude on 2025-12-02.
//

import Foundation
@testable import CurrencyConverterCamera
import CoreGraphics

/// Test helper functions for creating mock objects
enum TestHelper {
    // MARK: - Mock CurrencySettings

    /// Create a valid CurrencySettings for testing
    /// - Parameters:
    ///   - currency: Currency name (default: "JPY")
    ///   - rate: Exchange rate (default: 0.22)
    /// - Returns: Valid CurrencySettings instance
    static func createValidSettings(
        currency: String = "JPY",
        rate: Decimal = 0.22
    ) -> CurrencySettings {
        CurrencySettings(
            currencyName: currency,
            exchangeRate: rate
        )
    }

    /// Create an invalid CurrencySettings with empty currency name
    static func createInvalidSettingsEmptyName() -> CurrencySettings {
        CurrencySettings(
            currencyName: "",
            exchangeRate: 0.22
        )
    }

    /// Create an invalid CurrencySettings with zero exchange rate
    static func createInvalidSettingsZeroRate() -> CurrencySettings {
        CurrencySettings(
            currencyName: "JPY",
            exchangeRate: 0
        )
    }

    /// Create an invalid CurrencySettings with too-large exchange rate
    static func createInvalidSettingsTooLargeRate() -> CurrencySettings {
        CurrencySettings(
            currencyName: "JPY",
            exchangeRate: 10001
        )
    }

    /// Create an invalid CurrencySettings with currency name too long
    static func createInvalidSettingsNameTooLong() -> CurrencySettings {
        CurrencySettings(
            currencyName: "CURRENCYNAMETOOLONGFORTESTING",
            exchangeRate: 0.22
        )
    }

    // MARK: - Mock ConversionRecord

    /// Create a ConversionRecord for testing
    /// - Parameters:
    ///   - original: Original price (default: 3500)
    ///   - converted: Converted amount (default: 770.00)
    ///   - currency: Currency name (default: "JPY")
    ///   - rate: Exchange rate (default: 0.22)
    ///   - timestamp: Record timestamp (default: now)
    /// - Returns: ConversionRecord instance
    static func createConversionRecord(
        original: Decimal = 3500,
        converted: Decimal = 770.00,
        currency: String = "JPY",
        rate: Decimal = 0.22,
        timestamp: Date = Date()
    ) -> ConversionRecord {
        ConversionRecord(
            originalPrice: original,
            convertedAmount: converted,
            currencyName: currency,
            exchangeRate: rate,
            timestamp: timestamp
        )
    }

    /// Create multiple ConversionRecords for testing
    /// - Parameters:
    ///   - count: Number of records to create (default: 5)
    ///   - spacing: Time spacing between records in seconds (default: 60)
    /// - Returns: Array of ConversionRecord instances
    static func createConversionRecords(count: Int = 5, spacing: TimeInterval = 60) -> [ConversionRecord] {
        var records: [ConversionRecord] = []
        let now = Date()

        for i in 0..<count {
            let timestamp = now.addingTimeInterval(-Double(i) * spacing)
            let record = createConversionRecord(
                original: Decimal(3500 + i * 100),
                converted: Decimal(770 + i * 20),
                timestamp: timestamp
            )
            records.append(record)
        }

        return records
    }

    // MARK: - Mock DetectedNumber

    /// Create a DetectedNumber for testing
    /// - Parameters:
    ///   - value: Detected number value (default: 3500)
    ///   - boundingBox: Normalized bounding box (default: centered)
    ///   - confidence: Detection confidence (default: 0.95)
    /// - Returns: DetectedNumber instance
    static func createDetectedNumber(
        value: Decimal = 3500,
        boundingBox: CGRect = CGRect(x: 0.3, y: 0.4, width: 0.4, height: 0.2),
        confidence: Double = 0.95
    ) -> DetectedNumber {
        DetectedNumber(
            value: value,
            boundingBox: boundingBox,
            confidence: confidence
        )
    }

    /// Create a DetectedNumber with low confidence
    static func createDetectedNumberLowConfidence() -> DetectedNumber {
        DetectedNumber(
            value: 3500,
            boundingBox: CGRect(x: 0.3, y: 0.4, width: 0.4, height: 0.2),
            confidence: 0.3
        )
    }

    /// Create a DetectedNumber with invalid bounding box
    static func createDetectedNumberInvalidBox() -> DetectedNumber {
        DetectedNumber(
            value: 3500,
            boundingBox: CGRect(x: -0.1, y: 0.4, width: 0.4, height: 0.2),
            confidence: 0.95
        )
    }

    // MARK: - Test Data

    /// Valid test exchange rates
    static let validExchangeRates: [Decimal] = [
        0.0001,
        0.22,      // JPY
        31.35,     // USD
        35.50,     // EUR
        9999.99,
        10000
    ]

    /// Invalid test exchange rates
    static let invalidExchangeRates: [Decimal] = [
        -0.5,
        0,
        10000.01,
        99999
    ]

    /// Valid test currency names
    static let validCurrencyNames: [String] = [
        "JPY",
        "USD",
        "EUR",
        "GBP",
        "CHF",
        "CAD",
        "AUD"
    ]

    /// Invalid test currency names
    static let invalidCurrencyNames: [String] = [
        "",
        String(repeating: "A", count: 21)  // Too long
    ]

    // MARK: - Cleanup

    /// Clean up test files and data
    static func cleanup() throws {
        let fileManager = FileManager.default
        guard let documentsPath = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true
        ).first else {
            return
        }

        let historyURL = URL(fileURLWithPath: documentsPath)
            .appendingPathComponent("conversion_history.json")

        if fileManager.fileExists(atPath: historyURL.path) {
            try fileManager.removeItem(at: historyURL)
        }

        UserDefaults.standard.removeObject(forKey: "currencySettings")
        UserDefaults.standard.synchronize()
    }
}
