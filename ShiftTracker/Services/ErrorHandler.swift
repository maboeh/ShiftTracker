//
//  ErrorHandler.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 16.02.26.
//

import Combine
import Foundation
import SwiftUI
import os.log

enum ShiftTrackerError: LocalizedError {
    case databaseError(String)
    case exportError(String)
    case validationError(String)
    case securityError(String)
    case unknownError(String)

    var errorDescription: String? {
        switch self {
        case .databaseError(let message):
            return "Datenbankfehler: \(message)"
        case .exportError(let message):
            return "Exportfehler: \(message)"
        case .validationError(let message):
            return "Validierungsfehler: \(message)"
        case .securityError(let message):
            return "Sicherheitsfehler: \(message)"
        case .unknownError(let message):
            return "Unbekannter Fehler: \(message)"
        }
    }
}

@MainActor
class ErrorHandler: ObservableObject {
    static let shared = ErrorHandler()

    @Published var currentError: ShiftTrackerError?
    @Published var showError = false

    private let logger = Logger(subsystem: "com.maboeh.ShiftTracker", category: "ErrorHandler")

    private init() {}

    func handle(_ error: Error) {
        let shiftTrackerError: ShiftTrackerError

        if let stError = error as? ShiftTrackerError {
            shiftTrackerError = stError
        } else {
            shiftTrackerError = .unknownError(error.localizedDescription)
        }

        currentError = shiftTrackerError
        showError = true

        logger.error("\(shiftTrackerError.errorDescription ?? "Unknown error", privacy: .public)")
    }

    func dismiss() {
        currentError = nil
        showError = false
    }
}

extension View {
    func errorAlert() -> some View {
        self.alert(AppStrings.errorTitle, isPresented: Binding(
            get: { ErrorHandler.shared.showError },
            set: { if !$0 { ErrorHandler.shared.dismiss() } }
        )) {
            Button("OK", role: .cancel) {
                ErrorHandler.shared.dismiss()
            }
        } message: {
            Text(ErrorHandler.shared.currentError?.errorDescription ?? "")
        }
    }
}
