//
//  PlannedShiftService.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 07.03.26.
//

import Foundation
import SwiftData

@MainActor
final class PlannedShiftService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - CRUD

    @discardableResult
    func createPlannedShift(date: Date, startTime: Date, endTime: Date,
                            shiftType: ShiftType? = nil, template: ShiftTemplate? = nil,
                            reminderMinutesBefore: Int = 30,
                            isAutoStartEnabled: Bool = false) throws -> PlannedShift {
        let planned = PlannedShift(
            plannedDate: date,
            startTime: startTime,
            endTime: endTime,
            shiftType: shiftType,
            template: template,
            isAutoStartEnabled: isAutoStartEnabled,
            reminderMinutesBefore: reminderMinutesBefore
        )
        modelContext.insert(planned)
        try modelContext.save()

        if reminderMinutesBefore > 0 {
            scheduleReminder(for: planned)
        }

        return planned
    }

    func updatePlannedShift(_ planned: PlannedShift) throws {
        planned.plannedDate = Calendar.current.startOfDay(for: planned.plannedDate)
        try modelContext.save()

        cancelReminder(for: planned)
        if planned.reminderMinutesBefore > 0 {
            scheduleReminder(for: planned)
        }
    }

    func deletePlannedShift(_ planned: PlannedShift) throws {
        cancelReminder(for: planned)
        modelContext.delete(planned)
        try modelContext.save()
    }

    // MARK: - Queries

    func fetchPlannedShifts(for date: Date) throws -> [PlannedShift] {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { return [] }

        let descriptor = FetchDescriptor<PlannedShift>(
            predicate: #Predicate<PlannedShift> { $0.plannedDate >= dayStart && $0.plannedDate < dayEnd },
            sortBy: [SortDescriptor(\PlannedShift.startTime)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchPlannedShifts(in interval: DateInterval) throws -> [PlannedShift] {
        let start = interval.start
        let end = interval.end
        let descriptor = FetchDescriptor<PlannedShift>(
            predicate: #Predicate<PlannedShift> { $0.plannedDate >= start && $0.plannedDate < end },
            sortBy: [SortDescriptor(\PlannedShift.startTime)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchDueAutoStartShifts(before date: Date) throws -> [PlannedShift] {
        let descriptor = FetchDescriptor<PlannedShift>(
            predicate: #Predicate<PlannedShift> {
                $0.isAutoStartEnabled && $0.linkedShift == nil && $0.startTime <= date
            },
            sortBy: [SortDescriptor(\PlannedShift.startTime, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    // MARK: - Conversion

    @discardableResult
    func convertToShift(_ planned: PlannedShift, shiftService: ShiftService) throws -> Shift {
        let shift = try shiftService.startShift(shiftType: planned.shiftType)
        planned.linkedShift = shift
        try modelContext.save()
        return shift
    }

    // MARK: - Notifications

    func scheduleReminder(for planned: PlannedShift) {
        guard planned.reminderMinutesBefore > 0 else { return }

        let triggerDate = planned.startTime.addingTimeInterval(-Double(planned.reminderMinutesBefore) * 60)
        guard triggerDate > Date() else { return }

        let identifier = "plannedShift_\(UUID().uuidString)"
        planned.notificationIdentifier = identifier

        let shiftTypeName = planned.shiftType?.name ?? AppStrings.schicht
        let title = AppStrings.geplanteSchichtErinnerungTitel
        let body = String(format: AppStrings.geplanteSchichtErinnerungText, shiftTypeName, planned.reminderMinutesBefore)

        NotificationManager.shared.schedulePlannedShiftReminder(
            identifier: identifier,
            title: title,
            body: body,
            triggerDate: triggerDate
        )
    }

    func cancelReminder(for planned: PlannedShift) {
        guard let identifier = planned.notificationIdentifier else { return }
        NotificationManager.shared.cancelPlannedShiftReminder(identifier: identifier)
        planned.notificationIdentifier = nil
    }
}
