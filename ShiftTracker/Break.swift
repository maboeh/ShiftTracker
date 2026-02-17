//
//  Break.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 17.02.26.
//

import Foundation
import SwiftData

@Model
class Break {
    var startTime: Date
    var endTime: Date?

    var shift: Shift?

    var duration: TimeInterval {
        if let end = endTime {
            return max(end.timeIntervalSince(startTime), 0)
        } else {
            return max(Date.now.timeIntervalSince(startTime), 0)
        }
    }

    var isActive: Bool {
        endTime == nil
    }

    init(startTime: Date, endTime: Date? = nil) {
        self.startTime = startTime
        self.endTime = endTime
    }
}
