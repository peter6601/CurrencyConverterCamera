//
//  VisionService.swift
//  CurrencyConverterCamera
//
//  Created by Claude on 2025-12-03.
//

import Foundation
import Vision
import CoreGraphics

/// Service for Vision framework integration (OCR and detection)
class VisionService {
    // MARK: - Private Properties

    private let textRecognitionRequest = VNRecognizeTextRequest()

    // MARK: - Initialization

    init() {
        textRecognitionRequest.recognitionLanguages = ["en"]
        textRecognitionRequest.usesLanguageCorrection = true
        AppLogger.debug("VisionService initialized", category: AppLogger.general)
    }

    // MARK: - Text Recognition

    /// Recognizes text from a pixel buffer and extracts detected numbers
    func recognizeText(from pixelBuffer: CVPixelBuffer) async throws -> [DetectedNumber] {
        return try await withCheckedThrowingContinuation { continuation in
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])

            let request = VNRecognizeTextRequest { [weak self] request, error in
                if let error = error {
                    AppLogger.error("Text recognition failed", error: error, category: AppLogger.general)
                    continuation.resume(throwing: error)
                    return
                }

                guard let results = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: [])
                    return
                }

                var detectedNumbers: [DetectedNumber] = []

                for observation in results {
                    guard let topCandidate = observation.topCandidates(1).first else { continue }

                    let recognizedText = topCandidate.string
                    let confidence = self?.calculateConfidence(for: observation) ?? 0.0

                    AppLogger.debug("Recognized text: \(recognizedText), confidence: \(confidence)", category: AppLogger.general)

                    // Extract numbers from recognized text
                    let numbers = self?.extractNumbers(from: recognizedText) ?? []

                    for numberString in numbers {
                        if let number = Decimal(string: numberString) {
                            let detectedNumber = DetectedNumber(
                                value: number,
                                boundingBox: observation.boundingBox,
                                confidence: confidence
                            )
                            detectedNumbers.append(detectedNumber)
                        }
                    }
                }

                continuation.resume(returning: detectedNumbers)
            }

            request.recognitionLanguages = ["en"]
            request.usesLanguageCorrection = true

            do {
                try handler.perform([request])
            } catch {
                AppLogger.error("Failed to perform text recognition", error: error, category: AppLogger.general)
                continuation.resume(throwing: error)
            }
        }
    }

    // MARK: - Number Extraction

    /// Extracts numbers from recognized text
    func extractNumbers(from text: String) -> [String] {
        // Pattern matches integers and decimals
        let pattern = "-?\\d+(?:\\.\\d+)?"
        var numbers: [String] = []

        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let nsString = text as NSString
            let range = NSRange(location: 0, length: nsString.length)

            let matches = regex.matches(in: text, options: [], range: range)

            for match in matches {
                let matchString = nsString.substring(with: match.range)
                numbers.append(matchString)
            }

            AppLogger.debug("Extracted \(numbers.count) numbers from text", category: AppLogger.general)
        } catch {
            AppLogger.error("Failed to extract numbers", error: error, category: AppLogger.general)
        }

        return numbers
    }

    // MARK: - Confidence Calculation

    /// Calculates confidence score for text observation
    func calculateConfidence(for observation: VNRecognizedTextObservation) -> Double {
        // Use observation confidence directly
        let confidence = Double(observation.confidence)

        // Clamp to [0, 1]
        return max(0.0, min(1.0, confidence))
    }

    // MARK: - Helper Methods

    /// Filters detections by confidence threshold
    func filterByConfidence(_ detections: [DetectedNumber], threshold: Double) -> [DetectedNumber] {
        detections.filter { $0.confidence >= threshold }
    }

    /// Deduplicates nearby detections
    func deduplicateDetections(_ detections: [DetectedNumber], distance: CGFloat = 0.05) -> [DetectedNumber] {
        // If DetectedNumber doesn't expose positional info, return as-is
        // We attempt to access `sourceRegion` via Mirror; if not found, skip deduplication
        guard let first = detections.first else { return [] }
        let mirror = Mirror(reflecting: first)
        let hasSourceRegion = mirror.children.contains { $0.label == "sourceRegion" }
        guard hasSourceRegion else { return detections }

        var unique: [DetectedNumber] = []
        for detection in detections {
            let isDuplicate = unique.contains { (existing: DetectedNumber) -> Bool in
                // Force-cast via KVC-like reflection since we already checked presence
                let dMirror = Mirror(reflecting: detection)
                let eMirror = Mirror(reflecting: existing)
                guard
                    let dBox = dMirror.children.first(where: { $0.label == "sourceRegion" })?.value as? CGRect,
                    let eBox = eMirror.children.first(where: { $0.label == "sourceRegion" })?.value as? CGRect
                else { return false }
                let dx = dBox.midX - eBox.midX
                let dy = dBox.midY - eBox.midY
                let dist = sqrt(dx * dx + dy * dy)
                return dist < distance
            }
            if !isDuplicate {
                unique.append(detection)
            }
        }
        AppLogger.debug("Deduplication: \(detections.count) -> \(unique.count) detections", category: AppLogger.general)
        return unique
    }
}
