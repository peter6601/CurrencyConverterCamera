//
//  CameraManager.swift
//  CurrencyConverterCamera
//
//  Created by Claude on 2025-12-03.
//

import Foundation
import AVFoundation
internal import Combine

// MARK: - Camera Manager Delegate Protocol

/// Delegate protocol for camera frame delivery
protocol CameraManagerDelegate: AnyObject {
    func cameraManager(_ manager: CameraManager, didCaptureFrame pixelBuffer: CVPixelBuffer)
    func cameraManager(_ manager: CameraManager, didUpdateAuthorizationStatus status: AVAuthorizationStatus)
    func cameraManager(_ manager: CameraManager, didEncounterError error: Error)
}

/// Manages camera capture session and frame delivery
class CameraManager: NSObject, ObservableObject {
    // MARK: - Published Properties

    @Published var authorizationStatus: AVAuthorizationStatus = .notDetermined
    @Published var isSessionRunning = false

    // MARK: - Public Properties

    let session = AVCaptureSession()
    weak var delegate: CameraManagerDelegate?

    // MARK: - Private Properties

    private let sessionQueue = DispatchQueue(label: "com.currencyconvertercamera.camera.session", attributes: .concurrent)
    private var videoDataOutput: AVCaptureVideoDataOutput?
    private var isConfigured = false

    // MARK: - Initialization

    override init() {
        super.init()
        updateAuthorizationStatus()
        AppLogger.debug("CameraManager initialized", category: AppLogger.general)
    }

    // MARK: - Camera Permissions

    func requestCameraPermission() {
        AppLogger.debug("Requesting camera permission", category: AppLogger.general)

        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.updateAuthorizationStatus()
                if granted {
                    AppLogger.info("Camera permission granted", category: AppLogger.general)
                    // Notify delegate about authorization update
                    if let self = self {
                        self.delegate?.cameraManager(self, didUpdateAuthorizationStatus: .authorized)
                    }
                } else {
                    AppLogger.warning("Camera permission denied", category: AppLogger.general)
                    if let self = self {
                        self.delegate?.cameraManager(self, didUpdateAuthorizationStatus: .denied)
                    }
                }
            }
        }
    }

    private func updateAuthorizationStatus() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        DispatchQueue.main.async {
            self.authorizationStatus = status
        }
    }

    // MARK: - Session Management

    func startSession() {
        sessionQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }

            AppLogger.debug("Starting camera session", category: AppLogger.general)

            // Check authorization
            guard self.authorizationStatus == .authorized else {
                AppLogger.warning("Camera not authorized, cannot start session", category: AppLogger.general)
                return
            }

            // Configure if needed
            if !self.isConfigured {
                self.configureSession()
            }

            // Start session
            if !self.session.isRunning {
                self.session.startRunning()
                DispatchQueue.main.async {
                    self.isSessionRunning = true
                }
                AppLogger.info("Camera session started", category: AppLogger.general)
            }
        }
    }

    func stopSession() {
        sessionQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }

            AppLogger.debug("Stopping camera session", category: AppLogger.general)

            if self.session.isRunning {
                self.session.stopRunning()
                DispatchQueue.main.async {
                    self.isSessionRunning = false
                }
                AppLogger.info("Camera session stopped", category: AppLogger.general)
            }
        }
    }

    // MARK: - Session Configuration

    private func configureSession() {
        guard authorizationStatus == .authorized else {
            AppLogger.warning("Cannot configure session without authorization", category: AppLogger.general)
            return
        }

        session.beginConfiguration()
        defer { session.commitConfiguration() }

        // Set preset
        if session.canSetSessionPreset(.high) {
            session.sessionPreset = .high
        }

        // Configure video input
        configureVideoInput()

        // Configure video output
        configureVideoOutput()

        isConfigured = true
        AppLogger.debug("Camera session configured", category: AppLogger.general)
    }

    private func configureVideoInput() {
        // Remove existing inputs
        session.inputs.forEach { input in
            session.removeInput(input)
        }

        // Add video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            AppLogger.error("Could not get video device", error: nil, category: AppLogger.general)
            return
        }

        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
                AppLogger.debug("Video input added to session", category: AppLogger.general)
            }
        } catch {
            AppLogger.error("Failed to create video input", error: error, category: AppLogger.general)
        }
    }

    private func configureVideoOutput() {
        // Remove existing outputs
        session.outputs.forEach { output in
            session.removeOutput(output)
        }

        // Create and configure video output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)

        // Configure pixel format
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]

        // Discard late frames to prevent delays
        videoOutput.alwaysDiscardsLateVideoFrames = true

        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
            self.videoDataOutput = videoOutput

            // Set connection
            if let connection = videoOutput.connection(with: .video) {
                connection.videoOrientation = .portrait
            }

            AppLogger.debug("Video output added to session", category: AppLogger.general)
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            AppLogger.error("Could not get pixel buffer", error: nil, category: AppLogger.general)
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.delegate?.cameraManager(self ?? CameraManager(), didCaptureFrame: pixelBuffer)
        }
    }

    func captureOutput(
        _ output: AVCaptureOutput,
        didDrop sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        AppLogger.debug("Dropped video frame", category: AppLogger.general)
    }
}
