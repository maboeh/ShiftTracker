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
    
    // NEU: State für "Shift läuft noch"
    @State private var isActive: Bool
    
    private var isEndBeforeStart: Bool {
            if let end = shift.endTime {
                return end < shift.startTime
            }
            return false
        }
    
    // NEU: Init um isActive zu setzen
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
                
                // NEU: Toggle für aktiven Shift
                Toggle("Shift läuft noch", isOn: $isActive)
                    .onChange(of: isActive) { oldValue, newValue in
                        if newValue {
                            // Shift wurde aktiviert → endTime auf nil
                            shift.endTime = nil
                        } else {
                            // Shift wurde beendet → endTime auf jetzt
                            shift.endTime = Date()
                        }
                    }
                
                // NEU: DatePicker nur wenn Shift NICHT aktiv
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
            
            Section("Info") {
                LabeledContent("Dauer") {
                    Text(String(format: "%.1f Stunden", shift.duration / 3600))
                        .foregroundStyle(isEndBeforeStart ? .red : .primary)
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
            }
        }
    }
}
