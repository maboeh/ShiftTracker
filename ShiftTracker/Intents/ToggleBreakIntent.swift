//
//  ToggleBreakIntent.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 17.02.26.
//

import AppIntents
import SwiftData
import WidgetKit

struct ToggleBreakIntent: AppIntent {
    static var title: LocalizedStringResource = "Pause umschalten"
    static var description = IntentDescription("Startet oder beendet eine Pause")

    @MainActor
    func perform() async throws -> some IntentResult {
        let context = ModelContainerProvider.shared.mainContext
        let service = ShiftService(modelContext: context)
        let state = try service.getCurrentState()

        switch state {
        case .active:
            try service.startBreak()
        case .onBreak:
            try service.endBreak()
        case .inactive:
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
