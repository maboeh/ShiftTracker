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
    
    
    var duration: TimeInterval {
        if let end = endTime {
            let duration = end.timeIntervalSince(startTime)
            return max(duration, 0)  // NIE negativ!
        } else {
            let duration = Date.now.timeIntervalSince(startTime)
            return max(duration, 0)  // NIE negativ!
        }
    }
    
    init(startTime: Date, endTime: Date? = nil, shiftType: ShiftType? = nil) {
        self.startTime = startTime
        self.endTime = endTime
        self.shiftType = shiftType
    }
}
