//
//  ExportManager.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 16.02.26.
//

import Combine
import Foundation
import SwiftData

class ExportManager: ObservableObject {
    static let shared = ExportManager()

    @Published var isExporting = false
    @Published var lastExportURL: URL?
    @Published var exportError: Error?

    private init() {}

    func export(shifts: [Shift], options: ExportOptions, modelContext: ModelContext? = nil) async -> Result<URL, Error> {
        await MainActor.run {
            isExporting = true
            exportError = nil
        }
        
        let result: Result<URL, Error>
        
        switch options.format {
        case .csv:
            result = CSVExporter.export(shifts: shifts, options: options)
        case .pdf:
            result = PDFExporter.export(shifts: shifts, options: options)
        }
        
        let finalResult: Result<URL, Error>

        if case .success(let url) = result, let password = options.encryptionPassword, !password.isEmpty {
            do {
                let fileData = try Data(contentsOf: url)
                let encrypted = try EncryptionManager.encrypt(data: fileData, password: password)
                let encryptedURL = url.appendingPathExtension("enc")
                try encrypted.write(to: encryptedURL)
                try FileManager.default.removeItem(at: url)
                finalResult = .success(encryptedURL)
            } catch {
                finalResult = .failure(error)
            }
        } else {
            finalResult = result
        }

        await MainActor.run {
            isExporting = false
            switch finalResult {
            case .success(let url):
                lastExportURL = url
                if let modelContext {
                    let record = ExportRecord(
                        format: options.format.rawValue,
                        shiftCount: shifts.count,
                        dateRangeDescription: options.dateRangePreset.rawValue
                    )
                    modelContext.insert(record)
                    try? modelContext.save()
                }
            case .failure(let error):
                exportError = error
            }
        }

        return finalResult
    }
}
