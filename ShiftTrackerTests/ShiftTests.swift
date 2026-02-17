//
//  ShiftTests.swift
//  ShiftTrackerTests
//
//  Created by Matthias Böhnke on 16.02.26.
//

import XCTest
@testable import ShiftTracker

final class ShiftTests: XCTestCase {
    
    // MARK: - Duration Calculation Tests
    
    func testDurationCalculation() {
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(3600) // 1 hour
        
        let shift = Shift(startTime: startTime, endTime: endTime)
        
        XCTAssertEqual(shift.duration, 3600, accuracy: 0.001, "Duration should be 3600 seconds (1 hour)")
    }
    
    func testDurationWithActiveShift() {
        let startTime = Date()
        
        let shift = Shift(startTime: startTime, endTime: nil)
        
        XCTAssertGreaterThan(shift.duration, 0, "Active shift duration should be greater than 0")
    }
    
    func testNegativeDurationProtection() {
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(-3600) // 1 hour in the past
        
        let shift = Shift(startTime: startTime, endTime: endTime)
        
        XCTAssertGreaterThanOrEqual(shift.duration, 0, "Duration should never be negative")
    }
    
    func testDurationWithMultipleHours() {
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(8 * 3600) // 8 hours
        
        let shift = Shift(startTime: startTime, endTime: endTime)
        
        XCTAssertEqual(shift.duration, 8 * 3600, accuracy: 0.001, "Duration should be 8 hours in seconds")
    }
    
    // MARK: - Shift Type Assignment Tests
    
    func testShiftTypeAssignment() {
        let shift = Shift(startTime: Date())
        let shiftType = ShiftType(name: "Frühschicht", colorHex: "#007AFF")
        
        shift.shiftType = shiftType
        
        XCTAssertNotNil(shift.shiftType, "Shift type should be assigned")
        XCTAssertEqual(shift.shiftType?.name, "Frühschicht", "Shift type name should match")
    }
    
    func testShiftWithoutType() {
        let shift = Shift(startTime: Date())
        
        XCTAssertNil(shift.shiftType, "New shift should have no type assigned")
    }
    
    // MARK: - End Time Tests
    
    func testActiveShiftHasNoEndTime() {
        let shift = Shift(startTime: Date(), endTime: nil)
        
        XCTAssertNil(shift.endTime, "Active shift should have no end time")
    }
    
    func testCompletedShiftHasEndTime() {
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(3600)
        
        let shift = Shift(startTime: startTime, endTime: endTime)
        
        XCTAssertNotNil(shift.endTime, "Completed shift should have an end time")
        XCTAssertEqual(shift.endTime, endTime, "End time should match")
    }
}
