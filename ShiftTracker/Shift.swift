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
            return end.timeIntervalSince(startTime)  
        } else {
            return Date.now.timeIntervalSince(startTime)
        }
    }
    
    init(startTime: Date, endTime: Date? = nil, shiftType: ShiftType? = nil) {
        self.startTime = startTime
        self.endTime = endTime
        self.shiftType = shiftType
    }
}
