//
//  PlannedShiftAutoStartService.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 07.03.26.
//

import Foundation
import SwiftData

@MainActor
final class PlannedShiftAutoStartService {
    static let shared = PlannedShiftAutoStartService()

    private init() {}

    /// Checks for due auto-start planned shifts and starts the most recent one.
    /// Should be called when the app becomes active.
    func checkAndStartDueShifts(modelContext: ModelContext) {
        guard UserDefaults.standard.bool(forKey: AppConfiguration.autoStartEnabledKey) else { return }

        let shiftService = ShiftService(modelContext: modelContext)
        let plannedService = PlannedShiftService(modelContext: modelContext)

        do {
            // Only auto-start if no shift is currently active
            guard try shiftService.fetchActiveShift() == nil else { return }

            let now = Date()
            let dueShifts = try plannedService.fetchDueAutoStartShifts(before: now)

            // Start the most recent due shift if within 30-minute tolerance
            if let planned = dueShifts.first,
               now.timeIntervalSince(planned.startTime) < 30 * 60 {
                try plannedService.convertToShift(planned, shiftService: shiftService)
                NotificationManager.shared.onShiftStarted()
            }
        } catch {
            ErrorHandler.shared.handle(error)
        }
    }
}
