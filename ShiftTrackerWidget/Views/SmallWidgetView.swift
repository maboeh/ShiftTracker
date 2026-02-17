//
//  SmallWidgetView.swift
//  ShiftTrackerWidget
//
//  Created by Matthias Böhnke on 17.02.26.
//

import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let entry: ShiftWidgetEntry

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: statusIcon)
                .font(.title)
                .foregroundStyle(statusColor)

            if let startTime = entry.shiftStartTime {
                Text(startTime, style: .timer)
                    .font(.title2)
                    .fontWeight(.bold)
                    .monospacedDigit()
            } else {
                Text("Keine Schicht")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let typeName = entry.shiftTypeName {
                Text(typeName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            if entry.shiftState == .onBreak {
                Text("Pause")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.orange)
            }
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }

    private var statusIcon: String {
        switch entry.shiftState {
        case .active: return "figure.walk"
        case .onBreak: return "cup.and.saucer.fill"
        case .inactive: return "moon.zzz.fill"
        }
    }

    private var statusColor: Color {
        switch entry.shiftState {
        case .active: return .green
        case .onBreak: return .orange
        case .inactive: return .secondary
        }
    }
}
