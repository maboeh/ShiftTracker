//
//  ShiftPatternTests.swift
//  ShiftTrackerTests
//
//  Created by Matthias Böhnke on 07.03.26.
//

import XCTest
import SwiftData
@testable import ShiftTracker

@MainActor
final class ShiftPatternTests: XCTestCase {

    var container: ModelContainer!
    var context: ModelContext!

    override func setUp() async throws {
        container = try TestContainer.create()
        context = container.mainContext
    }

    func testPatternDayEntryCreation() {
        let entry = PatternDayEntry(shiftTypeName: "Frühschicht", shiftTypeColorHex: "#007AFF",
                                     startHour: 6, startMinute: 0, endHour: 14, endMinute: 0)
        XCTAssertFalse(entry.isFreeDay)
        XCTAssertEqual(entry.shiftTypeName, "Frühschicht")
        XCTAssertEqual(entry.formattedTimeRange, "06:00 - 14:00")
    }

    func testFreeDayEntry() {
        let entry = PatternDayEntry(isFreeDay: true)
        XCTAssertTrue(entry.isFreeDay)
        XCTAssertEqual(entry.formattedTimeRange, "Frei")
    }

    func testPatternCreation() throws {
        let entries: [PatternDayEntry] = [
            PatternDayEntry(shiftTypeName: "Frühschicht", startHour: 6, startMinute: 0, endHour: 14, endMinute: 0),
            PatternDayEntry(shiftTypeName: "Frühschicht", startHour: 6, startMinute: 0, endHour: 14, endMinute: 0),
            PatternDayEntry(isFreeDay: true),
        ]

        let pattern = ShiftPattern(name: "Test-Muster", startDate: Date(), cycleEntries: entries)
        context.insert(pattern)
        try context.save()

        let descriptor = FetchDescriptor<ShiftPattern>()
        let fetched = try context.fetch(descriptor)
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.name, "Test-Muster")
    }

    func testCycleDataJsonRoundTrip() {
        let entries: [PatternDayEntry] = [
            PatternDayEntry(shiftTypeName: "Frühschicht", shiftTypeColorHex: "#007AFF",
                            startHour: 6, startMinute: 0, endHour: 14, endMinute: 0),
            PatternDayEntry(isFreeDay: true),
            PatternDayEntry(shiftTypeName: "Spätschicht", shiftTypeColorHex: "#FF9500",
                            startHour: 14, startMinute: 0, endHour: 22, endMinute: 0),
        ]

        let pattern = ShiftPattern(name: "Zyklus", startDate: Date(), cycleEntries: entries)

        let decoded = pattern.cycleEntries
        XCTAssertEqual(decoded.count, 3)
        XCTAssertEqual(decoded[0].shiftTypeName, "Frühschicht")
        XCTAssertTrue(decoded[1].isFreeDay)
        XCTAssertEqual(decoded[2].shiftTypeName, "Spätschicht")
        XCTAssertEqual(decoded[2].startHour, 14)
    }

    func testCycleLength() {
        let entries: [PatternDayEntry] = [
            PatternDayEntry(shiftTypeName: "Früh", startHour: 6, startMinute: 0, endHour: 14, endMinute: 0),
            PatternDayEntry(shiftTypeName: "Früh", startHour: 6, startMinute: 0, endHour: 14, endMinute: 0),
            PatternDayEntry(shiftTypeName: "Spät", startHour: 14, startMinute: 0, endHour: 22, endMinute: 0),
            PatternDayEntry(shiftTypeName: "Spät", startHour: 14, startMinute: 0, endHour: 22, endMinute: 0),
            PatternDayEntry(shiftTypeName: "Nacht", startHour: 22, startMinute: 0, endHour: 6, endMinute: 0),
            PatternDayEntry(shiftTypeName: "Nacht", startHour: 22, startMinute: 0, endHour: 6, endMinute: 0),
            PatternDayEntry(isFreeDay: true),
            PatternDayEntry(isFreeDay: true),
        ]

        let pattern = ShiftPattern(name: "8er Zyklus", startDate: Date(), cycleEntries: entries)
        XCTAssertEqual(pattern.cycleLength, 8)
    }

    func testCycleEntriesSetter() {
        let pattern = ShiftPattern(name: "Leer", startDate: Date(), cycleEntries: [])
        XCTAssertEqual(pattern.cycleLength, 0)

        pattern.cycleEntries = [
            PatternDayEntry(shiftTypeName: "Früh", startHour: 6, startMinute: 0, endHour: 14, endMinute: 0),
        ]
        XCTAssertEqual(pattern.cycleLength, 1)
        XCTAssertEqual(pattern.cycleEntries.first?.shiftTypeName, "Früh")
    }

    func testStartDateNormalization() {
        let calendar = Calendar.current
        let afternoon = calendar.date(bySettingHour: 15, minute: 30, second: 0, of: Date())!

        let pattern = ShiftPattern(name: "Test", startDate: afternoon, cycleEntries: [])
        XCTAssertEqual(pattern.startDate, calendar.startOfDay(for: afternoon))
    }

    func testPatternPlannedShiftRelationship() throws {
        let pattern = ShiftPattern(name: "Muster", startDate: Date(), cycleEntries: [])
        context.insert(pattern)

        let planned = PlannedShift(plannedDate: Date(), startTime: Date(), endTime: Date().addingTimeInterval(3600))
        planned.pattern = pattern
        context.insert(planned)
        try context.save()

        XCTAssertTrue(pattern.plannedShifts?.contains(where: { $0.persistentModelID == planned.persistentModelID }) ?? false)
    }
}
