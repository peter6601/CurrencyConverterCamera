//
//  VisionServiceTests.swift
//  CurrencyConverterCameraTests
//
//  Created by Claude on 2025-12-03.
//

import XCTest
import Vision
import CoreGraphics
@testable import CurrencyConverterCamera

final class VisionServiceTests: XCTestCase {

    var visionService: VisionService!

    override func setUp() {
        super.setUp()
        visionService = VisionService()
    }

    override func tearDown() {
        super.tearDown()
        visionService = nil
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        XCTAssertNotNil(visionService)
    }

    // MARK: - Number Extraction Tests

    func testExtractNumbersFromSimpleText() {
        let text = "Price: 100.50"
        let numbers = visionService.extractNumbers(from: text)

        XCTAssertGreaterThan(numbers.count, 0)
        XCTAssert(numbers.contains { $0.contains("100") })
    }

    func testExtractNumbersFromEmptyText() {
        let text = ""
        let numbers = visionService.extractNumbers(from: text)

        XCTAssertEqual(numbers.count, 0)
    }

    func testExtractMultipleNumbers() {
        let text = "Prices: 100.50 and 250.75"
        let numbers = visionService.extractNumbers(from: text)

        XCTAssertGreaterThanOrEqual(numbers.count, 1)
    }

    func testExtractNumberWithDecimal() {
        let text = "Rate: 31.35"
        let numbers = visionService.extractNumbers(from: text)

        XCTAssertGreaterThan(numbers.count, 0)
        XCTAssert(numbers.contains { $0.contains("31") || $0.contains("35") })
    }

    func testExtractNumbersIgnoresText() {
        let text = "Apple costs $5.99"
        let numbers = visionService.extractNumbers(from: text)

        // Should extract numbers only, not letters
        XCTAssertTrue(numbers.allSatisfy { num in
            !num.contains("Apple")
        })
    }

    // MARK: - Confidence Calculation Tests

    func testCalculateConfidence() {
        let mockObservation = MockTextObservation()
        let confidence = visionService.calculateConfidence(for: mockObservation)

        XCTAssert((0.0...1.0).contains(confidence))
    }

    func testConfidenceIsBetweeZeroAndOne() {
        let mockObservation = MockTextObservation(confidence: 0.85)
        let confidence = visionService.calculateConfidence(for: mockObservation)

        XCTAssertGreaterThanOrEqual(confidence, 0.0)
        XCTAssertLessThanOrEqual(confidence, 1.0)
    }

    func testHighConfidenceObservation() {
        let mockObservation = MockTextObservation(confidence: 0.95)
        let confidence = visionService.calculateConfidence(for: mockObservation)

        XCTAssertGreaterThan(confidence, 0.8)
    }

    func testLowConfidenceObservation() {
        let mockObservation = MockTextObservation(confidence: 0.50)
        let confidence = visionService.calculateConfidence(for: mockObservation)

        XCTAssertLessThan(confidence, 0.7)
    }

    // MARK: - Performance Tests

    func testNumberExtractionPerformance() {
        let text = String(repeating: "Price 100.50 ", count: 100)

        measure {
            let _ = visionService.extractNumbers(from: text)
        }
    }

    // MARK: - Edge Cases

    func testExtractNumbersFromMixedCharacters() {
        let text = "Price: $100.50 USD"
        let numbers = visionService.extractNumbers(from: text)

        XCTAssertGreaterThan(numbers.count, 0)
    }

    func testExtractNumbersWithLeadingZeros() {
        let text = "Code: 0001"
        let numbers = visionService.extractNumbers(from: text)

        XCTAssertGreaterThan(numbers.count, 0)
    }

    func testExtractVeryLargeNumbers() {
        let text = "Amount: 1000000.99"
        let numbers = visionService.extractNumbers(from: text)

        XCTAssertGreaterThan(numbers.count, 0)
    }

    func testExtractVerySmallNumbers() {
        let text = "Rate: 0.0001"
        let numbers = visionService.extractNumbers(from: text)

        XCTAssertGreaterThan(numbers.count, 0)
    }
}

// MARK: - Helper Methods

extension VisionServiceTests {
    func createPixelBuffer(from image: UIImage) throws -> CVPixelBuffer {
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "VisionServiceTests", code: -1, userInfo: nil)
        }

        var pixelBuffer: CVPixelBuffer?
        let width = cgImage.width
        let height = cgImage.height

        let attributes: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height
        ]

        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            attributes as CFDictionary,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            throw NSError(domain: "VisionServiceTests", code: -2, userInfo: nil)
        }

        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }

        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
        ) else {
            throw NSError(domain: "VisionServiceTests", code: -3, userInfo: nil)
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        return buffer
    }
}

// MARK: - Mock Objects

class MockTextObservation: VNRecognizedTextObservation {
    let mockConfidence: VNConfidence

    init(confidence: VNConfidence = 0.85) {
        self.mockConfidence = confidence
        super.init()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var confidence: VNConfidence {
        return mockConfidence
    }
}
