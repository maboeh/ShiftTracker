//
//  PlannedShiftEditView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 07.03.26.
//

import SwiftUI
import SwiftData

struct PlannedShiftEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query var shiftTypes: [ShiftType]

    @State private var date: Date
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var selectedShiftType: ShiftType?
    @State private var isAutoStartEnabled: Bool
    @State private var reminderMinutes: Int
    @State private var notes: String

    private let editingPlanned: PlannedShift?

    init(initialDate: Date = Date()) {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: initialDate)
        let defaultStart = calendar.date(bySettingHour: 6, minute: 0, second: 0, of: dayStart) ?? dayStart
        let defaultEnd = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: dayStart) ?? dayStart

        self.editingPlanned = nil
        _date = State(initialValue: initialDate)
        _startTime = State(initialValue: defaultStart)
        _endTime = State(initialValue: defaultEnd)
        _selectedShiftType = State(initialValue: nil)
        _isAutoStartEnabled = State(initialValue: false)
        _reminderMinutes = State(initialValue: 30)
        _notes = State(initialValue: "")
    }

    init(editing planned: PlannedShift) {
        self.editingPlanned = planned
        _date = State(initialValue: planned.plannedDate)
        _startTime = State(initialValue: planned.startTime)
        _endTime = State(initialValue: planned.endTime)
        _selectedShiftType = State(initialValue: planned.shiftType)
        _isAutoStartEnabled = State(initialValue: planned.isAutoStartEnabled)
        _reminderMinutes = State(initialValue: planned.reminderMinutesBefore)
        _notes = State(initialValue: planned.notes)
    }

    private var isEditing: Bool { editingPlanned != nil }

    var body: some View {
        Form {
            Section {
                DatePicker(AppStrings.datum, selection: $date, displayedComponents: .date)
                DatePicker(AppStrings.startzeit, selection: $startTime, displayedComponents: .hourAndMinute)
                DatePicker(AppStrings.endzeit, selection: $endTime, displayedComponents: .hourAndMinute)
            }

            Section {
                Picker(AppStrings.schichtTyp, selection: $selectedShiftType) {
                    Text(AppStrings.keineErinnerung).tag(ShiftType?.none)
                    ForEach(shiftTypes, id: \.persistentModelID) { type in
                        HStack {
                            Circle()
                                .fill(type.color)
                                .frame(width: 10, height: 10)
                            Text(type.name)
                        }
                        .tag(ShiftType?.some(type))
                    }
                }
            }

            Section {
                Toggle(AppStrings.autoStart, isOn: $isAutoStartEnabled)

                Picker(AppStrings.erinnerungVorSchicht, selection: $reminderMinutes) {
                    Text(AppStrings.keineErinnerung).tag(0)
                    Text(AppStrings.minVorher15).tag(15)
                    Text(AppStrings.minVorher30).tag(30)
                    Text(AppStrings.minVorher60).tag(60)
                }
            } footer: {
                if isAutoStartEnabled {
                    Text(AppStrings.autoStartInfo)
                }
            }

            Section {
                TextField(AppStrings.notizen, text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            }
        }
        .navigationTitle(isEditing ? AppStrings.geplanteSchichtBearbeiten : AppStrings.neueGeplanteSchicht)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(AppStrings.abbrechen) {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(AppStrings.speichern) {
                    save()
                }
            }
        }
    }

    private func save() {
        let service = PlannedShiftService(modelContext: modelContext)
        let calendar = Calendar.current

        // Combine date with time components
        let dayStart = calendar.startOfDay(for: date)
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        let actualStart = calendar.date(bySettingHour: startComponents.hour ?? 0, minute: startComponents.minute ?? 0, second: 0, of: dayStart) ?? startTime
        var actualEnd = calendar.date(bySettingHour: endComponents.hour ?? 0, minute: endComponents.minute ?? 0, second: 0, of: dayStart) ?? endTime
        if actualEnd <= actualStart {
            actualEnd = actualEnd.addingTimeInterval(24 * 3600)
        }

        do {
            if let editing = editingPlanned {
                editing.plannedDate = dayStart
                editing.startTime = actualStart
                editing.endTime = actualEnd
                editing.shiftType = selectedShiftType
                editing.isAutoStartEnabled = isAutoStartEnabled
                editing.reminderMinutesBefore = reminderMinutes
                editing.notes = notes
                try service.updatePlannedShift(editing)
            } else {
                try service.createPlannedShift(
                    date: dayStart,
                    startTime: actualStart,
                    endTime: actualEnd,
                    shiftType: selectedShiftType,
                    reminderMinutesBefore: reminderMinutes,
                    isAutoStartEnabled: isAutoStartEnabled
                )
            }
            HapticFeedback.success()
            dismiss()
        } catch {
            ErrorHandler.shared.handle(error)
        }
    }
}
