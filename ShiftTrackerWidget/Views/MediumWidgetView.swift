//
//  MediumWidgetView.swift
//  ShiftTrackerWidget
//
//  Created by Matthias Böhnke on 17.02.26.
//

import SwiftUI
import WidgetKit
import AppIntents

struct MediumWidgetView: View {
    let entry: ShiftWidgetEntry

    var body: some View {
        HStack(spacing: 12) {
            // Left side: Status info
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: statusIcon)
                        .font(.title2)
                        .foregroundStyle(statusColor)
                    Text(statusText)
                        .font(.headline)
                }

                if let startTime = entry.shiftStartTime {
                    Text(startTime, style: .timer)
                        .font(.title)
                        .fontWeight(.bold)
                        .monospacedDigit()
                }

                if let typeName = entry.shiftTypeName {
                    Text(typeName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Right side: Interactive buttons
            VStack(spacing: 8) {
                switch entry.shiftState {
                case .inactive:
                    Button(intent: StartShiftIntent()) {
                        Label("Start", systemImage: "play.fill")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .tint(.green)

                case .active:
                    Button(intent: ToggleBreakIntent()) {
                        Label("Pause", systemImage: "pause.fill")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .tint(.orange)

                    Button(intent: EndShiftIntent()) {
                        Label("Ende", systemImage: "stop.fill")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .tint(.red)

                case .onBreak:
                    Button(intent: ToggleBreakIntent()) {
                        Label("Weiter", systemImage: "play.fill")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .tint(.green)

                    Button(intent: EndShiftIntent()) {
                        Label("Ende", systemImage: "stop.fill")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .tint(.red)
                }
            }
            .buttonStyle(.borderedProminent)
            .frame(width: 100)
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

    private var statusText: String {
        switch entry.shiftState {
        case .active: return "Arbeite..."
        case .onBreak: return "In Pause"
        case .inactive: return "Keine Schicht"
        }
    }
}
