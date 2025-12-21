//
//  ShiftRow.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 20.12.25.
//

import SwiftUI

struct ShiftRow: View {
    let shift: Shift
    
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
            // 1. STATUS ICON (links)
            Image(systemName: shift.endTime == nil ? "clock.fill" : "checkmark.circle.fill")
                .foregroundStyle(shift.endTime == nil ? .green : .blue)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                // Datum + Uhrzeit zusammen
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
            
            Spacer()  // ← Schiebt alles nach links, Duration nach rechts
            
            // 3. DURATION (rechts)
            Text(String(format: "%.1f h", shift.duration / 3600))
                .font(.headline)
                .foregroundStyle(shift.endTime == nil ? .green : .primary)
        }
        .padding(.vertical, 8)  // Mehr Höhe für die Row
    }
}
