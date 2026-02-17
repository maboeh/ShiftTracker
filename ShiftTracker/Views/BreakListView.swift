//
//  BreakListView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 17.02.26.
//

import SwiftUI
import SwiftData

struct BreakListView: View {
    @Bindable var shift: Shift
    @Environment(\.modelContext) private var modelContext

    private var sortedBreaks: [Break] {
        (shift.breaks ?? []).sorted { $0.startTime > $1.startTime }
    }

    var body: some View {
        if sortedBreaks.isEmpty {
            Text(AppStrings.keinePausen)
                .foregroundStyle(.secondary)
                .font(.subheadline)
        } else {
            ForEach(sortedBreaks) { brk in
                NavigationLink {
                    BreakEditView(brk: brk, shiftStart: shift.startTime, shiftEnd: shift.endTime)
                } label: {
                    BreakRowView(brk: brk)
                }
            }
            .onDelete(perform: deleteBreaks)
        }
    }

    private func deleteBreaks(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(sortedBreaks[index])
            }
            do {
                try modelContext.save()
            } catch {
                modelContext.rollback()
                ErrorHandler.shared.handle(error)
            }
        }
    }
}

private struct BreakRowView: View {
    let brk: Break

    var body: some View {
        HStack {
            Image(systemName: brk.isActive ? "pause.circle.fill" : "pause.circle")
                .foregroundStyle(brk.isActive ? .orange : .secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(brk.startTime.formatted(date: .omitted, time: .shortened))\(endTimeText)")
                    .font(.subheadline)

                Text(durationText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if brk.isActive {
                Text(AppStrings.laeuftGerade)
                    .font(.caption2)
                    .foregroundStyle(.orange)
                    .fontWeight(.semibold)
            }
        }
    }

    private var endTimeText: String {
        if let end = brk.endTime {
            return " – \(end.formatted(date: .omitted, time: .shortened))"
        }
        return ""
    }

    private var durationText: String {
        let minutes = brk.duration / 60
        if minutes < 1 {
            return "< 1 Min."
        }
        return String(format: "%.0f Min.", minutes)
    }
}
