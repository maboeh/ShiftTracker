//
//  ShiftPatternServiceTests.swift
//  ShiftTrackerTests
//
//  Created by Matthias Böhnke on 07.03.26.
//

import XCTest
import SwiftData
@testable import ShiftTracker

@MainActor
final class ShiftPatternServiceTests: XCTestCase {

    var container: ModelContainer!
    var context: ModelContext!
    var service: ShiftPatternService!

    override func setUp() async throws {
        container = try TestContainer.create()
        context = container.mainContext
        service = ShiftPatternService(modelContext: context)
    }

    // MARK: - Pattern CRUD

    func testCreatePattern() throws {
        let entries: [PatternDayEntry] = [
            PatternDayEntry(shiftTypeName: "Frühschicht", startHour: 6, startMinute: 0, endHour: 14, endMinute: 0),
            PatternDayEntry(isFreeDay: true),
        ]

        let pattern = try service.createPattern(name: "Test", startDate: Date(), cycleEntries: entries)
        XCTAssertEqual(pattern.name, "Test")
        XCTAssertEqual(pattern.cycleLength, 2)
        XCTAssertTrue(pattern.isActive)
    }

    func testDeletePatternWithoutFuturePlanned() throws {
        let pattern = try service.createPattern(name: "Delete-Test", startDate: Date(), cycleEntries: [])
        try service.deletePattern(pattern, deleteFuturePlanned: false)

        let descriptor = FetchDescriptor<ShiftPattern>()
        let remaining = try context.fetch(descriptor)
        XCTAssertTrue(remaining.isEmpty)
    }

    // MARK: - Generation

    func testGeneratePlannedShifts() throws {
        let frueh = ShiftType(name: "Frühschicht", colorHex: "#007AFF")
        context.insert(frueh)
        try context.save()

        let entries: [PatternDayEntry] = [
            PatternDayEntry(shiftTypeName: "Frühschicht", startHour: 6, startMinute: 0, endHour: 14, endMinute: 0),
            PatternDayEntry(isFreeDay: true),
        ]

        let pattern = try service.createPattern(name: "FF", startDate: Date(), cycleEntries: entries)
        let generated = try service.generatePlannedShifts(for: pattern, weeks: 2)

        // 2 weeks = 14 days, cycle is 2 days (1 work + 1 free), so 7 work days
        XCTAssertEqual(generated.count, 7)
        XCTAssertNotNil(pattern.generatedUntil)

        // All generated shifts should have the shift type
        for planned in generated {
            XCTAssertEqual(planned.shiftType?.name, "Frühschicht")
            XCTAssertNotNil(planned.pattern)
        }
    }

    func testGenerateSkipsFreeDays() throws {
        let entries: [PatternDayEntry] = [
            PatternDayEntry(isFreeDay: true),
            PatternDayEntry(isFreeDay: true),
            PatternDayEntry(shiftTypeName: "Spät", startHour: 14, startMinute: 0, endHour: 22, endMinute: 0),
        ]

        let pattern = try service.createPattern(name: "Mostly Free", startDate: Date(), cycleEntries: entries)
        let generated = try service.generatePlannedShifts(for: pattern, weeks: 3)

        // 3 weeks = 21 days, cycle is 3 days (2 free + 1 work), so 7 work days
        XCTAssertEqual(generated.count, 7)
    }

    func testExtendPattern() throws {
        let entries: [PatternDayEntry] = [
            PatternDayEntry(shiftTypeName: "Nacht", startHour: 22, startMinute: 0, endHour: 6, endMinute: 0),
        ]

        let pattern = try service.createPattern(name: "Nacht", startDate: Date(), cycleEntries: entries)
        let first = try service.generatePlannedShifts(for: pattern, weeks: 1)
        XCTAssertEqual(first.count, 7)

        let extended = try service.extendPattern(pattern, additionalWeeks: 1)
        XCTAssertEqual(extended.count, 7)

        // Total should be 14
        let descriptor = FetchDescriptor<PlannedShift>()
        let all = try context.fetch(descriptor)
        XCTAssertEqual(all.count, 14)
    }

    func testNightShiftEndTimeAdjusted() throws {
        let entries: [PatternDayEntry] = [
            PatternDayEntry(shiftTypeName: "Nacht", startHour: 22, startMinute: 0, endHour: 6, endMinute: 0),
        ]

        let pattern = try service.createPattern(name: "Nacht", startDate: Date(), cycleEntries: entries)
        let generated = try service.generatePlannedShifts(for: pattern, weeks: 1)

        for planned in generated {
            // End time should be after start time (next day)
            XCTAssertTrue(planned.endTime > planned.startTime, "End time should be after start time for night shifts")
        }
    }

    func testClearFuturePlannedShifts() throws {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!

        let entries: [PatternDayEntry] = [
            PatternDayEntry(shiftTypeName: "Früh", startHour: 6, startMinute: 0, endHour: 14, endMinute: 0),
        ]

        let pattern = try service.createPattern(name: "Clear-Test", startDate: yesterday, cycleEntries: entries)
        _ = try service.generatePlannedShifts(for: pattern, weeks: 2)

        try service.clearFuturePlannedShifts(for: pattern)

        let remaining = (pattern.plannedShifts ?? []).filter { $0.plannedDate > Date() }
        // All future unlinked should be deleted
        XCTAssertEqual(remaining.count, 0)
    }

    func testResolveShiftType() throws {
        let frueh = ShiftType(name: "Frühschicht", colorHex: "#007AFF")
        context.insert(frueh)
        try context.save()

        let resolved = try service.resolveShiftType(named: "Frühschicht")
        XCTAssertNotNil(resolved)
        XCTAssertEqual(resolved?.name, "Frühschicht")

        let unknown = try service.resolveShiftType(named: "Unknown")
        XCTAssertNil(unknown)

        let nilName = try service.resolveShiftType(named: nil)
        XCTAssertNil(nilName)
    }

    func testEmptyCycleGeneratesNothing() throws {
        let pattern = try service.createPattern(name: "Empty", startDate: Date(), cycleEntries: [])
        let generated = try service.generatePlannedShifts(for: pattern, weeks: 2)
        XCTAssertTrue(generated.isEmpty)
    }
}
