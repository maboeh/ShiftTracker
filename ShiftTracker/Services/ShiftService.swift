//
//  ShiftService.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 17.02.26.
//

import ActivityKit
import Foundation
import SwiftData
import WidgetKit

@MainActor
final class ShiftService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Queries

    func fetchActiveShift() throws -> Shift? {
        var descriptor = FetchDescriptor<Shift>(
            predicate: #Predicate<Shift> { $0.endTime == nil },
            sortBy: [SortDescriptor(\Shift.startTime, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    func getCurrentState() throws -> ShiftState {
        guard let activeShift = try fetchActiveShift() else {
            return .inactive
        }
        return activeShift.hasActiveBreak ? .onBreak : .active
    }

    // MARK: - Shift Operations

    @discardableResult
    func startShift(shiftType: ShiftType? = nil) throws -> Shift {
        guard try fetchActiveShift() == nil else {
            throw ShiftServiceError.activeShiftExists
        }
        let newShift = Shift(startTime: Date(), endTime: nil, shiftType: shiftType)
        modelContext.insert(newShift)
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }
        reloadWidgets()
        LiveActivityManager.shared.startActivity(
            shiftId: newShift.persistentModelID.hashValue.description,
            startTime: newShift.startTime,
            shiftTypeName: shiftType?.name,
            shiftTypeColorHex: shiftType?.colorHex
        )
        return newShift
    }

    func endShift() throws {
        guard let activeShift = try fetchActiveShift() else {
            throw ShiftServiceError.noActiveShift
        }
        if let activeBreak = (activeShift.breaks ?? []).first(where: { $0.isActive }) {
            activeBreak.endTime = Date()
        }
        activeShift.endTime = Date()
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }
        reloadWidgets()
        LiveActivityManager.shared.endActivity()
    }

    // MARK: - Break Operations

    func startBreak() throws {
        guard let activeShift = try fetchActiveShift() else {
            throw ShiftServiceError.noActiveShift
        }
        guard !(activeShift.breaks ?? []).contains(where: { $0.isActive }) else {
            throw ShiftServiceError.activeBreakExists
        }
        let newBreak = Break(startTime: Date())
        newBreak.shift = activeShift
        modelContext.insert(newBreak)
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }
        reloadWidgets()
        updateLiveActivity(shift: activeShift, state: .onBreak, breakStartTime: newBreak.startTime)
    }

    func endBreak() throws {
        guard let activeShift = try fetchActiveShift() else {
            throw ShiftServiceError.noActiveShift
        }
        guard let activeBreak = (activeShift.breaks ?? []).first(where: { $0.isActive }) else {
            throw ShiftServiceError.noActiveBreak
        }
        activeBreak.endTime = Date()
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }
        reloadWidgets()
        updateLiveActivity(shift: activeShift, state: .active, breakStartTime: nil)
    }

    // MARK: - Planned Shift Conversion

    @discardableResult
    func startShiftFromPlanned(_ planned: PlannedShift) throws -> Shift {
        let shift = try startShift(shiftType: planned.shiftType)
        planned.linkedShift = shift
        try modelContext.save()
        return shift
    }

    // MARK: - Widget & Live Activity Refresh

    private func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func updateLiveActivity(shift: Shift, state: ShiftState, breakStartTime: Date?) {
        LiveActivityManager.shared.updateActivity(
            state: state,
            shiftStartTime: shift.startTime,
            breakStartTime: breakStartTime,
            shiftTypeName: shift.shiftType?.name,
            shiftTypeColorHex: shift.shiftType?.colorHex
        )
    }
}

// MARK: - Errors

enum ShiftServiceError: LocalizedError {
    case activeShiftExists
    case noActiveShift
    case activeBreakExists
    case noActiveBreak

    var errorDescription: String? {
        switch self {
        case .activeShiftExists: return "Es läuft bereits eine Schicht."
        case .noActiveShift: return "Keine aktive Schicht vorhanden."
        case .activeBreakExists: return "Es läuft bereits eine Pause."
        case .noActiveBreak: return "Keine aktive Pause vorhanden."
        }
    }
}
