//
//  ShiftTypeManagementView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 17.02.26.
//

import SwiftUI
import SwiftData

struct ShiftTypeManagementView: View {
    @Query(sort: \ShiftType.name) var shiftTypes: [ShiftType]
    @Environment(\.modelContext) private var modelContext
    @State private var showAddSheet = false
    @State private var showDeleteConfirm = false
    @State private var pendingDeleteOffsets: IndexSet?

    var body: some View {
        List {
            if shiftTypes.isEmpty {
                ContentUnavailableView(
                    AppStrings.keineSchichttypen,
                    systemImage: "list.bullet.rectangle",
                    description: Text(AppStrings.schichttypHinzufuegen)
                )
            } else {
                ForEach(shiftTypes) { shiftType in
                    NavigationLink {
                        ShiftTypeEditView(shiftType: shiftType)
                    } label: {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(shiftType.color)
                                .frame(width: 20, height: 20)

                            Text(shiftType.name)

                            Spacer()

                            if let count = shiftType.shifts?.count, count > 0 {
                                Text("\(count)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .onDelete { offsets in
                    let hasAssigned = offsets.contains { (shiftTypes[$0].shifts?.count ?? 0) > 0 }
                    if hasAssigned {
                        pendingDeleteOffsets = offsets
                        showDeleteConfirm = true
                    } else {
                        deleteTypes(at: offsets)
                    }
                }
            }
        }
        .navigationTitle(AppStrings.schichttypen)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            NavigationStack {
                ShiftTypeAddView()
            }
        }
        .alert(AppStrings.schichttypLoeschen, isPresented: $showDeleteConfirm) {
            Button(AppStrings.loeschen, role: .destructive) {
                if let offsets = pendingDeleteOffsets {
                    deleteTypes(at: offsets)
                }
            }
            Button(AppStrings.fertig, role: .cancel) {}
        } message: {
            Text(AppStrings.schichttypLoeschenInfo)
        }
    }

    private func deleteTypes(at offsets: IndexSet) {
        for index in offsets {
            let shiftType = shiftTypes[index]
            modelContext.delete(shiftType)
        }
        do {
            try modelContext.save()
            HapticFeedback.lightImpact()
        } catch {
            modelContext.rollback()
            ErrorHandler.shared.handle(error)
        }
    }
}

// MARK: - Add View

struct ShiftTypeAddView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name = ""
    @State private var selectedColor = Color.blue

    var body: some View {
        Form {
            Section {
                TextField(AppStrings.name, text: $name)
                ColorPicker(AppStrings.farbe, selection: $selectedColor, supportsOpacity: false)
            }
        }
        .navigationTitle(AppStrings.neuerSchichttyp)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(AppStrings.fertig) {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(AppStrings.speichern) {
                    let newType = ShiftType(name: name, colorHex: selectedColor.toHex())
                    modelContext.insert(newType)
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
