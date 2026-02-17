//
//  TemplatesView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 17.02.26.
//

import SwiftUI
import SwiftData

struct TemplatesView: View {
    @Query var templates: [ShiftTemplate]
    @Query var shiftTypes: [ShiftType]
    @Environment(\.modelContext) private var modelContext

    @State private var showAddSheet = false

    var onSelectTemplate: ((ShiftTemplate) -> Void)?

    var body: some View {
        List {
            if templates.isEmpty {
                ContentUnavailableView(
                    AppStrings.vorlagen,
                    systemImage: "doc.on.doc",
                    description: Text(AppStrings.neueVorlage)
                )
            } else {
                ForEach(templates) { template in
                    Button {
                        onSelectTemplate?(template)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(template.name)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                HStack(spacing: 8) {
                                    Text(template.formattedStartTime)
                                    Text("·")
                                    Text(String(format: "%.1f h", template.defaultDurationHours))
                                    if let typeName = template.shiftType?.name {
                                        Text("·")
                                        Text(typeName)
                                            .foregroundStyle(template.shiftType?.color ?? .secondary)
                                    }
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if onSelectTemplate != nil {
                                Image(systemName: "play.circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.title3)
                                    .accessibilityHidden(true)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteTemplates)
            }
        }
        .navigationTitle(AppStrings.vorlagen)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            TemplateAddView(shiftTypes: shiftTypes)
        }
    }

    private func deleteTemplates(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(templates[index])
        }
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            ErrorHandler.shared.handle(error)
        }
    }
}

struct TemplateAddView: View {
    let shiftTypes: [ShiftType]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedShiftType: ShiftType?
    @State private var startTime = Calendar.current.date(from: DateComponents(hour: 6, minute: 0)) ?? Date()
    @State private var durationHours = 8.0

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(AppStrings.name, text: $name)
                }

                Section {
                    Picker(AppStrings.schichtArt, selection: $selectedShiftType) {
                        Text(AppStrings.keineAuswahl).tag(nil as ShiftType?)
                        ForEach(shiftTypes) { type in
                            Text(type.name).tag(type as ShiftType?)
                        }
                    }
                }

                Section {
                    DatePicker(AppStrings.startzeit, selection: $startTime, displayedComponents: .hourAndMinute)
                    HStack {
                        Text(AppStrings.standardDauer)
                        Spacer()
                        TextField("", value: Binding(
                            get: { durationHours },
                            set: { durationHours = min(max($0, 1), 24) }
                        ), format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 50)
                            .accessibilityLabel(AppStrings.standardDauer)
                        Text(AppStrings.std)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(AppStrings.neueVorlage)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(AppStrings.fertig) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(AppStrings.speichern) {
                        let calendar = Calendar.current
                        let hour = calendar.component(.hour, from: startTime)
                        let minute = calendar.component(.minute, from: startTime)

                        let template = ShiftTemplate(
                            name: name,
                            shiftType: selectedShiftType,
                            defaultStartHour: hour,
                            defaultStartMinute: minute,
                            defaultDurationHours: durationHours
                        )
                        modelContext.insert(template)
                        do {
                            try modelContext.save()
                            dismiss()
                        } catch {
                            modelContext.rollback()
                            ErrorHandler.shared.handle(error)
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
