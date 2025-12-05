//
//  StorageService.swift
//  CurrencyConverterCamera
//
//  Created by Claude on 2025-12-02.
//

import Foundation

/// Protocol defining storage operations for settings and conversion history
protocol StorageServiceProtocol {
    func saveCurrencySettings(_ settings: CurrencySettings) throws
    func loadCurrencySettings() -> CurrencySettings?
    func addConversionRecord(_ record: ConversionRecord) throws
    func loadConversionHistory() -> [ConversionRecord]
    func clearHistory() throws
}

/// Concrete implementation of StorageService
///
/// Handles persistence using:
/// - UserDefaults for CurrencySettings (small, frequently accessed)
/// - FileManager for ConversionRecord array as JSON (larger, less frequent)
class StorageService: StorageServiceProtocol {
    // MARK: - Constants

    private let settingsKey = "currencySettings"
    private let historyFileName = "conversion_history.json"
    private let maxHistoryCount = 50
    
    // MARK: - Thread Safety
    
    private let lock = NSLock()

    // MARK: - Initialization

    init() {}

    // MARK: - CurrencySettings Persistence

    /// Save currency settings to UserDefaults
    /// - Parameter settings: CurrencySettings to persist
    /// - Throws: Encoding errors
    func saveCurrencySettings(_ settings: CurrencySettings) throws {
        // Update timestamp before saving
        var updatedSettings = settings
        updatedSettings.lastUpdated = Date()
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(updatedSettings)
        UserDefaults.standard.set(data, forKey: settingsKey)
        UserDefaults.standard.synchronize()
    }

    /// Load currency settings from UserDefaults
    /// - Returns: Saved CurrencySettings or nil if not found
    func loadCurrencySettings() -> CurrencySettings? {
        guard let data = UserDefaults.standard.data(forKey: settingsKey) else {
            return nil
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(CurrencySettings.self, from: data)
    }

    // MARK: - ConversionRecord Persistence

    /// Add a conversion record to history
    /// Automatically prunes oldest records if count exceeds 50
    /// - Parameter record: ConversionRecord to add
    /// - Throws: File I/O or encoding errors
    func addConversionRecord(_ record: ConversionRecord) throws {
        lock.lock()
        defer { lock.unlock() }
        
        // Load history without sorting (raw from file)
        var history = loadConversionHistoryRaw()

        // Add new record
        history.append(record)

        // Sort by timestamp (most recent first)
        history.sort { $0.timestamp > $1.timestamp }

        // Prune if over limit (keep only the first 50 after sorting)
        if history.count > maxHistoryCount {
            history = Array(history.prefix(maxHistoryCount))
        }

        // Save to file
        try saveHistoryToFileUnsafe(history)
    }
    
    /// Load raw history without sorting (for internal use)
    private func loadConversionHistoryRaw() -> [ConversionRecord] {
        do {
            guard let url = historyFileURL else { return [] }
            guard FileManager.default.fileExists(atPath: url.path) else { return [] }

            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            return try decoder.decode([ConversionRecord].self, from: data)
        } catch {
            debugPrint("Error loading conversion history: \(error)")
            return []
        }
    }

    /// Load conversion history from file
    /// Returns records sorted by timestamp (most recent first)
    /// - Returns: Array of ConversionRecords, or empty array if file doesn't exist
    func loadConversionHistory() -> [ConversionRecord] {
        lock.lock()
        defer { lock.unlock() }
        return loadConversionHistoryUnsafe()
    }
    
    /// Internal method to load history without locking (for use within locked sections)
    private func loadConversionHistoryUnsafe() -> [ConversionRecord] {
        do {
            guard let url = historyFileURL else { return [] }
            guard FileManager.default.fileExists(atPath: url.path) else { return [] }

            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let records = try decoder.decode([ConversionRecord].self, from: data)
            // Return sorted by timestamp (most recent first)
            return records.sorted { $0.timestamp > $1.timestamp }
        } catch {
            debugPrint("Error loading conversion history: \(error)")
            return []
        }
    }

    /// Clear all conversion history
    /// - Throws: File I/O errors
    func clearHistory() throws {
        guard let url = historyFileURL else { return }
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }

    // MARK: - Private Helpers

    /// Get the URL for the conversion history JSON file
    private var historyFileURL: URL? {
        guard let documentsPath = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true
        ).first else {
            return nil
        }
        let documentsURL = URL(fileURLWithPath: documentsPath)
        return documentsURL.appendingPathComponent(historyFileName)
    }

    /// Save conversion history array to file
    private func saveHistoryToFile(_ records: [ConversionRecord]) throws {
        lock.lock()
        defer { lock.unlock() }
        try saveHistoryToFileUnsafe(records)
    }
    
    /// Internal method to save history without locking (for use within locked sections)
    private func saveHistoryToFileUnsafe(_ records: [ConversionRecord]) throws {
        guard let url = historyFileURL else {
            throw StorageError.invalidURL
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let data = try encoder.encode(records)
        try data.write(to: url, options: .atomic)
    }

    // MARK: - Error Types

    enum StorageError: Error {
        case invalidURL
        case encodingFailed
        case decodingFailed
        case fileFailed
    }
}
