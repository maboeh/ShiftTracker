//
//  PDFExporterTests.swift
//  ShiftTrackerTests
//
//  Created by Matthias Böhnke on 17.02.26.
//

import XCTest
import SwiftData
@testable import ShiftTracker

final class PDFExporterTests: XCTestCase {

    @MainActor
    func testPDFExportSucceeds() throws {
        let container = try TestContainer.create()
        let context = container.mainContext

        let shift = MockShift.completed(durationHours: 8)
        context.insert(shift)
        try context.save()

        let options = ExportOptions(format: .pdf, fields: ExportField.defaultFields)
        let result = PDFExporter.export(shifts: [shift], options: options)

        switch result {
        case .success(let url):
            XCTAssertTrue(url.lastPathComponent.hasSuffix(".pdf"))
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
            try? FileManager.default.removeItem(at: url)
        case .failure(let error):
            XCTFail("PDF export should succeed: \(error)")
        }

        _ = container
    }

    @MainActor
    func testPDFExportProducesNonEmptyFile() throws {
        let container = try TestContainer.create()
        let context = container.mainContext

        let shift = MockShift.completed(durationHours: 8)
        context.insert(shift)
        try context.save()

        let options = ExportOptions(format: .pdf, fields: ExportField.defaultFields)
        let result = PDFExporter.export(shifts: [shift], options: options)

        if case .success(let url) = result {
            let data = try Data(contentsOf: url)
            XCTAssertGreaterThan(data.count, 0, "PDF file should not be empty")
            try? FileManager.default.removeItem(at: url)
        } else {
            XCTFail("Export should succeed")
        }

        _ = container
    }

    @MainActor
    func testPDFExportWithMultipleShifts() throws {
        let container = try TestContainer.create()
        let context = container.mainContext

        var shifts: [Shift] = []
        for i in 0..<5 {
            let shift = MockShift.completed(hoursAgo: Double(i * 10 + 8), durationHours: 8)
            context.insert(shift)
            shifts.append(shift)
        }
        try context.save()

        let options = ExportOptions(format: .pdf, fields: ExportField.defaultFields)
        let result = PDFExporter.export(shifts: shifts, options: options)

        if case .success(let url) = result {
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
            try? FileManager.default.removeItem(at: url)
        } else {
            XCTFail("Multi-shift PDF export should succeed")
        }

        _ = container
    }

    func testPDFExportErrorDescriptions() {
        let error1 = PDFExportError.pdfCreationFailed
        XCTAssertNotNil(error1.errorDescription)

        let error2 = PDFExportError.pageRenderFailed
        XCTAssertNotNil(error2.errorDescription)
    }
}
