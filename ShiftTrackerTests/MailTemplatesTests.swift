//
//  MailTemplatesTests.swift
//  ShiftTrackerTests
//
//  Created by Matthias Böhnke on 17.02.26.
//

import XCTest
@testable import ShiftTracker

final class MailTemplatesTests: XCTestCase {

    // MARK: - Subject Lines

    func testWeeklyReportSubject() {
        let template = MailTemplate.weeklyReport(totalHours: 40, overtime: 0, shiftCount: 5)
        XCTAssertEqual(template.subject, "ShiftTracker - Wochenbericht")
    }

    func testMonthlyReportSubject() {
        let template = MailTemplate.monthlyReport(totalHours: 160, overtime: 10, shiftCount: 20)
        XCTAssertEqual(template.subject, "ShiftTracker - Monatsbericht")
    }

    func testCustomSubject() {
        XCTAssertEqual(MailTemplate.custom.subject, "ShiftTracker - Datenexport")
    }

    // MARK: - Body Content

    func testWeeklyReportBodyContainsValues() {
        let template = MailTemplate.weeklyReport(totalHours: 42.5, overtime: 2.5, shiftCount: 5)
        let body = template.body

        XCTAssertTrue(body.contains("42.5"), "Body should contain total hours")
        XCTAssertTrue(body.contains("2.5"), "Body should contain overtime")
        XCTAssertTrue(body.contains("5"), "Body should contain shift count")
        XCTAssertTrue(body.contains("Wochenbericht"), "Body should mention weekly report")
    }

    func testMonthlyReportBodyContainsValues() {
        let template = MailTemplate.monthlyReport(totalHours: 168.0, overtime: 8.0, shiftCount: 22)
        let body = template.body

        XCTAssertTrue(body.contains("168.0"), "Body should contain total hours")
        XCTAssertTrue(body.contains("8.0"), "Body should contain overtime")
        XCTAssertTrue(body.contains("22"), "Body should contain shift count")
        XCTAssertTrue(body.contains("Monatsbericht"), "Body should mention monthly report")
    }

    func testCustomBodyIsGeneric() {
        let body = MailTemplate.custom.body
        XCTAssertTrue(body.contains("Datenexport"), "Custom body should mention data export")
        XCTAssertTrue(body.contains("Hallo"), "Body should start with greeting")
        XCTAssertTrue(body.contains("Grüße"), "Body should end with closing")
    }

    func testAllTemplatesHaveGreeting() {
        let templates: [MailTemplate] = [
            .weeklyReport(totalHours: 40, overtime: 0, shiftCount: 5),
            .monthlyReport(totalHours: 160, overtime: 0, shiftCount: 20),
            .custom
        ]
        for template in templates {
            XCTAssertTrue(template.body.contains("Hallo"), "All templates should have a greeting")
        }
    }
}
