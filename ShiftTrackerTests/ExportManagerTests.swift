//
//  ExportManagerTests.swift
//  ShiftTrackerTests
//
//  Created by Matthias Böhnke on 17.02.26.
//

import XCTest
import SwiftData
@testable import ShiftTracker

final class ExportManagerTests: XCTestCase {

    // MARK: - CSV Export

    @MainActor
    func testCSVExportSucceeds() async throws {
        let container = try TestContainer.create()
        let context = container.mainContext

        let shift = MockShift.completed(durationHours: 8)
        context.insert(shift)
        try context.save()

        let options = ExportOptions(format: .csv, fields: ExportField.defaultFields)
        let manager = ExportManager.shared

        let result = await manager.export(shifts: [shift], options: options)

        switch result {
        case .success(let url):
            XCTAssertTrue(url.lastPathComponent.hasSuffix(".csv"))
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
            try? FileManager.default.removeItem(at: url)
        case .failure(let error):
            XCTFail("Export should succeed: \(error)")
        }
    }

    // MARK: - Encrypted Export

    @MainActor
    func testEncryptedExportProducesEncFile() async throws {
        let container = try TestContainer.create()
        let context = container.mainContext

        let shift = MockShift.completed(durationHours: 8)
        context.insert(shift)
        try context.save()

        var options = ExportOptions(format: .csv, fields: ExportField.defaultFields)
        options.encryptionPassword = "testpassword123"

        let manager = ExportManager.shared
        let result = await manager.export(shifts: [shift], options: options)

        switch result {
        case .success(let url):
            XCTAssertTrue(url.lastPathComponent.hasSuffix(".enc"), "Encrypted export should have .enc extension")
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
            try? FileManager.default.removeItem(at: url)
        case .failure(let error):
            XCTFail("Encrypted export should succeed: \(error)")
        }
    }

    @MainActor
    func testEmptyPasswordSkipsEncryption() async throws {
        let container = try TestContainer.create()
        let context = container.mainContext

        let shift = MockShift.completed(durationHours: 8)
        context.insert(shift)
        try context.save()

        var options = ExportOptions(format: .csv, fields: ExportField.defaultFields)
        options.encryptionPassword = ""

        let manager = ExportManager.shared
        let result = await manager.export(shifts: [shift], options: options)

        switch result {
        case .success(let url):
            XCTAssertFalse(url.lastPathComponent.hasSuffix(".enc"), "Empty password should not encrypt")
            try? FileManager.default.removeItem(at: url)
        case .failure(let error):
            XCTFail("Export should succeed: \(error)")
        }
    }

    // MARK: - Export Record

    @MainActor
    func testExportRecordCreatedOnSuccess() async throws {
        let container = try TestContainer.create()
        let context = container.mainContext

        let shift = MockShift.completed(durationHours: 8)
        context.insert(shift)
        try context.save()

        let options = ExportOptions(format: .csv, fields: ExportField.defaultFields)
        let manager = ExportManager.shared

        let result = await manager.export(shifts: [shift], options: options, modelContext: context)

        if case .success(let url) = result {
            let records = try context.fetch(FetchDescriptor<ExportRecord>())
            XCTAssertFalse(records.isEmpty, "Export record should be created")
            XCTAssertEqual(records.last?.format, "CSV")
            XCTAssertEqual(records.last?.shiftCount, 1)
            try? FileManager.default.removeItem(at: url)
        } else {
            XCTFail("Export should succeed")
        }
    }

    // MARK: - State Management

    @MainActor
    func testIsExportingFalseAfterExport() async throws {
        let container = try TestContainer.create()
        let context = container.mainContext

        let shift = MockShift.completed(durationHours: 8)
        context.insert(shift)
        try context.save()

        let options = ExportOptions(format: .csv, fields: ExportField.defaultFields)
        let manager = ExportManager.shared

        let result = await manager.export(shifts: [shift], options: options)
        XCTAssertFalse(manager.isExporting)

        if case .success(let url) = result {
            try? FileManager.default.removeItem(at: url)
        }
    }
}
