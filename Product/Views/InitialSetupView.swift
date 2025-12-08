//
//  InitialSetupView.swift
//  CurrencyConverterCamera
//
//  Created by Claude on 2025-12-03.
//

import SwiftUI
import UIKit

struct InitialSetupView: View {
    @Environment(\.appState) var appState

    // UI State
    @State private var foreignCurrency = ""
    @State private var localCurrency = ""
    @State private var exchangeRateText = ""
    @State private var validationError: String?
    @State private var isSaving = false

    // Callback to navigate to camera
    var onContinueToCamera: () -> Void

    // Computed Properties for Validation
    var isValid: Bool {
        let foreignValid =
            !foreignCurrency.isEmpty && foreignCurrency.count <= 20
            && foreignCurrency.allSatisfy { $0.isLetter }
        let localValid =
            !localCurrency.isEmpty && localCurrency.count <= 20
            && localCurrency.allSatisfy { $0.isLetter }

        guard let rate = Decimal(string: exchangeRateText) else {
            return false
        }
        let rateValid = !exchangeRateText.isEmpty && rate > 0

        return foreignValid && localValid && rateValid
    }

    var body: some View {
        ZStack {
            // Background
            Color(.systemGray6)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Blue Header
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Spacer()
                        // Optional dots menu if needed, ignoring for now based on screenshot
                    }

                    Text("匯率設定")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 40)

                    Text("設定您的換算基準")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.bottom, 20)
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.blue)  // Using standard blue, or a custom hex if needed
                .cornerRadius(30, corners: [.bottomLeft, .bottomRight])
                .ignoresSafeArea(edges: .top)

                // MARK: - Main Content Card
                ScrollView {
                    VStack(spacing: 24) {

                        // MARK: - Rate Input Section
                        // 匯率 (1 外幣 = ? 本幣)
                        VStack(alignment: .leading, spacing: 8) {
                            Text(
                                "匯率 (1 \(foreignCurrency.isEmpty ? "外幣" : foreignCurrency) = ? \(localCurrency.isEmpty ? "本幣" : localCurrency))"
                            )
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .fontWeight(.bold)

                            HStack(spacing: 12) {
                                Image(systemName: "multiply")
                                    .font(.system(size: 24))
                                    .foregroundColor(.gray)

                                TextField("0.00", text: $exchangeRateText)
                                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                                    .foregroundColor(.blue)
                                    .keyboardType(.decimalPad)
                            }

                            Divider()
                        }

                        // MARK: - Local Currency Section
                        // 本幣 (顯示)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("本幣 (顯示)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .fontWeight(.bold)

                            HStack(spacing: 12) {
                                Image(systemName: "dollarsign.circle.fill")  // Replaced bag icon with SF Symbol
                                    .font(.system(size: 32))
                                    .foregroundColor(.gray)

                                TextField("NTD", text: $localCurrency)
                                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))  // Dark blue-gray
                                    .textInputAutocapitalization(.characters)
                                    .onChange(of: localCurrency) { _, newValue in
                                        localCurrency = String(
                                            newValue.filter { $0.isLetter }.prefix(20)
                                        ).uppercased()
                                    }

                                Spacer()
                            }

                            Divider()
                        }

                        // MARK: - Foreign Currency Section (Added to match logic)
                        // Needed to define what "1 Foreign" is.
                        // Based on screenshot "1,000 JPY", user must input JPY somewhere.
                        // I will add a third field similar to Local Currency.

                        VStack(alignment: .leading, spacing: 8) {
                            Text("外幣代號")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .fontWeight(.bold)

                            HStack(spacing: 12) {
                                Image(systemName: "globe")
                                    .font(.system(size: 32))
                                    .foregroundColor(.gray)

                                TextField("JPY", text: $foreignCurrency)
                                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
                                    .textInputAutocapitalization(.characters)
                                    .onChange(of: foreignCurrency) { _, newValue in
                                        foreignCurrency = String(
                                            newValue.filter { $0.isLetter }.prefix(20)
                                        ).uppercased()
                                    }

                                Spacer()
                            }

                            Divider()
                        }

                        // MARK: - Prevention Preview Card
                        // 試算預覽
                        VStack(spacing: 16) {
                            Text("試算預覽")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .fontWeight(.bold)

                            HStack(alignment: .center, spacing: 8) {
                                Text("1,000")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)

                                Text(foreignCurrency.isEmpty ? "JPY" : foreignCurrency)
                                    .font(.headline)
                                    .foregroundColor(.gray)

                                Text("=")
                                    .font(.title2)
                                    .foregroundColor(.gray.opacity(0.5))

                                let rate = Decimal(string: exchangeRateText) ?? 0
                                let result = rate * 1000
                                let formattedResult = formatResult(result)

                                Text(formattedResult)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)

                                Text(localCurrency.isEmpty ? "NTD" : localCurrency)
                                    .font(.headline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )

                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(24)
                    .padding(.horizontal, 16)
                    .padding(.top, -20)  // Overlap with blue header slightly
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                }

                Spacer()

                // MARK: - Bottom Button
                Button(action: saveSettings) {
                    HStack {
                        if isSaving {
                            ProgressView()
                                .tint(.white)
                                .padding(.trailing, 8)
                        } else {
                            Image(systemName: "camera")
                                .font(.headline)
                        }

                        Text(isSaving ? "儲存中..." : "儲存並開啟相機")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isValid ? Color.blue : Color.blue.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 34)  // Bottom safe area
                .disabled(!isValid || isSaving)
            }
        }
        .onAppear {
            loadExistingSettings()
        }
    }

    // MARK: - Logic

    private func loadExistingSettings() {
        if let settings = appState.currencySettings {
            foreignCurrency = settings.foreignCurrency
            localCurrency = settings.localCurrency
            exchangeRateText = String(describing: settings.exchangeRate)
            // Auto-load implies we just populate.
            // Requirement said "Next time ... automatically bring in values".
        }
    }

    private func formatResult(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter.string(from: value as NSDecimalNumber) ?? "0"
    }

    private func saveSettings() {
        guard isValid else { return }

        isSaving = true

        // Simulating save delay slightly for UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let rate = Decimal(string: self.exchangeRateText) else {
                self.isSaving = false
                return
            }

            let settings = CurrencySettings(
                foreignCurrency: self.foreignCurrency,
                localCurrency: self.localCurrency,
                exchangeRate: rate
            )

            // Save via AppState
            self.appState.saveCurrencySettings(settings)

            if self.appState.errorMessage == nil {
                // Success - navigate to camera
                self.onContinueToCamera()
            } else {
                // Error handling handled by AppState state, but we could show alert
                self.validationError = self.appState.errorMessage
            }

            self.isSaving = false
        }
    }
}

// MARK: - Corner Radius Helper
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - Preview

#Preview {
    InitialSetupView(onContinueToCamera: {})
        .environment(\.appState, AppState())
}
