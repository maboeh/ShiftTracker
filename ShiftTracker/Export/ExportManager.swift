//
//  ExportManager.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 16.02.26.
//

import Combine
import Foundation

class ExportManager: ObservableObject {
    static let shared = ExportManager()
    
    @Published var isExporting = false
    @Published var lastExportURL: URL?
    @Published var exportError: Error?
    
    private init() {}
    
    func export(shifts: [Shift], options: ExportOptions) async -> Result<URL, Error> {
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
        
        await MainActor.run {
            isExporting = false
            switch result {
            case .success(let url):
                lastExportURL = url
            case .failure(let error):
                exportError = error
            }
        }
        
        return result
    }
}
