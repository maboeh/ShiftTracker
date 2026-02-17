//
//  ShiftType.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 22.12.25.
//

import SwiftUI
import SwiftData

@Model
class ShiftType {
    var name: String
    var colorHex: String  // Speichern als Hex-String (z.B. "#0000FF")
    
    // Relationship: Welche Shifts gehören zu diesem Type?
    @Relationship(deleteRule: .nullify, inverse: \Shift.shiftType)
    var shifts: [Shift]?
    
    init(name: String, colorHex: String) {
        self.name = name
        self.colorHex = colorHex
        self.shifts = []
    }
    
    // Computed Property: Hex → SwiftUI Color
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
}

// BONUS: Color Extension für Hex-Strings
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }

    func toHex() -> String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0

        if uiColor.getRed(&r, green: &g, blue: &b, alpha: nil) {
            return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
        }

        // Fallback für Graustufen-Farbraum
        var white: CGFloat = 0
        if uiColor.getWhite(&white, alpha: nil) {
            let v = Int(white * 255)
            return String(format: "#%02X%02X%02X", v, v, v)
        }

        return "#0000FF"
    }
}
