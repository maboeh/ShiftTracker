//
//  AccessoryCircularView.swift
//  ShiftTrackerWidget
//
//  Created by Matthias Böhnke on 17.02.26.
//

import SwiftUI
import WidgetKit

struct AccessoryCircularView: View {
    let entry: ShiftWidgetEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()

            VStack(spacing: 2) {
                Image(systemName: statusIcon)
                    .font(.caption)
                    .widgetAccentable()

                if let startTime = entry.shiftStartTime, entry.shiftState != .inactive {
                    Text(startTime, style: .timer)
                        .font(.caption2)
                        .monospacedDigit()
                        .multilineTextAlignment(.center)
                } else {
                    Text("--:--")
                        .font(.caption2)
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
}
