//
//  StatsView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 17.02.26.
//

import Charts
import SwiftUI
import SwiftData

// MARK: - Data Models

struct WeeklyData: Identifiable {
    let id = UUID()
    let weekStart: Date
    let hours: Double
    let breakMinutes: Double
}

struct MonthlyData: Identifiable {
    let id = UUID()
    let month: Date
    let hours: Double
    let shiftCount: Int
}

// MARK: - Stats Overview

struct StatsView: View {
    @Query(sort: \Shift.startTime, order: .reverse) var shifts: [Shift]

    var body: some View {
        List {
            if shifts.isEmpty {
                ContentUnavailableView(
                    AppStrings.keineStatistiken,
                    systemImage: "chart.bar",
                    description: Text(AppStrings.keineStatistikenInfo)
                )
            } else {
                Section {
                    NavigationLink {
                        MonthlyStatsView(shifts: shifts)
                    } label: {
                        Label(AppStrings.monatsUebersicht, systemImage: "calendar")
                    }

                    NavigationLink {
                        YearlyStatsView(shifts: shifts)
                    } label: {
                        Label(AppStrings.jahresUebersicht, systemImage: "chart.bar.fill")
                    }

                    NavigationLink {
                        EarningsCalculatorView(shifts: shifts)
                    } label: {
                        Label(AppStrings.verdienstrechner, systemImage: "eurosign.circle")
                    }
                }
            }
        }
        .navigationTitle(AppStrings.statistiken)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Monthly Stats (Wochen im aktuellen Monat)

struct MonthlyStatsView: View {
    let shifts: [Shift]
    @AppStorage(AppConfiguration.weeklyHoursKey) private var weeklyTarget = AppConfiguration.defaultWeeklyHours

    private var weeklyData: [WeeklyData] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2

        let now = Date()
        guard let monthInterval = calendar.dateInterval(of: .month, for: now) else { return [] }

        let monthShifts = shifts.filter {
            $0.endTime != nil && $0.startTime >= monthInterval.start && $0.startTime < monthInterval.end
        }

        var grouped: [Date: (hours: Double, breakMinutes: Double)] = [:]

        for shift in monthShifts {
            guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: shift.startTime)?.start else { continue }
            let existing = grouped[weekStart] ?? (0, 0)
            grouped[weekStart] = (
                existing.hours + shift.netDuration / 3600,
                existing.breakMinutes + shift.totalBreakDuration / 60
            )
        }

        return grouped.map { WeeklyData(weekStart: $0.key, hours: $0.value.hours, breakMinutes: $0.value.breakMinutes) }
            .sorted { $0.weekStart < $1.weekStart }
    }

    private var totalHours: Double {
        weeklyData.reduce(0) { $0 + $1.hours }
    }

    var body: some View {
        List {
            Section {
                Chart(weeklyData) { data in
                    BarMark(
                        x: .value("KW", data.weekStart, unit: .weekOfYear),
                        y: .value(AppStrings.stunden, data.hours)
                    )
                    .foregroundStyle(.blue.gradient)

                    RuleMark(y: .value("Ziel", weeklyTarget))
                        .foregroundStyle(.orange)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 3]))
                }
                .chartYAxisLabel(AppStrings.stunden)
                .frame(height: 220)
            } header: {
                Text(AppStrings.stundenProWoche)
            }

            Section(AppStrings.zusammenfassung) {
                LabeledContent(AppStrings.gesamtStunden) {
                    Text(String(format: "%.1f h", totalHours))
                }
                LabeledContent(AppStrings.durchschnitt) {
                    let avg = weeklyData.isEmpty ? 0 : totalHours / Double(weeklyData.count)
                    Text(String(format: "%.1f h / %@", avg, AppStrings.woche))
                }
            }
        }
        .navigationTitle(AppStrings.monatsUebersicht)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Yearly Stats (Monate im aktuellen Jahr)

struct YearlyStatsView: View {
    let shifts: [Shift]

    private var monthlyData: [MonthlyData] {
        let calendar = Calendar.current
        let now = Date()
        let year = calendar.component(.year, from: now)

        guard let yearStart = calendar.date(from: DateComponents(year: year, month: 1, day: 1)),
              let yearEnd = calendar.date(from: DateComponents(year: year + 1, month: 1, day: 1)) else { return [] }

        let yearShifts = shifts.filter {
            $0.endTime != nil && $0.startTime >= yearStart && $0.startTime < yearEnd
        }

        var grouped: [Int: (hours: Double, count: Int)] = [:]

        for shift in yearShifts {
            let month = calendar.component(.month, from: shift.startTime)
            let existing = grouped[month] ?? (0, 0)
            grouped[month] = (existing.hours + shift.netDuration / 3600, existing.count + 1)
        }

        return grouped.compactMap { month, data in
            guard let date = calendar.date(from: DateComponents(year: year, month: month, day: 1)) else { return nil }
            return MonthlyData(month: date, hours: data.hours, shiftCount: data.count)
        }
        .sorted { $0.month < $1.month }
    }

    private var totalHours: Double {
        monthlyData.reduce(0) { $0 + $1.hours }
    }

    private var totalShifts: Int {
        monthlyData.reduce(0) { $0 + $1.shiftCount }
    }

    var body: some View {
        List {
            Section {
                Chart(monthlyData) { data in
                    BarMark(
                        x: .value("Monat", data.month, unit: .month),
                        y: .value(AppStrings.stunden, data.hours)
                    )
                    .foregroundStyle(.green.gradient)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .month)) { value in
                        AxisValueLabel(format: .dateTime.month(.abbreviated))
                    }
                }
                .chartYAxisLabel(AppStrings.stunden)
                .frame(height: 220)
            } header: {
                Text(AppStrings.stundenProMonat)
            }

            Section(AppStrings.zusammenfassung) {
                LabeledContent(AppStrings.gesamtStunden) {
                    Text(String(format: "%.1f h", totalHours))
                }
                LabeledContent(AppStrings.anzahlSchichten) {
                    Text("\(totalShifts)")
                }
                LabeledContent(AppStrings.durchschnitt) {
                    let avg = monthlyData.isEmpty ? 0 : totalHours / Double(monthlyData.count)
                    Text(String(format: "%.1f h / %@", avg, AppStrings.monat))
                }
            }
        }
        .navigationTitle(AppStrings.jahresUebersicht)
        .navigationBarTitleDisplayMode(.inline)
    }
}
