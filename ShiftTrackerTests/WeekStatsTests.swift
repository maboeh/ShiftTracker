//
//  WeekStatsTests.swift
//  ShiftTrackerTests
//
//  Created by Matthias Böhnke on 16.02.26.
//

import XCTest
@testable import ShiftTracker

final class WeekStatsTests: XCTestCase {
    
    // MARK: - Weekly Total Hours Tests
    
    func testWeeklyTotalHours() {
        let calendar = Calendar.current
        let now = Date()
        
        guard let monday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else {
            XCTFail("Could not calculate Monday")
            return
        }
        
        let shifts = createTestShifts(forWeekStarting: monday, hoursPerShift: [8, 8, 8, 8, 8])
        
        let totalSeconds = shifts.reduce(0.0) { $0 + $1.duration }
        let totalHours = totalSeconds / 3600
        
        XCTAssertEqual(totalHours, 40.0, accuracy: 0.001, "Total hours should be 40")
    }
    
    func testEmptyWeek() {
        let shifts: [Shift] = []
        
        let totalSeconds = shifts.reduce(0.0) { $0 + $1.duration }
        let totalHours = totalSeconds / 3600
        
        XCTAssertEqual(totalHours, 0.0, accuracy: 0.001, "Empty week should have 0 hours")
    }
    
    // MARK: - Overtime Calculation Tests
    
    func testOvertimeCalculation() {
        let totalHours = 45.0
        let targetHours = AppConfiguration.defaultWeeklyHours
        let overtime = totalHours - targetHours
        
        XCTAssertEqual(overtime, 5.0, accuracy: 0.001, "Overtime should be 5 hours")
    }
    
    func testNoOvertimeWhenUnderTarget() {
        let totalHours = 35.0
        let targetHours = AppConfiguration.defaultWeeklyHours
        let overtime = totalHours - targetHours
        
        XCTAssertLessThan(overtime, 0, "Overtime should be negative when under target")
    }
    
    // MARK: - Week Progress Tests
    
    func testWeekProgressAtZero() {
        let totalHours = 0.0
        let targetHours = AppConfiguration.defaultWeeklyHours
        let progress = min(totalHours / targetHours, 1.0)
        
        XCTAssertEqual(progress, 0.0, accuracy: 0.001, "Progress should be 0 when no hours worked")
    }
    
    func testWeekProgressAt50Percent() {
        let totalHours = 20.0
        let targetHours = AppConfiguration.defaultWeeklyHours
        let progress = min(totalHours / targetHours, 1.0)
        
        XCTAssertEqual(progress, 0.5, accuracy: 0.001, "Progress should be 0.5 at 20 hours")
    }
    
    func testWeekProgressAt100Percent() {
        let totalHours = 40.0
        let targetHours = AppConfiguration.defaultWeeklyHours
        let progress = min(totalHours / targetHours, 1.0)
        
        XCTAssertEqual(progress, 1.0, accuracy: 0.001, "Progress should be 1.0 at 40 hours")
    }
    
    func testWeekProgressCappedAt100Percent() {
        let totalHours = 50.0
        let targetHours = AppConfiguration.defaultWeeklyHours
        let progress = min(totalHours / targetHours, 1.0)
        
        XCTAssertEqual(progress, 1.0, accuracy: 0.001, "Progress should be capped at 1.0")
    }
    
    // MARK: - Helper Methods
    
    private func createTestShifts(forWeekStarting monday: Date, hoursPerShift: [Double]) -> [Shift] {
        var shifts: [Shift] = []
        let calendar = Calendar.current
        
        for (index, hours) in hoursPerShift.enumerated() {
            guard let day = calendar.date(byAdding: .day, value: index, to: monday) else { continue }
            
            let startTime = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: day) ?? day
            let endTime = startTime.addingTimeInterval(hours * 3600)
            
            let shift = Shift(startTime: startTime, endTime: endTime)
            shifts.append(shift)
        }
        
        return shifts
    }
}
