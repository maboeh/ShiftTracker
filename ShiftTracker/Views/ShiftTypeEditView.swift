//
//  ShiftTypeEditView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 17.02.26.
//

import SwiftUI
import SwiftData

struct ShiftTypeEditView: View {
    @Bindable var shiftType: ShiftType
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var selectedColor: Color

    init(shiftType: ShiftType) {
        self.shiftType = shiftType
        _selectedColor = State(initialValue: shiftType.color)
    }

    var body: some View {
        Form {
            Section {
                TextField(AppStrings.name, text: $shiftType.name)
                ColorPicker(AppStrings.farbe, selection: $selectedColor, supportsOpacity: false)
                    .onChange(of: selectedColor) { _, newValue in
                        shiftType.colorHex = newValue.toHex()
                    }
            }

            if let shifts = shiftType.shifts, !shifts.isEmpty {
                Section {
                    LabeledContent(AppStrings.zugewieseneSchichten) {
                        Text("\(shifts.count)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle(AppStrings.schichttypBearbeiten)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(AppStrings.fertig) {
                    do {
                        try modelContext.save()
                        dismiss()
                    } catch {
                        modelContext.rollback()
                        ErrorHandler.shared.handle(error)
                    }
                }
                .disabled(shiftType.name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
}
