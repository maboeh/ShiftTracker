//
//  BreakTests.swift
//  ShiftTrackerTests
//
//  Created by Matthias Böhnke on 17.02.26.
//

import XCTest
import SwiftData
@testable import ShiftTracker

final class BreakTests: XCTestCase {

    // MARK: - Break Duration

    func testCompletedBreakDuration() {
        let start = Date().addingTimeInterval(-3600) // 1h ago
        let end = Date()
        let brk = Break(startTime: start, endTime: end)

        let hours = brk.duration / 3600
        XCTAssertEqual(hours, 1.0, accuracy: 0.01)
    }

    func testActiveBreakDuration() {
        let start = Date().addingTimeInterval(-1800) // 30min ago
        let brk = Break(startTime: start, endTime: nil)

        XCTAssertTrue(brk.isActive)
        XCTAssertGreaterThan(brk.duration, 0)
    }

    func testBreakNeverNegativeDuration() {
        let start = Date()
        let end = Date().addingTimeInterval(-3600) // end before start
        let brk = Break(startTime: start, endTime: end)

        XCTAssertEqual(brk.duration, 0)
    }

    func testIsActiveFlag() {
        let active = Break(startTime: Date(), endTime: nil)
        XCTAssertTrue(active.isActive)

        let completed = Break(startTime: Date(), endTime: Date())
        XCTAssertFalse(completed.isActive)
    }

    // MARK: - Shift + Break Integration

    func testShiftTotalBreakDuration() {
        let shift = Shift(
            startTime: Date().addingTimeInterval(-8 * 3600),
            endTime: Date()
        )

        let break1 = Break(
            startTime: Date().addingTimeInterval(-6 * 3600),
            endTime: Date().addingTimeInterval(-5.5 * 3600)
        ) // 30min
        let break2 = Break(
            startTime: Date().addingTimeInterval(-3 * 3600),
            endTime: Date().addingTimeInterval(-2.75 * 3600)
        ) // 15min

        shift.breaks = [break1, break2]

        let totalMinutes = shift.totalBreakDuration / 60
        XCTAssertEqual(totalMinutes, 45, accuracy: 1)
    }

    func testShiftNetDuration() {
        let shift = Shift(
            startTime: Date().addingTimeInterval(-8 * 3600),
            endTime: Date()
        ) // 8h brutto

        let brk = Break(
            startTime: Date().addingTimeInterval(-4 * 3600),
            endTime: Date().addingTimeInterval(-3.5 * 3600)
        ) // 30min Pause

        shift.breaks = [brk]

        let netHours = shift.netDuration / 3600
        XCTAssertEqual(netHours, 7.5, accuracy: 0.01)
    }

    func testShiftWithNoBreaks() {
        let shift = Shift(
            startTime: Date().addingTimeInterval(-8 * 3600),
            endTime: Date()
        )
        shift.breaks = []

        XCTAssertEqual(shift.totalBreakDuration, 0)
        XCTAssertEqual(shift.netDuration, shift.duration, accuracy: 0.01)
    }

    func testShiftWithNilBreaks() {
        let shift = Shift(
            startTime: Date().addingTimeInterval(-8 * 3600),
            endTime: Date()
        )
        shift.breaks = nil

        XCTAssertEqual(shift.totalBreakDuration, 0)
        XCTAssertEqual(shift.netDuration, shift.duration, accuracy: 0.01)
    }

    func testHasActiveBreak() {
        let shift = Shift(
            startTime: Date().addingTimeInterval(-8 * 3600),
            endTime: nil
        )

        let completedBreak = Break(
            startTime: Date().addingTimeInterval(-4 * 3600),
            endTime: Date().addingTimeInterval(-3.5 * 3600)
        )
        shift.breaks = [completedBreak]
        XCTAssertFalse(shift.hasActiveBreak)

        let activeBreak = Break(startTime: Date().addingTimeInterval(-1800), endTime: nil)
        shift.breaks = [completedBreak, activeBreak]
        XCTAssertTrue(shift.hasActiveBreak)
    }

    // MARK: - SwiftData Persistence

    @MainActor
    func testBreakPersistence() throws {
        let container = try TestContainer.create()
        let context = container.mainContext

        let shift = Shift(
            startTime: Date().addingTimeInterval(-8 * 3600),
            endTime: Date()
        )
        context.insert(shift)

        let brk = Break(
            startTime: Date().addingTimeInterval(-4 * 3600),
            endTime: Date().addingTimeInterval(-3.5 * 3600)
        )
        brk.shift = shift
        context.insert(brk)

        try context.save()

        let fetchedShifts = try context.fetch(FetchDescriptor<Shift>())
        XCTAssertEqual(fetchedShifts.count, 1)
        XCTAssertEqual(fetchedShifts.first?.breaks?.count, 1)
    }

    @MainActor
    func testCascadeDeletion() throws {
        let container = try TestContainer.create()
        let context = container.mainContext

        let shift = Shift(
            startTime: Date().addingTimeInterval(-8 * 3600),
            endTime: Date()
        )
        context.insert(shift)

        let break1 = Break(
            startTime: Date().addingTimeInterval(-4 * 3600),
            endTime: Date().addingTimeInterval(-3.5 * 3600)
        )
        break1.shift = shift
        context.insert(break1)

        let break2 = Break(
            startTime: Date().addingTimeInterval(-2 * 3600),
            endTime: Date().addingTimeInterval(-1.75 * 3600)
        )
        break2.shift = shift
        context.insert(break2)

        try context.save()

        // Verify setup
        let breaksBefore = try context.fetch(FetchDescriptor<Break>())
        XCTAssertEqual(breaksBefore.count, 2)

        // Delete shift — breaks should cascade
        context.delete(shift)
        try context.save()

        let shiftsAfter = try context.fetch(FetchDescriptor<Shift>())
        let breaksAfter = try context.fetch(FetchDescriptor<Break>())
        XCTAssertEqual(shiftsAfter.count, 0)
        XCTAssertEqual(breaksAfter.count, 0)
    }
}
