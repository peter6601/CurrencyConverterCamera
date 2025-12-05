//
//  CameraPreviewView.swift
//  CurrencyConverterCamera
//
//  Created by Claude on 2025-12-04.
//

import SwiftUI
import AVFoundation

/// SwiftUI wrapper for AVCaptureVideoPreviewLayer
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: PreviewView, context: Context) {
        // Update the session if needed
        if uiView.videoPreviewLayer.session != session {
            uiView.videoPreviewLayer.session = session
        }
    }
    
    /// Custom UIView that contains the preview layer
    class PreviewView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            layer as! AVCaptureVideoPreviewLayer
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupLayer()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupLayer()
        }
        
        private func setupLayer() {
            videoPreviewLayer.videoGravity = .resizeAspectFill
            backgroundColor = .black
        }
    }
}
