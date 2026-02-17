//
//  ShiftLiveActivityView.swift
//  ShiftTrackerWidget
//
//  Created by Matthias Böhnke on 17.02.26.
//

import SwiftUI
import WidgetKit
import ActivityKit

struct ShiftLiveActivityView: View {
    let state: ShiftActivityAttributes.ContentState

    var body: some View {
        HStack(spacing: 12) {
            // Status icon
            Image(systemName: statusIcon)
                .font(.title2)
                .foregroundStyle(statusColor)

            // Timer and status
            VStack(alignment: .leading, spacing: 4) {
                Text(statusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(state.shiftStartTime, style: .timer)
                    .font(.title2)
                    .fontWeight(.bold)
                    .monospacedDigit()

                if let typeName = state.shiftTypeName {
                    Text(typeName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Interactive buttons
            VStack(spacing: 6) {
                if state.shiftState == .active {
                    Button(intent: ToggleBreakIntent()) {
                        Image(systemName: "pause.fill")
                            .font(.caption)
                            .frame(width: 36, height: 36)
                    }
                    .tint(.orange)

                    Button(intent: EndShiftIntent()) {
                        Image(systemName: "stop.fill")
                            .font(.caption)
                            .frame(width: 36, height: 36)
                    }
                    .tint(.red)
                } else if state.shiftState == .onBreak {
                    Button(intent: ToggleBreakIntent()) {
                        Image(systemName: "play.fill")
                            .font(.caption)
                            .frame(width: 36, height: 36)
                    }
                    .tint(.green)

                    Button(intent: EndShiftIntent()) {
                        Image(systemName: "stop.fill")
                            .font(.caption)
                            .frame(width: 36, height: 36)
                    }
                    .tint(.red)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private var statusIcon: String {
        switch state.shiftState {
        case .active: return "figure.walk"
        case .onBreak: return "cup.and.saucer.fill"
        case .inactive: return "moon.zzz.fill"
        }
    }

    private var statusColor: Color {
        switch state.shiftState {
        case .active: return .green
        case .onBreak: return .orange
        case .inactive: return .secondary
        }
    }

    private var statusText: String {
        switch state.shiftState {
        case .active: return "Arbeite..."
        case .onBreak: return "In Pause"
        case .inactive: return "Keine Schicht"
        }
    }
}
