//
//  EncryptionManager.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 17.02.26.
//

import CryptoKit
import Foundation

enum EncryptionError: LocalizedError {
    case encryptionFailed
    case decryptionFailed
    case invalidData

    var errorDescription: String? {
        switch self {
        case .encryptionFailed: return "Verschlüsselung fehlgeschlagen"
        case .decryptionFailed: return "Entschlüsselung fehlgeschlagen"
        case .invalidData: return "Ungültige Daten"
        }
    }
}

enum EncryptionManager {
    private static let saltLength = 16

    static func encrypt(data: Data, password: String) throws -> Data {
        var salt = Data(count: saltLength)
        let result = salt.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, saltLength, $0.baseAddress!) }
        guard result == errSecSuccess else { throw EncryptionError.encryptionFailed }

        let key = deriveKey(from: password, salt: salt)
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            guard let combined = sealedBox.combined else {
                throw EncryptionError.encryptionFailed
            }
            return salt + combined
        } catch {
            throw EncryptionError.encryptionFailed
        }
    }

    static func decrypt(data: Data, password: String) throws -> Data {
        guard data.count > saltLength else { throw EncryptionError.invalidData }

        let salt = data.prefix(saltLength)
        let ciphertext = data.dropFirst(saltLength)
        let key = deriveKey(from: password, salt: salt)
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: ciphertext)
            return try AES.GCM.open(sealedBox, using: key)
        } catch {
            throw EncryptionError.decryptionFailed
        }
    }

    private static func deriveKey(from password: String, salt: Data) -> SymmetricKey {
        let inputKey = SymmetricKey(data: Data(password.utf8))
        return HKDF<SHA256>.deriveKey(
            inputKeyMaterial: inputKey,
            salt: salt,
            info: Data("ShiftTracker-Export".utf8),
            outputByteCount: 32
        )
    }
}
