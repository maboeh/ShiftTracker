//
//  ShiftPatternListView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 07.03.26.
//

import SwiftUI
import SwiftData

struct ShiftPatternListView: View {
    @Query(sort: \ShiftPattern.name) var patterns: [ShiftPattern]
    @Environment(\.modelContext) private var modelContext
    @State private var showAddSheet = false

    var body: some View {
        List {
            if patterns.isEmpty {
                ContentUnavailableView(
                    AppStrings.schichtMuster,
                    systemImage: "repeat",
                    description: Text(AppStrings.musterBeschreibung)
                )
            } else {
                ForEach(patterns, id: \.persistentModelID) { pattern in
                    NavigationLink {
                        ShiftPatternEditView(editing: pattern)
                    } label: {
                        PatternRow(pattern: pattern)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            deletePattern(pattern)
                        } label: {
                            Label(AppStrings.loeschen, systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle(AppStrings.schichtMuster)
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
            NavigationStack {
                ShiftPatternEditView()
            }
        }
    }

    private func deletePattern(_ pattern: ShiftPattern) {
        let service = ShiftPatternService(modelContext: modelContext)
        do {
            try service.deletePattern(pattern, deleteFuturePlanned: true)
            HapticFeedback.lightImpact()
        } catch {
            ErrorHandler.shared.handle(error)
        }
    }
}

// MARK: - Pattern Row

private struct PatternRow: View {
    let pattern: ShiftPattern

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(pattern.name)
                .font(.subheadline)
                .fontWeight(.medium)

            HStack(spacing: 4) {
                Text("\(pattern.cycleLength)-\(AppStrings.tageZyklus)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !pattern.isActive {
                    Text(AppStrings.inaktiv)
                        .font(.caption2)
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(Color.orange.opacity(0.1), in: Capsule())
                }
            }

            // Mini cycle preview
            HStack(spacing: 2) {
                ForEach(pattern.cycleEntries.prefix(14)) { entry in
                    if entry.isFreeDay {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 12, height: 12)
                    } else {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(hex: entry.shiftTypeColorHex ?? "#808080") ?? .gray)
                            .frame(width: 12, height: 12)
                    }
                }
            }
        }
        .padding(.vertical, 2)
    }
}
