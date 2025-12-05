//
//  CurrencySettingsTests.swift
//  CurrencyConverterCameraTests
//
//  Created by Claude on 2025-12-02.
//

import XCTest
@testable import CurrencyConverterCamera

final class CurrencySettingsTests: XCTestCase {

    // MARK: - Initialization Tests

    func testInitWithValidData() {
        let settings = TestHelper.createValidSettings(currency: "JPY", rate: 0.22)

        XCTAssertEqual(settings.currencyName, "JPY")
        XCTAssertEqual(settings.exchangeRate, 0.22)
        XCTAssertNotNil(settings.lastUpdated)
    }

    func testInitWithDefaultLastUpdated() {
        let before = Date()
        let settings = TestHelper.createValidSettings()
        let after = Date()

        XCTAssertTrue(settings.lastUpdated >= before && settings.lastUpdated <= after)
    }

    // MARK: - Validation Tests

    func testIsValidWithValidData() {
        let settings = TestHelper.createValidSettings(currency: "JPY", rate: 0.22)
        XCTAssertTrue(settings.isValid)
    }

    func testIsInvalidWithEmptyCurrency() {
        let settings = TestHelper.createInvalidSettingsEmptyName()
        XCTAssertFalse(settings.isValid)
    }

    func testIsInvalidWithZeroRate() {
        let settings = TestHelper.createInvalidSettingsZeroRate()
        XCTAssertFalse(settings.isValid)
    }

    func testIsInvalidWithNegativeRate() {
        let settings = CurrencySettings(currencyName: "JPY", exchangeRate: -0.5)
        XCTAssertFalse(settings.isValid)
    }

    func testIsInvalidWithTooLargeRate() {
        let settings = TestHelper.createInvalidSettingsTooLargeRate()
        XCTAssertFalse(settings.isValid)
    }

    func testIsInvalidWithCurrencyNameTooLong() {
        let settings = TestHelper.createInvalidSettingsNameTooLong()
        XCTAssertFalse(settings.isValid)
    }

    // MARK: - Edge Cases

    func testValidWithMinimumRate() {
        let settings = CurrencySettings(currencyName: "JPY", exchangeRate: 0.0001)
        XCTAssertTrue(settings.isValid)
    }

    func testValidWithMaximumRate() {
        let settings = CurrencySettings(currencyName: "JPY", exchangeRate: 10000)
        XCTAssertTrue(settings.isValid)
    }

    func testValidWithMaxLengthCurrency() {
        let longCurrency = String(repeating: "A", count: 20)
        let settings = CurrencySettings(currencyName: longCurrency, exchangeRate: 0.22)
        XCTAssertTrue(settings.isValid)
    }

    func testInvalidWithOneCharTooLongCurrency() {
        let tooLongCurrency = String(repeating: "A", count: 21)
        let settings = CurrencySettings(currencyName: tooLongCurrency, exchangeRate: 0.22)
        XCTAssertFalse(settings.isValid)
    }

    // MARK: - Validation Error Tests

    func testValidationErrorForEmptyCurrency() {
        let settings = TestHelper.createInvalidSettingsEmptyName()
        XCTAssertEqual(settings.validationError, .emptyCurrencyName)
    }

    func testValidationErrorForCurrencyTooLong() {
        let settings = TestHelper.createInvalidSettingsNameTooLong()
        XCTAssertEqual(settings.validationError, .currencyNameTooLong)
    }

    func testValidationErrorForZeroRate() {
        let settings = TestHelper.createInvalidSettingsZeroRate()
        XCTAssertEqual(settings.validationError, .exchangeRateNotPositive)
    }

    func testValidationErrorForTooLargeRate() {
        let settings = TestHelper.createInvalidSettingsTooLargeRate()
        XCTAssertEqual(settings.validationError, .exchangeRateTooLarge)
    }

    func testNoValidationErrorForValidSettings() {
        let settings = TestHelper.createValidSettings()
        XCTAssertNil(settings.validationError)
    }

    // MARK: - Codable Tests

    func testEncodingDecoding() throws {
        let original = TestHelper.createValidSettings(currency: "USD", rate: 31.35)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let encoded = try encoder.encode(original)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(CurrencySettings.self, from: encoded)

        XCTAssertEqual(original.currencyName, decoded.currencyName)
        XCTAssertEqual(original.exchangeRate, decoded.exchangeRate)
    }

    // MARK: - Equatable Tests

    func testEquatableWithSameValues() {
        let settings1 = TestHelper.createValidSettings(currency: "JPY", rate: 0.22)
        let settings2 = CurrencySettings(
            currencyName: "JPY",
            exchangeRate: 0.22,
            lastUpdated: settings1.lastUpdated
        )

        XCTAssertEqual(settings1, settings2)
    }

    func testNotEquatableWithDifferentCurrency() {
        let settings1 = TestHelper.createValidSettings(currency: "JPY", rate: 0.22)
        let settings2 = TestHelper.createValidSettings(currency: "USD", rate: 0.22)

        XCTAssertNotEqual(settings1, settings2)
    }

    func testNotEquatableWithDifferentRate() {
        let settings1 = TestHelper.createValidSettings(currency: "JPY", rate: 0.22)
        let settings2 = TestHelper.createValidSettings(currency: "JPY", rate: 0.23)

        XCTAssertNotEqual(settings1, settings2)
    }

}
