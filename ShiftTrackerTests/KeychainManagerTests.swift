//
//  KeychainManagerTests.swift
//  ShiftTrackerTests
//
//  Created by Matthias Böhnke on 17.02.26.
//

import XCTest
@testable import ShiftTracker

final class KeychainManagerTests: XCTestCase {

    private let testKey = "com.shifttracker.test.keychain"

    override func tearDown() {
        try? KeychainManager.delete(key: testKey)
        super.tearDown()
    }

    // MARK: - Save & Load

    func testSaveAndLoadRoundTrip() throws {
        let data = Data("hello-keychain".utf8)
        try KeychainManager.save(key: testKey, data: data)

        let loaded = try KeychainManager.load(key: testKey)
        XCTAssertEqual(loaded, data)
    }

    func testLoadReturnsNilForMissingKey() throws {
        let loaded = try KeychainManager.load(key: "nonexistent-key-xyz")
        XCTAssertNil(loaded)
    }

    // MARK: - Overwrite

    func testOverwriteExistingKey() throws {
        let data1 = Data("first".utf8)
        let data2 = Data("second".utf8)

        try KeychainManager.save(key: testKey, data: data1)
        try KeychainManager.save(key: testKey, data: data2)

        let loaded = try KeychainManager.load(key: testKey)
        XCTAssertEqual(loaded, data2)
    }

    // MARK: - Delete

    func testDeleteRemovesItem() throws {
        let data = Data("to-delete".utf8)
        try KeychainManager.save(key: testKey, data: data)

        try KeychainManager.delete(key: testKey)

        let loaded = try KeychainManager.load(key: testKey)
        XCTAssertNil(loaded)
    }

    func testDeleteNonExistentKeySucceeds() throws {
        XCTAssertNoThrow(try KeychainManager.delete(key: "nonexistent-key-xyz"))
    }

    // MARK: - Separate Keys

    func testDifferentKeysAreSeparate() throws {
        let key2 = testKey + ".second"
        defer { try? KeychainManager.delete(key: key2) }

        let data1 = Data("value1".utf8)
        let data2 = Data("value2".utf8)

        try KeychainManager.save(key: testKey, data: data1)
        try KeychainManager.save(key: key2, data: data2)

        XCTAssertEqual(try KeychainManager.load(key: testKey), data1)
        XCTAssertEqual(try KeychainManager.load(key: key2), data2)
    }

    // MARK: - Error Descriptions

    func testKeychainErrorDescriptions() {
        let saveError = KeychainError.saveFailed(-25299)
        XCTAssertNotNil(saveError.errorDescription)
        XCTAssertTrue(saveError.errorDescription!.contains("save"))

        let loadError = KeychainError.loadFailed(-25300)
        XCTAssertNotNil(loadError.errorDescription)
        XCTAssertTrue(loadError.errorDescription!.contains("load"))

        let deleteError = KeychainError.deleteFailed(-25301)
        XCTAssertNotNil(deleteError.errorDescription)
        XCTAssertTrue(deleteError.errorDescription!.contains("delete"))
    }
}
