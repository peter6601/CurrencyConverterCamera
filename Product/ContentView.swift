//
//  ContentView.swift
//  CurrencyConverterCamera
//
//  Created by 丁暐哲 on 2025/12/2.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.appState) var appState
    @State private var selectedView: MainView = .settings

    enum MainView {
        case settings
        case camera
    }

    var body: some View {
        Group {
            switch selectedView {
            case .settings:
                InitialSetupView(onContinueToCamera: {
                    selectedView = .camera
                })
            case .camera:
                cameraViewWithBackButton
            }
        }
    }
    
    private var cameraViewWithBackButton: some View {
        ZStack(alignment: .topLeading) {
            CameraView()
            
            // Back to Settings button
            Button(action: {
                selectedView = .settings
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Settings")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.6))
                .foregroundColor(.white)
                .cornerRadius(20)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
        .environment(\.appState, AppState())
}
