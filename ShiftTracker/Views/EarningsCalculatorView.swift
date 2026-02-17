//
//  EarningsCalculatorView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 17.02.26.
//

import SwiftUI

struct EarningsCalculatorView: View {
    let shifts: [Shift]
    @AppStorage("hourlyRate") private var hourlyRate = 0.0

    private var weekShifts: [Shift] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: Date()) else { return [] }
        return shifts.filter { $0.startTime >= interval.start && $0.startTime < interval.end }
    }

    private var monthShifts: [Shift] {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .month, for: Date()) else { return [] }
        return shifts.filter { $0.startTime >= interval.start && $0.startTime < interval.end }
    }

    private var yearShifts: [Shift] {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        guard let start = calendar.date(from: DateComponents(year: year, month: 1, day: 1)),
              let end = calendar.date(from: DateComponents(year: year + 1, month: 1, day: 1)) else { return [] }
        return shifts.filter { $0.startTime >= start && $0.startTime < end }
    }

    var body: some View {
        List {
            Section {
                HStack {
                    Text(AppStrings.stundenlohn)
                    Spacer()
                    TextField("", value: Binding(
                        get: { hourlyRate },
                        set: { hourlyRate = max($0, 0) }
                    ), format: .currency(code: "EUR"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                }
            } footer: {
                Text(AppStrings.stundenlohnInfo)
            }

            if hourlyRate > 0 {
                Section(AppStrings.verdienst) {
                    earningsRow(AppStrings.verdienstDieseWoche, shifts: weekShifts)
                    earningsRow(AppStrings.verdienstDieserMonat, shifts: monthShifts)
                    earningsRow(AppStrings.verdienstDiesesJahr, shifts: yearShifts)
                }

                if !earningsByType.isEmpty {
                    Section(AppStrings.aufschluesselungNachTyp) {
                        ForEach(earningsByType, id: \.name) { entry in
                            LabeledContent(entry.name) {
                                VStack(alignment: .trailing) {
                                    Text(entry.earnings, format: .currency(code: "EUR"))
                                        .fontWeight(.semibold)
                                    Text(String(format: "%.1f h × %.2f €", entry.hours, entry.rate))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(AppStrings.verdienstrechner)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var earningsByType: [(name: String, hours: Double, rate: Double, earnings: Double)] {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .month, for: Date()) else { return [] }
        let monthShifts = shifts.filter { $0.endTime != nil && $0.startTime >= interval.start && $0.startTime < interval.end }

        var grouped: [String: (hours: Double, rate: Double)] = [:]
        for shift in monthShifts {
            let typeName = shift.shiftType?.name ?? AppStrings.keineAuswahl
            let rate = shift.shiftType?.hourlyRate ?? hourlyRate
            let existing = grouped[typeName] ?? (0, rate)
            grouped[typeName] = (existing.hours + shift.netDuration / 3600, rate)
        }

        return grouped.map { (name: $0.key, hours: $0.value.hours, rate: $0.value.rate, earnings: $0.value.hours * $0.value.rate) }
            .sorted { $0.earnings > $1.earnings }
    }

    private func earningsForShifts(_ filteredShifts: [Shift]) -> Double {
        filteredShifts.reduce(0) { sum, shift in
            let rate = shift.shiftType?.hourlyRate ?? hourlyRate
            return sum + (shift.netDuration / 3600) * rate
        }
    }

    private func earningsRow(_ label: String, shifts filteredShifts: [Shift]) -> some View {
        let hours = filteredShifts.reduce(0.0) { $0 + $1.netDuration / 3600 }
        let amount = earningsForShifts(filteredShifts)
        return LabeledContent(label) {
            VStack(alignment: .trailing) {
                Text(amount, format: .currency(code: "EUR"))
                    .fontWeight(.semibold)
                Text(String(format: "%.1f h", hours))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
