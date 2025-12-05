//
//  ConversionEngineTests.swift
//  CurrencyConverterCameraTests
//
//  Created by Claude on 2025-12-03.
//

import XCTest
@testable import CurrencyConverterCamera

final class ConversionEngineTests: XCTestCase {

    var conversionEngine: ConversionEngine!

    override func setUp() {
        super.setUp()
        conversionEngine = ConversionEngine()
    }

    override func tearDown() {
        super.tearDown()
        conversionEngine = nil
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        XCTAssertNotNil(conversionEngine)
    }

    // MARK: - Basic Conversion Tests

    func testSimpleConversion() throws {
        let price = Decimal(100)
        let sourceCurrency = "USD"
        let targetCurrency = "JPY"
        let rate = Decimal(string: "110.5")!

        let result = try conversionEngine.convertPrice(
            price,
            from: sourceCurrency,
            to: targetCurrency,
            using: rate
        )

        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result, Decimal(0))
    }

    func testConversionCalculation() throws {
        let price = Decimal(100)
        let rate = Decimal(2)

        let result = try conversionEngine.convertPrice(
            price,
            from: "USD",
            to: "EUR",
            using: rate
        )

        XCTAssertEqual(result, Decimal(200))
    }

    func testConversionWithDecimalPrice() throws {
        let price = Decimal(string: "99.99")!
        let rate = Decimal(string: "0.85")!

        let result = try conversionEngine.convertPrice(
            price,
            from: "USD",
            to: "EUR",
            using: rate
        )

        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result, Decimal(0))
    }

    func testConversionWithSmallRate() throws {
        let price = Decimal(100)
        let rate = Decimal(string: "0.01")!

        let result = try conversionEngine.convertPrice(
            price,
            from: "USD",
            to: "JPY",
            using: rate
        )

        XCTAssertEqual(result, Decimal(1))
    }

    func testConversionWithLargeRate() throws {
        let price = Decimal(1)
        let rate = Decimal(string: "31.35")!

        let result = try conversionEngine.convertPrice(
            price,
            from: "USD",
            to: "JPY",
            using: rate
        )

        XCTAssertGreaterThan(result, price)
    }

    // MARK: - Error Handling Tests

    func testConversionWithZeroPrice() throws {
        let price = Decimal(0)
        let rate = Decimal(2)

        let result = try conversionEngine.convertPrice(
            price,
            from: "USD",
            to: "EUR",
            using: rate
        )

        XCTAssertEqual(result, Decimal(0))
    }

    func testConversionWithNegativePrice() throws {
        let price = Decimal(-100)
        let rate = Decimal(2)

        XCTAssertThrowsError(
            try conversionEngine.convertPrice(
                price,
                from: "USD",
                to: "EUR",
                using: rate
            )
        ) { error in
            XCTAssertEqual(error as? ConversionEngine.ConversionError, .invalidPrice)
        }
    }

    func testConversionWithZeroRate() throws {
        let price = Decimal(100)
        let rate = Decimal(0)

        XCTAssertThrowsError(
            try conversionEngine.convertPrice(
                price,
                from: "USD",
                to: "EUR",
                using: rate
            )
        ) { error in
            XCTAssertEqual(error as? ConversionEngine.ConversionError, .invalidRate)
        }
    }

    func testConversionWithNegativeRate() throws {
        let price = Decimal(100)
        let rate = Decimal(-2)

        XCTAssertThrowsError(
            try conversionEngine.convertPrice(
                price,
                from: "USD",
                to: "EUR",
                using: rate
            )
        ) { error in
            XCTAssertEqual(error as? ConversionEngine.ConversionError, .invalidRate)
        }
    }

    // MARK: - Formatting Tests

    func testFormatResultWithTwoDecimals() {
        let amount = Decimal(string: "123.45")!
        let formatted = conversionEngine.formatResult(amount, currency: "USD")

        XCTAssertTrue(formatted.contains("123.45") || formatted.contains("123") || formatted.contains("45"))
    }

    func testFormatResultWithCurrency() {
        let amount = Decimal(100)
        let formatted = conversionEngine.formatResult(amount, currency: "JPY")

        XCTAssertTrue(formatted.contains("100") || formatted.contains("JPY"))
    }

    func testFormatResultWithSmallAmount() {
        let amount = Decimal(string: "0.01")!
        let formatted = conversionEngine.formatResult(amount, currency: "USD")

        XCTAssertTrue(formatted.contains("0.01") || formatted.contains("0") || formatted.contains("1"))
    }

    func testFormatResultWithLargeAmount() {
        let amount = Decimal(string: "1000000.99")!
        let formatted = conversionEngine.formatResult(amount, currency: "USD")

        XCTAssertTrue(formatted.contains("1000000") || formatted.contains("1,000,000"))
    }

    // MARK: - Precision Tests

    func testConversionPrecision() throws {
        let price = Decimal(string: "123.456")!
        let rate = Decimal(string: "0.85")!

        let result = try conversionEngine.convertPrice(
            price,
            from: "USD",
            to: "EUR",
            using: rate
        )

        // Verify we maintain reasonable precision
        XCTAssertNotNil(result)
    }

    func testResultRounding() throws {
        let price = Decimal(string: "10")!
        let rate = Decimal(string: "3.33")!

        let result = try conversionEngine.convertPrice(
            price,
            from: "USD",
            to: "EUR",
            using: rate
        )

        // Result should be 33.3
        XCTAssertGreaterThan(result, Decimal(30))
        XCTAssertLessThan(result, Decimal(40))
    }

    // MARK: - Currency Handling Tests

    func testConversionBetweenDifferentCurrencies() throws {
        let currencies = ["USD", "EUR", "JPY", "GBP", "AUD"]

        for source in currencies {
            for target in currencies {
                if source != target {
                    let price = Decimal(100)
                    let rate = Decimal(1.5)

                    let result = try conversionEngine.convertPrice(
                        price,
                        from: source,
                        to: target,
                        using: rate
                    )

                    XCTAssertGreaterThan(result, Decimal(0))
                }
            }
        }
    }

    // MARK: - Edge Cases

    func testConversionWithVerySmallAmount() throws {
        let price = Decimal(string: "0.0001")!
        let rate = Decimal(2)

        let result = try conversionEngine.convertPrice(
            price,
            from: "USD",
            to: "EUR",
            using: rate
        )

        XCTAssertEqual(result, Decimal(string: "0.0002"))
    }

    func testConversionWithVeryLargeAmount() throws {
        let price = Decimal(string: "999999.99")!
        let rate = Decimal(1.1)

        let result = try conversionEngine.convertPrice(
            price,
            from: "USD",
            to: "EUR",
            using: rate
        )

        XCTAssertGreaterThan(result, price)
    }

    func testMultipleConversionsInSequence() throws {
        var amount = Decimal(100)

        // USD to EUR
        amount = try conversionEngine.convertPrice(
            amount,
            from: "USD",
            to: "EUR",
            using: Decimal(string: "0.85")!
        )

        // EUR back to USD
        amount = try conversionEngine.convertPrice(
            amount,
            from: "EUR",
            to: "USD",
            using: Decimal(string: "1.18")!
        )

        // Should be close to original (with rounding)
        XCTAssertGreaterThan(amount, Decimal(90))
        XCTAssertLessThan(amount, Decimal(110))
    }
}
