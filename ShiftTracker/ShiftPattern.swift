//
//  ShiftPattern.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 07.03.26.
//

import Foundation
import SwiftData

struct PatternDayEntry: Codable, Identifiable, Hashable {
    var id: UUID
    var isFreeDay: Bool
    var shiftTypeName: String?
    var shiftTypeColorHex: String?
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int

    init(id: UUID = UUID(), isFreeDay: Bool = false,
         shiftTypeName: String? = nil, shiftTypeColorHex: String? = nil,
         startHour: Int = 6, startMinute: Int = 0,
         endHour: Int = 14, endMinute: Int = 0) {
        self.id = id
        self.isFreeDay = isFreeDay
        self.shiftTypeName = shiftTypeName
        self.shiftTypeColorHex = shiftTypeColorHex
        self.startHour = startHour
        self.startMinute = startMinute
        self.endHour = endHour
        self.endMinute = endMinute
    }

    var formattedTimeRange: String {
        guard !isFreeDay else { return "Frei" }
        return String(format: "%02d:%02d - %02d:%02d", startHour, startMinute, endHour, endMinute)
    }
}

@Model
class ShiftPattern {
    var name: String
    var startDate: Date
    var isActive: Bool
    var generatedUntil: Date?
    var cycleData: Data

    @Relationship(deleteRule: .nullify, inverse: \PlannedShift.pattern)
    var plannedShifts: [PlannedShift]?

    init(name: String, startDate: Date, cycleEntries: [PatternDayEntry], isActive: Bool = true) {
        self.name = name
        self.startDate = Calendar.current.startOfDay(for: startDate)
        self.isActive = isActive
        self.plannedShifts = []

        if let data = try? JSONEncoder().encode(cycleEntries) {
            self.cycleData = data
        } else {
            self.cycleData = Data()
        }
    }

    var cycleEntries: [PatternDayEntry] {
        get {
            (try? JSONDecoder().decode([PatternDayEntry].self, from: cycleData)) ?? []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                cycleData = data
            }
        }
    }

    var cycleLength: Int {
        cycleEntries.count
    }
}
