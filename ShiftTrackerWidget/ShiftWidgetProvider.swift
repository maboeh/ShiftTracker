//
//  ShiftWidgetProvider.swift
//  ShiftTrackerWidget
//
//  Created by Matthias Böhnke on 17.02.26.
//

import WidgetKit
import SwiftData

struct ShiftWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> ShiftWidgetEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (ShiftWidgetEntry) -> Void) {
        let entry = fetchCurrentEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ShiftWidgetEntry>) -> Void) {
        let entry = fetchCurrentEntry()

        // Text(.timer) zählt automatisch — kein häufiger Refresh nötig.
        // Statuswechsel werden über WidgetCenter.shared.reloadAllTimelines() ausgelöst.
        // 15 Min Fallback als Sicherheitsnetz falls ein reloadAllTimelines() verpasst wird.
        let refreshInterval: TimeInterval = 900
        let nextUpdate = Date().addingTimeInterval(refreshInterval)

        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    @MainActor
    private func fetchCurrentEntry() -> ShiftWidgetEntry {
        do {
            let context = ModelContainerProvider.shared.mainContext
            let service = ShiftService(modelContext: context)
            let state = try service.getCurrentState()

            guard let activeShift = try service.fetchActiveShift() else {
                return .inactive
            }

            let activeBreak = (activeShift.breaks ?? []).first(where: { $0.isActive })

            return ShiftWidgetEntry(
                date: Date(),
                shiftState: state,
                shiftStartTime: activeShift.startTime,
                breakStartTime: activeBreak?.startTime,
                shiftTypeName: activeShift.shiftType?.name,
                shiftTypeColorHex: activeShift.shiftType?.colorHex
            )
        } catch {
            return .inactive
        }
    }
}
