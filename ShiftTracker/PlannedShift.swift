//
//  PlannedShift.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 07.03.26.
//

import Foundation
import SwiftData

@Model
class PlannedShift {
    var plannedDate: Date
    var startTime: Date
    var endTime: Date
    var shiftType: ShiftType?
    var template: ShiftTemplate?
    var pattern: ShiftPattern?
    var notes: String
    var isAutoStartEnabled: Bool
    var reminderMinutesBefore: Int
    var linkedShift: Shift?
    var notificationIdentifier: String?

    init(plannedDate: Date, startTime: Date, endTime: Date,
         shiftType: ShiftType? = nil, template: ShiftTemplate? = nil,
         notes: String = "", isAutoStartEnabled: Bool = false,
         reminderMinutesBefore: Int = 30) {
        self.plannedDate = Calendar.current.startOfDay(for: plannedDate)
        self.startTime = startTime
        self.endTime = endTime
        self.shiftType = shiftType
        self.template = template
        self.notes = notes
        self.isAutoStartEnabled = isAutoStartEnabled
        self.reminderMinutesBefore = reminderMinutesBefore
    }

    var isLinked: Bool {
        linkedShift != nil
    }

    var isPast: Bool {
        endTime < Date()
    }

    var duration: TimeInterval {
        max(endTime.timeIntervalSince(startTime), 0)
    }

    var formattedTimeRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
}
