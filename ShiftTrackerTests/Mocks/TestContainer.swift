//
//  TestContainer.swift
//  ShiftTrackerTests
//
//  Created by Matthias Böhnke on 16.02.26.
//

import Foundation
import SwiftData
@testable import ShiftTracker

enum TestContainer {
    @MainActor
    static func create() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Shift.self, ShiftType.self, Break.self,
            configurations: config
        )
        return container
    }

    @MainActor
    static func createWithSampleData() throws -> (container: ModelContainer, shifts: [Shift]) {
        let container = try create()
        let context = container.mainContext

        let frueh = ShiftType(name: "Frühschicht", colorHex: "#007AFF")
        let spaet = ShiftType(name: "Spätschicht", colorHex: "#FF9500")
        context.insert(frueh)
        context.insert(spaet)

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var shifts: [Shift] = []

        // 3 completed shifts this week
        for dayOffset in 0..<3 {
            guard let day = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let start = calendar.date(byAdding: .hour, value: 8, to: day)!
            let end = calendar.date(byAdding: .hour, value: 16, to: day)!
            let shift = Shift(startTime: start, endTime: end, shiftType: dayOffset % 2 == 0 ? frueh : spaet)
            context.insert(shift)
            shifts.append(shift)
        }

        try context.save()
        return (container, shifts)
    }
}
