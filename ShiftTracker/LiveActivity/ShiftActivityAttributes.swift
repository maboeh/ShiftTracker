//
//  ShiftActivityAttributes.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 17.02.26.
//

import ActivityKit
import SwiftUI

struct ShiftActivityAttributes: ActivityAttributes {
    struct ContentState: Codable & Hashable {
        var shiftState: ShiftState
        var shiftStartTime: Date
        var breakStartTime: Date?
        var shiftTypeName: String?
        var shiftTypeColorHex: String?

        var shiftTypeColor: Color {
            guard let hex = shiftTypeColorHex else { return .blue }
            return Color(hex: hex) ?? .blue
        }
    }

    // Statische Attribute, die sich während der Live Activity nicht ändern
    let shiftId: String
}
