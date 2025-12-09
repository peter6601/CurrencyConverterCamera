//
//  PhotoScanViewModel.swift
//  CurrencyConverterCamera
//
//  Created by Claude on 2025-12-09.
//

internal import Combine
import CoreImage
import PhotosUI
import SwiftUI
import UIKit

/// ViewModel for photo scanning and conversion
@MainActor
class PhotoScanViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var selectedPhoto: PhotosPickerItem?
    @Published var selectedImage: UIImage?
    @Published var detectedNumbers: [DetectedNumber] = []
    @Published var latestResult: ConversionResult?
    @Published var isProcessing = false
    @Published var conversionError: String?
    @Published var showImagePicker = false

    // MARK: - Private Properties

    private let visionService = VisionService()
    private let conversionEngine = ConversionEngine()
    private let priceFilter = PriceFilterService.shared
    private let appState: AppState
    private let storageService: StorageService

    private var processingTask: Task<Void, Never>?

    // MARK: - Initialization

    init(appState: AppState = AppState(), storageService: StorageService = StorageService()) {
        self.appState = appState
        self.storageService = storageService

        AppLogger.debug("PhotoScanViewModel initialized", category: AppLogger.general)
    }

    // MARK: - Photo Selection

    func loadSelectedPhoto() {
        guard let item = selectedPhoto else { return }

        isProcessing = true
        conversionError = nil

        processingTask = Task {
            do {
                // Load image data from PhotosPickerItem
                guard let data = try await item.loadTransferable(type: Data.self) else {
                    await MainActor.run {
                        self.conversionError = "無法載入照片"
                        self.isProcessing = false
                    }
                    return
                }

                // Convert to UIImage
                guard let image = UIImage(data: data) else {
                    await MainActor.run {
                        self.conversionError = "照片格式不支援"
                        self.isProcessing = false
                    }
                    return
                }

                // Update UI with selected image
                await MainActor.run {
                    self.selectedImage = image
                }

                // Process the image
                try await processImage(image)

                await MainActor.run {
                    self.isProcessing = false
                }

            } catch {
                AppLogger.error("Failed to load photo", error: error, category: AppLogger.general)
                await MainActor.run {
                    self.conversionError = "載入照片失敗: \(error.localizedDescription)"
                    self.isProcessing = false
                }
            }
        }
    }

    // MARK: - Image Processing

    private func processImage(_ image: UIImage) async throws {
        // Convert UIImage to CVPixelBuffer for Vision processing
        guard let pixelBuffer = image.toPixelBuffer() else {
            await MainActor.run {
                self.conversionError = "無法處理照片"
            }
            return
        }

        do {
            // Recognize text from image
            let detectedNumbers = try await visionService.recognizeText(from: pixelBuffer)

            AppLogger.debug(
                "Initial detections from photo: \(detectedNumbers.count)",
                category: AppLogger.general
            )

            // Deduplicate and filter
            let filtered = visionService.deduplicateDetections(detectedNumbers)
            AppLogger.debug(
                "After deduplication: \(filtered.count)",
                category: AppLogger.general
            )

            // Apply confidence filter (lower threshold for photos)
            // Lowered to 0.5 to catch stylized prices like "4980" in red text
            let highConfidence = visionService.filterByConfidence(filtered, threshold: 0.5)
            AppLogger.debug(
                "After confidence filter (>0.5): \(highConfidence.count)",
                category: AppLogger.general
            )

            // Apply smart price filtering
            let smartFiltered = priceFilter.filterPrices(highConfidence, mode: .balanced)
            AppLogger.debug(
                "After smart price filter: \(smartFiltered.count)",
                category: AppLogger.general
            )

            await MainActor.run {
                self.detectedNumbers = smartFiltered
                self.processDetections(smartFiltered)
            }

        } catch {
            AppLogger.error("Image processing failed", error: error, category: AppLogger.general)
            await MainActor.run {
                self.conversionError = "識別失敗: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Smart Filtering

    private func processDetections(_ detections: [DetectedNumber]) {
        guard let settings = appState.currencySettings else {
            AppLogger.warning("No currency settings available", category: AppLogger.general)
            conversionError = "請先設定貨幣資訊"
            return
        }

        guard let firstDetection = detections.first else {
            conversionError = "未偵測到數字"
            return
        }

        do {
            // Convert the detected price
            let converted = try conversionEngine.convertPrice(
                firstDetection.value,
                from: settings.foreignCurrency,
                to: settings.localCurrency,
                using: settings.exchangeRate
            )

            let result = ConversionResult(
                detectedPrice: firstDetection.value,
                convertedAmount: converted,
                sourceCurrency: settings.foreignCurrency,
                targetCurrency: settings.localCurrency,
                exchangeRate: settings.exchangeRate,
                confidence: firstDetection.confidence
            )

            self.latestResult = result
            self.conversionError = nil

            AppLogger.debug(
                "Photo conversion result: \(firstDetection.value) -> \(converted)",
                category: AppLogger.general
            )
        } catch {
            AppLogger.error("Conversion failed", error: error, category: AppLogger.general)
            self.conversionError = "轉換失敗: \(error.localizedDescription)"
        }
    }

    // MARK: - Result Saving
    // TODO: 未來功能 - 歷史紀錄
    // 目前此功能尚未在 UI 中啟用，將在未來版本中加入歷史紀錄功能時使用

    func saveCurrentResult() {
        guard let result = latestResult else {
            AppLogger.warning("No result to save", category: AppLogger.general)
            return
        }

        do {
            let record = ConversionRecord(
                originalPrice: result.detectedPrice,
                convertedAmount: result.convertedAmount,
                foreignCurrency: result.sourceCurrency,
                localCurrency: result.targetCurrency,
                exchangeRate: result.exchangeRate,
                timestamp: result.timestamp
            )

            try storageService.addConversionRecord(record)

            AppLogger.info("Photo result saved successfully", category: AppLogger.general)

            self.conversionError = nil
        } catch {
            AppLogger.error("Failed to save result", error: error, category: AppLogger.general)
            self.conversionError = "儲存失敗: \(error.localizedDescription)"
        }
    }

    // MARK: - Reset

    func reset() {
        selectedPhoto = nil
        selectedImage = nil
        detectedNumbers = []
        latestResult = nil
        conversionError = nil
        processingTask?.cancel()
    }

    // MARK: - Cleanup

    deinit {
        processingTask?.cancel()
    }
}

// MARK: - UIImage Extension for CVPixelBuffer Conversion

extension UIImage {
    func toPixelBuffer() -> CVPixelBuffer? {
        let width = Int(self.size.width)
        let height = Int(self.size.height)

        let attributes: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
        ]

        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32ARGB,
            attributes as CFDictionary,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }

        let pixelData = CVPixelBufferGetBaseAddress(buffer)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard
            let context = CGContext(
                data: pixelData,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                space: rgbColorSpace,
                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
            )
        else {
            return nil
        }

        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()

        return buffer
    }
}
