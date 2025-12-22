//
//  ShiftTrackerApp.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 14.12.25.
//
import SwiftUI
import SwiftData

@main
struct ShiftTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Shift.self, ShiftType.self]) { result in
            // Diese Closure läuft beim ersten Start
            do {
                let container = try result.get()
                
                // Prüfen ob schon Shift Types existieren
                let descriptor = FetchDescriptor<ShiftType>()
                let existingTypes = try container.mainContext.fetch(descriptor)
                
                // Nur erstellen wenn noch keine da sind
                if existingTypes.isEmpty {
                    let frueh = ShiftType(name: "Frühschicht", colorHex: "#007AFF")  // Blau
                    let spaet = ShiftType(name: "Spätschicht", colorHex: "#FF9500")  // Orange
                    let nacht = ShiftType(name: "Nachtschicht", colorHex: "#AF52DE") // Lila
                    
                    container.mainContext.insert(frueh)
                    container.mainContext.insert(spaet)
                    container.mainContext.insert(nacht)
                }
            } catch {
                print("Failed to create default shift types: \(error)")
            }
        }
    }
}
