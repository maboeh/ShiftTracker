//
//  ShiftPatternService.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 07.03.26.
//

import Foundation
import SwiftData

@MainActor
final class ShiftPatternService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Pattern CRUD

    @discardableResult
    func createPattern(name: String, startDate: Date, cycleEntries: [PatternDayEntry]) throws -> ShiftPattern {
        let pattern = ShiftPattern(name: name, startDate: startDate, cycleEntries: cycleEntries)
        modelContext.insert(pattern)
        try modelContext.save()
        return pattern
    }

    func updatePattern(_ pattern: ShiftPattern) throws {
        try modelContext.save()
    }

    func deletePattern(_ pattern: ShiftPattern, deleteFuturePlanned: Bool) throws {
        if deleteFuturePlanned {
            try clearFuturePlannedShifts(for: pattern)
        }
        modelContext.delete(pattern)
        try modelContext.save()
    }

    // MARK: - Generation

    @discardableResult
    func generatePlannedShifts(for pattern: ShiftPattern, weeks: Int = 4) throws -> [PlannedShift] {
        let calendar = Calendar.current
        let entries = pattern.cycleEntries
        guard !entries.isEmpty else { return [] }

        let startFrom = pattern.generatedUntil ?? pattern.startDate
        let totalDays = weeks * 7
        var generated: [PlannedShift] = []

        for dayOffset in 0..<totalDays {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startFrom) else { continue }

            let entryIndex = dayOffset % entries.count
            let entry = entries[entryIndex]

            guard !entry.isFreeDay else { continue }

            let dayStart = calendar.startOfDay(for: date)
            guard let startTime = calendar.date(bySettingHour: entry.startHour, minute: entry.startMinute, second: 0, of: dayStart),
                  let endTime = calendar.date(bySettingHour: entry.endHour, minute: entry.endMinute, second: 0, of: dayStart) else {
                continue
            }

            let adjustedEndTime = endTime <= startTime
                ? endTime.addingTimeInterval(24 * 3600)
                : endTime

            let shiftType = try resolveShiftType(named: entry.shiftTypeName)

            let planned = PlannedShift(
                plannedDate: dayStart,
                startTime: startTime,
                endTime: adjustedEndTime,
                shiftType: shiftType
            )
            planned.pattern = pattern
            modelContext.insert(planned)
            generated.append(planned)
        }

        pattern.generatedUntil = calendar.date(byAdding: .day, value: totalDays, to: startFrom)
        try modelContext.save()

        return generated
    }

    func extendPattern(_ pattern: ShiftPattern, additionalWeeks: Int = 4) throws -> [PlannedShift] {
        return try generatePlannedShifts(for: pattern, weeks: additionalWeeks)
    }

    func clearFuturePlannedShifts(for pattern: ShiftPattern) throws {
        let now = Date()
        let shifts = (pattern.plannedShifts ?? []).filter { $0.linkedShift == nil && $0.plannedDate > now }
        for shift in shifts {
            modelContext.delete(shift)
        }
        try modelContext.save()
    }

    // MARK: - Helpers

    func resolveShiftType(named name: String?) throws -> ShiftType? {
        guard let name else { return nil }
        let descriptor = FetchDescriptor<ShiftType>(
            predicate: #Predicate<ShiftType> { $0.name == name }
        )
        return try modelContext.fetch(descriptor).first
    }
}
