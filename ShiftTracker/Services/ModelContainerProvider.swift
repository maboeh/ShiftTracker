//
//  ModelContainerProvider.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 17.02.26.
//

import Foundation
import SwiftData
import os.log

@MainActor
enum ModelContainerProvider {
    static let shared: ModelContainer = {
        let schema = Schema([
            Shift.self,
            Break.self,
            ShiftType.self,
            ShiftTemplate.self,
            ExportRecord.self,
            PlannedShift.self,
            ShiftPattern.self
        ])
        let config = ModelConfiguration(
            schema: schema,
            groupContainer: .identifier("group.maboeh.com.ShiftTracker")
        )
        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            seedDefaultShiftTypes(in: container.mainContext)
            return container
        } catch {
            fatalError("Failed to create shared ModelContainer: \(error)")
        }
    }()

    private static func seedDefaultShiftTypes(in context: ModelContext) {
        do {
            let descriptor = FetchDescriptor<ShiftType>()
            let existingTypes = try context.fetch(descriptor)

            if existingTypes.isEmpty {
                let frueh = ShiftType(name: "Frühschicht", colorHex: "#007AFF")
                let spaet = ShiftType(name: "Spätschicht", colorHex: "#FF9500")
                let nacht = ShiftType(name: "Nachtschicht", colorHex: "#AF52DE")

                context.insert(frueh)
                context.insert(spaet)
                context.insert(nacht)
                try context.save()
            }
        } catch {
            Logger(subsystem: "com.maboeh.ShiftTracker", category: "ModelContainer")
                .error("Failed to seed default ShiftTypes: \(error.localizedDescription, privacy: .public)")
        }
    }
}
