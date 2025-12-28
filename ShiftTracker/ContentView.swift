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
    
    // NEU: Gruppierte Shifts
    private var groupedShifts: [(String, [Shift])] {
        let calendar = Calendar.current
        let now = Date()
        
        // Gruppierung
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
        
        // Nur nicht-leere Gruppen zurückgeben
        var result: [(String, [Shift])] = []
        if !heute.isEmpty { result.append(("Heute", heute)) }
        if !gestern.isEmpty { result.append(("Gestern", gestern)) }
        if !dieseWoche.isEmpty { result.append(("Diese Woche", dieseWoche)) }
        if !aelter.isEmpty { result.append(("Älter", aelter)) }
        
        return result
    }
    
    // NEU: Statistiken für diese Woche
    private var weekStats: (totalHours: Double, overtime: Double) {
        let calendar = Calendar.current
        let now = Date()
        
        // Alle Shifts dieser Woche (inkl. heute)
        let thisWeekShifts = shifts.filter { shift in
            calendar.isDate(shift.startTime, equalTo: now, toGranularity: .weekOfYear)
        }
        
        // Gesamtstunden berechnen
        let totalSeconds = thisWeekShifts.reduce(0.0) { sum, shift in
            sum + shift.duration
        }
        let totalHours = totalSeconds / 3600
        
        // Überstunden = Alles über 40h
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
            List {
                Section {
                               WeekStatsCard(
                                   totalHours: weekStats.totalHours,
                                   overtime: weekStats.overtime,
                                   progress: weekProgress
                               )
                               .listRowInsets(EdgeInsets())  // Entfernt Standard-Padding
                               .listRowBackground(Color.clear)  // Transparenter Hintergrund
                           }
                ForEach(groupedShifts, id: \.0) { section in
                    Section(section.0) {  // section.0 = "Heute", "Gestern", etc.
                        ForEach(section.1) { shift in  // section.1 = Array von Shifts
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
            .navigationTitle("My Shifts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing){
                    Button("\(activeShift == nil ? "Einstempeln" : "Ausstempeln")") {
                        if activeShift == nil {
                            // NEUEN Shift ERSTELLEN und zur DB hinzufügen!
                            let newShift = Shift(startTime: Date(), endTime: nil)
                            modelContext.insert(newShift)
                        } else {
                            // Existierenden Shift MODIFIZIEREN
                            activeShift!.endTime = Date()
                        }
                    }
                }
                ToolbarItem(placement: .topBarLeading){
                    EditButton()
                }
                
                
                
                
            }
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

