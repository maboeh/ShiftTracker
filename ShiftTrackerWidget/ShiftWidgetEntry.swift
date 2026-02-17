//
//  ShiftWidgetEntry.swift
//  ShiftTrackerWidget
//
//  Created by Matthias Böhnke on 17.02.26.
//

import WidgetKit
import SwiftUI

struct ShiftWidgetEntry: TimelineEntry {
    let date: Date
    let shiftState: ShiftState
    let shiftStartTime: Date?
    let breakStartTime: Date?
    let shiftTypeName: String?
    let shiftTypeColorHex: String?

    var shiftTypeColor: Color {
        guard let hex = shiftTypeColorHex else { return .blue }
        return Color(hex: hex) ?? .blue
    }

    static var placeholder: ShiftWidgetEntry {
        ShiftWidgetEntry(
            date: Date(),
            shiftState: .active,
            shiftStartTime: Date().addingTimeInterval(-3600),
            breakStartTime: nil,
            shiftTypeName: "Frühschicht",
            shiftTypeColorHex: "#007AFF"
        )
    }

    static var inactive: ShiftWidgetEntry {
        ShiftWidgetEntry(
            date: Date(),
            shiftState: .inactive,
            shiftStartTime: nil,
            breakStartTime: nil,
            shiftTypeName: nil,
            shiftTypeColorHex: nil
        )
    }
}
