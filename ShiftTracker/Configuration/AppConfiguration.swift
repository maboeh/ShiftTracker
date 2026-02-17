//
//  AppConfiguration.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 16.02.26.
//

import Foundation

struct AppConfiguration {
    static let defaultWeeklyHours = 40.0
    static let defaultTimeoutMinutes = 5.0
    static let appName = "ShiftTracker"
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    // MARK: - UserDefaults Keys

    static let weeklyHoursKey = "weeklyTargetHours"

    // MARK: - Computed Settings

    static var weeklyTargetHours: Double {
        let stored = UserDefaults.standard.double(forKey: weeklyHoursKey)
        return stored > 0 ? stored : defaultWeeklyHours
    }
}
