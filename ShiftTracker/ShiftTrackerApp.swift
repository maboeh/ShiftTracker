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
        .modelContainer(for: Shift.self)
}
}
