//
//  CurrencyInputField.swift
//  CurrencyConverterCamera
//
//  Created by Claude on 2025-12-03.
//

import SwiftUI

/// Input field for currency code (e.g., "JPY", "USD")
struct CurrencyInputField: View {
    @Binding var value: String
    var isInvalid: Bool = false
    var errorMessage: String?
    var helperText: String = "3-letter currency code (e.g., JPY, USD, EUR)"

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // MARK: - Label
            HStack {
                Label("Currency", systemImage: "globe")
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
            TextField("e.g., JPY", text: $value)
                .textInputAutocapitalization(.characters)
                .keyboardType(.default)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
                .foregroundStyle(.primary)
                .padding(.vertical, 4)
                .onChange(of: value) { oldValue, newValue in
                    // Only allow letters, convert to uppercase
                    let filtered = newValue.filter { $0.isLetter }
                    if filtered != newValue {
                        value = filtered
                    } else {
                        value = filtered.uppercased()
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

            // MARK: - Character Count
            HStack {
                Spacer()
                Text("\(value.count)/20")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    VStack(spacing: 20) {
        CurrencyInputField(
            value: .constant("JPY"),
            isInvalid: false
        )

        CurrencyInputField(
            value: .constant(""),
            isInvalid: true,
            errorMessage: "Currency name cannot be empty"
        )

        Spacer()
    }
    .padding()
}
