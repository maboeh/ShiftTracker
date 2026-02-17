//
//  PDFExporter.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 16.02.26.
//

import Foundation
import PDFKit
import UIKit

enum PDFExportError: LocalizedError {
    case pdfCreationFailed
    case pageRenderFailed

    var errorDescription: String? {
        switch self {
        case .pdfCreationFailed:
            return "PDF konnte nicht erstellt werden."
        case .pageRenderFailed:
            return "PDF-Seite konnte nicht gerendert werden."
        }
    }
}

class PDFExporter {
    // A4 page dimensions in points
    private static let pageWidth: CGFloat = 595.28
    private static let pageHeight: CGFloat = 841.89
    private static let margin: CGFloat = 50
    private static let contentWidth: CGFloat = 595.28 - 100 // pageWidth - 2 * margin
    private static let rowHeight: CGFloat = 22
    private static let headerRowHeight: CGFloat = 28
    private static let summaryHeight: CGFloat = 108 // separator + title + 4 lines

    static func export(shifts: [Shift], options: ExportOptions) -> Result<URL, Error> {
        do {
            try ExportValidator.validate(shifts: shifts, options: options)

            let fileFormatter = DateFormatter()
            fileFormatter.dateFormat = "yyyy-MM-dd"
            let fileName = "ShiftTracker_Export_\(fileFormatter.string(from: Date())).pdf"
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent(fileName)

            let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
            let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"

            let data = renderer.pdfData { context in
                var pageNumber = 1
                context.beginPage()
                var yPos = drawHeader(context: context, options: options)
                yPos = drawTableHeader(yPos: yPos, fields: options.fields)
                yPos += 2 // small gap after header line

                for (index, shift) in shifts.enumerated() {
                    // Check if we need a new page
                    if yPos + rowHeight > pageHeight - margin - 30 {
                        drawFooter(pageNumber: pageNumber)
                        pageNumber += 1
                        context.beginPage()
                        yPos = margin
                        yPos = drawTableHeader(yPos: yPos, fields: options.fields)
                        yPos += 2
                    }

                    // Alternating row background
                    if index % 2 == 0 {
                        let rowRect = CGRect(x: margin, y: yPos, width: contentWidth, height: rowHeight)
                        UIColor.systemGray6.setFill()
                        UIRectFill(rowRect)
                    }

                    drawDataRow(yPos: yPos, shift: shift, fields: options.fields,
                               dateFormatter: dateFormatter, timeFormatter: timeFormatter)
                    yPos += rowHeight
                }

                // Summary section - neue Seite wenn nicht genug Platz
                yPos += 20
                if yPos + summaryHeight > pageHeight - margin - 30 {
                    drawFooter(pageNumber: pageNumber)
                    pageNumber += 1
                    context.beginPage()
                    yPos = margin
                }
                drawSummary(yPos: yPos, shifts: shifts, dateRange: options.dateRange)

                drawFooter(pageNumber: pageNumber)
            }

            try data.write(to: fileURL)
            return .success(fileURL)
        } catch {
            return .failure(error)
        }
    }

    // MARK: - Drawing Helpers

    private static func drawHeader(context: UIGraphicsPDFRendererContext, options: ExportOptions) -> CGFloat {
        var yPos = margin

        // Title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 20),
            .foregroundColor: UIColor.black
        ]
        let title = "ShiftTracker - Schichtbericht"
        title.draw(at: CGPoint(x: margin, y: yPos), withAttributes: titleAttributes)
        yPos += 30

        // Date range subtitle
        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.darkGray
        ]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let rangeText = "\(options.dateRangePreset.rawValue): \(dateFormatter.string(from: options.dateRange.start)) - \(dateFormatter.string(from: options.dateRange.end))"
        rangeText.draw(at: CGPoint(x: margin, y: yPos), withAttributes: subtitleAttributes)
        yPos += 20

        // Export date
        let exportDate = "Erstellt am: \(dateFormatter.string(from: Date()))"
        exportDate.draw(at: CGPoint(x: margin, y: yPos), withAttributes: subtitleAttributes)
        yPos += 30

        // Separator line
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: margin, y: yPos))
        linePath.addLine(to: CGPoint(x: pageWidth - margin, y: yPos))
        UIColor.darkGray.setStroke()
        linePath.lineWidth = 1.0
        linePath.stroke()
        yPos += 15

        return yPos
    }

    private static func drawTableHeader(yPos: CGFloat, fields: [ExportField]) -> CGFloat {
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 10),
            .foregroundColor: UIColor.black
        ]

        // Header background
        let headerRect = CGRect(x: margin, y: yPos, width: contentWidth, height: headerRowHeight)
        UIColor(red: 0.9, green: 0.92, blue: 0.95, alpha: 1.0).setFill()
        UIRectFill(headerRect)

        let columnWidth = contentWidth / CGFloat(fields.count)
        for (index, field) in fields.enumerated() {
            let xPos = margin + CGFloat(index) * columnWidth + 5
            field.rawValue.draw(at: CGPoint(x: xPos, y: yPos + 7), withAttributes: headerAttributes)
        }

        // Header bottom line
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: margin, y: yPos + headerRowHeight))
        linePath.addLine(to: CGPoint(x: pageWidth - margin, y: yPos + headerRowHeight))
        UIColor.darkGray.setStroke()
        linePath.lineWidth = 0.5
        linePath.stroke()

        return yPos + headerRowHeight
    }

    private static func drawDataRow(yPos: CGFloat, shift: Shift, fields: [ExportField],
                                     dateFormatter: DateFormatter, timeFormatter: DateFormatter) {
        let cellAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9),
            .foregroundColor: UIColor.black
        ]

        let columnWidth = contentWidth / CGFloat(fields.count)

        for (index, field) in fields.enumerated() {
            let xPos = margin + CGFloat(index) * columnWidth + 5
            let text: String

            switch field {
            case .date:
                text = dateFormatter.string(from: shift.startTime)
            case .startTime:
                text = timeFormatter.string(from: shift.startTime)
            case .endTime:
                text = shift.endTime.map { timeFormatter.string(from: $0) } ?? "-"
            case .duration:
                let hours = shift.netDuration / 3600
                text = String(format: "%.1f h", hours)
            case .shiftType:
                text = shift.shiftType?.name ?? "-"
            case .breakTime:
                let breakMinutes = shift.totalBreakDuration / 60
                text = breakMinutes > 0 ? String(format: "%.0f min", breakMinutes) : "-"
            }

            text.draw(at: CGPoint(x: xPos, y: yPos + 5), withAttributes: cellAttributes)
        }
    }

    private static func drawSummary(yPos: CGFloat, shifts: [Shift], dateRange: DateInterval) {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ]
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor.darkGray
        ]

        // Separator
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: margin, y: yPos))
        linePath.addLine(to: CGPoint(x: pageWidth - margin, y: yPos))
        UIColor.darkGray.setStroke()
        linePath.lineWidth = 0.5
        linePath.stroke()

        var y = yPos + 10
        "Zusammenfassung".draw(at: CGPoint(x: margin, y: y), withAttributes: titleAttributes)
        y += 20

        let totalHours = shifts.reduce(0.0) { $0 + $1.netDuration / 3600 }
        let totalBreakMinutes = shifts.reduce(0.0) { $0 + $1.totalBreakDuration / 60 }
        let completedShifts = shifts.filter { $0.endTime != nil }.count
        let weeks = max(dateRange.duration / (7 * 86400), 1)
        let targetForRange = AppConfiguration.weeklyTargetHours * weeks
        let overtime = totalHours - targetForRange

        "Anzahl Schichten: \(shifts.count) (\(completedShifts) abgeschlossen)".draw(
            at: CGPoint(x: margin, y: y), withAttributes: valueAttributes)
        y += 18
        "Gesamtstunden (netto): \(String(format: "%.1f", totalHours)) h".draw(
            at: CGPoint(x: margin, y: y), withAttributes: valueAttributes)
        y += 18
        "Gesamtpausen: \(String(format: "%.0f", totalBreakMinutes)) Min.".draw(
            at: CGPoint(x: margin, y: y), withAttributes: valueAttributes)
        y += 18
        let overtimeText = overtime >= 0 ? "Überstunden: +\(String(format: "%.1f", overtime)) h" : "Fehlstunden: \(String(format: "%.1f", overtime)) h"
        overtimeText.draw(at: CGPoint(x: margin, y: y), withAttributes: valueAttributes)
    }

    private static func drawFooter(pageNumber: Int) {
        let footerAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 8),
            .foregroundColor: UIColor.gray
        ]

        let footerY = pageHeight - margin + 10

        // Separator line
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: margin, y: footerY - 5))
        linePath.addLine(to: CGPoint(x: pageWidth - margin, y: footerY - 5))
        UIColor.lightGray.setStroke()
        linePath.lineWidth = 0.5
        linePath.stroke()

        // App name left
        "ShiftTracker".draw(at: CGPoint(x: margin, y: footerY), withAttributes: footerAttributes)

        // Page number right
        let pageText = "Seite \(pageNumber)"
        let pageSize = pageText.size(withAttributes: footerAttributes)
        pageText.draw(at: CGPoint(x: pageWidth - margin - pageSize.width, y: footerY), withAttributes: footerAttributes)
    }
}
