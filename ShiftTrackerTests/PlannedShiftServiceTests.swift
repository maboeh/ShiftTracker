//
//  PlannedShiftServiceTests.swift
//  ShiftTrackerTests
//
//  Created by Matthias Böhnke on 07.03.26.
//

import XCTest
import SwiftData
@testable import ShiftTracker

final class PlannedShiftServiceTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!
    private var service: PlannedShiftService!

    @MainActor
    override func setUp() {
        super.setUp()
        container = try! TestContainer.create()
        context = container.mainContext
        service = PlannedShiftService(modelContext: context)
    }

    override func tearDown() {
        container = nil
        context = nil
        service = nil
        super.tearDown()
    }

    // MARK: - CRUD

    @MainActor
    func testCreatePlannedShift() throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let start = calendar.date(bySettingHour: 6, minute: 0, second: 0, of: tomorrow)!
        let end = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: tomorrow)!

        let planned = try service.createPlannedShift(date: tomorrow, startTime: start, endTime: end)

        XCTAssertEqual(planned.plannedDate, calendar.startOfDay(for: tomorrow))
        XCTAssertEqual(planned.startTime, start)
        XCTAssertEqual(planned.endTime, end)
        XCTAssertEqual(planned.reminderMinutesBefore, 30)
    }

    @MainActor
    func testCreatePlannedShiftWithShiftType() throws {
        let shiftType = ShiftType(name: "Frühschicht", colorHex: "#007AFF")
        context.insert(shiftType)

        let start = Date()
        let end = start.addingTimeInterval(8 * 3600)
        let planned = try service.createPlannedShift(date: start, startTime: start, endTime: end, shiftType: shiftType)

        XCTAssertEqual(planned.shiftType?.name, "Frühschicht")
    }

    @MainActor
    func testDeletePlannedShift() throws {
        let start = Date()
        let end = start.addingTimeInterval(8 * 3600)
        let planned = try service.createPlannedShift(date: start, startTime: start, endTime: end)

        try service.deletePlannedShift(planned)

        let descriptor = FetchDescriptor<PlannedShift>()
        let remaining = try context.fetch(descriptor)
        XCTAssertTrue(remaining.isEmpty)
    }

    // MARK: - Queries

    @MainActor
    func testFetchPlannedShiftsForDate() throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        let todayStart = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: today)!
        let todayEnd = calendar.date(bySettingHour: 16, minute: 0, second: 0, of: today)!
        try service.createPlannedShift(date: today, startTime: todayStart, endTime: todayEnd, reminderMinutesBefore: 0)

        let tomorrowStart = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: tomorrow)!
        let tomorrowEnd = calendar.date(bySettingHour: 16, minute: 0, second: 0, of: tomorrow)!
        try service.createPlannedShift(date: tomorrow, startTime: tomorrowStart, endTime: tomorrowEnd, reminderMinutesBefore: 0)

        let todayShifts = try service.fetchPlannedShifts(for: today)
        XCTAssertEqual(todayShifts.count, 1)

        let tomorrowShifts = try service.fetchPlannedShifts(for: tomorrow)
        XCTAssertEqual(tomorrowShifts.count, 1)
    }

    @MainActor
    func testFetchPlannedShiftsInInterval() throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        for dayOffset in 0..<5 {
            let day = calendar.date(byAdding: .day, value: dayOffset, to: today)!
            let start = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: day)!
            let end = calendar.date(bySettingHour: 16, minute: 0, second: 0, of: day)!
            try service.createPlannedShift(date: day, startTime: start, endTime: end, reminderMinutesBefore: 0)
        }

        let threeDaysLater = calendar.date(byAdding: .day, value: 3, to: today)!
        let interval = DateInterval(start: today, end: threeDaysLater)
        let fetched = try service.fetchPlannedShifts(in: interval)
        XCTAssertEqual(fetched.count, 3)
    }

    // MARK: - Linking

    @MainActor
    func testLinkedShiftTracking() throws {
        let start = Date()
        let end = start.addingTimeInterval(8 * 3600)

        let shiftType = ShiftType(name: "Spätschicht", colorHex: "#FF9500")
        context.insert(shiftType)

        let planned = try service.createPlannedShift(date: start, startTime: start, endTime: end, shiftType: shiftType, reminderMinutesBefore: 0)
        XCTAssertFalse(planned.isLinked)

        // Simulate what convertToShift does: create a shift and link it
        let shift = Shift(startTime: Date(), shiftType: shiftType)
        context.insert(shift)
        planned.linkedShift = shift
        try context.save()

        XCTAssertTrue(planned.isLinked)
        XCTAssertNotNil(planned.linkedShift)
        XCTAssertEqual(planned.linkedShift?.shiftType?.name, "Spätschicht")
    }

    @MainActor
    func testFetchDueAutoStartShifts() throws {
        let pastTime = Date().addingTimeInterval(-600) // 10 min ago
        let futureTime = Date().addingTimeInterval(3600) // 1h from now

        // Past auto-start shift (should be found)
        try service.createPlannedShift(
            date: pastTime, startTime: pastTime, endTime: pastTime.addingTimeInterval(8 * 3600),
            reminderMinutesBefore: 0, isAutoStartEnabled: true
        )

        // Future auto-start shift (should NOT be found)
        try service.createPlannedShift(
            date: futureTime, startTime: futureTime, endTime: futureTime.addingTimeInterval(8 * 3600),
            reminderMinutesBefore: 0, isAutoStartEnabled: true
        )

        // Past non-auto-start shift (should NOT be found)
        try service.createPlannedShift(
            date: pastTime, startTime: pastTime, endTime: pastTime.addingTimeInterval(8 * 3600),
            reminderMinutesBefore: 0, isAutoStartEnabled: false
        )

        let due = try service.fetchDueAutoStartShifts(before: Date())
        XCTAssertEqual(due.count, 1)
        XCTAssertTrue(due.first!.isAutoStartEnabled)
    }
}
