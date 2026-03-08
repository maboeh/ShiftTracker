//
//  CalendarWeekView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 07.03.26.
//

import SwiftUI
import SwiftData

struct CalendarWeekView: View {
    @Binding var selectedDate: Date
    let refreshID: UUID

    @Environment(\.modelContext) private var modelContext
    @State private var weekShifts: [Shift] = []
    @State private var weekPlannedShifts: [PlannedShift] = []

    private let calendar: Calendar = {
        var cal = Calendar.current
        cal.firstWeekday = 2
        return cal
    }()

    private var weekDays: [Date] {
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekInterval.start) }
    }

    private func shiftsForDay(_ date: Date) -> [Shift] {
        weekShifts.filter { calendar.isDate($0.startTime, inSameDayAs: date) }
    }

    private func plannedShiftsForDay(_ date: Date) -> [PlannedShift] {
        let dayStart = calendar.startOfDay(for: date)
        return weekPlannedShifts.filter { $0.plannedDate == dayStart }
    }

    private var currentWeekStart: Date {
        calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
    }

    var body: some View {
        VStack(spacing: 0) {
            // Week navigation
            HStack {
                Button {
                    withAnimation {
                        selectedDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                }

                Spacer()

                Text(weekTitle)
                    .font(.headline)

                Spacer()

                Button {
                    withAnimation {
                        selectedDate = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Day columns
            ScrollView(.vertical, showsIndicators: false) {
                HStack(alignment: .top, spacing: 2) {
                    ForEach(weekDays, id: \.self) { day in
                        WeekDayColumn(
                            date: day,
                            isSelected: calendar.isDate(day, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(day),
                            shifts: shiftsForDay(day),
                            plannedShifts: plannedShiftsForDay(day)
                        )
                        .onTapGesture {
                            selectedDate = day
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            .frame(maxHeight: 200)
        }
        .task(id: WeekViewKey(weekStart: currentWeekStart, refreshID: refreshID)) {
            loadData()
        }
    }

    private func loadData() {
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else { return }
        let shiftService = ShiftService(modelContext: modelContext)
        let plannedService = PlannedShiftService(modelContext: modelContext)
        do {
            weekShifts = try shiftService.fetchShifts(in: weekInterval)
            weekPlannedShifts = try plannedService.fetchPlannedShifts(in: weekInterval)
        } catch {
            ErrorHandler.shared.handle(error)
        }
    }

    private var weekTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "d. MMM"

        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else { return "" }
        let endDate = calendar.date(byAdding: .day, value: 6, to: weekInterval.start) ?? weekInterval.end
        return "\(formatter.string(from: weekInterval.start)) – \(formatter.string(from: endDate))"
    }
}

private struct WeekViewKey: Equatable {
    let weekStart: Date
    let refreshID: UUID
}

// MARK: - Week Day Column

private struct WeekDayColumn: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let shifts: [Shift]
    let plannedShifts: [PlannedShift]

    private let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "de_DE")
        f.dateFormat = "E"
        return f
    }()

    private let numberFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f
    }()

    var body: some View {
        VStack(spacing: 4) {
            // Day header
            VStack(spacing: 2) {
                Text(dayFormatter.string(from: date))
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Text(numberFormatter.string(from: date))
                    .font(.caption)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundStyle(isSelected ? .white : isToday ? .blue : .primary)
                    .frame(width: 24, height: 24)
                    .background {
                        if isSelected {
                            Circle().fill(.blue)
                        }
                    }
            }

            // Shift blocks
            ForEach(shifts.prefix(3), id: \.persistentModelID) { shift in
                ShiftBlockView(
                    color: shift.shiftType?.color ?? .gray,
                    timeText: formatTime(shift.startTime),
                    isFilled: true
                )
            }

            ForEach(plannedShifts.prefix(3), id: \.persistentModelID) { planned in
                ShiftBlockView(
                    color: planned.shiftType?.color ?? .gray,
                    timeText: formatTime(planned.startTime),
                    isFilled: false
                )
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func formatTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH"
        return f.string(from: date)
    }
}

private struct ShiftBlockView: View {
    let color: Color
    let timeText: String
    let isFilled: Bool

    var body: some View {
        Text(timeText)
            .font(.system(size: 9))
            .foregroundStyle(isFilled ? .white : color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 3)
            .background {
                if isFilled {
                    RoundedRectangle(cornerRadius: 3).fill(color)
                } else {
                    RoundedRectangle(cornerRadius: 3).strokeBorder(color, lineWidth: 1)
                }
            }
    }
}
