//
//  MockTests.swift
//  ShiftTrackerTests
//
//  Created by Matthias Böhnke on 17.02.26.
//

import XCTest
import SwiftData
@testable import ShiftTracker

final class MockTests: XCTestCase {

    // MARK: - MockShift Tests

    func testCompletedShift() {
        let shift = MockShift.completed(hoursAgo: 10, durationHours: 8)
        XCTAssertNotNil(shift.endTime)
        XCTAssertEqual(shift.duration, 8 * 3600, accuracy: 1)
    }

    func testActiveShift() {
        let shift = MockShift.active(hoursAgo: 2)
        XCTAssertNil(shift.endTime)
        XCTAssertGreaterThan(shift.duration, 0)
    }

    func testShiftWithBreaks() {
        let shift = MockShift.withBreaks(durationHours: 8, breakMinutes: [30, 15])
        XCTAssertEqual(shift.breaks?.count, 2)
        let totalBreakMinutes = shift.totalBreakDuration / 60
        XCTAssertEqual(totalBreakMinutes, 45, accuracy: 1)
    }

    func testShiftOnDate() {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        let shift = MockShift.onDate(yesterday, startHour: 14, durationHours: 6)
        XCTAssertTrue(calendar.isDate(shift.startTime, inSameDayAs: yesterday))
        XCTAssertEqual(shift.duration, 6 * 3600, accuracy: 1)
    }

    // MARK: - MockShiftType Tests

    func testDefaultTypes() {
        XCTAssertEqual(MockShiftType.frueh.name, "Frühschicht")
        XCTAssertEqual(MockShiftType.spaet.name, "Spätschicht")
        XCTAssertEqual(MockShiftType.nacht.name, "Nachtschicht")
    }

    func testTypeWithRate() {
        let type = MockShiftType.withRate(25.0, name: "Nacht+")
        XCTAssertEqual(type.hourlyRate, 25.0)
        XCTAssertEqual(type.name, "Nacht+")
    }

    func testAllTypes() {
        XCTAssertEqual(MockShiftType.all().count, 3)
    }

    // MARK: - TestContainer Integration

    @MainActor
    func testContainerWithMocks() throws {
        let container = try TestContainer.create()
        let context = container.mainContext

        let type = MockShiftType.withRate(20.0)
        context.insert(type)

        let shift = MockShift.completed(durationHours: 8, shiftType: type)
        context.insert(shift)

        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Shift>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.shiftType?.hourlyRate, 20.0)
    }

    @MainActor
    func testSampleDataCreation() throws {
        let (container, shifts) = try TestContainer.createWithSampleData()
        XCTAssertEqual(shifts.count, 3)
        XCTAssertTrue(shifts.allSatisfy { $0.endTime != nil })
        _ = container
    }
}
