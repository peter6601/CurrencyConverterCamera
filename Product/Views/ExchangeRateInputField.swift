//
//  ExchangeRateInputField.swift
//  CurrencyConverterCamera
//
//  Created by Claude on 2025-12-03.
//

import SwiftUI

/// Input field for exchange rate (decimal value)
struct ExchangeRateInputField: View {
    @Binding var value: String
    var isInvalid: Bool = false
    var errorMessage: String?
    var helperText: String = "Rate must be between 0.0001 and 10000"

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // MARK: - Label
            HStack {
                Label("Exchange Rate", systemImage: "chart.line.uptrend.xyaxis")
                    .font(.headline)

                Spacer()

                if isInvalid {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.red)
                } else if !value.isEmpty {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }

            // MARK: - Input Field
            TextField("e.g., 0.22", text: $value)
                .keyboardType(.decimalPad)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
                .foregroundStyle(.primary)
                .padding(.vertical, 4)
                .onChange(of: value) { oldValue, newValue in
                    // Allow only digits and one decimal point
                    let filtered = filterDecimalInput(newValue)
                    if filtered != newValue {
                        value = filtered
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(
                            isInvalid ? Color.red : Color.gray.opacity(0.3),
                            lineWidth: isInvalid ? 2 : 1
                        )
                )

            // MARK: - Helper/Error Text
            if let errorMessage = errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.caption)
                        .foregroundStyle(.red)

                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)

                    Spacer()
                }
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundStyle(.blue)

                    Text(helperText)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()
                }
            }

            // MARK: - Range Info
            HStack {
                Text("Min: 0.0001")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("Max: 10000")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Helper

    private func filterDecimalInput(_ input: String) -> String {
        // Allow only digits and decimal point
        let filtered = input.filter { character in
            character.isNumber || character == "."
        }

        // Ensure only one decimal point
        let components = filtered.split(separator: ".", maxSplits: 1)
        if components.count > 2 {
            return String(components[0]) + "." + String(components[1])
        }

        return filtered
    }
}

#Preview {
    VStack(spacing: 20) {
        ExchangeRateInputField(
            value: .constant("0.22"),
            isInvalid: false
        )

        ExchangeRateInputField(
            value: .constant(""),
            isInvalid: true,
            errorMessage: "Exchange rate must be greater than 0"
        )

        Spacer()
    }
    .padding()
}
