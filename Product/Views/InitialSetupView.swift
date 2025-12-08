//
//  InitialSetupView.swift
//  CurrencyConverterCamera
//
//  Created by Claude on 2025-12-03.
//

import SwiftUI

struct InitialSetupView: View {
    @Environment(\.appState) var appState
    @State private var currencyName = ""
    @State private var exchangeRateText = ""
    @State private var validationError: String?
    @State private var isSaving = false
    
    // Callback to navigate to camera
    var onContinueToCamera: () -> Void

    var isValid: Bool {
        let currencyValid = !currencyName.isEmpty && currencyName.count <= 20 && currencyName.allSatisfy { $0.isLetter }
        guard let rate = Decimal(string: exchangeRateText) else {
            return false
        }
        let rateValid = !exchangeRateText.isEmpty && rate > 0
        return currencyValid && rateValid
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "gear.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)

                    Text("Currency Settings")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Configure your currency exchange rate")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.8))

                // Form
                ScrollView {
                    VStack(spacing: 20) {
                        // Currency Input
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Currency Code", systemImage: "dollarsign.circle.fill")
                                .font(.headline)
                                .foregroundColor(.blue)

                            TextField("e.g., JPY, USD, EUR", text: $currencyName)
                                .textInputAutocapitalization(.characters)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                .onChange(of: currencyName) { _, newValue in
                                    currencyName = String(newValue.filter { $0.isLetter }.prefix(20))
                                    validateInput()
                                }

                            Text("Maximum 20 letters, letters only")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        // Exchange Rate Input
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Exchange Rate", systemImage: "chart.line.uptrend.xyaxis.circle.fill")
                                .font(.headline)
                                .foregroundColor(.blue)

                            TextField("e.g., 0.22 or 31.35", text: $exchangeRateText)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                .onChange(of: exchangeRateText) { _, _ in
                                    validateInput()
                                }

                            Text("Must be between 0.0001 and 10000")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        // Validation Error
                        if let error = validationError {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.red)
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                        }

                        Spacer()
                    }
                    .padding()
                }

                // Action Buttons
                VStack(spacing: 12) {
                    // Debug info - 顯示當前狀態
                    if let currentSettings = appState.currencySettings {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Saved: \(currentSettings.currencyName)")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    } else {
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.orange)
                            Text("No settings saved yet")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Save Button
                    Button(action: saveSettings) {
                        if isSaving {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .tint(.white)
                                Text("Saving...")
                            }
                        } else {
                            Text("Save Settings")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isValid ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(!isValid || isSaving)
                    
                    // Continue to Camera Button
                    Button(action: {
                        // Only allow navigation if settings are saved
                        if appState.currencySettings != nil {
                            onContinueToCamera()
                        }
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("Continue to Camera")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(appState.currencySettings != nil ? Color.green : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(appState.currencySettings == nil)

                    Text(appState.currencySettings != nil ? "Tap to start using the camera" : "Save settings first to use the camera")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.white.opacity(0.8))
            }
        }
        .onAppear {
            loadExistingSettings()
        }
    }
    
    private func loadExistingSettings() {
        // Load existing settings if available
        if let settings = appState.currencySettings {
            currencyName = settings.currencyName
            exchangeRateText = String(describing: settings.exchangeRate)
            AppLogger.info("Loaded existing settings: \(settings.currencyName)", category: AppLogger.general)
        }
    }



    private func validateInput() {
        validationError = nil

        if currencyName.isEmpty {
            validationError = "Please enter a currency code"
            return
        }

        if currencyName.count > 20 {
            validationError = "Currency code must be 20 characters or less"
            return
        }

        if !currencyName.allSatisfy({ $0.isLetter }) {
            validationError = "Currency must contain letters only"
            return
        }

        if exchangeRateText.isEmpty {
            validationError = "Please enter an exchange rate"
            return
        }

        guard let rate = Decimal(string: exchangeRateText) else {
            validationError = "Invalid exchange rate format"
            return
        }

        if rate <= 0 {
            validationError = "Exchange rate must be greater than 0"
            return
        }

        if rate < Constants.minExchangeRate {
            validationError = "Exchange rate must be at least 0.0001"
            return
        }

        if rate > Constants.maxExchangeRate {
            validationError = "Exchange rate cannot exceed 10000"
            return
        }
    }


    private func saveSettings() {
        print("🔵 Save button pressed")
        print("🔵 Currency: '\(currencyName)'")
        print("🔵 Exchange Rate: '\(exchangeRateText)'")
        
        validateInput()

        guard validationError == nil else {
            print("🔴 Validation error: \(validationError ?? "unknown")")
            return
        }

        isSaving = true
        print("🔵 Starting save process...")

        // Use a slight delay to show the saving state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let rate = Decimal(string: self.exchangeRateText) else {
                print("🔴 Failed to parse exchange rate")
                self.validationError = "Invalid exchange rate"
                self.isSaving = false
                return
            }

            print("🔵 Parsed rate: \(rate)")

            let settings = CurrencySettings(
                currencyName: self.currencyName.uppercased(),
                exchangeRate: rate
            )

            print("🔵 Created settings: \(settings.currencyName) - \(settings.exchangeRate)")
            print("🔵 Settings valid: \(settings.isValid)")

            guard settings.isValid else {
                print("🔴 Settings validation failed: \(settings.validationError?.description ?? "unknown")")
                self.validationError = settings.validationError?.description ?? "Invalid settings"
                self.isSaving = false
                return
            }

            // Use AppState's save method to ensure proper state management
            print("🔵 Calling appState.saveCurrencySettings...")
            self.appState.saveCurrencySettings(settings)

            // Check if there was an error from AppState
            if self.appState.errorMessage != nil {
                print("🔴 AppState error: \(self.appState.errorMessage ?? "unknown")")
                self.validationError = self.appState.errorMessage
                self.appState.clearError()
            } else {
                print("✅ Settings saved successfully!")
                print("✅ appState.currencySettings: \(self.appState.currencySettings?.currencyName ?? "nil")")
                AppLogger.info("Settings saved successfully: \(settings.currencyName)", category: AppLogger.general)
            }

            self.isSaving = false
        }
    }
}

// MARK: - Preview

#Preview {
    InitialSetupView(onContinueToCamera: {})
        .environment(\.appState, AppState())
}
