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
            Section(AppStrings.zeiten) {
                DatePicker(AppStrings.start,
                          selection: $shift.startTime,
                          displayedComponents: [.date, .hourAndMinute])

                Toggle(AppStrings.shiftLaueftNoch, isOn: $isActive)
                    .onChange(of: isActive) { oldValue, newValue in
                        if newValue {
                            shift.endTime = nil
                        } else {
                            shift.endTime = Date()
                        }
                    }
                
                if !isActive {
                    DatePicker(AppStrings.ende,
                              selection: Binding(
                                  get: { shift.endTime ?? Date() },
                                  set: { shift.endTime = $0 }
                              ),
                              displayedComponents: [.date, .hourAndMinute])
                    
                    if isEndBeforeStart {
                        Text(AppStrings.endeLiegtVorStart)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
            }
            
            // NEU: Shift Type Section
            Section(AppStrings.schichtArt) {
                Picker(AppStrings.schichtArt, selection: $shift.shiftType) {
                    Text(AppStrings.keineAuswahl)
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
            
            Section(AppStrings.pausen) {
                BreakListView(shift: shift)

                Button {
                    addBreak()
                } label: {
                    Label(AppStrings.pauseHinzufuegen, systemImage: "plus.circle")
                }
            }

            Section(AppStrings.info) {
                LabeledContent(AppStrings.bruttoDauer) {
                    if isEndBeforeStart {
                        Text(AppStrings.ungueltig)
                            .foregroundStyle(.red)
                            .fontWeight(.semibold)
                    } else {
                        Text(String(format: "%.1f %@", shift.duration / 3600, AppStrings.stunden))
                            .foregroundStyle(.primary)
                    }
                }

                if shift.totalBreakDuration > 0 {
                    LabeledContent(AppStrings.pausenzeit) {
                        Text(String(format: "%.0f Min.", shift.totalBreakDuration / 60))
                            .foregroundStyle(.orange)
                    }

                    LabeledContent(AppStrings.nettoDauer) {
                        Text(String(format: "%.1f %@", shift.netDuration / 3600, AppStrings.stunden))
                            .foregroundStyle(.green)
                            .fontWeight(.semibold)
                    }
                }
            }
            
            // Pausen-Compliance (ArbZG §4)
            if let complianceWarning = breakComplianceWarning {
                Section {
                    Text(complianceWarning)
                        .foregroundStyle(.orange)
                        .font(.caption)
                }
            }

            Section {
                Button(role: .destructive) {
                    modelContext.delete(shift)
                    do {
                        try modelContext.save()
                        withAnimation { dismiss() }
                    } catch {
                        modelContext.rollback()
                        ErrorHandler.shared.handle(error)
                    }
                } label: {
                    Label(AppStrings.schichtLoeschen, systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .accessibilityHint(AppStrings.hintSchichtLoeschen)
            }
        }
        .navigationTitle(AppStrings.schichtBearbeiten)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(AppStrings.fertig) {
                    do {
                        try modelContext.save()
                    } catch {
                        ErrorHandler.shared.handle(error)
                    }
                    dismiss()
                }
                .disabled(isEndBeforeStart)
            }
        }
    }

    // MARK: - Break Management

    private func addBreak() {
        let newBreak = Break(startTime: Date())
        newBreak.shift = shift
        modelContext.insert(newBreak)
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            ErrorHandler.shared.handle(error)
        }
    }

    // MARK: - Pausen-Compliance (ArbZG §4)

    private var breakComplianceWarning: String? {
        let bruttoHours = shift.duration / 3600
        let totalBreakMinutes = shift.totalBreakDuration / 60

        if bruttoHours > 9 && totalBreakMinutes < 45 {
            return AppStrings.pauseWarnung9h
        } else if bruttoHours > 6 && totalBreakMinutes < 30 {
            return AppStrings.pauseWarnung6h
        }
        return nil
    }
}
