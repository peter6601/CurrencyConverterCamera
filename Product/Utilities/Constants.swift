//
//  Constants.swift
//  CurrencyConverterCamera
//
//  Created by Claude on 2025-12-02.
//

import Foundation

/// App-wide constants for currency converter application
enum Constants {
    // MARK: - Currency Settings Constraints

    /// Maximum length for currency name (e.g., "JPY", "USD")
    static let maxCurrencyNameLength = 20

    /// Minimum allowed exchange rate
    static let minExchangeRate = Decimal(string: "0.0001") ?? 0.0001

    /// Maximum allowed exchange rate
    static let maxExchangeRate = Decimal(10000)

    // MARK: - History Constraints

    /// Maximum number of conversion records to store
    static let maxHistoryCount = 50

    // MARK: - Performance Targets

    /// Target frame rate for camera processing (frames per second)
    static let targetFPS: ClosedRange<Int> = 5...8

    /// Target detection latency (milliseconds)
    static let maxDetectionLatencyMs = 500

    /// Target recognition accuracy (percentage)
    static let minRecognitionAccuracy = 0.85

    /// Target battery drain per hour (percentage)
    static let maxBatteryDrainPerHour = 0.15

    // MARK: - Vision Framework Settings

    /// Minimum confidence threshold for Vision detection (0.0 - 1.0)
    static let minDetectionConfidence = 0.5

    /// Target camera resolution
    static let targetCameraResolution = "1080p"

    // MARK: - Display & UI

    /// Number of decimal places for currency display
    static let currencyDecimalPlaces = 2

    /// Default padding for UI elements (points)
    static let defaultPadding: CGFloat = 16

    /// Default corner radius for UI elements (points)
    static let defaultCornerRadius: CGFloat = 8

    // MARK: - Storage Keys

    /// UserDefaults key for currency settings
    static let settingsKey = "currencySettings"

    /// FileManager file name for conversion history
    static let historyFileName = "conversion_history.json"

    // MARK: - Platform & Version

    /// Minimum iOS version required
    static let minIOSVersion = "15.0"

    /// Swift version
    static let swiftVersion = "5.9"

    // MARK: - Localization

    /// Primary app language
    static let primaryLanguage = "zh-TW"

    /// Fallback language
    static let fallbackLanguage = "en"
}
