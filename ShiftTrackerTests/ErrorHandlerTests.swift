//
//  ErrorHandlerTests.swift
//  ShiftTrackerTests
//
//  Created by Matthias Böhnke on 17.02.26.
//

import XCTest
@testable import ShiftTracker

final class ErrorHandlerTests: XCTestCase {

    // MARK: - ShiftTrackerError Descriptions

    func testDatabaseErrorDescription() {
        let error = ShiftTrackerError.databaseError("Connection lost")
        XCTAssertEqual(error.errorDescription, "Datenbankfehler: Connection lost")
    }

    func testExportErrorDescription() {
        let error = ShiftTrackerError.exportError("File not found")
        XCTAssertEqual(error.errorDescription, "Exportfehler: File not found")
    }

    func testValidationErrorDescription() {
        let error = ShiftTrackerError.validationError("Invalid input")
        XCTAssertEqual(error.errorDescription, "Validierungsfehler: Invalid input")
    }

    func testSecurityErrorDescription() {
        let error = ShiftTrackerError.securityError("Access denied")
        XCTAssertEqual(error.errorDescription, "Sicherheitsfehler: Access denied")
    }

    func testUnknownErrorDescription() {
        let error = ShiftTrackerError.unknownError("Something failed")
        XCTAssertEqual(error.errorDescription, "Unbekannter Fehler: Something failed")
    }

    // MARK: - ErrorHandler Handle/Dismiss

    @MainActor
    func testHandleShiftTrackerError() {
        let handler = ErrorHandler.shared

        handler.handle(ShiftTrackerError.exportError("test"))
        XCTAssertNotNil(handler.currentError)
        XCTAssertTrue(handler.showError)

        if case .exportError(let msg) = handler.currentError {
            XCTAssertEqual(msg, "test")
        } else {
            XCTFail("Expected .exportError")
        }

        handler.dismiss()
    }

    @MainActor
    func testHandleGenericErrorWrapsAsUnknown() {
        let handler = ErrorHandler.shared

        handler.handle(URLError(.badURL))
        XCTAssertNotNil(handler.currentError)

        if case .unknownError = handler.currentError {
            // expected
        } else {
            XCTFail("Expected .unknownError, got \(String(describing: handler.currentError))")
        }

        handler.dismiss()
    }

    @MainActor
    func testDismissClearsError() {
        let handler = ErrorHandler.shared

        handler.handle(ShiftTrackerError.databaseError("test"))
        XCTAssertTrue(handler.showError)

        handler.dismiss()
        XCTAssertNil(handler.currentError)
        XCTAssertFalse(handler.showError)
    }
}
