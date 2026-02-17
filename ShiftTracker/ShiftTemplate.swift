//
//  ShiftTemplate.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 17.02.26.
//

import Foundation
import SwiftData

@Model
class ShiftTemplate {
    var name: String
    var shiftType: ShiftType?
    var defaultStartHour: Int
    var defaultStartMinute: Int
    var defaultDurationHours: Double
    var isActive: Bool

    init(name: String, shiftType: ShiftType? = nil, defaultStartHour: Int = 6, defaultStartMinute: Int = 0, defaultDurationHours: Double = 8.0, isActive: Bool = true) {
        self.name = name
        self.shiftType = shiftType
        self.defaultStartHour = defaultStartHour
        self.defaultStartMinute = defaultStartMinute
        self.defaultDurationHours = defaultDurationHours
        self.isActive = isActive
    }

    var formattedStartTime: String {
        String(format: "%02d:%02d", defaultStartHour, defaultStartMinute)
    }
}
