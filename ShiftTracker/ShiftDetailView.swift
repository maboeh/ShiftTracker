//
//  ShiftDetailView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 21.12.25.
//
import SwiftUI
import SwiftData

struct ShiftDetailView: View {
    @Bindable var shift: Shift
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query var shiftTypes: [ShiftType]  // NEU: Alle verfügbaren Types
    
    @State private var isActive: Bool
    
    // NEU: Computed Property für Validierung
    private var isEndBeforeStart: Bool {
        if let end = shift.endTime {
            return end < shift.startTime
        }
        return false
    }
    
    init(shift: Shift) {
        self.shift = shift
        _isActive = State(initialValue: shift.endTime == nil)
    }
    
    var body: some View {
        Form {
            Section("Zeiten") {
                DatePicker("Start",
                          selection: $shift.startTime,
                          displayedComponents: [.date, .hourAndMinute])
                
                Toggle("Shift läuft noch", isOn: $isActive)
                    .onChange(of: isActive) { oldValue, newValue in
                        if newValue {
                            shift.endTime = nil
                        } else {
                            shift.endTime = Date()
                        }
                    }
                
                if !isActive {
                    DatePicker("Ende",
                              selection: Binding(
                                  get: { shift.endTime ?? Date() },
                                  set: { shift.endTime = $0 }
                              ),
                              displayedComponents: [.date, .hourAndMinute])
                    
                    if isEndBeforeStart {
                        Text("⚠️ Ende liegt vor Start")
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
            }
            
            // NEU: Shift Type Section
            Section("Schicht-Art") {
                Picker("Type", selection: $shift.shiftType) {
                    Text("Keine Auswahl")
                        .tag(nil as ShiftType?)
                    
                    ForEach(shiftTypes) { type in
                        HStack {
                            Circle()
                                .fill(type.color)
                                .frame(width: 12, height: 12)
                            Text(type.name)
                        }
                        .tag(type as ShiftType?)
                    }
                }
            }
            
            Section("Info") {
                LabeledContent("Dauer") {
                    if isEndBeforeStart {
                        Text("Ungültig")
                            .foregroundStyle(.red)
                            .fontWeight(.semibold)
                    } else {
                        Text(String(format: "%.1f Stunden", shift.duration / 3600))
                            .foregroundStyle(.primary)
                    }
                }
            }
            
            Section {
                Button(role: .destructive) {
                    modelContext.delete(shift)
                    dismiss()
                } label: {
                    Label("Shift löschen", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle("Shift bearbeiten")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Fertig") {
                    dismiss()
                }
                .disabled(isEndBeforeStart)  // NEU: Deaktiviert wenn ungültig!
            }
        }
    }
}
