//
//  SettingsView.swift
//  CurrencyConverterCamera
//
//  Created by Claude on 2025-12-03.
//

import SwiftUI

/// Main settings view for currency configuration
struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.appState) var appState

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.green)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Settings")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("Configure currency and exchange rate")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }
                    .padding()
                }
                .background(Color(.systemGray6))

                // MARK: - Content
                ScrollView {
                    VStack(spacing: 24) {
                        // MARK: - Current Settings Display
                        if let settings = appState.currencySettings {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Current Settings")
                                    .font(.headline)
                                    .padding(.horizontal)

                                VStack(spacing: 12) {
                                    HStack {
                                        Text("Currency")
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                        Text(settings.currencyName)
                                            .fontWeight(.bold)
                                            .font(.system(.body, design: .monospaced))
                                    }

                                    Divider()

                                    HStack {
                                        Text("Exchange Rate")
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                        Text(String(format: "%.4f", settings.exchangeRate.doubleValue))
                                            .fontWeight(.bold)
                                            .font(.system(.body, design: .monospaced))
                                    }

                                    Divider()

                                    HStack {
                                        Text("Last Updated")
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                        Text(settings.lastUpdated.relativeTimeString)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            }
                            .padding(.top)
                        }

                        // MARK: - Input Form
                        VStack(spacing: 16) {
                            Text("Update Settings")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)

                            CurrencyInputField(
                                value: $viewModel.currencyName,
                                isInvalid: isErrorForField(.currency),
                                errorMessage: isErrorForField(.currency) ? viewModel.validationError?.message : nil,
                                helperText: viewModel.currencyHelperText
                            )
                            .padding(.horizontal)

                            ExchangeRateInputField(
                                value: $viewModel.exchangeRateText,
                                isInvalid: isErrorForField(.rate),
                                errorMessage: isErrorForField(.rate) ? viewModel.validationError?.message : nil,
                                helperText: viewModel.exchangeRateHelperText
                            )
                            .padding(.horizontal)
                        }
                        .padding(.vertical)

                        // MARK: - Success Message
                        if let successMessage = viewModel.successMessage {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)

                                Text(successMessage)
                                    .font(.callout)

                                Spacer()
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal)
                        }

                        // MARK: - Error Alert
                        if let error = viewModel.validationError {
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.orange)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Validation Error")
                                        .font(.callout)
                                        .fontWeight(.semibold)

                                    Text(error.message)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()
                            }
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal)
                        }

                        Spacer()
                    }
                    .padding(.vertical)
                }

                // MARK: - Action Buttons
                VStack(spacing: 12) {
                    // Save Button
                    Button(action: {
                        viewModel.saveSettings()
                    }) {
                        if viewModel.isSaving {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .tint(.white)

                                Text("Saving...")
                            }
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle")
                                Text("Save Settings")
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isValid ? Color.blue : Color.gray)
                    .foregroundStyle(.white)
                    .cornerRadius(8)
                    .disabled(!viewModel.isValid || viewModel.isSaving)

                    // Reset Button
                    Button(action: {
                        viewModel.reset()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .foregroundStyle(.primary)
                    .cornerRadius(8)
                    .disabled(viewModel.isSaving)
                }
                .padding()
                .background(Color(.systemGray6))
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Helper

    private enum ErrorField {
        case currency
        case rate
    }

    private func isErrorForField(_ field: ErrorField) -> Bool {
        guard let error = viewModel.validationError else { return false }

        switch field {
        case .currency:
            switch error {
            case .emptyCurrencyName, .currencyNameTooLong, .invalidCurrencyFormat:
                return true
            default:
                return false
            }

        case .rate:
            switch error {
            case .invalidExchangeRate, .exchangeRateTooSmall, .exchangeRateTooLarge, .exchangeRateNotPositive:
                return true
            default:
                return false
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(\.appState, AppState())
}
