//
//  AuthManager.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 17.02.26.
//

import CryptoKit
import Foundation
import LocalAuthentication
import os.log

private let logger = Logger(subsystem: "com.maboeh.ShiftTracker", category: "AuthManager")

enum PINAuthResult {
    case success
    case wrongPIN(attemptsLeft: Int)
    case locked
    case error(String)
}

@Observable
@MainActor
final class AuthManager {
    static let shared = AuthManager()

    private(set) var isLocked = false
    private(set) var biometricType: LABiometryType = .none
    private(set) var failedPINAttempts = 0
    private let maxPINAttempts = 5

    var isPINLocked: Bool { failedPINAttempts >= maxPINAttempts }

    var isAppLockEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "appLockEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "appLockEnabled") }
    }

    var isBiometricEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "biometricEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "biometricEnabled") }
    }

    var isPINSet: Bool {
        do {
            return try KeychainManager.load(key: Self.pinKey) != nil
        } catch {
            logger.error("Keychain access failed for isPINSet: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    private static let pinKey = "userPIN"

    private static let weakPINs: Set<String> = [
        "0000", "1111", "2222", "3333", "4444", "5555",
        "6666", "7777", "8888", "9999", "1234", "4321",
        "0123", "1010", "2580",
        "00000", "11111", "12345", "00000", "54321",
        "000000", "111111", "123456", "654321"
    ]

    private init() {
        checkBiometricAvailability()
        if isAppLockEnabled {
            isLocked = true
        }
    }

    // MARK: - Biometric Authentication

    func checkBiometricAvailability() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricType = context.biometryType
        } else {
            biometricType = .none
            if let laError = error as? LAError {
                switch laError.code {
                case .biometryLockout:
                    logger.warning("Biometrics locked out")
                case .biometryNotAvailable:
                    logger.error("Biometric hardware not available: \(laError.localizedDescription, privacy: .public)")
                case .biometryNotEnrolled:
                    logger.info("Biometrics not enrolled")
                default:
                    logger.error("Biometric check failed: \(laError.localizedDescription, privacy: .public)")
                }
            } else if let error {
                logger.info("Biometrics not available: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    func authenticateWithBiometrics() async -> Bool {
        let context = LAContext()
        context.localizedFallbackTitle = ""

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Entsperre ShiftTracker"
            )
            if success {
                isLocked = false
                failedPINAttempts = 0
            }
            return success
        } catch {
            logger.error("Biometric auth failed: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    // MARK: - PIN Authentication

    static func isWeakPIN(_ pin: String) -> Bool {
        weakPINs.contains(pin)
    }

    func setupPIN(_ pin: String) throws {
        let hashData = sha256Hash(pin)
        do {
            try KeychainManager.save(key: Self.pinKey, data: hashData)
            isAppLockEnabled = true
            logger.info("PIN setup successful")
        } catch {
            logger.error("PIN setup failed: \(error.localizedDescription, privacy: .public)")
            throw ShiftTrackerError.securityError(AppStrings.saveFailed)
        }
    }

    func authenticateWithPIN(_ pin: String) -> PINAuthResult {
        guard !isPINLocked else {
            return .locked
        }

        let storedData: Data?
        do {
            storedData = try KeychainManager.load(key: Self.pinKey)
        } catch {
            logger.error("Keychain load failed during PIN auth: \(error.localizedDescription, privacy: .public)")
            return .error(AppStrings.keychainFehler)
        }

        guard let storedData else {
            logger.error("No PIN found in keychain during authentication")
            return .error(AppStrings.keychainFehler)
        }

        let inputHash = sha256Hash(pin)

        if inputHash == storedData {
            isLocked = false
            failedPINAttempts = 0
            return .success
        }

        failedPINAttempts += 1
        let attemptsLeft = maxPINAttempts - failedPINAttempts
        if attemptsLeft <= 0 {
            logger.warning("PIN locked after \(self.maxPINAttempts) failed attempts")
            return .locked
        }
        return .wrongPIN(attemptsLeft: attemptsLeft)
    }

    func removePIN() throws {
        do {
            try KeychainManager.delete(key: Self.pinKey)
            if !isBiometricEnabled {
                isAppLockEnabled = false
            }
            logger.info("PIN removed")
        } catch {
            logger.error("PIN removal failed: \(error.localizedDescription, privacy: .public)")
            throw ShiftTrackerError.securityError(AppStrings.pinEntfernenFehler)
        }
    }

    // MARK: - Lock/Unlock

    func lock() {
        guard isAppLockEnabled else { return }
        isLocked = true
    }

    func unlock() {
        isLocked = false
    }

    // MARK: - Private

    private func sha256Hash(_ input: String) -> Data {
        let hash = SHA256.hash(data: Data(input.utf8))
        return Data(hash)
    }
}
