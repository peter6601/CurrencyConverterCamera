//
//  SettingsViewModelTests.swift
//  CurrencyConverterCameraTests
//
//  Created by Claude on 2025-12-03.
//

import XCTest
@testable import CurrencyConverterCamera

final class SettingsViewModelTests: XCTestCase {

    var viewModel: SettingsViewModel!
    var mockAppState: AppState!

    override func setUp() {
        super.setUp()
        mockAppState = AppState()
        viewModel = SettingsViewModel(storageService: StorageService(), appState: mockAppState)
        try? TestHelper.cleanup()
    }

    override func tearDown() {
        super.tearDown()
        try? TestHelper.cleanup()
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        XCTAssertEqual(viewModel.currencyName, "")
        XCTAssertEqual(viewModel.exchangeRateText, "")
        XCTAssertNil(viewModel.validationError)
        XCTAssertFalse(viewModel.isSaving)
        XCTAssertNil(viewModel.successMessage)
    }

    // MARK: - Currency Name Validation Tests

    func testValidCurrencyName() {
        viewModel.currencyName = "JPY"
        XCTAssertNil(viewModel.validationError)
    }

    func testEmptyCurrencyName() {
        viewModel.currencyName = ""
        viewModel.validateNow()
        XCTAssertEqual(viewModel.validationError, .emptyCurrencyName)
    }

    func testCurrencyNameTooLong() {
        viewModel.currencyName = String(repeating: "A", count: 21)
        viewModel.validateNow()
        XCTAssertEqual(viewModel.validationError, .currencyNameTooLong)
    }

    func testCurrencyNameWithNumbers() {
        viewModel.currencyName = "JP1"
        viewModel.validateNow()
        XCTAssertEqual(viewModel.validationError, .invalidCurrencyFormat)
    }

    func testCurrencyNameMaxLength() {
        viewModel.currencyName = String(repeating: "A", count: 20)
        XCTAssertNil(viewModel.validationError)
    }

    // MARK: - Exchange Rate Validation Tests

    func testValidExchangeRate() {
        viewModel.currencyName = "JPY"
        viewModel.exchangeRateText = "0.22"
        XCTAssertNil(viewModel.validationError)
    }

    func testEmptyExchangeRateIsOK() {
        viewModel.currencyName = "JPY"
        viewModel.exchangeRateText = ""
        XCTAssertNil(viewModel.validationError)
    }

    func testInvalidExchangeRateFormat() {
        viewModel.currencyName = "JPY"
        viewModel.exchangeRateText = "abc"
        viewModel.validateNow()
        XCTAssertEqual(viewModel.validationError, .invalidExchangeRate)
    }

    func testExchangeRateZero() {
        viewModel.currencyName = "JPY"
        viewModel.exchangeRateText = "0"
        viewModel.validateNow()
        XCTAssertEqual(viewModel.validationError, .exchangeRateNotPositive)
    }

    func testExchangeRateTooSmall() {
        viewModel.currencyName = "JPY"
        viewModel.exchangeRateText = "0.00001"
        viewModel.validateNow()
        XCTAssertEqual(viewModel.validationError, .exchangeRateTooSmall)
    }

    func testExchangeRateTooLarge() {
        viewModel.currencyName = "JPY"
        viewModel.exchangeRateText = "10001"
        viewModel.validateNow()
        XCTAssertEqual(viewModel.validationError, .exchangeRateTooLarge)
    }

    func testExchangeRateMinimumValid() {
        viewModel.currencyName = "JPY"
        viewModel.exchangeRateText = "0.0001"
        XCTAssertNil(viewModel.validationError)
    }

    func testExchangeRateMaximumValid() {
        viewModel.currencyName = "JPY"
        viewModel.exchangeRateText = "10000"
        XCTAssertNil(viewModel.validationError)
    }

    // MARK: - Combined Validation Tests

    func testIsValidWhenBothFieldsFilled() {
        viewModel.currencyName = "JPY"
        viewModel.exchangeRateText = "0.22"
        XCTAssertTrue(viewModel.isValid)
    }

    func testIsNotValidWhenCurrencyEmpty() {
        viewModel.currencyName = ""
        viewModel.exchangeRateText = "0.22"
        XCTAssertFalse(viewModel.isValid)
    }

    func testIsNotValidWhenExchangeRateEmpty() {
        viewModel.currencyName = "JPY"
        viewModel.exchangeRateText = ""
        XCTAssertFalse(viewModel.isValid)
    }

    // MARK: - Saving Tests

    func testSaveValidSettings() throws {
        viewModel.currencyName = "JPY"
        viewModel.exchangeRateText = "0.22"

        viewModel.saveSettings()

        XCTAssertNil(viewModel.validationError)
        XCTAssertNotNil(viewModel.successMessage)
        XCTAssertEqual(mockAppState.currencySettings?.currencyName, "JPY")
    }

    func testSaveInvalidSettings() {
        viewModel.currencyName = ""
        viewModel.exchangeRateText = "0.22"

        viewModel.saveSettings()

        XCTAssertNotNil(viewModel.validationError)
    }

    func testCurrencyNameConvertedToUppercaseOnSave() {
        viewModel.currencyName = "jpy"
        viewModel.exchangeRateText = "0.22"

        viewModel.saveSettings()

        XCTAssertEqual(mockAppState.currencySettings?.currencyName, "JPY")
    }

    // MARK: - Reset Tests

    func testResetWithoutSavedSettings() {
        viewModel.currencyName = "JPY"
        viewModel.exchangeRateText = "0.22"

        viewModel.reset()

        XCTAssertEqual(viewModel.currencyName, "")
        XCTAssertEqual(viewModel.exchangeRateText, "")
        XCTAssertNil(viewModel.validationError)
    }

    // MARK: - Helper Property Tests

    func testCurrencyNameUppercased() {
        viewModel.currencyName = "jpy"
        XCTAssertEqual(viewModel.currencyNameUppercased, "JPY")
    }

    func testFormattedExchangeRate() {
        viewModel.exchangeRateText = "0.22"
        XCTAssertEqual(viewModel.formattedExchangeRate, "0.2200")
    }

    // MARK: - Error Message Tests

    func testValidationErrorMessage() {
        viewModel.currencyName = ""
        viewModel.validateNow()
        XCTAssertEqual(viewModel.validationError?.message, "Currency name cannot be empty")
    }

    func testExchangeRateTooSmallErrorMessage() {
        viewModel.currencyName = "JPY"
        viewModel.exchangeRateText = "0.00001"
        viewModel.validateNow()
        XCTAssertEqual(viewModel.validationError?.message, "Exchange rate must be at least 0.0001")
    }

    func testExchangeRateTooLargeErrorMessage() {
        viewModel.currencyName = "JPY"
        viewModel.exchangeRateText = "10001"
        viewModel.validateNow()
        XCTAssertEqual(viewModel.validationError?.message, "Exchange rate cannot exceed 10000")
    }
}
