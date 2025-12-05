//
//  CameraView.swift
//  CurrencyConverterCamera
//
//  Created by Claude on 2025-12-03.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var viewModel = CameraViewModel()
    @Environment(\.appState) var appState
    @State private var isConversionEnabled = false  // Switch state

    var body: some View {
        ZStack {
            // Camera preview background
            Color.black
                .ignoresSafeArea()

            if viewModel.cameraPermissionDenied {
                // Camera permission denied view
                permissionDeniedView
            } else {
                // Camera preview with overlay
                VStack(spacing: 0) {
                    // Camera preview area
                    cameraPreviewArea

                    // Detection results area
                    detectionResultsArea
                }
            }
        }
        .onAppear {
            // Request camera permission first
            viewModel.requestCameraPermission()
            
            // Start camera if authorized
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if !viewModel.cameraPermissionDenied {
                    viewModel.startCamera()
                }
            }
        }
        .onDisappear {
            viewModel.stopCamera()
        }
        .onChange(of: isConversionEnabled) { enabled in
            viewModel.isConversionEnabled = enabled
        }
    }

    // MARK: - Subviews

    private var permissionDeniedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("Camera Access Denied")
                .font(.headline)

            Text("Please enable camera access in Settings to use this feature")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            Button(action: openSettings) {
                Text("Open Settings")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding()

            Spacer()
        }
        .padding()
    }

    private var cameraPreviewArea: some View {
        ZStack {
            // Real camera preview
            if viewModel.isSessionRunning {
                CameraPreviewView(session: viewModel.cameraManager.session)
                    .ignoresSafeArea()
            } else {
                // Camera preview placeholder when not running
                Rectangle()
                    .fill(Color.black)
                    .overlay(
                        VStack {
                            Text("📷 Camera Preview")
                                .foregroundColor(.gray)
                            Text("Starting camera...")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
            }

            // Conversion Toggle Switch - 移到右上角
            VStack {
                HStack {
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 8) {
                            Text("Detect")
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Toggle("", isOn: $isConversionEnabled)
                                .labelsHidden()
                                .tint(.green)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(20)
                        
                        // 小狀態指示器
                        if isConversionEnabled {
                            Text("ON")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                                .padding(.trailing, 12)
                        } else {
                            Text("OFF")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                                .padding(.trailing, 12)
                        }
                    }
                    .padding(.top, 60) // 避開返回按鈕
                    .padding(.trailing, 16)
                }
                
                Spacer()
            }

            // Detection overlay (only show when enabled)
            if isConversionEnabled {
                if let frame = viewModel.currentFrame {
                    DetectionOverlayView(
                        frame: frame, 
                        detectedNumbers: viewModel.detectedNumbers,
                        conversionResult: viewModel.latestResult,
                        currencySettings: appState.currencySettings
                    )
                }
            }

            // Loading indicator (only show when enabled and processing)
            if isConversionEnabled && viewModel.isProcessing {
                VStack {
                    Spacer()
                    
                    HStack {
                        ProgressView()
                            .tint(.white)
                        Text("Detecting...")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                    .padding(.bottom, 20)
                }
            }
        }
        .frame(maxHeight: .infinity)
    }

    private var detectionResultsArea: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.gray.opacity(0.3))

            if !isConversionEnabled {
                // Show message when conversion is disabled
                VStack(spacing: 12) {
                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("Price Detection is Off")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Enable the switch above to start detecting prices")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
            } else if let result = viewModel.latestResult {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Detection Result")
                        .font(.headline)
                        .foregroundColor(.white)

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Detected")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(result.formattedDetectedPrice)
                                .font(.body)
                                .foregroundColor(.white)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Converted")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(result.formattedConvertedAmount)
                                .font(.body)
                                .foregroundColor(.green)
                        }
                    }

                    HStack {
                        Label(result.confidencePercentage, systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)

                        Spacer()

                        Text(result.formattedTimestamp)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    Button(action: viewModel.saveCurrentResult) {
                        Text("Save Result")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
            } else if let error = viewModel.conversionError {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .padding()
                .background(Color.red.opacity(0.1))
            } else {
                VStack(spacing: 8) {
                    Text("Point camera at price tags or receipts")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
        }
        .background(Color.gray.opacity(0.05))
    }

    // MARK: - Actions

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Preview

#Preview {
    CameraView()
        .environment(\.appState, AppState())
}
