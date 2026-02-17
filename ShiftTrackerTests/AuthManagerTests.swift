//
//  AuthManagerTests.swift
//  ShiftTrackerTests
//
//  Created by Matthias Böhnke on 17.02.26.
//

import XCTest
@testable import ShiftTracker

final class AuthManagerTests: XCTestCase {

    // MARK: - Weak PIN Detection

    @MainActor
    func testWeakPINsAreDetected() {
        let weakPINs = ["0000", "1111", "1234", "4321", "2580", "12345", "123456"]
        for pin in weakPINs {
            XCTAssertTrue(AuthManager.isWeakPIN(pin), "\(pin) should be detected as weak")
        }
    }

    @MainActor
    func testStrongPINsAreAllowed() {
        let strongPINs = ["4827", "9173", "3856", "72849", "583920"]
        for pin in strongPINs {
            XCTAssertFalse(AuthManager.isWeakPIN(pin), "\(pin) should not be detected as weak")
        }
    }

    @MainActor
    func testAllRepeatingDigitsAreWeak() {
        for digit in 0...9 {
            let pin = String(repeating: "\(digit)", count: 4)
            XCTAssertTrue(AuthManager.isWeakPIN(pin), "\(pin) should be weak")
        }
    }

    // MARK: - PIN Lock Logic

    @MainActor
    func testNotLockedInitially() {
        let manager = AuthManager.shared
        XCTAssertEqual(manager.failedPINAttempts, 0)
        XCTAssertFalse(manager.isPINLocked)
    }

    // MARK: - Lock/Unlock

    @MainActor
    func testLockOnlyWorksWhenAppLockEnabled() {
        let manager = AuthManager.shared
        let wasEnabled = manager.isAppLockEnabled

        manager.isAppLockEnabled = false
        manager.unlock()
        manager.lock()
        XCTAssertFalse(manager.isLocked, "lock() should not lock when appLock is disabled")

        manager.isAppLockEnabled = wasEnabled
    }

    @MainActor
    func testLockWorksWhenAppLockEnabled() {
        let manager = AuthManager.shared
        let wasEnabled = manager.isAppLockEnabled

        manager.isAppLockEnabled = true
        manager.unlock()
        manager.lock()
        XCTAssertTrue(manager.isLocked, "lock() should lock when appLock is enabled")

        manager.unlock()
        manager.isAppLockEnabled = wasEnabled
    }

    @MainActor
    func testUnlockAlwaysWorks() {
        let manager = AuthManager.shared
        let wasEnabled = manager.isAppLockEnabled

        manager.isAppLockEnabled = true
        manager.lock()
        XCTAssertTrue(manager.isLocked)

        manager.unlock()
        XCTAssertFalse(manager.isLocked)

        manager.isAppLockEnabled = wasEnabled
    }

    // MARK: - Auto-Lock Background/Foreground

    @MainActor
    func testImmediateLockWhenDelayIsZero() {
        let manager = AuthManager.shared
        let wasEnabled = manager.isAppLockEnabled
        let prevDelay = manager.autoLockDelay

        manager.isAppLockEnabled = true
        manager.autoLockDelay = 0
        manager.unlock()

        manager.onEnteredBackground()
        XCTAssertTrue(manager.isLocked, "Should lock immediately when delay is 0")

        manager.unlock()
        manager.autoLockDelay = prevDelay
        manager.isAppLockEnabled = wasEnabled
    }

    @MainActor
    func testNoLockWhenAppLockDisabled() {
        let manager = AuthManager.shared
        let wasEnabled = manager.isAppLockEnabled

        manager.isAppLockEnabled = false
        manager.unlock()

        manager.onEnteredBackground()
        XCTAssertFalse(manager.isLocked, "Should not lock when appLock is disabled")

        manager.isAppLockEnabled = wasEnabled
    }

    // MARK: - Auto-Lock Delay

    @MainActor
    func testAutoLockDelayDefaultValue() {
        let key = AppConfiguration.autoLockDelayKey
        let prevValue = UserDefaults.standard.object(forKey: key)

        UserDefaults.standard.removeObject(forKey: key)

        let manager = AuthManager.shared
        XCTAssertEqual(manager.autoLockDelay, AppConfiguration.defaultTimeoutMinutes)

        if let prev = prevValue {
            UserDefaults.standard.set(prev, forKey: key)
        }
    }

    @MainActor
    func testAutoLockDelayCustomValue() {
        let manager = AuthManager.shared
        let prevDelay = manager.autoLockDelay

        manager.autoLockDelay = 2.0
        XCTAssertEqual(manager.autoLockDelay, 2.0)

        manager.autoLockDelay = prevDelay
    }

    // MARK: - PIN Authentication with Keychain
    // Combined into a single test to guarantee execution order,
    // since AuthManager is a singleton with irrecoverable lockout state.

    @MainActor
    func testPINAuthenticationLifecycle() throws {
        let manager = AuthManager.shared
        let wasEnabled = manager.isAppLockEnabled

        // Step 1: Setup PIN
        try manager.setupPIN("9876")
        XCTAssertTrue(manager.isAppLockEnabled)
        XCTAssertTrue(manager.isPINSet)

        // Step 2: Correct PIN succeeds
        let successResult = manager.authenticateWithPIN("9876")
        if case .success = successResult {
            // expected
        } else {
            XCTFail("Expected .success, got \(successResult)")
        }
        XCTAssertEqual(manager.failedPINAttempts, 0)

        // Step 3: Wrong PIN returns .wrongPIN
        let wrongResult = manager.authenticateWithPIN("0001")
        if case .wrongPIN(let attemptsLeft) = wrongResult {
            XCTAssertEqual(attemptsLeft, 4)
        } else {
            XCTFail("Expected .wrongPIN, got \(wrongResult)")
        }
        XCTAssertEqual(manager.failedPINAttempts, 1)

        // Step 4: Reset via correct PIN
        let resetResult = manager.authenticateWithPIN("9876")
        if case .success = resetResult {
            XCTAssertEqual(manager.failedPINAttempts, 0)
        } else {
            XCTFail("Expected .success after reset, got \(resetResult)")
        }

        // Step 5: Lockout after max attempts
        for _ in 0..<5 {
            _ = manager.authenticateWithPIN("0000")
        }
        XCTAssertTrue(manager.isPINLocked)

        let lockedResult = manager.authenticateWithPIN("9876")
        if case .locked = lockedResult {
            // expected
        } else {
            XCTFail("Expected .locked, got \(lockedResult)")
        }

        // Cleanup
        manager.unlock()
        try manager.removePIN()
        manager.isAppLockEnabled = wasEnabled
    }
}
