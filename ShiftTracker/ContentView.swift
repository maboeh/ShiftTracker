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
    @AppStorage(AppConfiguration.weeklyHoursKey) private var weeklyTargetHours = AppConfiguration.defaultWeeklyHours
    @State private var showExportSheet = false

    var activeShift: Shift? {
        shifts.first(where: { $0.endTime == nil })
    }

    private var shiftState: ShiftState {
        guard let active = activeShift else { return .inactive }
        return active.hasActiveBreak ? .onBreak : .active
    }

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
        if !heute.isEmpty { result.append((AppStrings.heute, heute)) }
        if !gestern.isEmpty { result.append((AppStrings.gestern, gestern)) }
        if !dieseWoche.isEmpty { result.append((AppStrings.dieseWoche, dieseWoche)) }
        if !aelter.isEmpty { result.append((AppStrings.aelter, aelter)) }

        return result
    }

    private var weekStats: (totalHours: Double, overtime: Double) {
        var calendar = Calendar.current
        calendar.firstWeekday = 2

        let now = Date()

        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) else {
            return (0, 0)
        }

        let thisWeekShifts = shifts.filter { shift in
            shift.startTime >= weekInterval.start && shift.startTime < weekInterval.end
        }
        
        let totalSeconds = thisWeekShifts.reduce(0.0) { sum, shift in
            sum + shift.netDuration
        }
        let totalHours = totalSeconds / 3600
        let overtime = totalHours - weeklyTargetHours
        
        return (totalHours, overtime)
    }

    private var weekProgress: Double {
        guard weeklyTargetHours > 0 else { return 0 }
        return min(weekStats.totalHours / weeklyTargetHours, 1.0)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    Section {
                        WeekStatsCard(
                            totalHours: weekStats.totalHours,
                            overtime: weekStats.overtime,
                            progress: weekProgress,
                            targetHours: weeklyTargetHours
                        )
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }

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
                                            Label(AppStrings.loeschen, systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                ActionButton(
                    state: shiftState,
                    onToggleShift: toggleShift,
                    onToggleBreak: toggleBreak
                )
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        NavigationLink {
                            SettingsView()
                        } label: {
                            Image(systemName: "gearshape")
                        }
                        .accessibilityLabel(AppStrings.einstellungen)

                        Button {
                            showExportSheet = true
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .accessibilityLabel(AppStrings.exportTitle)
                        .accessibilityHint(AppStrings.hintExportOeffnen)
                    }
                }

                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text(AppStrings.shiftOverview)
                            .font(.headline)
                        Text("\(AppStrings.welcomeBack)!")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showExportSheet) {
                ExportView()
            }
            .errorAlert()
        }
    }

    private func toggleShift() {
        if activeShift == nil {
            let newShift = Shift(startTime: Date(), endTime: nil)
            modelContext.insert(newShift)
            do {
                try modelContext.save()
                NotificationManager.shared.onShiftStarted()
            } catch {
                modelContext.rollback()
                ErrorHandler.shared.handle(error)
            }
        } else if let current = activeShift {
            if let activeBreak = (current.breaks ?? []).first(where: { $0.isActive }) {
                activeBreak.endTime = Date()
            }
            current.endTime = Date()
            do {
                try modelContext.save()
                NotificationManager.shared.onShiftEnded()
            } catch {
                modelContext.rollback()
                ErrorHandler.shared.handle(error)
            }
        }
    }

    private func toggleBreak() {
        guard let current = activeShift else { return }

        let isEndingBreak = (current.breaks ?? []).contains { $0.isActive }

        if let activeBreak = (current.breaks ?? []).first(where: { $0.isActive }) {
            activeBreak.endTime = Date()
        } else {
            let newBreak = Break(startTime: Date())
            newBreak.shift = current
            modelContext.insert(newBreak)
        }

        do {
            try modelContext.save()
            if isEndingBreak {
                NotificationManager.shared.onBreakEnded(netWorkDurationSoFar: current.netDuration)
            } else {
                NotificationManager.shared.onBreakStarted()
            }
        } catch {
            modelContext.rollback()
            ErrorHandler.shared.handle(error)
        }
    }

    private func deleteShift(_ shift: Shift) {
        withAnimation {
            modelContext.delete(shift)
            do {
                try modelContext.save()
                HapticFeedback.lightImpact()
            } catch {
                modelContext.rollback()
                ErrorHandler.shared.handle(error)
            }
        }
    }
}

#Preview {
    ContentView()
}