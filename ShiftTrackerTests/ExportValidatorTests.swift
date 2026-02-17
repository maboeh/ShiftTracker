//
//  ExportValidatorTests.swift
//  ShiftTrackerTests
//
//  Created by Matthias Böhnke on 16.02.26.
//

import XCTest
@testable import ShiftTracker

final class ExportValidatorTests: XCTestCase {

    func testValidateEmptyShiftsThrows() {
        let options = ExportOptions(format: .csv, fields: [.date])

        XCTAssertThrowsError(try ExportValidator.validate(shifts: [], options: options)) { error in
            XCTAssertTrue(error is ExportValidationError)
        }
    }

    func testValidateEmptyFieldsThrows() {
        let shift = Shift(startTime: Date(), endTime: Date())
        let options = ExportOptions(format: .csv, fields: [])

        XCTAssertThrowsError(try ExportValidator.validate(shifts: [shift], options: options)) { error in
            XCTAssertTrue(error is ExportValidationError)
        }
    }

    func testValidateSucceedsWithValidInput() {
        let shift = Shift(startTime: Date(), endTime: Date())
        let options = ExportOptions(format: .csv, fields: [.date])

        XCTAssertNoThrow(try ExportValidator.validate(shifts: [shift], options: options))
    }

    func testFilterShiftsByDateRange() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastWeek = calendar.date(byAdding: .day, value: -10, to: today)!
        let lastMonth = calendar.date(byAdding: .month, value: -2, to: today)!

        let shiftToday = Shift(startTime: today.addingTimeInterval(8 * 3600), endTime: today.addingTimeInterval(16 * 3600))
        let shiftLastWeek = Shift(startTime: lastWeek.addingTimeInterval(8 * 3600), endTime: lastWeek.addingTimeInterval(16 * 3600))
        let shiftOld = Shift(startTime: lastMonth.addingTimeInterval(8 * 3600), endTime: lastMonth.addingTimeInterval(16 * 3600))

        let allShifts = [shiftToday, shiftLastWeek, shiftOld]

        // Filter to this week
        let thisWeekRange = calendar.weekInterval(for: today)
        let filtered = ExportValidator.filterShifts(allShifts, dateRange: thisWeekRange)

        // Only today's shift should be in this week
        XCTAssertTrue(filtered.contains { $0.startTime == shiftToday.startTime })
        XCTAssertFalse(filtered.contains { $0.startTime == shiftOld.startTime })
    }

    func testFilterShiftsExcludesOutOfRange() {
        let now = Date()
        let pastShift = Shift(startTime: now.addingTimeInterval(-86400 * 365), endTime: now.addingTimeInterval(-86400 * 365 + 3600))
        let recentShift = Shift(startTime: now.addingTimeInterval(-3600), endTime: now)

        let thisWeekRange = Calendar.current.weekInterval(for: now)
        let filtered = ExportValidator.filterShifts([pastShift, recentShift], dateRange: thisWeekRange)

        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.startTime, recentShift.startTime)
    }
}
