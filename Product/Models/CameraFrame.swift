//
//  CameraFrame.swift
//  CurrencyConverterCamera
//
//  Created by Claude on 2025-12-03.
//

import Foundation
import CoreGraphics
import UIKit

/// Metadata about a camera frame
struct CameraFrame: Identifiable, Equatable {
    let id: UUID
    let timestamp: Date
    let size: CGSize
    let orientation: UIDeviceOrientation
    let detectedNumbers: [DetectedNumber]

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        size: CGSize,
        orientation: UIDeviceOrientation = .portrait,
        detectedNumbers: [DetectedNumber] = []
    ) {
        self.id = id
        self.timestamp = timestamp
        self.size = size
        self.orientation = orientation
        self.detectedNumbers = detectedNumbers
    }

    /// Average confidence of all detections in this frame
    var averageConfidence: Double {
        guard !detectedNumbers.isEmpty else { return 0 }
        let totalConfidence = detectedNumbers.reduce(0) { $0 + Double(truncating: $1.confidence as NSNumber) }
        return totalConfidence / Double(detectedNumbers.count)
    }

    /// Highest confidence detection in this frame
    var maxConfidence: Double {
        detectedNumbers.map { Double(truncating: $0.confidence as NSNumber) }.max() ?? 0
    }

    /// Whether this frame has high-confidence detections
    var hasReliableDetections: Bool {
        averageConfidence >= 0.8 && !detectedNumbers.isEmpty
    }

    /// Time elapsed since frame was captured
    var timeAgoString: String {
        let elapsed = Date().timeIntervalSince(timestamp)

        if elapsed < 1 {
            return "Just now"
        } else if elapsed < 60 {
            return "\(Int(elapsed))s ago"
        } else if elapsed < 3600 {
            return "\(Int(elapsed / 60))m ago"
        } else {
            return "\(Int(elapsed / 3600))h ago"
        }
    }
}
