//
//  CameraViewModel.swift
//  CurrencyConverterCamera
//
//  Created by Claude on 2025-12-03.
//

import AVFoundation
internal import Combine
import Foundation

/// ViewModel for camera detection and conversion
class CameraViewModel: NSObject, ObservableObject {
    // MARK: - Published Properties

    @Published var currentFrame: CameraFrame?
    @Published var latestResult: ConversionResult?
    @Published var detectedNumbers: [DetectedNumber] = []
    @Published var cameraPermissionDenied = false
    @Published var isProcessing = false
    @Published var conversionError: String?
    @Published var isConversionEnabled = false  // Controls whether detection happens
    @Published var isSessionRunning = false  // Camera session status
    @Published var isSizeFilterEnabled = false  // Controls size filtering (height > 1/10)
    @Published var isThrottlingEnabled = false  // Controls frame processing throttling

    // MARK: - Private Properties

    let cameraManager = CameraManager()  // Public for preview access
    private let visionService = VisionService()
    private let conversionEngine = ConversionEngine()
    private let appState: AppState
    private let storageService: StorageService

    private var processingTask: Task<Void, Never>?
    private var lastProcessingTime: Date?
    private let processingInterval: TimeInterval = 0.1  // 每0.1秒處理一次（當啟用節流時）

    // MARK: - Initialization

    init(appState: AppState = AppState(), storageService: StorageService = StorageService()) {
        self.appState = appState
        self.storageService = storageService
        super.init()

        cameraManager.delegate = self
        setupCameraPermissions()

        // Monitor camera session status
        cameraManager.$isSessionRunning
            .receive(on: DispatchQueue.main)
            .assign(to: &$isSessionRunning)

        AppLogger.debug("CameraViewModel initialized", category: AppLogger.general)
    }

    // MARK: - Camera Permissions

    private func setupCameraPermissions() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            startCamera()
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.cameraPermissionDenied = true
            }
        case .notDetermined:
            cameraManager.requestCameraPermission()
        @unknown default:
            break
        }
    }

    func requestCameraPermission() {
        cameraManager.requestCameraPermission()
    }

    // MARK: - Camera Management

    func startCamera() {
        AppLogger.info("Starting camera", category: AppLogger.general)
        cameraManager.startSession()
    }

    func stopCamera() {
        AppLogger.info("Stopping camera", category: AppLogger.general)
        cameraManager.stopSession()
    }

    // MARK: - Frame Processing

    private func processFrame(_ pixelBuffer: CVPixelBuffer) {
        // Only process if conversion is enabled
        guard isConversionEnabled else {
            // Just update the frame without processing
            DispatchQueue.main.async {
                self.currentFrame = CameraFrame(
                    size: CGSize(
                        width: CVPixelBufferGetWidth(pixelBuffer),
                        height: CVPixelBufferGetHeight(pixelBuffer)),
                    detectedNumbers: []
                )
                self.detectedNumbers = []
                self.latestResult = nil
                self.conversionError = nil
            }
            return
        }

        // 節流控制：檢查是否距離上次處理已經過了 x 秒（如果啟用節流）
        if isThrottlingEnabled {
            let now = Date()
            if let lastTime = lastProcessingTime {
                let timeSinceLastProcessing = now.timeIntervalSince(lastTime)
                if timeSinceLastProcessing < processingInterval {
                    // 還不到設定的時間間隔，跳過這一幀
                    return
                }
            }
            // 更新最後處理時間
            lastProcessingTime = now
        }

        guard !isProcessing else { return }

        DispatchQueue.main.async {
            self.isProcessing = true
        }

        processingTask = Task {
            do {
                // Recognize text from frame
                let detectedNumbers = try await visionService.recognizeText(from: pixelBuffer)

                AppLogger.debug(
                    "Initial detections: \(detectedNumbers.count)",
                    category: AppLogger.general
                )

                // Deduplicate and filter
                let filtered = visionService.deduplicateDetections(detectedNumbers)
                AppLogger.debug(
                    "After deduplication: \(filtered.count)",
                    category: AppLogger.general
                )

                let highConfidence = visionService.filterByConfidence(filtered, threshold: 0.9)
                AppLogger.debug(
                    "After confidence filter (>0.9): \(highConfidence.count)",
                    category: AppLogger.general
                )

                // Filter by size: only keep detections where height > 1/10 of screen height
                let sizeFiltered: [DetectedNumber]
                if self.isSizeFilterEnabled {
                    sizeFiltered = highConfidence.filter { detection in
                        let height = detection.boundingBox.height
                        let meetsThreshold = height > (1.0 / 10.0)
                        AppLogger.debug(
                            "Detection: value=\(detection.value), height=\(height), passes=\(meetsThreshold)",
                            category: AppLogger.general
                        )
                        return meetsThreshold
                    }
                    AppLogger.debug(
                        "Size filter: \(highConfidence.count) -> \(sizeFiltered.count) detections",
                        category: AppLogger.general
                    )
                } else {
                    sizeFiltered = highConfidence
                }

                DispatchQueue.main.async {
                    self.detectedNumbers = sizeFiltered

                    // Update frame
                    self.currentFrame = CameraFrame(
                        size: CGSize(
                            width: CVPixelBufferGetWidth(pixelBuffer),
                            height: CVPixelBufferGetHeight(pixelBuffer)),
                        detectedNumbers: sizeFiltered
                    )

                    // Process conversions
                    self.processDetections(sizeFiltered)

                    self.isProcessing = false
                }
            } catch {
                AppLogger.error(
                    "Frame processing failed", error: error, category: AppLogger.general)
                DispatchQueue.main.async {
                    self.conversionError = String(
                        format: NSLocalizedString(
                            "error_detection_failed", comment: "Detection failed: %@"),
                        error.localizedDescription)
                    self.isProcessing = false
                }
            }
        }
    }

    private func processDetections(_ detections: [DetectedNumber]) {
        guard let settings = appState.currencySettings else {
            AppLogger.warning("No currency settings available", category: AppLogger.general)
            return
        }

        guard let firstDetection = detections.first else {
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

            DispatchQueue.main.async {
                self.latestResult = result
                self.conversionError = nil
            }

            AppLogger.debug(
                "Conversion result: \(firstDetection.value) -> \(converted)",
                category: AppLogger.general
            )
        } catch {
            AppLogger.error("Conversion failed", error: error, category: AppLogger.general)
            DispatchQueue.main.async {
                self.conversionError = String(
                    format: NSLocalizedString(
                        "error_conversion_failed", comment: "Conversion failed: %@"),
                    error.localizedDescription)
            }
        }
    }

    // MARK: - Result Saving

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

            AppLogger.info("Result saved successfully", category: AppLogger.general)

            DispatchQueue.main.async {
                self.conversionError = nil
            }
        } catch {
            AppLogger.error("Failed to save result", error: error, category: AppLogger.general)
            DispatchQueue.main.async {
                self.conversionError = String(
                    format: NSLocalizedString("error_save_failed", comment: "Failed to save: %@"),
                    error.localizedDescription)
            }
        }
    }

    // MARK: - Cleanup

    deinit {
        stopCamera()
        processingTask?.cancel()
        AppLogger.debug("CameraViewModel deallocated", category: AppLogger.general)
    }
}

// MARK: - Camera Manager Delegate

extension CameraViewModel: CameraManagerDelegate {
    func cameraManager(_ manager: CameraManager, didCaptureFrame pixelBuffer: CVPixelBuffer) {
        processFrame(pixelBuffer)
    }

    func cameraManager(
        _ manager: CameraManager, didUpdateAuthorizationStatus status: AVAuthorizationStatus
    ) {
        DispatchQueue.main.async {
            if status == .authorized {
                self.cameraPermissionDenied = false
                self.startCamera()
            } else if status == .denied {
                self.cameraPermissionDenied = true
            }
        }
    }

    func cameraManager(_ manager: CameraManager, didEncounterError error: Error) {
        AppLogger.error("Camera error", error: error, category: AppLogger.general)
        DispatchQueue.main.async {
            self.conversionError = String(
                format: NSLocalizedString("error_camera_general", comment: "Camera error: %@"),
                error.localizedDescription)
        }
    }
}
