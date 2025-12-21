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
    @State private var timer: Timer?  // NEU: Timer-Referenz
    
    private var liveDuration: TimeInterval {
        if shift.endTime == nil {
            return currentTime.timeIntervalSince(shift.startTime)
        
        }else{
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
            Text(String(format: "%.1f h", liveDuration / 3600))
                .font(.headline)
                .foregroundStyle(shift.endTime == nil ? .green : .primary)
        }
        .padding(.vertical, 8)
        .onAppear(){
            startTimer()
        }
        .onDisappear{
            stopTimer()
        }
    }
    
    // NEU: Timer-Funktionen
        private func startTimer() {
            // Nur für aktive Shifts
            guard shift.endTime == nil else { return }
            
            // Erstelle Timer der jede Sekunde feuert
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                currentTime = Date.now  // Update die Zeit
            }
        }
        
        private func stopTimer() {
            timer?.invalidate()  // Stoppe den Timer
            timer = nil          // Lösche die Referenz
        }
    }

