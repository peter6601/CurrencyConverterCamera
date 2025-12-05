//
//  SettingsViewModel.swift
//  CurrencyConverterCamera
//
//  Created by Claude on 2025-12-03.
//

import Foundation
internal import Combine

/// ViewModel for managing currency settings
class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var currencyName: String = ""
    @Published var exchangeRateText: String = ""
    @Published var validationError: ValidationError?
    @Published var isSaving = false
    @Published var successMessage: String?

    // MARK: - Private Properties

    private let storageService: StorageService
    private let appState: AppState
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Validation Error Type

    enum ValidationError: Error, Equatable {
        case emptyCurrencyName
        case currencyNameTooLong
        case invalidCurrencyFormat
        case invalidExchangeRate
        case exchangeRateTooSmall
        case exchangeRateTooLarge
        case exchangeRateNotPositive
        case storageError(String)

        var message: String {
            switch self {
            case .emptyCurrencyName:
                return "Currency name cannot be empty"
            case .currencyNameTooLong:
                return "Currency name must be 20 characters or less"
            case .invalidCurrencyFormat:
                return "Currency must be letters only (e.g., JPY)"
            case .invalidExchangeRate:
                return "Invalid exchange rate format"
            case .exchangeRateTooSmall:
                return "Exchange rate must be at least 0.0001"
            case .exchangeRateTooLarge:
                return "Exchange rate cannot exceed 10000"
            case .exchangeRateNotPositive:
                return "Exchange rate must be greater than 0"
            case .storageError(let message):
                return "Storage error: \(message)"
            }
        }
    }

    // MARK: - Initialization

    init(storageService: StorageService = StorageService(), appState: AppState = AppState()) {
        self.storageService = storageService
        self.appState = appState

        loadSettings()
        setupBindings()
    }

    // MARK: - Setup

    private func setupBindings() {
        $currencyName
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

    func loadSettings() {
        AppLogger.debug("Loading settings in ViewModel", category: AppLogger.general)

        do {
            if let settings = try storageService.loadCurrencySettings() {
                self.currencyName = settings.currencyName
                self.exchangeRateText = String(format: "%.4f", settings.exchangeRate.doubleValue)
                AppLogger.info("Settings loaded: \(settings.currencyName)", category: AppLogger.general)
            }
        } catch {
            AppLogger.error("Failed to load settings", error: error, category: AppLogger.general)
            self.validationError = .storageError("Failed to load settings")
        }
    }

    // MARK: - Validation

    private func validateInput() {
        let currencyError = validateCurrencyName(currencyName)
        let rateError = validateExchangeRate(exchangeRateText)

        self.validationError = currencyError ?? rateError
    }
    
    // For testing purposes: validate immediately without debounce
    func validateNow() {
        validateInput()
    }

    private func validateCurrencyName(_ name: String) -> ValidationError? {
        if name.isEmpty {
            return .emptyCurrencyName
        }

        if name.count > Constants.maxCurrencyNameLength {
            return .currencyNameTooLong
        }

        if !name.allSatisfy({ $0.isLetter }) {
            return .invalidCurrencyFormat
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
        let currencyOK = validateCurrencyName(currencyName) == nil
        let rateOK = validateExchangeRate(exchangeRateText) == nil
        let rateNotEmpty = !exchangeRateText.isEmpty

        return currencyOK && rateOK && rateNotEmpty
    }

    // MARK: - Saving

    func saveSettings() {
        AppLogger.debug("Saving settings from ViewModel", category: AppLogger.general)

        validateInput()

        guard isValid else {
            AppLogger.warning("Cannot save invalid settings", category: AppLogger.general)
            return
        }

        isSaving = true
        successMessage = nil

        do {
            guard let rate = Decimal(string: exchangeRateText) else {
                self.validationError = .invalidExchangeRate
                self.isSaving = false
                return
            }

            let settings = CurrencySettings(
                currencyName: currencyName.uppercased(),
                exchangeRate: rate
            )

            guard settings.isValid else {
                self.validationError = .storageError(settings.validationError?.localizedDescription ?? "Unknown error")
                self.isSaving = false
                return
            }

            try storageService.saveCurrencySettings(settings)

            appState.currencySettings = settings

            self.validationError = nil
            self.successMessage = "Settings saved successfully"

            AppLogger.info("Settings saved: \(settings.currencyName)", category: AppLogger.general)

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.successMessage = nil
            }
        } catch {
            AppLogger.error("Failed to save settings", error: error, category: AppLogger.general)
            self.validationError = .storageError("Failed to save settings")
        }

        isSaving = false
    }

    // MARK: - Reset

    func reset() {
        AppLogger.debug("Resetting settings form", category: AppLogger.general)

        if let settings = appState.currencySettings {
            self.currencyName = settings.currencyName
            self.exchangeRateText = String(format: "%.4f", settings.exchangeRate.doubleValue)
        } else {
            self.currencyName = ""
            self.exchangeRateText = ""
        }

        self.validationError = nil
        self.successMessage = nil
    }

    // MARK: - Helper Properties

    var currencyNameUppercased: String {
        currencyName.uppercased()
    }

    var formattedExchangeRate: String {
        guard let rate = Decimal(string: exchangeRateText) else {
            return exchangeRateText
        }
        return String(format: "%.4f", rate.doubleValue)
    }

    var currencyHelperText: String {
        "3-letter currency code (e.g., JPY, USD, EUR)"
    }

    var exchangeRateHelperText: String {
        "Rate must be between 0.0001 and 10000"
    }
}
