//
//  CSVExporter.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 16.02.26.
//

import Foundation

enum CSVExportError: LocalizedError {
    case fileCreationFailed
    case encodingFailed
    
    var errorDescription: String? {
        switch self {
        case .fileCreationFailed:
            return "CSV-Datei konnte nicht erstellt werden."
        case .encodingFailed:
            return "Daten konnten nicht kodiert werden."
        }
    }
}

class CSVExporter {
    static func export(shifts: [Shift], options: ExportOptions) -> Result<URL, Error> {
        do {
            try ExportValidator.validate(shifts: shifts, options: options)

            let fileFormatter = DateFormatter()
            fileFormatter.dateFormat = "yyyy-MM-dd"
            let fileName = "ShiftTracker_Export_\(fileFormatter.string(from: Date())).csv"
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent(fileName)

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"

            // UTF-8 BOM for Excel compatibility
            var csvContent = "\u{FEFF}"

            if options.includeHeaders {
                csvContent += options.fields.map { escapeCSVField($0.rawValue) }.joined(separator: ";") + "\r\n"
            }

            for shift in shifts {
                var row: [String] = []
                for field in options.fields {
                    switch field {
                    case .date:
                        row.append(escapeCSVField(dateFormatter.string(from: shift.startTime)))
                    case .startTime:
                        row.append(escapeCSVField(timeFormatter.string(from: shift.startTime)))
                    case .endTime:
                        if let end = shift.endTime {
                            row.append(escapeCSVField(timeFormatter.string(from: end)))
                        } else {
                            row.append("")
                        }
                    case .duration:
                        let hours = shift.netDuration / 3600
                        row.append(escapeCSVField(String(format: "%.2f", hours)))
                    case .shiftType:
                        row.append(escapeCSVField(shift.shiftType?.name ?? ""))
                    case .breakTime:
                        let breakMinutes = shift.totalBreakDuration / 60
                        row.append(escapeCSVField(breakMinutes > 0 ? String(format: "%.0f", breakMinutes) : ""))
                    }
                }
                csvContent += row.joined(separator: ";") + "\r\n"
            }

            guard let csvData = csvContent.data(using: .utf8) else {
                return .failure(CSVExportError.encodingFailed)
            }

            try csvData.write(to: fileURL)

            return .success(fileURL)
        } catch {
            return .failure(error)
        }
    }

    static func escapeCSVField(_ field: String) -> String {
        if field.contains(";") || field.contains("\"") || field.contains("\n") {
            return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return field
    }
}
