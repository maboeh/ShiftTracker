//
//  EndShiftIntent.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 17.02.26.
//

import AppIntents
import SwiftData
import WidgetKit

struct EndShiftIntent: AppIntent {
    static var title: LocalizedStringResource = "Schicht beenden"
    static var description = IntentDescription("Beendet die aktuelle Arbeitsschicht")

    @MainActor
    func perform() async throws -> some IntentResult {
        let context = ModelContainerProvider.shared.mainContext
        let service = ShiftService(modelContext: context)
        do {
            try service.endShift()
        } catch ShiftServiceError.noActiveShift {
            throw Error.noActiveShift
        }
        return .result()
    }

    enum Error: Swift.Error, CustomLocalizedStringResourceConvertible {
        case noActiveShift

        var localizedStringResource: LocalizedStringResource {
            switch self {
            case .noActiveShift: return "Keine aktive Schicht vorhanden."
            }
        }
    }
}
