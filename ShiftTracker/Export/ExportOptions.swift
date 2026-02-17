//
//  ExportOptions.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 16.02.26.
//

import Foundation
import os.log

private let logger = Logger(subsystem: "com.maboeh.ShiftTracker", category: "ExportOptions")

enum ExportField: String, CaseIterable {
    case date = "Datum"
    case startTime = "Start"
    case endTime = "Ende"
    case duration = "Dauer"
    case shiftType = "Schichttyp"
    case breakTime = "Pausen"
    
    static var defaultFields: [ExportField] {
        [.date, .startTime, .endTime, .duration, .breakTime, .shiftType]
    }
}

enum ExportFormat: String, CaseIterable {
    case csv = "CSV"
    case pdf = "PDF"
}

enum DateRangePreset: String, CaseIterable {
    case thisWeek = "Diese Woche"
    case thisMonth = "Dieser Monat"
    case lastMonth = "Letzter Monat"
    case thisYear = "Dieses Jahr"
    case custom = "Benutzerdefiniert"
}

struct ExportOptions {
    var format: ExportFormat = .csv
    var dateRangePreset: DateRangePreset = .thisWeek
    var customDateRange: DateInterval?
    var fields: [ExportField] = ExportField.defaultFields
    var includeHeaders: Bool = true
    
    var dateRange: DateInterval {
        switch dateRangePreset {
        case .thisWeek:
            return Calendar.current.weekInterval(for: Date())
        case .thisMonth:
            return Calendar.current.monthInterval(for: Date())
        case .lastMonth:
            return Calendar.current.lastMonthInterval()
        case .thisYear:
            return Calendar.current.yearInterval(for: Date())
        case .custom:
            if let custom = customDateRange {
                return custom
            }
            assertionFailure("Custom date range selected but customDateRange is nil")
            logger.error("ExportOptions.dateRange: custom range is nil, using fallback")
            return DateInterval(start: Date(), duration: 86400 * 7)
        }
    }
}

extension Calendar {
    func weekInterval(for date: Date) -> DateInterval {
        var calendar = self
        calendar.firstWeekday = 2
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: date) else {
            assertionFailure("Calendar.dateInterval returned nil for .weekOfYear")
            logger.error("Calendar.weekInterval fallback used for date: \(date)")
            return DateInterval(start: date, duration: 86400 * 7)
        }
        return interval
    }

    func monthInterval(for date: Date) -> DateInterval {
        guard let interval = dateInterval(of: .month, for: date) else {
            assertionFailure("Calendar.dateInterval returned nil for .month")
            logger.error("Calendar.monthInterval fallback used for date: \(date)")
            return DateInterval(start: date, duration: 86400 * 30)
        }
        return interval
    }

    func lastMonthInterval() -> DateInterval {
        guard let lastMonth = date(byAdding: .month, value: -1, to: Date()) else {
            assertionFailure("Calendar.date(byAdding:) returned nil for lastMonth")
            logger.error("Calendar.lastMonthInterval fallback used")
            return DateInterval(start: Date(), duration: 86400 * 30)
        }
        return monthInterval(for: lastMonth)
    }

    func yearInterval(for date: Date) -> DateInterval {
        guard let interval = dateInterval(of: .year, for: date) else {
            assertionFailure("Calendar.dateInterval returned nil for .year")
            logger.error("Calendar.yearInterval fallback used for date: \(date)")
            return DateInterval(start: date, duration: 86400 * 365)
        }
        return interval
    }
}
