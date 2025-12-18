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
    var endTime: Date
    var shiftTypeName: String?  // optional - kann leer sein
    
    // Computed Property - wird nicht in DB gespeichert
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    init(startTime: Date, endTime: Date, shiftTypeName: String? = nil) {
        self.startTime = startTime
        self.endTime = endTime
        self.shiftTypeName = shiftTypeName
    }
}
