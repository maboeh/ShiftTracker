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

    private var thisWeekHours: Double {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: Date()) else { return 0 }
        return shifts
            .filter { $0.startTime >= interval.start && $0.startTime < interval.end }
            .reduce(0) { $0 + $1.netDuration / 3600 }
    }

    private var thisMonthHours: Double {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .month, for: Date()) else { return 0 }
        return shifts
            .filter { $0.startTime >= interval.start && $0.startTime < interval.end }
            .reduce(0) { $0 + $1.netDuration / 3600 }
    }

    private var thisYearHours: Double {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        guard let start = calendar.date(from: DateComponents(year: year, month: 1, day: 1)),
              let end = calendar.date(from: DateComponents(year: year + 1, month: 1, day: 1)) else { return 0 }
        return shifts
            .filter { $0.startTime >= start && $0.startTime < end }
            .reduce(0) { $0 + $1.netDuration / 3600 }
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
                    earningsRow(AppStrings.verdienstDieseWoche, hours: thisWeekHours)
                    earningsRow(AppStrings.verdienstDieserMonat, hours: thisMonthHours)
                    earningsRow(AppStrings.verdienstDiesesJahr, hours: thisYearHours)
                }
            }
        }
        .navigationTitle(AppStrings.verdienstrechner)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func earningsRow(_ label: String, hours: Double) -> some View {
        LabeledContent(label) {
            VStack(alignment: .trailing) {
                Text(hours * hourlyRate, format: .currency(code: "EUR"))
                    .fontWeight(.semibold)
                Text(String(format: "%.1f h", hours))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
