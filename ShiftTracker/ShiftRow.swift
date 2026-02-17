//
//  ShiftRow.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 20.12.25.
//
import SwiftUI

struct ShiftRow: View {
    let shift: Shift
    @State private var currentTime = Date.now
    @State private var timer: Timer?
    
    private var liveDuration: TimeInterval {
        if shift.endTime == nil {
            return max(currentTime.timeIntervalSince(shift.startTime) - shift.totalBreakDuration, 0)
        } else {
            return shift.netDuration
        }
    }
    
    private var statusIcon: String {
        if shift.endTime == nil {
            return shift.hasActiveBreak ? "pause.circle.fill" : "clock.fill"
        }
        return "checkmark.circle.fill"
    }

    private var statusColor: Color {
        if let typeColor = shift.shiftType?.color {
            return typeColor
        }
        if shift.endTime == nil {
            return shift.hasActiveBreak ? .orange : .green
        }
        return .blue
    }

    private var breakComplianceWarning: Bool {
        guard shift.endTime != nil else { return false }
        let bruttoHours = shift.duration / 3600
        let totalBreakMinutes = shift.totalBreakDuration / 60
        return (bruttoHours > 9 && totalBreakMinutes < 45) ||
               (bruttoHours > 6 && totalBreakMinutes < 30)
    }

    private var formattedDate: String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(shift.startTime) {
            return AppStrings.heute
        } else if calendar.isDateInYesterday(shift.startTime) {
            return AppStrings.gestern
        } else {
            return shift.startTime.formatted(date: .abbreviated, time: .omitted)
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: statusIcon)
                .foregroundStyle(statusColor)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                if let typeName = shift.shiftType?.name {
                    Text(typeName)
                        .font(.caption)
                        .foregroundStyle(shift.shiftType?.color ?? .secondary)
                        .fontWeight(.semibold)
                }

                Text("\(formattedDate), \(shift.startTime.formatted(date: .omitted, time: .shortened))")
                    .font(.headline)

                if shift.endTime == nil {
                    if shift.hasActiveBreak {
                        Text(AppStrings.inPause)
                            .font(.caption)
                            .foregroundStyle(.orange)
                    } else {
                        Text(AppStrings.laeuftGerade)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("\(AppStrings.bis) \(shift.endTime!.formatted(date: .omitted, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.1f h", liveDuration / 3600))
                    .font(.headline)
                    .foregroundStyle(shift.endTime == nil ? .green : .primary)

                if breakComplianceWarning {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityHint(AppStrings.hintDoppeltippen)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private var accessibilityDescription: String {
        let type = shift.shiftType?.name ?? "Schicht"
        let date = formattedDate
        let time = shift.startTime.formatted(date: .omitted, time: .shortened)
        let duration = String(format: "%.1f Stunden", liveDuration / 3600)

        if shift.endTime == nil {
            return "\(type), \(date) ab \(time), läuft gerade, \(duration)"
        } else {
            let endTime = shift.endTime!.formatted(date: .omitted, time: .shortened)
            return "\(type), \(date), \(time) bis \(endTime), \(duration)"
        }
    }

    private func startTimer() {
        guard shift.endTime == nil else { return }

        let newTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            currentTime = Date.now
        }
        RunLoop.current.add(newTimer, forMode: .common)
        timer = newTimer
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
