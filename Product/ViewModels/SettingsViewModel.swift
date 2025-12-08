//
//  SettingsViewModel.swift
//  CurrencyConverterCamera
//
//  Created by Claude on 2025-12-03.
//

internal import Combine
import Foundation

/// ViewModel for managing currency settings
class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var foreignCurrency: String = ""
    @Published var localCurrency: String = ""
    @Published var exchangeRateText: String = ""
    @Published var validationError: ValidationError?
    @Published var isSaving = false
    @Published var successMessage: String?

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Validation Error Type

    enum ValidationError: Error, Equatable {
        case emptyForeignCurrency
        case foreignCurrencyTooLong
        case invalidForeignCurrencyFormat
        case emptyLocalCurrency
        case localCurrencyTooLong
        case invalidLocalCurrencyFormat
        case invalidExchangeRate
        case exchangeRateTooSmall
        case exchangeRateTooLarge
        case exchangeRateNotPositive
        case storageError(String)

        var message: String {
            switch self {
            case .emptyForeignCurrency:
                return NSLocalizedString(
                    "error_empty_foreign", comment: "Foreign currency code cannot be empty")
            case .foreignCurrencyTooLong:
                return NSLocalizedString(
                    "error_long_foreign",
                    comment: "Foreign currency code must be 20 characters or less")
            case .invalidForeignCurrencyFormat:
                return NSLocalizedString(
                    "error_invalid_foreign", comment: "Foreign currency must be letters only")
            case .emptyLocalCurrency:
                return NSLocalizedString(
                    "error_empty_local", comment: "Local currency code cannot be empty")
            case .localCurrencyTooLong:
                return NSLocalizedString(
                    "error_long_local", comment: "Local currency code must be 20 characters or less"
                )
            case .invalidLocalCurrencyFormat:
                return NSLocalizedString(
                    "error_invalid_local", comment: "Local currency must be letters only")
            case .invalidExchangeRate:
                return NSLocalizedString(
                    "error_invalid_rate", comment: "Invalid exchange rate format")
            case .exchangeRateTooSmall:
                return NSLocalizedString(
                    "error_rate_too_small", comment: "Exchange rate must be at least 0.0001")
            case .exchangeRateTooLarge:
                return NSLocalizedString(
                    "error_rate_too_large", comment: "Exchange rate cannot exceed 10000")
            case .exchangeRateNotPositive:
                return NSLocalizedString(
                    "error_rate_not_positive", comment: "Exchange rate must be greater than 0")
            case .storageError(let message):
                return String(
                    format: NSLocalizedString("error_storage", comment: "Storage error: %@"),
                    message)
            }
        }
    }

    // MARK: - Initialization

    init() {
        setupBindings()
    }

    // MARK: - Setup

    private func setupBindings() {
        $foreignCurrency
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.validateInput()
            }
            .store(in: &cancellables)

        $localCurrency
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.validateInput()
            }
            .store(in: &cancellables)

        $exchangeRateText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.validateInput()
            }
            .store(in: &cancellables)
    }

    // MARK: - Loading

    func loadSettings(from settings: CurrencySettings?) {
        AppLogger.debug("Loading settings into ViewModel", category: AppLogger.general)

        if let settings = settings {
            self.foreignCurrency = settings.foreignCurrency
            self.localCurrency = settings.localCurrency
            self.exchangeRateText = String(format: "%.4f", settings.exchangeRate.doubleValue)
        }
    }

    // MARK: - Validation

    private func validateInput() {
        let foreignError = validateCurrencyCode(foreignCurrency, type: .foreign)
        let localError = validateCurrencyCode(localCurrency, type: .local)
        let rateError = validateExchangeRate(exchangeRateText)

        self.validationError = foreignError ?? localError ?? rateError
    }

    // For testing purposes: validate immediately without debounce
    func validateNow() {
        validateInput()
    }

    private enum CurrencyType {
        case foreign
        case local
    }

    private func validateCurrencyCode(_ code: String, type: CurrencyType) -> ValidationError? {
        if code.isEmpty {
            return type == .foreign ? .emptyForeignCurrency : .emptyLocalCurrency
        }

        if code.count > Constants.maxCurrencyNameLength {
            return type == .foreign ? .foreignCurrencyTooLong : .localCurrencyTooLong
        }

        if !code.allSatisfy({ $0.isLetter }) {
            return type == .foreign ? .invalidForeignCurrencyFormat : .invalidLocalCurrencyFormat
        }

        return nil
    }

    private func validateExchangeRate(_ rateText: String) -> ValidationError? {
        guard !rateText.isEmpty else {
            return nil
        }

        guard let rate = Decimal(string: rateText) else {
            return .invalidExchangeRate
        }

        if rate <= 0 {
            return .exchangeRateNotPositive
        }

        if rate < Constants.minExchangeRate {
            return .exchangeRateTooSmall
        }

        if rate > Constants.maxExchangeRate {
            return .exchangeRateTooLarge
        }

        return nil
    }

    var isValid: Bool {
        let foreignOK = validateCurrencyCode(foreignCurrency, type: .foreign) == nil
        let localOK = validateCurrencyCode(localCurrency, type: .local) == nil
        let rateOK = validateExchangeRate(exchangeRateText) == nil
        let rateNotEmpty = !exchangeRateText.isEmpty

        return foreignOK && localOK && rateOK && rateNotEmpty
    }

    // MARK: - Saving

    func saveSettings(to appState: AppState) {
        AppLogger.debug("Saving settings from ViewModel", category: AppLogger.general)

        validateInput()

        guard isValid else {
            AppLogger.warning("Cannot save invalid settings", category: AppLogger.general)
            return
        }

        isSaving = true
        successMessage = nil

        guard let rate = Decimal(string: exchangeRateText) else {
            self.validationError = .invalidExchangeRate
            self.isSaving = false
            return
        }

        let settings = CurrencySettings(
            foreignCurrency: foreignCurrency.uppercased(),
            localCurrency: localCurrency.uppercased(),
            exchangeRate: rate
        )

        guard settings.isValid else {
            self.validationError = .storageError(
                settings.validationError?.description ?? "Unknown error")
            self.isSaving = false
            return
        }

        // Use AppState to save
        appState.saveCurrencySettings(settings)

        if let error = appState.errorMessage {
            self.validationError = .storageError(error)
        } else {
            self.validationError = nil
            self.successMessage = NSLocalizedString(
                "success_saved", comment: "Settings saved successfully")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.successMessage = nil
            }
        }

        isSaving = false
    }

    // MARK: - Reset

    func reset(from settings: CurrencySettings?) {
        AppLogger.debug("Resetting settings form", category: AppLogger.general)

        if let settings = settings {
            self.foreignCurrency = settings.foreignCurrency
            self.localCurrency = settings.localCurrency
            self.exchangeRateText = String(format: "%.4f", settings.exchangeRate.doubleValue)
        } else {
            self.foreignCurrency = ""
            self.localCurrency = ""
            self.exchangeRateText = ""
        }

        self.validationError = nil
        self.successMessage = nil
    }

    // MARK: - Helper Properties

    var foreignCurrencyUppercased: String {
        foreignCurrency.uppercased()
    }

    var localCurrencyUppercased: String {
        localCurrency.uppercased()
    }

    var formattedExchangeRate: String {
        guard let rate = Decimal(string: exchangeRateText) else {
            return exchangeRateText
        }
        return String(format: "%.4f", rate.doubleValue)
    }

    var foreignCurrencyHelperText: String {
        NSLocalizedString("helper_foreign", comment: "3-letter code (e.g., JPY)")
    }

    var localCurrencyHelperText: String {
        NSLocalizedString("helper_local", comment: "3-letter code (e.g., NTD)")
    }

    var exchangeRateHelperText: String {
        NSLocalizedString("helper_rate", comment: "Rate must be between 0.0001 and 10000")
    }
}
