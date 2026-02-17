//
//  ShiftServiceTests.swift
//  ShiftTrackerTests
//
//  Created by Matthias Böhnke on 17.02.26.
//

import XCTest
import SwiftData
@testable import ShiftTracker

final class ShiftServiceTests: XCTestCase {

    private var container: ModelContainer!
    private var service: ShiftService!

    @MainActor
    override func setUp() {
        super.setUp()
        container = try! TestContainer.create()
        service = ShiftService(modelContext: container.mainContext)
    }

    override func tearDown() {
        container = nil
        service = nil
        super.tearDown()
    }

    // MARK: - Start Shift

    @MainActor
    func testStartShiftCreatesActiveShift() throws {
        let shift = try service.startShift()
        XCTAssertNotNil(shift)
        XCTAssertNil(shift.endTime)

        let fetched = try service.fetchActiveShift()
        XCTAssertNotNil(fetched)
    }

    @MainActor
    func testStartShiftWithShiftType() throws {
        let shiftType = ShiftType(name: "Frühschicht", colorHex: "#007AFF")
        container.mainContext.insert(shiftType)

        let shift = try service.startShift(shiftType: shiftType)
        XCTAssertEqual(shift.shiftType?.name, "Frühschicht")
    }

    @MainActor
    func testStartShiftThrowsWhenAlreadyActive() throws {
        try service.startShift()
        XCTAssertThrowsError(try service.startShift()) { error in
            XCTAssertTrue(error is ShiftServiceError)
        }
    }

    // MARK: - End Shift

    @MainActor
    func testEndShiftSetsEndTime() throws {
        try service.startShift()
        try service.endShift()

        let active = try service.fetchActiveShift()
        XCTAssertNil(active)
    }

    @MainActor
    func testEndShiftThrowsWhenNoActiveShift() throws {
        XCTAssertThrowsError(try service.endShift()) { error in
            XCTAssertTrue(error is ShiftServiceError)
        }
    }

    @MainActor
    func testEndShiftClosesActiveBreak() throws {
        let shift = try service.startShift()
        try service.startBreak()

        let breaks = shift.breaks ?? []
        XCTAssertEqual(breaks.count, 1)
        XCTAssertTrue(breaks[0].isActive)

        try service.endShift()
        XCTAssertNotNil(breaks[0].endTime)
    }

    // MARK: - Get Current State

    @MainActor
    func testGetCurrentStateInactive() throws {
        let state = try service.getCurrentState()
        XCTAssertEqual(state, .inactive)
    }

    @MainActor
    func testGetCurrentStateActive() throws {
        try service.startShift()
        let state = try service.getCurrentState()
        XCTAssertEqual(state, .active)
    }

    @MainActor
    func testGetCurrentStateOnBreak() throws {
        try service.startShift()
        try service.startBreak()
        let state = try service.getCurrentState()
        XCTAssertEqual(state, .onBreak)
    }

    // MARK: - Break Operations

    @MainActor
    func testStartBreakCreatesActiveBreak() throws {
        let shift = try service.startShift()
        try service.startBreak()

        let breaks = shift.breaks ?? []
        XCTAssertEqual(breaks.count, 1)
        XCTAssertTrue(breaks[0].isActive)
    }

    @MainActor
    func testStartBreakThrowsWhenNoActiveShift() throws {
        XCTAssertThrowsError(try service.startBreak()) { error in
            XCTAssertTrue(error is ShiftServiceError)
        }
    }

    @MainActor
    func testStartBreakThrowsWhenBreakAlreadyActive() throws {
        try service.startShift()
        try service.startBreak()
        XCTAssertThrowsError(try service.startBreak()) { error in
            XCTAssertTrue(error is ShiftServiceError)
        }
    }

    @MainActor
    func testEndBreakSetsEndTime() throws {
        try service.startShift()
        try service.startBreak()
        try service.endBreak()

        let state = try service.getCurrentState()
        XCTAssertEqual(state, .active)
    }

    @MainActor
    func testEndBreakThrowsWhenNoActiveShift() throws {
        XCTAssertThrowsError(try service.endBreak()) { error in
            XCTAssertTrue(error is ShiftServiceError)
        }
    }

    @MainActor
    func testEndBreakThrowsWhenNoActiveBreak() throws {
        try service.startShift()
        XCTAssertThrowsError(try service.endBreak()) { error in
            XCTAssertTrue(error is ShiftServiceError)
        }
    }

    // MARK: - Multiple Breaks

    @MainActor
    func testMultipleBreaksInOneShift() throws {
        let shift = try service.startShift()
        try service.startBreak()
        try service.endBreak()
        try service.startBreak()
        try service.endBreak()

        let breaks = shift.breaks ?? []
        XCTAssertEqual(breaks.count, 2)
        XCTAssertFalse(breaks[0].isActive)
        XCTAssertFalse(breaks[1].isActive)
    }

    // MARK: - Error Descriptions

    @MainActor
    func testErrorDescriptions() {
        XCTAssertNotNil(ShiftServiceError.activeShiftExists.errorDescription)
        XCTAssertNotNil(ShiftServiceError.noActiveShift.errorDescription)
        XCTAssertNotNil(ShiftServiceError.activeBreakExists.errorDescription)
        XCTAssertNotNil(ShiftServiceError.noActiveBreak.errorDescription)
    }
}
