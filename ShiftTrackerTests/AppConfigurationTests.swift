//
//  AppConfigurationTests.swift
//  ShiftTrackerTests
//
//  Created by Matthias Böhnke on 17.02.26.
//

import XCTest
@testable import ShiftTracker

final class AppConfigurationTests: XCTestCase {

    // MARK: - Constants

    func testDefaultWeeklyHoursConstant() {
        XCTAssertEqual(AppConfiguration.defaultWeeklyHours, 40.0)
    }

    func testDefaultTimeoutMinutesConstant() {
        XCTAssertEqual(AppConfiguration.defaultTimeoutMinutes, 5.0)
    }

    func testAppNameConstant() {
        XCTAssertEqual(AppConfiguration.appName, "ShiftTracker")
    }

    // MARK: - UserDefaults Keys

    func testWeeklyHoursKeyIsCorrect() {
        XCTAssertEqual(AppConfiguration.weeklyHoursKey, "weeklyTargetHours")
    }

    func testAutoLockDelayKeyIsCorrect() {
        XCTAssertEqual(AppConfiguration.autoLockDelayKey, "autoLockDelay")
    }

    // MARK: - Computed weeklyTargetHours

    func testWeeklyTargetHoursDefaultWhenNotSet() {
        let key = AppConfiguration.weeklyHoursKey
        let prev = UserDefaults.standard.object(forKey: key)

        UserDefaults.standard.removeObject(forKey: key)
        XCTAssertEqual(AppConfiguration.weeklyTargetHours, 40.0)

        if let prev { UserDefaults.standard.set(prev, forKey: key) }
    }

    func testWeeklyTargetHoursCustomValue() {
        let key = AppConfiguration.weeklyHoursKey
        let prev = UserDefaults.standard.object(forKey: key)

        UserDefaults.standard.set(35.0, forKey: key)
        XCTAssertEqual(AppConfiguration.weeklyTargetHours, 35.0)

        if let prev {
            UserDefaults.standard.set(prev, forKey: key)
        } else {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    func testWeeklyTargetHoursZeroFallsBackToDefault() {
        let key = AppConfiguration.weeklyHoursKey
        let prev = UserDefaults.standard.object(forKey: key)

        UserDefaults.standard.set(0.0, forKey: key)
        XCTAssertEqual(AppConfiguration.weeklyTargetHours, 40.0, "Zero should fall back to default")

        if let prev {
            UserDefaults.standard.set(prev, forKey: key)
        } else {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}
