//
//  ExportOptionsTests.swift
//  ShiftTrackerTests
//
//  Created by Matthias Böhnke on 16.02.26.
//

import XCTest
@testable import ShiftTracker

final class ExportOptionsTests: XCTestCase {
    
    // MARK: - Export Field Tests
    
    func testDefaultFieldsCount() {
        let defaultFields = ExportField.defaultFields
        
        XCTAssertEqual(defaultFields.count, 6, "Default fields should have 6 items (including breakTime)")
    }
    
    func testAllFieldsCount() {
        let allFields = ExportField.allCases
        
        XCTAssertEqual(allFields.count, 6, "Total fields should be 6")
    }
    
    func testFieldRawValues() {
        XCTAssertEqual(ExportField.date.rawValue, "Datum")
        XCTAssertEqual(ExportField.startTime.rawValue, "Start")
        XCTAssertEqual(ExportField.endTime.rawValue, "Ende")
        XCTAssertEqual(ExportField.duration.rawValue, "Dauer")
        XCTAssertEqual(ExportField.shiftType.rawValue, "Schichttyp")
        XCTAssertEqual(ExportField.breakTime.rawValue, "Pausen")
    }
    
    // MARK: - Export Format Tests
    
    func testExportFormats() {
        let formats = ExportFormat.allCases
        
        XCTAssertEqual(formats.count, 2, "Should have 2 export formats")
        XCTAssertEqual(ExportFormat.csv.rawValue, "CSV")
        XCTAssertEqual(ExportFormat.pdf.rawValue, "PDF")
    }
    
    // MARK: - Date Range Preset Tests
    
    func testDateRangePresets() {
        let presets = DateRangePreset.allCases
        
        XCTAssertEqual(presets.count, 5, "Should have 5 date range presets")
    }
    
    func testDateRangePresetRawValues() {
        XCTAssertEqual(DateRangePreset.thisWeek.rawValue, "Diese Woche")
        XCTAssertEqual(DateRangePreset.thisMonth.rawValue, "Dieser Monat")
        XCTAssertEqual(DateRangePreset.lastMonth.rawValue, "Letzter Monat")
        XCTAssertEqual(DateRangePreset.thisYear.rawValue, "Dieses Jahr")
        XCTAssertEqual(DateRangePreset.custom.rawValue, "Benutzerdefiniert")
    }
    
    // MARK: - Export Options Tests
    
    func testDefaultExportOptions() {
        let options = ExportOptions()
        
        XCTAssertEqual(options.format, .csv, "Default format should be CSV")
        XCTAssertEqual(options.dateRangePreset, .thisWeek, "Default date range should be this week")
        XCTAssertTrue(options.includeHeaders, "Default should include headers")
    }
    
    func testCustomExportOptions() {
        let options = ExportOptions(
            format: .pdf,
            dateRangePreset: .thisMonth,
            fields: [.date, .startTime],
            includeHeaders: false
        )
        
        XCTAssertEqual(options.format, .pdf)
        XCTAssertEqual(options.dateRangePreset, .thisMonth)
        XCTAssertEqual(options.fields.count, 2)
        XCTAssertFalse(options.includeHeaders)
    }
}
