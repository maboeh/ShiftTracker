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
            return currentTime.timeIntervalSince(shift.startTime)
        } else {
            return shift.duration
        }
    }
    
    private var formattedDate: String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(shift.startTime) {
            return "Heute"
        } else if calendar.isDateInYesterday(shift.startTime) {
            return "Gestern"
        } else {
            return shift.startTime.formatted(date: .abbreviated, time: .omitted)
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // STATUS ICON - jetzt mit ShiftType Farbe!
            Image(systemName: shift.endTime == nil ? "clock.fill" : "checkmark.circle.fill")
                .foregroundStyle(shift.shiftType?.color ?? (shift.endTime == nil ? .green : .blue))
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                // NEU: ShiftType Name wenn vorhanden
                if let typeName = shift.shiftType?.name {
                    Text(typeName)
                        .font(.caption)
                        .foregroundStyle(shift.shiftType?.color ?? .secondary)
                        .fontWeight(.semibold)
                }
                
                Text("\(formattedDate), \(shift.startTime.formatted(date: .omitted, time: .shortened))")
                    .font(.headline)
                
                if shift.endTime == nil {
                    Text("Läuft gerade...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("bis \(shift.endTime!.formatted(date: .omitted, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Text(String(format: "%.1f h", liveDuration / 3600))
                .font(.headline)
                .foregroundStyle(shift.endTime == nil ? .green : .primary)
        }
        .padding(.vertical, 8)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func startTimer() {
        guard shift.endTime == nil else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            currentTime = Date.now
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
