//
//  MockShiftType.swift
//  ShiftTrackerTests
//
//  Created by Matthias Böhnke on 17.02.26.
//

import Foundation
@testable import ShiftTracker

enum MockShiftType {
    static let frueh = ShiftType(name: "Frühschicht", colorHex: "#007AFF")
    static let spaet = ShiftType(name: "Spätschicht", colorHex: "#FF9500")
    static let nacht = ShiftType(name: "Nachtschicht", colorHex: "#AF52DE")

    static func withRate(_ rate: Double, name: String = "Custom", colorHex: String = "#34C759") -> ShiftType {
        ShiftType(name: name, colorHex: colorHex, hourlyRate: rate)
    }

    static func all() -> [ShiftType] {
        [frueh, spaet, nacht]
    }
}
