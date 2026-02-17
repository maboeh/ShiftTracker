//
//  DynamicIslandViews.swift
//  ShiftTrackerWidget
//
//  Created by Matthias Böhnke on 17.02.26.
//

import SwiftUI
import WidgetKit
import ActivityKit

// MARK: - Compact Leading

struct DynamicIslandCompactLeading: View {
    let state: ShiftActivityAttributes.ContentState

    var body: some View {
        Image(systemName: statusIcon)
            .foregroundStyle(statusColor)

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
}

// MARK: - Compact Trailing

struct DynamicIslandCompactTrailing: View {
    let state: ShiftActivityAttributes.ContentState

    var body: some View {
        Text(state.shiftStartTime, style: .timer)
            .monospacedDigit()
            .font(.caption2)
            .frame(width: 52)
    }
}

// MARK: - Minimal

struct DynamicIslandMinimal: View {
    let state: ShiftActivityAttributes.ContentState

    var body: some View {
        Image(systemName: state.shiftState == .onBreak ? "cup.and.saucer.fill" : "figure.walk")
            .foregroundStyle(state.shiftState == .onBreak ? .orange : .green)
    }
}

// MARK: - Expanded

struct DynamicIslandExpanded: View {
    let state: ShiftActivityAttributes.ContentState

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: statusIcon)
                    .foregroundStyle(statusColor)
                Text(statusText)
                    .font(.headline)
                Spacer()
                Text(state.shiftStartTime, style: .timer)
                    .font(.title2)
                    .fontWeight(.bold)
                    .monospacedDigit()
            }

            if let typeName = state.shiftTypeName {
                HStack {
                    Text(typeName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }

            HStack(spacing: 12) {
                if state.shiftState == .active {
                    Button(intent: ToggleBreakIntent()) {
                        Label("Pause", systemImage: "pause.fill")
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                    }
                    .tint(.orange)

                    Button(intent: EndShiftIntent()) {
                        Label("Ende", systemImage: "stop.fill")
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                    }
                    .tint(.red)
                } else if state.shiftState == .onBreak {
                    Button(intent: ToggleBreakIntent()) {
                        Label("Weiter", systemImage: "play.fill")
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                    }
                    .tint(.green)

                    Button(intent: EndShiftIntent()) {
                        Label("Ende", systemImage: "stop.fill")
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                    }
                    .tint(.red)
                }
            }
            .buttonStyle(.borderedProminent)
        }
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
