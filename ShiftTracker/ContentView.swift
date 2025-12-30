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

    private var weekStats: (totalHours: Double, overtime: Double) {
        var calendar = Calendar.current
        calendar.firstWeekday = 2  // 2 = Montag (1 = Sonntag)
        
        let now = Date()
        
        // Montag dieser Woche (00:00 Uhr)
        guard let mondayStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start else {
            return (0, 0)
        }
        
        // Sonntag 00:00 = Ende von Samstag für Filter
        guard let sundayStart = calendar.date(byAdding: .day, value: 6, to: mondayStart) else {
            return (0, 0)
        }
        
        // Shifts zwischen Montag und Samstag
        let thisWeekShifts = shifts.filter { shift in
            shift.startTime >= mondayStart && shift.startTime < sundayStart
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
            VStack(spacing: 0) {
                List {
                    // WeekStats (immer da)
                    Section {
                        WeekStatsCard(
                            totalHours: weekStats.totalHours,
                            overtime: weekStats.overtime,
                            progress: weekProgress
                        )
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }

                    // Empty State ODER Shift-Liste
                    if groupedShifts.isEmpty {
                        Section {
                            EmptyStateView()
                                .transition(.opacity.combined(with: .scale))
                        }
                    } else {
                        ForEach(groupedShifts, id: \.0) { section in
                            Section(section.0) {
                                ForEach(section.1) { shift in
                                    NavigationLink {
                                        ShiftDetailView(shift: shift)
                                    } label: {
                                        ShiftRow(shift: shift)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            deleteShift(shift)
                                        } label: {
                                            Label("Löschen", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Großer Action-Button am unteren Rand
                ActionButton(
                    isActive: activeShift != nil,
                    action: toggleShift
                )
            }
            .toolbar {
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

    private func toggleShift() {
        if activeShift == nil {
            let newShift = Shift(startTime: Date(), endTime: nil)
            modelContext.insert(newShift)
            try? modelContext.save()
        } else if let current = activeShift {
            current.endTime = Date()
            try? modelContext.save()
        }
    }

    private func deleteShift(_ shift: Shift) {
        withAnimation {
            modelContext.delete(shift)
            try? modelContext.save()
        }
    }
}

#Preview {
    ContentView()
}

