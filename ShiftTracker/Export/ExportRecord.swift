//
//  ExportRecord.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 17.02.26.
//

import Foundation
import SwiftData

@Model
class ExportRecord {
    var exportedAt: Date
    var format: String
    var shiftCount: Int
    var dateRangeDescription: String

    init(exportedAt: Date = Date(), format: String, shiftCount: Int, dateRangeDescription: String) {
        self.exportedAt = exportedAt
        self.format = format
        self.shiftCount = shiftCount
        self.dateRangeDescription = dateRangeDescription
    }
}
