//
//  StorageServiceTests.swift
//  CurrencyConverterCameraTests
//
//  Created by Claude on 2025-12-02.
//

import XCTest
@testable import CurrencyConverterCamera

final class StorageServiceTests: XCTestCase {

    var storageService: StorageService!

    override func setUp() {
        super.setUp()
        storageService = StorageService()
        // Clean up before each test
        try? TestHelper.cleanup()
    }

    override func tearDown() {
        super.tearDown()
        // Clean up after each test
        try? TestHelper.cleanup()
    }

    // MARK: - CurrencySettings Tests

    func testSaveAndLoadCurrencySettings() throws {
        let settings = TestHelper.createValidSettings(currency: "USD", rate: 31.35)

        try storageService.saveCurrencySettings(settings)
        let loaded =   storageService.loadCurrencySettings()

        XCTAssertEqual(loaded!.currencyName, "USD")
        XCTAssertEqual(loaded!.exchangeRate, 31.35)
    }

    func testSaveCurrencySettingsWithValidation() throws {
        let settings = TestHelper.createValidSettings(currency: "EUR", rate: 35.50)

        try storageService.saveCurrencySettings(settings)
        let loaded = try storageService.loadCurrencySettings()

        XCTAssertTrue(loaded!.isValid)
    }

    func testLoadCurrencySettingsWhenNeverSaved() throws {
        // Should not throw, might return nil or default
        let result = try storageService.loadCurrencySettings()
        XCTAssertNil(result)
    }

    func testOverwriteExistingCurrencySettings() throws {
        let settings1 = TestHelper.createValidSettings(currency: "JPY", rate: 0.22)
        try storageService.saveCurrencySettings(settings1)

        let settings2 = TestHelper.createValidSettings(currency: "GBP", rate: 45.20)
        try storageService.saveCurrencySettings(settings2)

        let loaded = try storageService.loadCurrencySettings()
        XCTAssertEqual(loaded?.currencyName, "GBP")
        XCTAssertEqual(loaded?.exchangeRate, 45.20)
    }

    func testSaveCurrencySettingsUpdatesTimestamp() throws {
        let before = Date()
        Thread.sleep(forTimeInterval: 0.01)  // Small delay to ensure timestamp difference
        let settings = TestHelper.createValidSettings(currency: "AUD", rate: 20.50)
        try storageService.saveCurrencySettings(settings)
        let after = Date()

        let loaded = try storageService.loadCurrencySettings()
        XCTAssertNotNil(loaded?.lastUpdated)
        
        // Allow 1 second tolerance for timestamp comparison
        let tolerance: TimeInterval = 1.0
        XCTAssertTrue(loaded!.lastUpdated.timeIntervalSince(before) >= -tolerance, 
                      "Timestamp should be after 'before'")
        XCTAssertTrue(loaded!.lastUpdated.timeIntervalSince(after) <= tolerance,
                      "Timestamp should be before 'after'")
    }

    // MARK: - ConversionRecord Tests

    func testAddSingleConversionRecord() throws {
        let record = TestHelper.createConversionRecord(original: 3500, converted: 770.00)

        try storageService.addConversionRecord(record)
        let history = try storageService.loadConversionHistory()

        XCTAssertEqual(history.count, 1)
        XCTAssertEqual(history[0].originalPrice, 3500)
    }

    func testAddMultipleConversionRecords() throws {
        let records = TestHelper.createConversionRecords(count: 5, spacing: 60)

        for record in records {
            try storageService.addConversionRecord(record)
        }

        let history = try storageService.loadConversionHistory()
        XCTAssertEqual(history.count, 5)
    }

    func testConversionHistorySortedByTimestampDescending() throws {
        let now = Date()
        let record1 = TestHelper.createConversionRecord(original: 1000, timestamp: now.addingTimeInterval(-120))
        let record2 = TestHelper.createConversionRecord(original: 2000, timestamp: now)
        let record3 = TestHelper.createConversionRecord(original: 3000, timestamp: now.addingTimeInterval(-60))

        try storageService.addConversionRecord(record1)
        try storageService.addConversionRecord(record2)
        try storageService.addConversionRecord(record3)

        let history = try storageService.loadConversionHistory()

        XCTAssertEqual(history[0].originalPrice, 2000)  // Most recent
        XCTAssertEqual(history[1].originalPrice, 3000)  // Middle
        XCTAssertEqual(history[2].originalPrice, 1000)  // Oldest
    }

    func testHistoryRetentionPolicy() throws {
        // Add more than max records (50)
        for i in 0..<55 {
            let record = TestHelper.createConversionRecord(
                original: Decimal(i),
                timestamp: Date().addingTimeInterval(-Double(i) * 60)
            )
            try storageService.addConversionRecord(record)
        }

        let history = try storageService.loadConversionHistory()

        // Should keep only 50 most recent
        XCTAssertEqual(history.count, 50, "Should keep exactly 50 records")
        
        // Most recent should be i=0 (now - 0 minutes)
        XCTAssertEqual(history.first?.originalPrice, Decimal(0), "Newest record should be i=0")
        
        // Oldest kept should be i=49 (the 50th most recent)
        XCTAssertEqual(history.last?.originalPrice, Decimal(49), "Oldest kept record should be i=49")
    }

    func testHistoryEmptyWhenCleared() throws {
        let records = TestHelper.createConversionRecords(count: 5)
        for record in records {
            try storageService.addConversionRecord(record)
        }

        try storageService.clearHistory()
        let history = try storageService.loadConversionHistory()

        XCTAssertEqual(history.count, 0)
    }

    func testLoadHistoryWhenEmpty() throws {
        let history = try storageService.loadConversionHistory()
        XCTAssertEqual(history.count, 0)
    }

    // MARK: - Different Currencies

    func testHistoryWithDifferentCurrencies() throws {
        let now = Date()
        let record1 = TestHelper.createConversionRecord(
            converted: 770.00, 
            currency: "JPY",
            timestamp: now.addingTimeInterval(-120)  // 2 minutes ago
        )
        let record2 = TestHelper.createConversionRecord(
            converted: 35.00, 
            currency: "USD",
            timestamp: now.addingTimeInterval(-60)   // 1 minute ago
        )
        let record3 = TestHelper.createConversionRecord(
            converted: 32.50, 
            currency: "EUR",
            timestamp: now                           // now (most recent)
        )

        try storageService.addConversionRecord(record1)
        try storageService.addConversionRecord(record2)
        try storageService.addConversionRecord(record3)

        let history = try storageService.loadConversionHistory()

        XCTAssertEqual(history.count, 3, "Should have 3 records")
        XCTAssertEqual(history[0].currencyName, "EUR", "Most recent should be EUR")
        XCTAssertEqual(history[1].currencyName, "USD", "Middle should be USD")
        XCTAssertEqual(history[2].currencyName, "JPY", "Oldest should be JPY")
    }

    // MARK: - Data Integrity Tests

    func testRecordDataPreservedAfterPersistence() throws {
        let originalRecord = TestHelper.createConversionRecord(
            original: 12345,
            converted: 2718.50,
            currency: "SGD",
            rate: 0.22
        )

        try storageService.addConversionRecord(originalRecord)
        let history = try storageService.loadConversionHistory()
        let loadedRecord = history[0]

        XCTAssertEqual(loadedRecord.originalPrice, originalRecord.originalPrice)
        XCTAssertEqual(loadedRecord.convertedAmount, originalRecord.convertedAmount)
        XCTAssertEqual(loadedRecord.currencyName, originalRecord.currencyName)
        XCTAssertEqual(loadedRecord.exchangeRate, originalRecord.exchangeRate)
    }

    func testRecordIDsAreUnique() throws {
        let record1 = TestHelper.createConversionRecord()
        let record2 = TestHelper.createConversionRecord()

        try storageService.addConversionRecord(record1)
        try storageService.addConversionRecord(record2)

        let history = try storageService.loadConversionHistory()

        XCTAssertNotEqual(history[0].id, history[1].id)
    }

    func testTimestampPreservation() throws {
        let specificTime = Date(timeIntervalSince1970: 1700000000)
        let record = TestHelper.createConversionRecord(timestamp: specificTime)

        try storageService.addConversionRecord(record)
        let history = try storageService.loadConversionHistory()

        // Allow small time difference due to encoding/decoding
        let timeDifference = abs(history[0].timestamp.timeIntervalSince(specificTime))
        XCTAssertLessThan(timeDifference, 1.0)
    }

    // MARK: - Edge Cases

    func testAddRecordWithMinimalValues() throws {
        let record = TestHelper.createConversionRecord(
            original: Decimal(0.01),
            converted: Decimal(0.002),
            rate: Decimal(0.0001)
        )

        try storageService.addConversionRecord(record)
        let history = try storageService.loadConversionHistory()

        XCTAssertEqual(history[0].originalPrice, Decimal(0.01))
    }

    func testAddRecordWithLargeValues() throws {
        let record = TestHelper.createConversionRecord(
            original: Decimal(999999.99),
            converted: Decimal(99999.99),
            rate: Decimal(10000)
        )

        try storageService.addConversionRecord(record)
        let history = try storageService.loadConversionHistory()

        XCTAssertEqual(history[0].originalPrice, Decimal(999999.99))
    }

    func testCurrencySettingsWithMaxLengthName() throws {
        let longName = String(repeating: "A", count: 20)
        let settings = CurrencySettings(currencyName: longName, exchangeRate: 0.22)

        try storageService.saveCurrencySettings(settings)
        let loaded = try storageService.loadCurrencySettings()

        XCTAssertEqual(loaded?.currencyName, longName)
    }

    // MARK: - Concurrent Access

    func testConcurrentRecordAddition() throws {
        let dispatchGroup = DispatchGroup()

        for i in 0..<10 {
            dispatchGroup.enter()
            DispatchQueue.global().async {
                let record = TestHelper.createConversionRecord(original: Decimal(i * 100))
                try? self.storageService.addConversionRecord(record)
                dispatchGroup.leave()
            }
        }

        dispatchGroup.wait()

        let history = try storageService.loadConversionHistory()
        XCTAssertEqual(history.count, 10)
    }

    // MARK: - Cleanup Tests

    func testCleanupRemovesHistoryFile() throws {
        let record = TestHelper.createConversionRecord()
        try storageService.addConversionRecord(record)

        var historyBefore = try storageService.loadConversionHistory()
        XCTAssertEqual(historyBefore.count, 1)

        try storageService.clearHistory()

        let historyAfter = try storageService.loadConversionHistory()
        XCTAssertEqual(historyAfter.count, 0)
    }

}
