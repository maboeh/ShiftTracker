//
//  PDFPreviewView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 16.02.26.
//

import PDFKit
import SwiftUI

struct PDFPreviewView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        if let document = PDFDocument(url: url) {
            pdfView.document = document
        } else {
            ErrorHandler.shared.handle(
                ShiftTrackerError.exportError("PDF-Datei konnte nicht geladen werden.")
            )
        }
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        if let document = PDFDocument(url: url) {
            uiView.document = document
        }
    }
}
