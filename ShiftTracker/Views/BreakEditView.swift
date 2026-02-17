//
//  BreakEditView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 17.02.26.
//

import SwiftUI
import SwiftData

struct BreakEditView: View {
    @Bindable var brk: Break
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let shiftStart: Date
    let shiftEnd: Date?

    @State private var isActive: Bool

    private var isEndBeforeStart: Bool {
        if let end = brk.endTime {
            return end < brk.startTime
        }
        return false
    }

    private var isOutsideShift: Bool {
        if brk.startTime < shiftStart { return true }
        if let shiftEnd, let breakEnd = brk.endTime, breakEnd > shiftEnd { return true }
        return false
    }

    init(brk: Break, shiftStart: Date, shiftEnd: Date?) {
        self.brk = brk
        self.shiftStart = shiftStart
        self.shiftEnd = shiftEnd
        _isActive = State(initialValue: brk.endTime == nil)
    }

    var body: some View {
        Form {
            Section(AppStrings.zeiten) {
                DatePicker(AppStrings.start,
                          selection: $brk.startTime,
                          displayedComponents: [.date, .hourAndMinute])

                Toggle(AppStrings.laeuftGerade, isOn: $isActive)
                    .onChange(of: isActive) { _, newValue in
                        brk.endTime = newValue ? nil : Date()
                    }

                if !isActive {
                    DatePicker(AppStrings.ende,
                              selection: Binding(
                                  get: { brk.endTime ?? Date() },
                                  set: { brk.endTime = $0 }
                              ),
                              displayedComponents: [.date, .hourAndMinute])

                    if isEndBeforeStart {
                        Text(AppStrings.endeLiegtVorStart)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }

                if isOutsideShift {
                    Text(AppStrings.pauseAusserhalbSchicht)
                        .foregroundStyle(.orange)
                        .font(.caption)
                }
            }

            Section(AppStrings.info) {
                LabeledContent(AppStrings.dauer) {
                    if isEndBeforeStart {
                        Text(AppStrings.ungueltig)
                            .foregroundStyle(.red)
                            .fontWeight(.semibold)
                    } else {
                        let minutes = brk.duration / 60
                        Text(String(format: "%.0f Min.", minutes))
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
        .navigationTitle(AppStrings.pauseBearbeiten)
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
                .disabled(isEndBeforeStart || isOutsideShift)
            }
        }
    }
}
