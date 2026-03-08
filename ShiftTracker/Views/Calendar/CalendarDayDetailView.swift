//
//  CalendarDayDetailView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 07.03.26.
//

import SwiftUI
import SwiftData

struct CalendarDayDetailView: View {
    let date: Date
    let refreshID: UUID

    @Environment(\.modelContext) private var modelContext

    @State private var dayShifts: [Shift] = []
    @State private var dayPlannedShifts: [PlannedShift] = []
    @State private var editingPlanned: PlannedShift?

    private let calendar: Calendar = {
        var cal = Calendar.current
        cal.firstWeekday = 2
        return cal
    }()

    private var dateTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }

    var body: some View {
        List {
            Section {
                Text(dateTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
            }

            if !dayPlannedShifts.isEmpty {
                Section(AppStrings.geplant) {
                    ForEach(dayPlannedShifts, id: \.persistentModelID) { planned in
                        PlannedShiftRow(planned: planned)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editingPlanned = planned
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deletePlannedShift(planned)
                                } label: {
                                    Label(AppStrings.loeschen, systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                if !planned.isLinked {
                                    Button {
                                        startFromPlanned(planned)
                                    } label: {
                                        Label(AppStrings.jetztStarten, systemImage: "play.fill")
                                    }
                                    .tint(.green)
                                }
                            }
                    }
                }
            }

            if !dayShifts.isEmpty {
                Section(AppStrings.erfasst) {
                    ForEach(dayShifts, id: \.persistentModelID) { shift in
                        NavigationLink {
                            ShiftDetailView(shift: shift)
                        } label: {
                            ShiftRow(shift: shift)
                        }
                    }
                }
            }

            if dayShifts.isEmpty && dayPlannedShifts.isEmpty {
                Section {
                    Text(AppStrings.keineSchichtenAnTag)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .listStyle(.insetGrouped)
        .sheet(item: $editingPlanned, onDismiss: {
            loadData()
        }) { planned in
            NavigationStack {
                PlannedShiftEditView(editing: planned)
            }
        }
        .task(id: DayDetailKey(date: calendar.startOfDay(for: date), refreshID: refreshID)) {
            loadData()
        }
    }

    private func loadData() {
        let shiftService = ShiftService(modelContext: modelContext)
        let plannedService = PlannedShiftService(modelContext: modelContext)
        let dayStart = calendar.startOfDay(for: date)
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { return }
        do {
            dayShifts = try shiftService.fetchShifts(in: DateInterval(start: dayStart, end: dayEnd))
            dayPlannedShifts = try plannedService.fetchPlannedShifts(for: date)
        } catch {
            ErrorHandler.shared.handle(error)
        }
    }

    private func deletePlannedShift(_ planned: PlannedShift) {
        let service = PlannedShiftService(modelContext: modelContext)
        do {
            try service.deletePlannedShift(planned)
            loadData()
            HapticFeedback.lightImpact()
        } catch {
            ErrorHandler.shared.handle(error)
        }
    }

    private func startFromPlanned(_ planned: PlannedShift) {
        let shiftService = ShiftService(modelContext: modelContext)
        let plannedService = PlannedShiftService(modelContext: modelContext)
        do {
            try plannedService.convertToShift(planned, shiftService: shiftService)
            NotificationManager.shared.onShiftStarted()
            loadData()
            HapticFeedback.success()
        } catch {
            ErrorHandler.shared.handle(error)
        }
    }
}

private struct DayDetailKey: Equatable {
    let date: Date
    let refreshID: UUID
}

// MARK: - Planned Shift Row

private struct PlannedShiftRow: View {
    let planned: PlannedShift

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(planned.shiftType?.color ?? .gray)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(planned.shiftType?.name ?? AppStrings.schicht)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(planned.formattedTimeRange)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if planned.isLinked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.caption)
            } else if planned.isAutoStartEnabled {
                Image(systemName: "bolt.circle")
                    .foregroundStyle(.orange)
                    .font(.caption)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
