//
//  Shift.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 17.12.25.
//

import SwiftUI
import SwiftData

@Model
class Shift {
    var startTime: Date
    var endTime: Date?

    var shiftType: ShiftType?

    @Relationship(deleteRule: .cascade, inverse: \Break.shift)
    var breaks: [Break]?

    var duration: TimeInterval {
        if let end = endTime {
            return max(end.timeIntervalSince(startTime), 0)
        } else {
            return max(Date.now.timeIntervalSince(startTime), 0)
        }
    }

    var totalBreakDuration: TimeInterval {
        (breaks ?? []).reduce(0) { $0 + $1.duration }
    }

    var netDuration: TimeInterval {
        max(duration - totalBreakDuration, 0)
    }

    var hasActiveBreak: Bool {
        (breaks ?? []).contains { $0.isActive }
    }

    init(startTime: Date, endTime: Date? = nil, shiftType: ShiftType? = nil) {
        self.startTime = startTime
        self.endTime = endTime
        self.shiftType = shiftType
        self.breaks = []
    }
}
