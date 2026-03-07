//
//  ShiftPatternEditView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 07.03.26.
//

import SwiftUI
import SwiftData

struct ShiftPatternEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query var shiftTypes: [ShiftType]

    @State private var name: String
    @State private var startDate: Date
    @State private var cycleEntries: [PatternDayEntry]
    @State private var weeksToGenerate: Int = 4
    @State private var isActive: Bool

    private let editingPattern: ShiftPattern?

    init() {
        self.editingPattern = nil
        _name = State(initialValue: "")
        _startDate = State(initialValue: Date())
        _cycleEntries = State(initialValue: [
            PatternDayEntry(startHour: 6, startMinute: 0, endHour: 14, endMinute: 0),
        ])
        _isActive = State(initialValue: true)
    }

    init(editing pattern: ShiftPattern) {
        self.editingPattern = pattern
        _name = State(initialValue: pattern.name)
        _startDate = State(initialValue: pattern.startDate)
        _cycleEntries = State(initialValue: pattern.cycleEntries)
        _isActive = State(initialValue: pattern.isActive)
    }

    private var isEditing: Bool { editingPattern != nil }

    var body: some View {
        Form {
            Section {
                TextField(AppStrings.musterName, text: $name)
                DatePicker(AppStrings.startDatum, selection: $startDate, displayedComponents: .date)
                Toggle(AppStrings.aktiv, isOn: $isActive)
            }

            Section {
                ForEach(Array(cycleEntries.enumerated()), id: \.element.id) { index, entry in
                    CycleDayRow(
                        entry: $cycleEntries[index],
                        dayNumber: index + 1,
                        shiftTypes: shiftTypes
                    )
                }
                .onDelete { indexSet in
                    cycleEntries.remove(atOffsets: indexSet)
                }

                Button {
                    cycleEntries.append(PatternDayEntry())
                } label: {
                    Label(AppStrings.tagHinzufuegen, systemImage: "plus.circle")
                }
            } header: {
                Text("\(AppStrings.tageImZyklus) (\(cycleEntries.count))")
            }

            if isEditing {
                Section {
                    Stepper("\(AppStrings.wochenVoraus): \(weeksToGenerate)", value: $weeksToGenerate, in: 1...12)

                    Button {
                        generateShifts()
                    } label: {
                        Label(AppStrings.musterErweitern, systemImage: "calendar.badge.plus")
                    }

                    Button(role: .destructive) {
                        clearFuture()
                    } label: {
                        Label(AppStrings.zukunftLoeschen, systemImage: "trash")
                    }
                }
            } else {
                Section {
                    Stepper("\(AppStrings.wochenVoraus): \(weeksToGenerate)", value: $weeksToGenerate, in: 1...12)
                }
            }
        }
        .navigationTitle(isEditing ? AppStrings.musterBearbeiten : AppStrings.neuesMuster)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(AppStrings.abbrechen) { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(AppStrings.speichern) { save() }
                    .disabled(name.isEmpty || cycleEntries.isEmpty)
            }
        }
    }

    private func save() {
        let service = ShiftPatternService(modelContext: modelContext)

        do {
            if let editing = editingPattern {
                editing.name = name
                editing.startDate = Calendar.current.startOfDay(for: startDate)
                editing.cycleEntries = cycleEntries
                editing.isActive = isActive
                try service.updatePattern(editing)
            } else {
                let pattern = try service.createPattern(
                    name: name,
                    startDate: startDate,
                    cycleEntries: cycleEntries
                )
                pattern.isActive = isActive
                _ = try service.generatePlannedShifts(for: pattern, weeks: weeksToGenerate)
            }
            HapticFeedback.success()
            dismiss()
        } catch {
            ErrorHandler.shared.handle(error)
        }
    }

    private func generateShifts() {
        guard let pattern = editingPattern else { return }
        let service = ShiftPatternService(modelContext: modelContext)
        do {
            pattern.cycleEntries = cycleEntries
            _ = try service.extendPattern(pattern, additionalWeeks: weeksToGenerate)
            HapticFeedback.success()
        } catch {
            ErrorHandler.shared.handle(error)
        }
    }

    private func clearFuture() {
        guard let pattern = editingPattern else { return }
        let service = ShiftPatternService(modelContext: modelContext)
        do {
            try service.clearFuturePlannedShifts(for: pattern)
            HapticFeedback.lightImpact()
        } catch {
            ErrorHandler.shared.handle(error)
        }
    }
}

// MARK: - Cycle Day Row

private struct CycleDayRow: View {
    @Binding var entry: PatternDayEntry
    let dayNumber: Int
    let shiftTypes: [ShiftType]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(String(format: AppStrings.tagImZyklus, dayNumber))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Toggle(AppStrings.freiTag, isOn: $entry.isFreeDay)
                    .labelsHidden()

                Text(entry.isFreeDay ? AppStrings.freiTag : AppStrings.arbeitstag)
                    .font(.caption)
                    .foregroundStyle(entry.isFreeDay ? .green : .primary)
            }

            if !entry.isFreeDay {
                HStack(spacing: 8) {
                    Picker("", selection: shiftTypeBinding) {
                        Text("-").tag(String?.none)
                        ForEach(shiftTypes, id: \.persistentModelID) { type in
                            HStack {
                                Circle()
                                    .fill(type.color)
                                    .frame(width: 8, height: 8)
                                Text(type.name)
                            }
                            .tag(String?.some(type.name))
                        }
                    }
                    .labelsHidden()

                    Spacer()

                    HStack(spacing: 4) {
                        Text(String(format: "%02d:%02d", entry.startHour, entry.startMinute))
                            .font(.caption)
                            .monospacedDigit()

                        Text("-")
                            .font(.caption)

                        Text(String(format: "%02d:%02d", entry.endHour, entry.endMinute))
                            .font(.caption)
                            .monospacedDigit()
                    }
                    .foregroundStyle(.secondary)
                }

                HStack(spacing: 12) {
                    TimeStepper(label: "Start", hour: $entry.startHour, minute: $entry.startMinute)
                    TimeStepper(label: "Ende", hour: $entry.endHour, minute: $entry.endMinute)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var shiftTypeBinding: Binding<String?> {
        Binding(
            get: { entry.shiftTypeName },
            set: { newName in
                entry.shiftTypeName = newName
                if let type = shiftTypes.first(where: { $0.name == newName }) {
                    entry.shiftTypeColorHex = type.colorHex
                }
            }
        )
    }
}

// MARK: - Time Stepper

private struct TimeStepper: View {
    let label: String
    @Binding var hour: Int
    @Binding var minute: Int

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(width: 35, alignment: .leading)

            Stepper("", value: $hour, in: 0...23)
                .labelsHidden()
                .scaleEffect(0.8)

            Text(String(format: "%02d:%02d", hour, minute))
                .font(.caption)
                .monospacedDigit()
                .frame(width: 40)

            Stepper("", value: $minute, in: 0...45, step: 15)
                .labelsHidden()
                .scaleEffect(0.8)
        }
    }
}
