//
//  CSVExporterTests.swift
//  ShiftTrackerTests
//
//  Created by Matthias Böhnke on 16.02.26.
//

import XCTest
@testable import ShiftTracker

final class CSVExporterTests: XCTestCase {

    /// Strips the UTF-8 BOM character from the beginning of a string
    private func stripBOM(_ string: String) -> String {
        var s = string
        if s.hasPrefix("\u{FEFF}") {
            s.removeFirst()
        }
        return s
    }

    private func makeShift(hoursAgo start: Int, duration hours: Double, typeName: String? = nil) -> Shift {
        let startTime = Date().addingTimeInterval(-Double(start) * 3600)
        let endTime = startTime.addingTimeInterval(hours * 3600)
        var shiftType: ShiftType? = nil
        if let name = typeName {
            shiftType = ShiftType(name: name, colorHex: "#007AFF")
        }
        return Shift(startTime: startTime, endTime: endTime, shiftType: shiftType)
    }

    func testCSVGenerationWithHeaders() throws {
        let shifts = [makeShift(hoursAgo: 24, duration: 8)]
        let options = ExportOptions(
            format: .csv,
            fields: [.date, .startTime, .endTime, .duration],
            includeHeaders: true
        )

        let result = CSVExporter.export(shifts: shifts, options: options)
        let url = try result.get()
        let content = try String(contentsOf: url, encoding: .utf8)

        // Should contain header row
        XCTAssertTrue(content.contains("Datum;Start;Ende;Dauer"))
        // Should contain at least one data row (2 lines minimum: header + data)
        let lines = content.components(separatedBy: "\r\n").filter { !$0.isEmpty }
        XCTAssertEqual(lines.count, 2) // header + 1 data row
    }

    func testCSVGenerationWithoutHeaders() throws {
        let shifts = [makeShift(hoursAgo: 24, duration: 8)]
        let options = ExportOptions(
            format: .csv,
            fields: [.date, .startTime],
            includeHeaders: false
        )

        let result = CSVExporter.export(shifts: shifts, options: options)
        let url = try result.get()
        let content = try String(contentsOf: url, encoding: .utf8)

        // Should NOT contain header
        XCTAssertFalse(content.contains("Datum;Start"))
        // But should have data
        let lines = content.components(separatedBy: "\r\n").filter { !$0.isEmpty }
        XCTAssertEqual(lines.count, 1)
    }

    func testCSVSemicolonSeparator() throws {
        let shifts = [makeShift(hoursAgo: 24, duration: 8)]
        let options = ExportOptions(
            format: .csv,
            fields: [.date, .startTime, .endTime],
            includeHeaders: true
        )

        let result = CSVExporter.export(shifts: shifts, options: options)
        let url = try result.get()
        let content = try String(contentsOf: url, encoding: .utf8)

        // Each line should have semicolons as separators
        let lines = content.components(separatedBy: "\r\n").filter { !$0.isEmpty }
        for line in lines {
            let fieldCount = line.components(separatedBy: ";").count
            XCTAssertEqual(fieldCount, 3, "Expected 3 fields separated by semicolons")
        }
    }

    func testCSVSpecialCharacterEscaping() {
        // Semicolons in field should be escaped with quotes
        let escaped = CSVExporter.escapeCSVField("Nacht;Schicht")
        XCTAssertEqual(escaped, "\"Nacht;Schicht\"")

        // Quotes should be doubled
        let escapedQuotes = CSVExporter.escapeCSVField("Test\"Value")
        XCTAssertEqual(escapedQuotes, "\"Test\"\"Value\"")

        // Normal values unchanged
        let normal = CSVExporter.escapeCSVField("Normal")
        XCTAssertEqual(normal, "Normal")
    }

    func testCSVEmptyShiftList() {
        let options = ExportOptions(format: .csv, fields: [.date])

        let result = CSVExporter.export(shifts: [], options: options)

        switch result {
        case .success:
            XCTFail("Expected failure with empty shifts")
        case .failure:
            break // Expected
        }
    }

    func testCSVUTF8BOM() throws {
        let shifts = [makeShift(hoursAgo: 24, duration: 8)]
        let options = ExportOptions(format: .csv, fields: [.date])

        let result = CSVExporter.export(shifts: shifts, options: options)
        let url = try result.get()
        let data = try Data(contentsOf: url)

        // UTF-8 BOM is EF BB BF
        XCTAssertTrue(data.count >= 3)
        XCTAssertEqual(data[0], 0xEF)
        XCTAssertEqual(data[1], 0xBB)
        XCTAssertEqual(data[2], 0xBF)
    }

    func testCSVActiveShiftNoEndTime() throws {
        let activeShift = Shift(startTime: Date().addingTimeInterval(-3600), endTime: nil)
        let options = ExportOptions(format: .csv, fields: [.endTime], includeHeaders: false)

        let result = CSVExporter.export(shifts: [activeShift], options: options)
        let url = try result.get()
        let content = stripBOM(try String(contentsOf: url, encoding: .utf8))

        // Ende column should be empty for active shift - content is just \r\n (empty data row)
        XCTAssertEqual(content, "\r\n")
    }

    func testCSVDurationFormat() throws {
        let shifts = [makeShift(hoursAgo: 24, duration: 8.5)]
        let options = ExportOptions(format: .csv, fields: [.duration], includeHeaders: false)

        let result = CSVExporter.export(shifts: shifts, options: options)
        let url = try result.get()
        let content = stripBOM(try String(contentsOf: url, encoding: .utf8))

        let lines = content.components(separatedBy: "\r\n").filter { !$0.isEmpty }
        XCTAssertEqual(lines.first, "8.50")
    }

    func testCSVShiftTypeIncluded() throws {
        let shifts = [makeShift(hoursAgo: 24, duration: 8, typeName: "Frühschicht")]
        let options = ExportOptions(format: .csv, fields: [.shiftType], includeHeaders: false)

        let result = CSVExporter.export(shifts: shifts, options: options)
        let url = try result.get()
        let content = stripBOM(try String(contentsOf: url, encoding: .utf8))

        let lines = content.components(separatedBy: "\r\n").filter { !$0.isEmpty }
        XCTAssertEqual(lines.first, "Frühschicht")
    }

    func testCSVBreakTimeFieldEmpty() throws {
        let shifts = [makeShift(hoursAgo: 24, duration: 8)]
        let options = ExportOptions(format: .csv, fields: [.breakTime], includeHeaders: false)

        let result = CSVExporter.export(shifts: shifts, options: options)
        let url = try result.get()
        let content = stripBOM(try String(contentsOf: url, encoding: .utf8))

        // Shift without breaks should produce empty breakTime field → just "\r\n"
        XCTAssertEqual(content, "\r\n")
    }

    @MainActor
    func testCSVBreakTimeWithBreaks() throws {
        let container = try TestContainer.create()
        let context = container.mainContext

        let start = Date().addingTimeInterval(-10 * 3600)
        let end = start.addingTimeInterval(8 * 3600)
        let shift = Shift(startTime: start, endTime: end)
        context.insert(shift)

        // 30 minute break
        let breakStart = start.addingTimeInterval(4 * 3600)
        let breakEnd = breakStart.addingTimeInterval(30 * 60)
        let brk = Break(startTime: breakStart, endTime: breakEnd)
        brk.shift = shift
        context.insert(brk)
        try context.save()

        let options = ExportOptions(format: .csv, fields: [.breakTime], includeHeaders: false)
        let result = CSVExporter.export(shifts: [shift], options: options)
        let url = try result.get()
        let content = stripBOM(try String(contentsOf: url, encoding: .utf8))

        let lines = content.components(separatedBy: "\r\n").filter { !$0.isEmpty }
        XCTAssertEqual(lines.first, "30")
    }

    @MainActor
    func testCSVNetDurationWithBreaks() throws {
        let container = try TestContainer.create()
        let context = container.mainContext

        let start = Date().addingTimeInterval(-10 * 3600)
        let end = start.addingTimeInterval(8 * 3600) // 8h brutto
        let shift = Shift(startTime: start, endTime: end)
        context.insert(shift)

        // 1 hour break → 7h netto
        let breakStart = start.addingTimeInterval(4 * 3600)
        let breakEnd = breakStart.addingTimeInterval(1 * 3600)
        let brk = Break(startTime: breakStart, endTime: breakEnd)
        brk.shift = shift
        context.insert(brk)
        try context.save()

        let options = ExportOptions(format: .csv, fields: [.duration], includeHeaders: false)
        let result = CSVExporter.export(shifts: [shift], options: options)
        let url = try result.get()
        let content = stripBOM(try String(contentsOf: url, encoding: .utf8))

        let lines = content.components(separatedBy: "\r\n").filter { !$0.isEmpty }
        XCTAssertEqual(lines.first, "7.00") // 8h - 1h break = 7h net
    }

    func testCSVDefaultFieldsIncludeBreakTime() {
        let defaultFields = ExportField.defaultFields
        XCTAssertTrue(defaultFields.contains(.breakTime), "Default fields should include breakTime")
    }
}
