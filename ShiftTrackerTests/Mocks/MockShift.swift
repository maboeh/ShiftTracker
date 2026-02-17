//
//  MockShift.swift
//  ShiftTrackerTests
//
//  Created by Matthias Böhnke on 17.02.26.
//

import Foundation
@testable import ShiftTracker

enum MockShift {
    static func completed(
        hoursAgo: Double = 8,
        durationHours: Double = 8,
        shiftType: ShiftType? = nil
    ) -> Shift {
        let start = Date().addingTimeInterval(-hoursAgo * 3600)
        let end = start.addingTimeInterval(durationHours * 3600)
        return Shift(startTime: start, endTime: end, shiftType: shiftType)
    }

    static func active(
        hoursAgo: Double = 2,
        shiftType: ShiftType? = nil
    ) -> Shift {
        let start = Date().addingTimeInterval(-hoursAgo * 3600)
        return Shift(startTime: start, endTime: nil, shiftType: shiftType)
    }

    static func withBreaks(
        durationHours: Double = 8,
        breakMinutes: [Double] = [30],
        shiftType: ShiftType? = nil
    ) -> Shift {
        let start = Date().addingTimeInterval(-durationHours * 3600)
        let end = Date()
        let shift = Shift(startTime: start, endTime: end, shiftType: shiftType)

        var breaks: [Break] = []
        var offset: TimeInterval = 3 * 3600 // first break after 3h

        for minutes in breakMinutes {
            let breakStart = start.addingTimeInterval(offset)
            let breakEnd = breakStart.addingTimeInterval(minutes * 60)
            breaks.append(Break(startTime: breakStart, endTime: breakEnd))
            offset += 2 * 3600 // next break 2h later
        }

        shift.breaks = breaks
        return shift
    }

    static func onDate(
        _ date: Date,
        startHour: Int = 8,
        durationHours: Double = 8,
        shiftType: ShiftType? = nil
    ) -> Shift {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        let start = calendar.date(byAdding: .hour, value: startHour, to: dayStart)!
        let end = start.addingTimeInterval(durationHours * 3600)
        return Shift(startTime: start, endTime: end, shiftType: shiftType)
    }
}
