//
//  ExportValidator.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 16.02.26.
//

import Foundation

enum ExportValidationError: LocalizedError {
    case noShifts
    case invalidDateRange
    case noFieldsSelected
    
    var errorDescription: String? {
        switch self {
        case .noShifts:
            return AppStrings.noDataToExport
        case .invalidDateRange:
            return "Der ausgewählte Zeitraum ist ungültig."
        case .noFieldsSelected:
            return "Bitte wähle mindestens ein Feld für den Export aus."
        }
    }
}

struct ExportValidator {
    static func validate(shifts: [Shift], options: ExportOptions) throws {
        guard !shifts.isEmpty else {
            throw ExportValidationError.noShifts
        }
        
        guard !options.fields.isEmpty else {
            throw ExportValidationError.noFieldsSelected
        }
        
        guard options.dateRange.duration > 0 else {
            throw ExportValidationError.invalidDateRange
        }
    }
    
    static func filterShifts(_ shifts: [Shift], dateRange: DateInterval) -> [Shift] {
        return shifts.filter { shift in
            shift.startTime >= dateRange.start && shift.startTime < dateRange.end
        }
    }
}
