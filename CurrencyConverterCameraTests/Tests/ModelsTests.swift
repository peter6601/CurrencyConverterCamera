//
//  ModelsTests.swift
//  CurrencyConverterCameraTests
//
//  Created by Claude on 2025-12-02.
//

import XCTest
@testable import CurrencyConverterCamera

// MARK: - ConversionRecord Tests

final class ConversionRecordTests: XCTestCase {

    func testInitialization() {
        let record = TestHelper.createConversionRecord(
            original: 3500,
            converted: 770.00,
            currency: "JPY",
            rate: 0.22
        )

        XCTAssertEqual(record.originalPrice, 3500)
        XCTAssertEqual(record.convertedAmount, 770.00)
        XCTAssertEqual(record.currencyName, "JPY")
        XCTAssertEqual(record.exchangeRate, 0.22)
        XCTAssertNotNil(record.id)
        XCTAssertNotNil(record.timestamp)
    }

    func testFormattedAmountDisplay() {
        let record = TestHelper.createConversionRecord(converted: 770.00)

        XCTAssertTrue(record.formattedAmount.contains("770"))
        XCTAssertTrue(record.formattedAmount.contains("NT$"))
    }

    func testFormattedOriginalPriceDisplay() {
        let record = TestHelper.createConversionRecord(original: 3500, currency: "JPY")

        XCTAssertTrue(record.formattedOriginalPrice.contains("JPY"))
        // Accept both "3500" and "3,500" (with thousand separator)
        XCTAssertTrue(
            record.formattedOriginalPrice.contains("3500") || 
            record.formattedOriginalPrice.contains("3,500"),
            "Should contain 3500 or 3,500, got: \(record.formattedOriginalPrice)"
        )
    }

    func testFormattedTimestampJustNow() {
        let record = TestHelper.createConversionRecord(timestamp: Date())

        XCTAssertEqual(record.formattedTimestamp, "just now")
    }

    func testFormattedTimestampMinutesAgo() {
        let timestamp = Date().addingTimeInterval(-120)  // 2 minutes ago
        let record = TestHelper.createConversionRecord(timestamp: timestamp)

        XCTAssertTrue(record.formattedTimestamp.contains("minute"))
    }

    func testCodableEncodingDecoding() throws {
        let original = TestHelper.createConversionRecord()

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let encoded = try encoder.encode(original)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(ConversionRecord.self, from: encoded)

        XCTAssertEqual(original.id, decoded.id)
        XCTAssertEqual(original.originalPrice, decoded.originalPrice)
        XCTAssertEqual(original.convertedAmount, decoded.convertedAmount)
        XCTAssertEqual(original.currencyName, decoded.currencyName)
        XCTAssertEqual(original.exchangeRate, decoded.exchangeRate)
    }

    func testIdentifiable() {
        let record1 = TestHelper.createConversionRecord()
        let record2 = TestHelper.createConversionRecord()

        XCTAssertNotEqual(record1.id, record2.id)
    }

}

// MARK: - DetectedNumber Tests

final class DetectedNumberTests: XCTestCase {

    func testInitialization() {
        let number = TestHelper.createDetectedNumber(
            value: 3500,
            confidence: 0.95
        )

        XCTAssertEqual(number.value, 3500)
        XCTAssertEqual(number.confidence, 0.95)
        XCTAssert(number.isValidBoundingBox)
    }

    func testConfidenceThreshold() {
        let highConfidence = TestHelper.createDetectedNumber(confidence: 0.95)
        XCTAssertTrue(highConfidence.meetsConfidenceThreshold(0.5))

        let lowConfidence = TestHelper.createDetectedNumberLowConfidence()
        XCTAssertFalse(lowConfidence.meetsConfidenceThreshold(0.5))
    }

    func testConfidenceClamping() {
        let overOneConfidence = DetectedNumber(value: 3500, boundingBox: CGRect(x: 0.3, y: 0.4, width: 0.4, height: 0.2), confidence: 1.5)
        XCTAssertEqual(overOneConfidence.confidence, 1.0)

        let negativeConfidence = DetectedNumber(value: 3500, boundingBox: CGRect(x: 0.3, y: 0.4, width: 0.4, height: 0.2), confidence: -0.5)
        XCTAssertEqual(negativeConfidence.confidence, 0.0)
    }

    func testFormattedValue() {
        let number = TestHelper.createDetectedNumber(value: 3500.5)
        XCTAssertTrue(number.formattedValue.contains("3500"))
    }

    func testScreenBoundingBoxConversion() {
        let number = TestHelper.createDetectedNumber(
            boundingBox: CGRect(x: 0.2, y: 0.3, width: 0.4, height: 0.4)
        )

        let screenSize = CGSize(width: 1000, height: 1000)
        let screenBox = number.screenBoundingBox(for: screenSize)

        XCTAssertEqual(screenBox.minX, 200)  // 0.2 * 1000
        XCTAssertEqual(screenBox.minY, 300)  // 0.3 * 1000
        XCTAssertEqual(screenBox.width, 400) // 0.4 * 1000
        XCTAssertEqual(screenBox.height, 400) // 0.4 * 1000
    }

    func testValidBoundingBox() {
        let validNumber = TestHelper.createDetectedNumber()
        XCTAssertTrue(validNumber.isValidBoundingBox)
    }

    func testInvalidBoundingBox() {
        let invalidNumber = TestHelper.createDetectedNumberInvalidBox()
        XCTAssertFalse(invalidNumber.isValidBoundingBox)

        let zeroDimensionNumber = DetectedNumber(
            value: 3500,
            boundingBox: CGRect(x: 0, y: 0, width: 0, height: 0),
            confidence: 0.95
        )
        XCTAssertFalse(zeroDimensionNumber.isValidBoundingBox)
    }

    func testEquatable() {
        let number1 = TestHelper.createDetectedNumber(value: 3500, confidence: 0.95)
        let number2 = TestHelper.createDetectedNumber(value: 3500, confidence: 0.95)
        let number3 = TestHelper.createDetectedNumber(value: 3600, confidence: 0.95)

        XCTAssertEqual(number1, number2)
        XCTAssertNotEqual(number1, number3)
    }

}
