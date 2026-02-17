//
//  AccessoryRectangularView.swift
//  ShiftTrackerWidget
//
//  Created by Matthias Böhnke on 17.02.26.
//

import SwiftUI
import WidgetKit

struct AccessoryRectangularView: View {
    let entry: ShiftWidgetEntry

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: statusIcon)
                .font(.title3)
                .widgetAccentable()

            VStack(alignment: .leading, spacing: 2) {
                Text(statusText)
                    .font(.headline)
                    .lineLimit(1)

                if let startTime = entry.shiftStartTime, entry.shiftState != .inactive {
                    Text(startTime, style: .timer)
                        .font(.body)
                        .monospacedDigit()
                } else {
                    Text("Keine Schicht")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .containerBackground(for: .widget) { }
    }

    private var statusIcon: String {
        switch entry.shiftState {
        case .active: return "figure.walk"
        case .onBreak: return "cup.and.saucer.fill"
        case .inactive: return "moon.zzz.fill"
        }
    }

    private var statusText: String {
        switch entry.shiftState {
        case .active: return "Arbeite..."
        case .onBreak: return "In Pause"
        case .inactive: return "Frei"
        }
    }
}
