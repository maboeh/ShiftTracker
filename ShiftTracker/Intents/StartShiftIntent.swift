//
//  StartShiftIntent.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 17.02.26.
//

import AppIntents
import SwiftData
import WidgetKit

struct StartShiftIntent: AppIntent {
    static var title: LocalizedStringResource = "Schicht starten"
    static var description = IntentDescription("Startet eine neue Arbeitsschicht")

    @MainActor
    func perform() async throws -> some IntentResult {
        let context = ModelContainerProvider.shared.mainContext
        let service = ShiftService(modelContext: context)
        do {
            try service.startShift()
        } catch ShiftServiceError.activeShiftExists {
            throw Error.activeShiftExists
        }
        return .result()
    }

    enum Error: Swift.Error, CustomLocalizedStringResourceConvertible {
        case activeShiftExists

        var localizedStringResource: LocalizedStringResource {
            switch self {
            case .activeShiftExists: return "Es läuft bereits eine Schicht."
            }
        }
    }
}
