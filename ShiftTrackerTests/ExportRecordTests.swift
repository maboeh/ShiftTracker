//
//  ExportRecordTests.swift
//  ShiftTrackerTests
//
//  Created by Matthias Böhnke on 17.02.26.
//

import XCTest
import SwiftData
@testable import ShiftTracker

final class ExportRecordTests: XCTestCase {

    func testDefaultDate() {
        let record = ExportRecord(format: "CSV", shiftCount: 5, dateRangeDescription: "Diese Woche")
        XCTAssertEqual(record.format, "CSV")
        XCTAssertEqual(record.shiftCount, 5)
        XCTAssertEqual(record.dateRangeDescription, "Diese Woche")
    }

    @MainActor
    func testExportRecordPersistence() throws {
        let container = try TestContainer.create()
        let context = container.mainContext

        let record = ExportRecord(format: "PDF", shiftCount: 12, dateRangeDescription: "Dieser Monat")
        context.insert(record)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<ExportRecord>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.format, "PDF")
        XCTAssertEqual(fetched.first?.shiftCount, 12)
    }

    @MainActor
    func testMultipleExportRecords() throws {
        let container = try TestContainer.create()
        let context = container.mainContext

        for i in 1...5 {
            let record = ExportRecord(format: i % 2 == 0 ? "PDF" : "CSV", shiftCount: i * 3, dateRangeDescription: "Export \(i)")
            context.insert(record)
        }
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<ExportRecord>())
        XCTAssertEqual(fetched.count, 5)
    }
}
