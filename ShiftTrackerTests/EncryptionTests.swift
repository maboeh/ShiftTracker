//
//  EncryptionTests.swift
//  ShiftTrackerTests
//
//  Created by Matthias Böhnke on 17.02.26.
//

import XCTest
@testable import ShiftTracker

final class EncryptionTests: XCTestCase {

    func testEncryptDecryptRoundTrip() throws {
        let original = "Hello, ShiftTracker!".data(using: .utf8)!
        let password = "testpassword123"

        let encrypted = try EncryptionManager.encrypt(data: original, password: password)
        let decrypted = try EncryptionManager.decrypt(data: encrypted, password: password)

        XCTAssertEqual(decrypted, original)
    }

    func testEncryptedDataDiffersFromOriginal() throws {
        let original = "Sensitive shift data".data(using: .utf8)!
        let encrypted = try EncryptionManager.encrypt(data: original, password: "password")

        XCTAssertNotEqual(encrypted, original)
    }

    func testDifferentPasswordsProduceDifferentCiphertext() throws {
        let original = "Same data".data(using: .utf8)!
        let enc1 = try EncryptionManager.encrypt(data: original, password: "password1")
        let enc2 = try EncryptionManager.encrypt(data: original, password: "password2")

        XCTAssertNotEqual(enc1, enc2)
    }

    func testSamePasswordProducesDifferentCiphertext() throws {
        let original = "Same data".data(using: .utf8)!
        let enc1 = try EncryptionManager.encrypt(data: original, password: "samepassword")
        let enc2 = try EncryptionManager.encrypt(data: original, password: "samepassword")

        // Different salt each time → different ciphertext
        XCTAssertNotEqual(enc1, enc2)
    }

    func testWrongPasswordFailsDecryption() {
        let original = "Secret data".data(using: .utf8)!

        do {
            let encrypted = try EncryptionManager.encrypt(data: original, password: "correct")
            _ = try EncryptionManager.decrypt(data: encrypted, password: "wrong")
            XCTFail("Decryption with wrong password should throw")
        } catch {
            XCTAssertTrue(error is EncryptionError)
        }
    }

    func testEmptyDataEncryption() throws {
        let original = Data()
        let password = "password"

        let encrypted = try EncryptionManager.encrypt(data: original, password: password)
        let decrypted = try EncryptionManager.decrypt(data: encrypted, password: password)

        XCTAssertEqual(decrypted, original)
    }

    func testLargeDataEncryption() throws {
        let original = Data(repeating: 0xAB, count: 100_000)
        let password = "strongpassword"

        let encrypted = try EncryptionManager.encrypt(data: original, password: password)
        let decrypted = try EncryptionManager.decrypt(data: encrypted, password: password)

        XCTAssertEqual(decrypted, original)
    }

    func testInvalidDataDecryption() {
        let tooShort = Data([0x01, 0x02, 0x03])

        XCTAssertThrowsError(try EncryptionManager.decrypt(data: tooShort, password: "password")) { error in
            XCTAssertEqual(error as? EncryptionError, .invalidData)
        }
    }
}
