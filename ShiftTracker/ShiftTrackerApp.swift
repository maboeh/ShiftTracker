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
    @State private var authManager = AuthManager.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()

                if authManager.isLocked {
                    AuthView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: authManager.isLocked)
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .background {
                    authManager.lock()
                }
            }
        }
        .modelContainer(for: [Shift.self, ShiftType.self, Break.self]) { result in
            do {
                let container = try result.get()

                let descriptor = FetchDescriptor<ShiftType>()
                let existingTypes = try container.mainContext.fetch(descriptor)

                if existingTypes.isEmpty {
                    let frueh = ShiftType(name: "Frühschicht", colorHex: "#007AFF")
                    let spaet = ShiftType(name: "Spätschicht", colorHex: "#FF9500")
                    let nacht = ShiftType(name: "Nachtschicht", colorHex: "#AF52DE")

                    container.mainContext.insert(frueh)
                    container.mainContext.insert(spaet)
                    container.mainContext.insert(nacht)
                    try container.mainContext.save()
                }
            } catch {
                ErrorHandler.shared.handle(
                    ShiftTrackerError.databaseError(error.localizedDescription)
                )
            }
        }
    }
}
