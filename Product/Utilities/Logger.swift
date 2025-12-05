//
//  Logger.swift
//  CurrencyConverterCamera
//
//  Created by Claude on 2025-12-02.
//

import Foundation
import os.log

/// Simple logging utility for debug output
/// Uses Apple's os.log framework for performance
class AppLogger {
    // MARK: - Log Categories

    static let general = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "general")
    static let camera = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "camera")
    static let vision = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "vision")
    static let storage = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "storage")
    static let conversion = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "conversion")

    // MARK: - Log Levels

    enum LogLevel {
        case debug
        case info
        case warning
        case error

        var osLogType: OSLogType {
            switch self {
            case .debug:
                return .debug
            case .info:
                return .info
            case .warning:
                return .error
            case .error:
                return .fault
            }
        }

        var prefix: String {
            switch self {
            case .debug:
                return "🔍 DEBUG"
            case .info:
                return "ℹ️  INFO"
            case .warning:
                return "⚠️  WARN"
            case .error:
                return "❌ ERROR"
            }
        }
    }

    // MARK: - Logging Methods

    /// Log message to console and os.log
    static func log(
        _ message: String,
        level: LogLevel = .info,
        category: OSLog = AppLogger.general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let fileName = (file as NSString).lastPathComponent
        let prefix = level.prefix
        let formattedMessage = "[\(fileName):\(line) \(function)] \(prefix): \(message)"

        // Console output (debug builds)
        #if DEBUG
        debugPrint(formattedMessage)
        #endif

        // os.log output
        os_log("%{public}@", log: category, type: level.osLogType, formattedMessage)
    }

    /// Log debug message
    static func debug(
        _ message: String,
        category: OSLog = AppLogger.general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .debug, category: category, file: file, function: function, line: line)
    }

    /// Log info message
    static func info(
        _ message: String,
        category: OSLog = AppLogger.general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .info, category: category, file: file, function: function, line: line)
    }

    /// Log warning message
    static func warning(
        _ message: String,
        category: OSLog = AppLogger.general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: .warning, category: category, file: file, function: function, line: line)
    }

    /// Log error message
    static func error(
        _ message: String,
        error: Error? = nil,
        category: OSLog = AppLogger.general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let fullMessage = error.map { "\(message) - \($0)" } ?? message
        log(fullMessage, level: .error, category: category, file: file, function: function, line: line)
    }

    // MARK: - Performance Logging

    /// Start timing an operation
    /// Returns a closure to call when operation completes
    static func startTimer(name: String) -> () -> Void {
        let startTime = Date()
        return {
            let elapsed = Date().timeIntervalSince(startTime) * 1000 // Convert to ms
            AppLogger.debug("\(name) completed in \(String(format: "%.2f", elapsed))ms")
        }
    }
}

// MARK: - Convenience Functions

/// Global debug logging function
func debugLog(_ message: String, category: OSLog = AppLogger.general) {
    AppLogger.debug(message, category: category)
}

/// Global error logging function
func errorLog(_ message: String, error: Error? = nil, category: OSLog = AppLogger.general) {
    AppLogger.error(message, error: error, category: category)
}
