//
//  DetectionOverlayView.swift
//  CurrencyConverterCamera
//
//  Created by Claude on 2025-12-03.
//

import SwiftUI

struct DetectionOverlayView: View {
    let frame: CameraFrame
    let detectedNumbers: [DetectedNumber]
    let conversionResult: ConversionResult?  // 新增：轉換結果
    let currencySettings: CurrencySettings?   // 新增：貨幣設定

    var body: some View {
        Canvas { context, canvasSize in
            // Draw bounding boxes for each detection
            for detection in detectedNumbers {
                let rect = detection.boundingBox
                let x = rect.minX * canvasSize.width
                let y = rect.minY * canvasSize.height
                let width = rect.width * canvasSize.width
                let height = rect.height * canvasSize.height

                let boundingBox = CGRect(x: x, y: y, width: width, height: height)

                // Draw rectangle
                var path = Path()
                path.addRect(boundingBox)

                let confidence: Double
                if let number = detection.confidence as? NSNumber {
                    confidence = number.doubleValue
                } else if let decimal = detection.confidence as? Decimal {
                    confidence = NSDecimalNumber(decimal: decimal).doubleValue
                } else if let doubleValue = detection.confidence as? Double {
                    confidence = doubleValue
                } else {
                    confidence = 0.0
                }
                let color = confidenceColor(confidence)

                context.stroke(
                    path,
                    with: .color(color),
                    lineWidth: 3  // 加粗線條讓框更明顯
                )

                // 在框的正上方顯示轉換後的金額
                if let settings = currencySettings {
                    
                    // 計算轉換後的金額（針對這個偵測到的數字）
                    let detectedValue = detection.value
                    
                    // 將 exchangeRate 和 detectedValue 從 Decimal 轉換為 Double
                    let exchangeRateDouble = NSDecimalNumber(decimal: settings.exchangeRate).doubleValue
                    let detectedValueDouble = NSDecimalNumber(decimal: detectedValue).doubleValue
                    
                    // 計算轉換金額
                    let convertedValue = detectedValueDouble * exchangeRateDouble
                    
                    // 格式化顯示
                    let convertedText = String(format: "NT$ %.2f", convertedValue)
                    
                    // 背景框
                    let textSize = CGSize(width: 120, height: 30)
                    let textX = x + width / 2 - textSize.width / 2
                    let textY = y - textSize.height - 8  // 在框的上方留一點間距
                    
                    let backgroundRect = CGRect(
                        x: textX,
                        y: textY,
                        width: textSize.width,
                        height: textSize.height
                    )
                    
                    // 繪製背景（半透明黑色）
                    context.fill(
                        Path(roundedRect: backgroundRect, cornerRadius: 8),
                        with: .color(.black.opacity(0.8))
                    )
                    
                    // 繪製轉換金額（綠色大字）
                    context.draw(
                        Text(convertedText)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.green),
                        at: CGPoint(x: textX + textSize.width / 2, y: textY + textSize.height / 2),
                        anchor: .center
                    )
                    
                    // 在框的左上角顯示原始偵測值（小字）
                    let originalText = String(format: "¥%.0f", detectedValue as CVarArg)
                    context.draw(
                        Text(originalText)
                            .font(.caption2)
                            .foregroundColor(.white),
                        at: CGPoint(x: x + 5, y: y + 5),
                        anchor: .topLeading
                    )
                }

                // 右上角顯示信心度（如果沒有轉換結果才顯示）
                if conversionResult == nil {
                    let badgeText = String(format: "%.0f%%", confidence * 100.0)
                    context.draw(
                        Text(badgeText)
                            .font(.caption2)
                            .foregroundColor(.white),
                        at: CGPoint(x: x + width - 40, y: y + 5),
                        anchor: .topLeading
                    )
                }
            }

            // Draw frame info (移到左上角，不要太顯眼)
            if !detectedNumbers.isEmpty && conversionResult == nil {
                let avgText = String(format: "%.0f%%", Double(frame.averageConfidence) * 100.0)
                let infoText = "Found: \(detectedNumbers.count) | Avg: \(avgText)"
                context.draw(
                    Text(infoText)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7)),
                    at: CGPoint(x: 10, y: 10),
                    anchor: .topLeading
                )
            }
        }
        .background(Color.clear)
    }

    // MARK: - Helper Methods

    private func confidenceColor(_ confidence: Double) -> Color {
        if confidence >= 0.85 {
            return .green
        } else if confidence >= 0.70 {
            return .yellow
        } else {
            return .red
        }
    }
}

// MARK: - Preview

#Preview {
    let detection = DetectedNumber(
        value: 1000.0,
        boundingBox: CGRect(x: 0.2, y: 0.3, width: 0.4, height: 0.2),
        confidence: 0.85
    )

    let avgConfidence: Double = 0.85
    let frame = CameraFrame(
        size: CGSize(width: 375, height: 812),
        detectedNumbers: [detection]
    )
    
    let settings = CurrencySettings(
        currencyName: "JPY",
        exchangeRate: 0.22
    )

    DetectionOverlayView(
        frame: frame, 
        detectedNumbers: [detection],
        conversionResult: nil,
        currencySettings: settings
    )
    .frame(height: 400)
    .background(Color.black)
}

