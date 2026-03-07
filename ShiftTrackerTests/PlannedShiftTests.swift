//
//  PlannedShiftTests.swift
//  ShiftTrackerTests
//
//  Created by Matthias Böhnke on 07.03.26.
//

import XCTest
import SwiftData
@testable import ShiftTracker

@MainActor
final class PlannedShiftTests: XCTestCase {

    var container: ModelContainer!
    var context: ModelContext!

    override func setUp() async throws {
        container = try TestContainer.create()
        context = container.mainContext
    }

    func testPlannedShiftCreation() throws {
        let date = Date()
        let start = date
        let end = date.addingTimeInterval(8 * 3600)

        let planned = PlannedShift(plannedDate: date, startTime: start, endTime: end)
        context.insert(planned)
        try context.save()

        let descriptor = FetchDescriptor<PlannedShift>()
        let fetched = try context.fetch(descriptor)
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.plannedDate, Calendar.current.startOfDay(for: date))
    }

    func testPlannedDateNormalization() {
        let calendar = Calendar.current
        let afternoon = calendar.date(bySettingHour: 15, minute: 30, second: 0, of: Date())!

        let planned = PlannedShift(plannedDate: afternoon, startTime: afternoon, endTime: afternoon.addingTimeInterval(3600))
        XCTAssertEqual(planned.plannedDate, calendar.startOfDay(for: afternoon))
    }

    func testDuration() {
        let start = Date()
        let end = start.addingTimeInterval(8 * 3600)

        let planned = PlannedShift(plannedDate: start, startTime: start, endTime: end)
        XCTAssertEqual(planned.duration, 8 * 3600, accuracy: 1)
    }

    func testFormattedTimeRange() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let start = calendar.date(bySettingHour: 6, minute: 0, second: 0, of: today)!
        let end = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: today)!

        let planned = PlannedShift(plannedDate: today, startTime: start, endTime: end)
        XCTAssertEqual(planned.formattedTimeRange, "06:00 - 14:00")
    }

    func testIsLinkedDefaultFalse() {
        let planned = PlannedShift(plannedDate: Date(), startTime: Date(), endTime: Date().addingTimeInterval(3600))
        XCTAssertFalse(planned.isLinked)
    }

    func testShiftTypeRelationship() throws {
        let shiftType = ShiftType(name: "Frühschicht", colorHex: "#007AFF")
        context.insert(shiftType)

        let planned = PlannedShift(plannedDate: Date(), startTime: Date(), endTime: Date().addingTimeInterval(3600), shiftType: shiftType)
        context.insert(planned)
        try context.save()

        XCTAssertEqual(planned.shiftType?.name, "Frühschicht")
        XCTAssertTrue(shiftType.plannedShifts?.contains(where: { $0.persistentModelID == planned.persistentModelID }) ?? false)
    }

    func testDefaultValues() {
        let planned = PlannedShift(plannedDate: Date(), startTime: Date(), endTime: Date().addingTimeInterval(3600))
        XCTAssertEqual(planned.notes, "")
        XCTAssertFalse(planned.isAutoStartEnabled)
        XCTAssertEqual(planned.reminderMinutesBefore, 30)
        XCTAssertNil(planned.linkedShift)
        XCTAssertNil(planned.notificationIdentifier)
    }
}
