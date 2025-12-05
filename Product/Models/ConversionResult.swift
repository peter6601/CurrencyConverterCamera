//
//  ConversionResult.swift
//  CurrencyConverterCamera
//
//  Created by Claude on 2025-12-03.
//

import Foundation

/// Result of a currency conversion operation
struct ConversionResult: Identifiable, Codable, Equatable {
    let id: UUID
    let detectedPrice: Decimal
    let convertedAmount: Decimal
    let sourceCurrency: String
    let targetCurrency: String
    let exchangeRate: Decimal
    let confidence: Double
    let timestamp: Date

    init(
        id: UUID = UUID(),
        detectedPrice: Decimal,
        convertedAmount: Decimal,
        sourceCurrency: String,
        targetCurrency: String,
        exchangeRate: Decimal,
        confidence: Double,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.detectedPrice = detectedPrice
        self.convertedAmount = convertedAmount
        self.sourceCurrency = sourceCurrency
        self.targetCurrency = targetCurrency
        self.exchangeRate = exchangeRate
        self.confidence = min(max(confidence, 0.0), 1.0) // Clamp to [0, 1]
        self.timestamp = timestamp
    }

    var formattedDetectedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 4
        return (formatter.string(from: detectedPrice as NSDecimalNumber) ?? detectedPrice.description) + " " + sourceCurrency
    }

    var formattedConvertedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 4
        return (formatter.string(from: convertedAmount as NSDecimalNumber) ?? convertedAmount.description) + " " + targetCurrency
    }

    var confidencePercentage: String {
        String(format: "%.0f%%", confidence * 100)
    }

    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}
