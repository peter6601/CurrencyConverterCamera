//
//  CurrencyConverterCameraApp.swift
//  CurrencyConverterCamera
//
//  Created by 丁暐哲 on 2025/12/2.
//

import SwiftUI
internal import Combine

@main
struct CurrencyConverterCameraApp: App {
    // MARK: - App Lifecycle
    
    @State private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.appState, appState)
        }
    }
}

// MARK: - App State

/// Global application state for managing currency settings and conversion history
class AppState: ObservableObject {
    // MARK: - Properties

    @Published var currencySettings: CurrencySettings?
    @Published var conversionHistory: [ConversionRecord] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let storageService: StorageService
    
    // MARK: - Initialization
    
    init() {
        self.storageService = StorageService()
        self.setupApp()
    }
    
    // MARK: - Setup
    
    private func setupApp() {
        AppLogger.info("App initializing...", category: AppLogger.general)

        // Load saved settings
        loadCurrencySettings()

        // Load conversion history
        loadConversionHistory()

        AppLogger.info("App initialized successfully", category: AppLogger.general)
    }
    
    // MARK: - Currency Settings Management
    
    /// Load currency settings from persistent storage
    func loadCurrencySettings() {
        AppLogger.debug("Loading currency settings...", category: AppLogger.storage)
        
        do {
            if let settings =  storageService.loadCurrencySettings() {
                self.currencySettings = settings
                AppLogger.info("Currency settings loaded: \(settings.currencyName)", category: AppLogger.storage)
            } else {
                AppLogger.info("No saved currency settings found", category: AppLogger.storage)
            }
        } catch {
            AppLogger.error("Failed to load currency settings", error: error, category: AppLogger.storage)
            self.errorMessage = "Failed to load settings"
        }
    }
    
    /// Save currency settings to persistent storage
    func saveCurrencySettings(_ settings: CurrencySettings) {
        AppLogger.debug("Saving currency settings: \(settings.currencyName)", category: AppLogger.storage)
        
        guard settings.isValid else {
            AppLogger.warning("Cannot save invalid currency settings", category: AppLogger.storage)
            self.errorMessage = "Invalid settings: \(settings.validationError?.localizedDescription ?? "Unknown error")"
            return
        }
        
        do {
            try storageService.saveCurrencySettings(settings)
            self.currencySettings = settings
            self.errorMessage = nil
            AppLogger.info("Currency settings saved successfully", category: AppLogger.storage)
        } catch {
            AppLogger.error("Failed to save currency settings", error: error, category: AppLogger.storage)
            self.errorMessage = "Failed to save settings"
        }
    }
    
    // MARK: - Conversion History Management
    
    /// Load conversion history from persistent storage
    func loadConversionHistory() {
        AppLogger.debug("Loading conversion history...", category: AppLogger.storage)
        
        do {
            self.conversionHistory = try storageService.loadConversionHistory()
            AppLogger.info("Loaded \(conversionHistory.count) conversion records", category: AppLogger.storage)
        } catch {
            AppLogger.error("Failed to load conversion history", error: error, category: AppLogger.storage)
            self.errorMessage = "Failed to load history"
            self.conversionHistory = []
        }
    }
    
    /// Add a new conversion record to history
    func addConversionRecord(_ record: ConversionRecord) {
        AppLogger.debug("Adding conversion record: \(record.originalPrice) → \(record.convertedAmount)", category: AppLogger.conversion)
        
        do {
            try storageService.addConversionRecord(record)
            self.conversionHistory.insert(record, at: 0) // Insert at top (most recent first)
            self.errorMessage = nil
            AppLogger.info("Conversion record added successfully", category: AppLogger.conversion)
        } catch {
            AppLogger.error("Failed to add conversion record", error: error, category: AppLogger.conversion)
            self.errorMessage = "Failed to save conversion"
        }
    }
    
    /// Clear all conversion history
    func clearConversionHistory() {
        AppLogger.warning("Clearing conversion history...", category: AppLogger.storage)
        
        do {
            try storageService.clearHistory()
            self.conversionHistory = []
            self.errorMessage = nil
            AppLogger.info("Conversion history cleared", category: AppLogger.storage)
        } catch {
            AppLogger.error("Failed to clear conversion history", error: error, category: AppLogger.storage)
            self.errorMessage = "Failed to clear history"
        }
    }
    
    // MARK: - Error Handling
    
    /// Clear the current error message
    func clearError() {
        self.errorMessage = nil
    }
}

// MARK: - Environment Key

/// Environment key for accessing app state throughout the app
struct AppStateEnvironmentKey: EnvironmentKey {
    static let defaultValue: AppState = AppState()
}

extension EnvironmentValues {
    var appState: AppState {
        get { self[AppStateEnvironmentKey.self] }
        set { self[AppStateEnvironmentKey.self] = newValue }
    }
}
