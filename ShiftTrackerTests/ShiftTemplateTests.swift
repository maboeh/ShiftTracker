//
//  ShiftTemplateTests.swift
//  ShiftTrackerTests
//
//  Created by Matthias Böhnke on 17.02.26.
//

import XCTest
import SwiftData
@testable import ShiftTracker

final class ShiftTemplateTests: XCTestCase {

    func testFormattedStartTime() {
        let template = ShiftTemplate(name: "Frühschicht", defaultStartHour: 6, defaultStartMinute: 0)
        XCTAssertEqual(template.formattedStartTime, "06:00")
    }

    func testFormattedStartTimeWithMinutes() {
        let template = ShiftTemplate(name: "Spätschicht", defaultStartHour: 14, defaultStartMinute: 30)
        XCTAssertEqual(template.formattedStartTime, "14:30")
    }

    func testDefaultValues() {
        let template = ShiftTemplate(name: "Test")
        XCTAssertEqual(template.defaultStartHour, 6)
        XCTAssertEqual(template.defaultStartMinute, 0)
        XCTAssertEqual(template.defaultDurationHours, 8.0)
        XCTAssertTrue(template.isActive)
        XCTAssertNil(template.shiftType)
    }

    func testTemplateWithShiftType() {
        let type = MockShiftType.frueh
        let template = ShiftTemplate(name: "Morgen", shiftType: type)
        XCTAssertEqual(template.shiftType?.name, "Frühschicht")
    }

    @MainActor
    func testTemplatePersistence() throws {
        let container = try TestContainer.create()
        let context = container.mainContext

        let template = ShiftTemplate(
            name: "Nachtschicht",
            defaultStartHour: 22,
            defaultStartMinute: 0,
            defaultDurationHours: 10
        )
        context.insert(template)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<ShiftTemplate>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.name, "Nachtschicht")
        XCTAssertEqual(fetched.first?.defaultStartHour, 22)
        XCTAssertEqual(fetched.first?.defaultDurationHours, 10)
    }
}
