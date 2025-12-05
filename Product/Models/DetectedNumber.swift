//
//  DetectedNumber.swift
//  CurrencyConverterCamera
//
//  Created by Claude on 2025-12-02.
//

import Foundation
import CoreGraphics

/// Represents a number detected in a camera frame.
///
/// This is an ephemeral model that exists only during frame processing.
/// It contains the detected value, its location on screen, and confidence from Vision framework.
/// Once the frame is processed and overlay is rendered, this object is discarded.
struct DetectedNumber: Equatable {
    /// The detected numeric value
    /// Example: 3500
    var value: Decimal

    /// Screen coordinates where number was detected
    /// Uses normalized coordinates (0.0-1.0) from Vision framework
    /// Must be converted to screen space for overlay rendering
    var boundingBox: CGRect

    /// Vision framework confidence score (0.0-1.0)
    /// 1.0 = high confidence, 0.0 = low confidence
    /// Typically display overlay only if confidence > 0.5
    var confidence: Double

    /// Default initializer
    init(value: Decimal, boundingBox: CGRect, confidence: Double) {
        self.value = value
        self.boundingBox = boundingBox
        self.confidence = Double(max(0.0, min(1.0, confidence))) // Clamp to [0, 1]
    }

    // MARK: - Computed Properties

    /// Check if this detection meets minimum confidence threshold
    /// Default threshold: 0.5
    func meetsConfidenceThreshold(_ threshold: Double = 0.5) -> Bool {
        confidence >= threshold
    }

    /// Formatted value as string with 2 decimal places
    var formattedValue: String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        let nsDecimal = value as NSDecimalNumber
        return formatter.string(from: nsDecimal) ?? "0"
    }

    // MARK: - Helper Methods

    /// Convert Vision-normalized bounding box to screen coordinates
    /// - Parameter screenSize: Size of the screen/view where overlay will be drawn
    /// - Returns: Adjusted CGRect in screen coordinates
    func screenBoundingBox(for screenSize: CGSize) -> CGRect {
        CGRect(
            x: boundingBox.minX * screenSize.width,
            y: boundingBox.minY * screenSize.height,
            width: boundingBox.width * screenSize.width,
            height: boundingBox.height * screenSize.height
        )
    }

    /// Check if bounding box is valid (non-zero size, within bounds)
    var isValidBoundingBox: Bool {
        boundingBox.width > 0 &&
        boundingBox.height > 0 &&
        boundingBox.minX >= 0 &&
        boundingBox.minY >= 0 &&
        boundingBox.maxX <= 1.0 &&
        boundingBox.maxY <= 1.0
    }
}
