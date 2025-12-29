//
//  ContentView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 14.12.25.
//
//
//  ContentView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 14.12.25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \Shift.startTime, order: .reverse) var shifts: [Shift]
    @Environment(\.modelContext) private var modelContext
    
    var activeShift: Shift? {
        shifts.first(where: { $0.endTime == nil })
    }
    
    // Gruppierte Shifts
    private var groupedShifts: [(String, [Shift])] {
        let calendar = Calendar.current
        let now = Date()
        
        var heute: [Shift] = []
        var gestern: [Shift] = []
        var dieseWoche: [Shift] = []
        var aelter: [Shift] = []
        
        for shift in shifts {
            if calendar.isDateInToday(shift.startTime) {
                heute.append(shift)
            } else if calendar.isDateInYesterday(shift.startTime) {
                gestern.append(shift)
            } else if calendar.isDate(shift.startTime, equalTo: now, toGranularity: .weekOfYear) {
                dieseWoche.append(shift)
            } else {
                aelter.append(shift)
            }
        }
        
        var result: [(String, [Shift])] = []
        if !heute.isEmpty { result.append(("Heute", heute)) }
        if !gestern.isEmpty { result.append(("Gestern", gestern)) }
        if !dieseWoche.isEmpty { result.append(("Diese Woche", dieseWoche)) }
        if !aelter.isEmpty { result.append(("Älter", aelter)) }
        
        return result
    }
    
    // Statistiken für diese Woche
    private var weekStats: (totalHours: Double, overtime: Double) {
        let calendar = Calendar.current
        let now = Date()
        
        let thisWeekShifts = shifts.filter { shift in
            calendar.isDate(shift.startTime, equalTo: now, toGranularity: .weekOfYear)
        }
        
        let totalSeconds = thisWeekShifts.reduce(0.0) { sum, shift in
            sum + shift.duration
        }
        let totalHours = totalSeconds / 3600
        let targetHours = 40.0
        let overtime = totalHours - targetHours
        
        return (totalHours, overtime)
    }

    private var weekProgress: Double {
        let targetHours = 40.0
        return min(weekStats.totalHours / targetHours, 1.0)
    }
    
    var body: some View {
        NavigationStack {
            // NEU: VStack um List + Button zu kombinieren
            VStack(spacing: 0) {
                // Die Liste (wie gehabt)
                List {
                    Section {
                        WeekStatsCard(
                            totalHours: weekStats.totalHours,
                            overtime: weekStats.overtime,
                            progress: weekProgress
                        )
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                    
                    ForEach(groupedShifts, id: \.0) { section in
                        Section(section.0) {
                            ForEach(section.1) { shift in
                                NavigationLink {
                                    ShiftDetailView(shift: shift)
                                } label: {
                                    ShiftRow(shift: shift)
                                }
                            }
                            .onDelete { indexSet in
                                deleteShifts(in: section.1, at: indexSet)
                            }
                        }
                    }
                }
                
                // NEU: Großer Action-Button am unteren Rand
                ActionButton(
                    isActive: activeShift != nil,
                    action: toggleShift
                )
            }
            // NEU: Personalisierte Toolbar
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text("Schichtübersicht")
                            .font(.headline)
                        Text("Willkommen zurück, Matthias")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
    
    // NEU: Ausgelagerte Toggle-Funktion (sauberer Code!)
    private func toggleShift() {
        if activeShift == nil {
            // Neuen Shift erstellen
            let newShift = Shift(startTime: Date(), endTime: nil)
            modelContext.insert(newShift)
        } else {
            // Aktiven Shift beenden
            activeShift!.endTime = Date()
        }
    }
    
    private func deleteShifts(in shifts: [Shift], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(shifts[index])
        }
    }
}

#Preview {
    ContentView()
}


