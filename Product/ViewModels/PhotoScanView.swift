//
//  PhotoScanView.swift
//  CurrencyConverterCamera
//
//  Created by Claude on 2025-12-09.
//

import SwiftUI
import PhotosUI

struct PhotoScanView: View {
    @Environment(\.appState) var appState
    @StateObject private var viewModel: PhotoScanViewModel
    
    init(appState: AppState, storageService: StorageService = StorageService()) {
        _viewModel = StateObject(wrappedValue: PhotoScanViewModel(appState: appState, storageService: storageService))
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Image Display Area
                if let image = viewModel.selectedImage {
                    imageDisplayView(image: image)
                } else {
                    emptyStateView
                }
                
                // MARK: - Bottom Control Panel
                bottomControlPanel
            }
            
            // MARK: - Loading Overlay
            if viewModel.isProcessing {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    
                    Text("processing_photo")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
        .onChange(of: viewModel.selectedPhoto) { _, _ in
            viewModel.loadSelectedPhoto()
        }
    }
    
    // MARK: - Image Display View
    
    private func imageDisplayView(image: UIImage) -> some View {
        GeometryReader { geometry in
            ZStack {
                // Display selected image
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Use DetectionOverlayView (same as CameraView)
                if !viewModel.detectedNumbers.isEmpty {
                    // Create a CameraFrame for the overlay
                    let frame = CameraFrame(
                        size: image.size,
                        detectedNumbers: viewModel.detectedNumbers
                    )
                    
                    DetectionOverlayView(
                        frame: frame,
                        detectedNumbers: viewModel.detectedNumbers,
                        conversionResult: viewModel.latestResult,
                        currencySettings: appState.currencySettings
                    )
                }
            }
        }
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("select_photo_to_scan")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("select_photo_subtitle")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Bottom Control Panel
    
    private var bottomControlPanel: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.gray.opacity(0.3))
            
            // Conversion Result Display (similar to CameraView)
            if let result = viewModel.latestResult {
                VStack(alignment: .leading, spacing: 12) {
                    Text("detection_result")
                        .font(.headline)
                        .foregroundColor(.white)

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("detected_amount")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(result.formattedDetectedPrice)
                                .font(.body)
                                .foregroundColor(.white)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("converted_amount")
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

                    // Action Button - Select another photo
                    PhotosPicker(
                        selection: $viewModel.selectedPhoto,
                        matching: .images
                    ) {
                        HStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.system(size: 16))
                            Text("reselect_photo")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else if let error = viewModel.conversionError {
                // Error Display
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    // Photo Picker Button
                    PhotosPicker(
                        selection: $viewModel.selectedPhoto,
                        matching: .images
                    ) {
                        HStack(spacing: 8) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 18))
                            Text("reselect_photo")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                // Empty state or initial instruction
                VStack(spacing: 12) {
                    if viewModel.selectedImage == nil {
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 32))
                            .foregroundColor(.gray)
                        
                        Text("tap_button_to_select_photo")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        Text("detecting_price_in_photo")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.05))
            }
            
            // Main Photo Picker Button (always visible at bottom)
            if viewModel.latestResult == nil && viewModel.conversionError == nil {
                let hasImage = viewModel.selectedImage != nil
                PhotosPicker(
                    selection: $viewModel.selectedPhoto,
                    matching: .images
                ) {
                    HStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 20))
                        Text(hasImage ? "reselect" : "select_photo")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(Color.black.opacity(0.9))
            }
        }
        .background(Color.gray.opacity(0.05))
    }
    
    // MARK: - Helper Functions
    
    private func formatNumber(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter.string(from: value as NSDecimalNumber) ?? "0"
    }
    
    private func confidenceColor(_ confidence: Double) -> Color {
        if confidence >= 0.9 {
            return .green
        } else if confidence >= 0.7 {
            return .yellow
        } else {
            return .orange
        }
    }
}

// MARK: - Preview

#Preview {
    let appState = AppState()
    PhotoScanView(appState: appState)
        .environment(\.appState, appState)
}
