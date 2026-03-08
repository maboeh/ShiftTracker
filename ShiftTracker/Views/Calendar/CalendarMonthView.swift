//
//  CalendarMonthView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 07.03.26.
//

import SwiftUI
import SwiftData

struct CalendarMonthView: View {
    @Binding var selectedDate: Date
    @Binding var displayedMonth: Date
    let refreshID: UUID

    @Environment(\.modelContext) private var modelContext
    @State private var monthShifts: [Shift] = []
    @State private var monthPlannedShifts: [PlannedShift] = []

    private let calendar: Calendar = {
        var cal = Calendar.current
        cal.firstWeekday = 2
        return cal
    }()

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdaySymbols: [String] = {
        var cal = Calendar.current
        cal.firstWeekday = 2
        let symbols = cal.shortWeekdaySymbols
        // Reorder starting from Monday
        let mondayIndex = cal.firstWeekday - 1
        return Array(symbols[mondayIndex...]) + Array(symbols[..<mondayIndex])
    }()

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: displayedMonth)
    }

    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday else {
            return []
        }

        // Calculate offset for the first day (Monday = 0)
        let offset = (firstWeekday - calendar.firstWeekday + 7) % 7

        let daysCount = calendar.range(of: .day, in: .month, for: displayedMonth)?.count ?? 30
        var days: [Date?] = Array(repeating: nil, count: offset)

        for day in 0..<daysCount {
            if let date = calendar.date(byAdding: .day, value: day, to: monthInterval.start) {
                days.append(date)
            }
        }

        return days
    }

    private func shiftsForDay(_ date: Date) -> [Shift] {
        monthShifts.filter { calendar.isDate($0.startTime, inSameDayAs: date) }
    }

    private func plannedShiftsForDay(_ date: Date) -> [PlannedShift] {
        let dayStart = calendar.startOfDay(for: date)
        return monthPlannedShifts.filter { $0.plannedDate == dayStart }
    }

    var body: some View {
        VStack(spacing: 8) {
            // Month navigation
            HStack {
                Button {
                    withAnimation {
                        displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                }

                Spacer()

                Text(monthTitle)
                    .font(.headline)

                Spacer()

                Button {
                    withAnimation {
                        displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)

            // Weekday headers
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 8)

            // Day grid
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                    if let date {
                        DayCellView(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            shifts: shiftsForDay(date),
                            plannedShifts: plannedShiftsForDay(date)
                        )
                        .onTapGesture {
                            selectedDate = date
                        }
                    } else {
                        Color.clear
                            .frame(height: 44)
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(.bottom, 8)
        .task(id: DisplayedMonthKey(month: displayedMonth, refreshID: refreshID)) {
            loadData()
        }
    }

    private func loadData() {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth) else { return }
        let shiftService = ShiftService(modelContext: modelContext)
        let plannedService = PlannedShiftService(modelContext: modelContext)
        do {
            monthShifts = try shiftService.fetchShifts(in: monthInterval)
            monthPlannedShifts = try plannedService.fetchPlannedShifts(in: monthInterval)
        } catch {
            ErrorHandler.shared.handle(error)
        }
    }
}

private struct DisplayedMonthKey: Equatable {
    let month: Date
    let refreshID: UUID
}

// MARK: - Day Cell

private struct DayCellView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let shifts: [Shift]
    let plannedShifts: [PlannedShift]

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(spacing: 2) {
            Text(dayNumber)
                .font(.subheadline)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundStyle(isSelected ? .white : isToday ? .blue : .primary)
                .frame(width: 32, height: 32)
                .background {
                    if isSelected {
                        Circle().fill(.blue)
                    } else if isToday {
                        Circle().strokeBorder(.blue, lineWidth: 1.5)
                    }
                }

            // Shift indicators
            HStack(spacing: 2) {
                ForEach(shifts.prefix(3), id: \.persistentModelID) { shift in
                    Circle()
                        .fill(shift.shiftType?.color ?? .gray)
                        .frame(width: 5, height: 5)
                }
                ForEach(plannedShifts.prefix(3), id: \.persistentModelID) { planned in
                    Circle()
                        .strokeBorder(planned.shiftType?.color ?? .gray, lineWidth: 1)
                        .frame(width: 5, height: 5)
                }
            }
            .frame(height: 6)
        }
        .frame(height: 44)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(dayNumber), \(shifts.count) Schichten, \(plannedShifts.count) geplant")
    }
}
