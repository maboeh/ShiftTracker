//
//  MailTemplates.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 16.02.26.
//

import Foundation

enum MailTemplate {
    case weeklyReport(totalHours: Double, overtime: Double, shiftCount: Int)
    case monthlyReport(totalHours: Double, overtime: Double, shiftCount: Int)
    case custom
    
    var subject: String {
        switch self {
        case .weeklyReport:
            return "ShiftTracker - Wochenbericht"
        case .monthlyReport:
            return "ShiftTracker - Monatsbericht"
        case .custom:
            return "ShiftTracker - Datenexport"
        }
    }
    
    var body: String {
        switch self {
        case .weeklyReport(let totalHours, let overtime, let shiftCount):
            return """
            Hallo,
            
            anbei findest du meinen Wochenbericht aus ShiftTracker.
            
            Wochenstatistik:
            - Arbeitsstunden: \(String(format: "%.1f", totalHours)) Stunden
            - Überstunden: \(String(format: "%.1f", overtime)) Stunden
            - Anzahl Schichten: \(shiftCount)
            
            Viele Grüße
            """
            
        case .monthlyReport(let totalHours, let overtime, let shiftCount):
            return """
            Hallo,
            
            anbei findest du meinen Monatsbericht aus ShiftTracker.
            
            Monatsstatistik:
            - Arbeitsstunden: \(String(format: "%.1f", totalHours)) Stunden
            - Überstunden: \(String(format: "%.1f", overtime)) Stunden
            - Anzahl Schichten: \(shiftCount)
            
            Viele Grüße
            """
            
        case .custom:
            return """
            Hallo,
            
            anbei findest du den angeforderten Datenexport aus ShiftTracker.
            
            Viele Grüße
            """
        }
    }
}
