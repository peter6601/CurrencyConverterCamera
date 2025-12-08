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
                            Text("settings_title")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("settings_subtitle")
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
                                Text("current_settings")
                                    .font(.headline)
                                    .padding(.horizontal)

                                VStack(spacing: 12) {
                                    HStack {
                                        Text("variables")
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                        Text(
                                            "1 \(settings.foreignCurrency) = \(settings.exchangeRate.doubleValue) \(settings.localCurrency)"
                                        )
                                        .fontWeight(.bold)
                                        .font(.system(.body, design: .monospaced))
                                    }

                                    Divider()

                                    HStack {
                                        Text("last_updated")
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
                            Text("update_settings")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)

                            // Foreign Currency Input
                            CurrencyInputField(
                                value: $viewModel.foreignCurrency,
                                isInvalid: isErrorForField(.foreign),
                                errorMessage: isErrorForField(.foreign)
                                    ? viewModel.validationError?.message : nil,
                                helperText: String(localized: "foreign_prefix")
                                    + viewModel.foreignCurrencyHelperText
                            )
                            .padding(.horizontal)

                            // Local Currency Input
                            CurrencyInputField(
                                value: $viewModel.localCurrency,
                                isInvalid: isErrorForField(.local),
                                errorMessage: isErrorForField(.local)
                                    ? viewModel.validationError?.message : nil,
                                helperText: String(localized: "local_prefix")
                                    + viewModel.localCurrencyHelperText
                            )
                            .padding(.horizontal)

                            // Exchange Rate Input
                            ExchangeRateInputField(
                                value: $viewModel.exchangeRateText,
                                isInvalid: isErrorForField(.rate),
                                errorMessage: isErrorForField(.rate)
                                    ? viewModel.validationError?.message : nil,
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
                                    Text("validation_error")
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
                        viewModel.saveSettings(to: appState)
                    }) {
                        if viewModel.isSaving {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .tint(.white)

                                Text("saving")
                            }
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle")
                                Text("save_settings")
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
                        viewModel.reset(from: appState.currencySettings)
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("reset")
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
            .navigationTitle(String(localized: "settings_title"))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadSettings(from: appState.currencySettings)
            }
        }
    }

    // MARK: - Helper

    private enum ErrorField {
        case foreign
        case local
        case rate
    }

    private func isErrorForField(_ field: ErrorField) -> Bool {
        guard let error = viewModel.validationError else { return false }

        switch field {
        case .foreign:
            switch error {
            case .emptyForeignCurrency, .foreignCurrencyTooLong, .invalidForeignCurrencyFormat:
                return true
            default:
                return false
            }
        case .local:
            switch error {
            case .emptyLocalCurrency, .localCurrencyTooLong, .invalidLocalCurrencyFormat:
                return true
            default:
                return false
            }

        case .rate:
            switch error {
            case .invalidExchangeRate, .exchangeRateTooSmall, .exchangeRateTooLarge,
                .exchangeRateNotPositive:
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
