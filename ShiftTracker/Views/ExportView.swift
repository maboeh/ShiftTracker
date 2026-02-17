//
//  ExportView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 16.02.26.
//

import SwiftData
import SwiftUI

struct ExportView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var exportManager = ExportManager.shared
    @Query(sort: \Shift.startTime, order: .reverse) private var allShifts: [Shift]

    @State private var selectedFormat: ExportFormat = .csv
    @State private var selectedDateRange: DateRangePreset = .thisWeek
    @State private var selectedFields: Set<ExportField> = Set(ExportField.defaultFields)
    @State private var includeHeaders = true
    @State private var showShareSheet = false
    @State private var showMailComposer = false
    @State private var showPDFPreview = false
    @State private var exportedFileURL: URL?
    
    var body: some View {
        NavigationStack {
            Form {
                Section(AppStrings.exportTitle) {
                    Picker("Format", selection: $selectedFormat) {
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(AppStrings.zeitraum) {
                    Picker(AppStrings.zeitraum, selection: $selectedDateRange) {
                        ForEach(DateRangePreset.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                }
                
                Section(AppStrings.felder) {
                    ForEach(ExportField.allCases, id: \.self) { field in
                        Toggle(field.rawValue, isOn: Binding(
                            get: { selectedFields.contains(field) },
                            set: { isSelected in
                                if isSelected {
                                    selectedFields.insert(field)
                                } else {
                                    selectedFields.remove(field)
                                }
                            }
                        ))
                    }
                }
                
                Section {
                    Toggle(AppStrings.kopfzeilenEinfuegen, isOn: $includeHeaders)
                }
                
                Section {
                    Button {
                        performExport()
                    } label: {
                        if exportManager.isExporting {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Label(AppStrings.exportieren, systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(selectedFields.isEmpty || exportManager.isExporting)
                }
            }
            .navigationTitle(AppStrings.exportTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(AppStrings.fertig) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = exportedFileURL {
                    ShareSheetView(items: [url])
                }
            }
            .sheet(isPresented: $showMailComposer) {
                if let url = exportedFileURL {
                    MailComposerView(
                        isPresented: $showMailComposer,
                        subject: mailTemplate.subject,
                        body: mailTemplate.body,
                        attachmentURL: url,
                        attachmentMimeType: selectedFormat == .csv ? "text/csv" : "application/pdf"
                    )
                }
            }
            .sheet(isPresented: $showPDFPreview) {
                if let url = exportedFileURL {
                    NavigationStack {
                        PDFPreviewView(url: url)
                            .navigationTitle(AppStrings.pdfVorschau)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button(AppStrings.fertig) {
                                        showPDFPreview = false
                                    }
                                }
                                ToolbarItem(placement: .topBarTrailing) {
                                    Button {
                                        showPDFPreview = false
                                        showShareSheet = true
                                    } label: {
                                        Image(systemName: "square.and.arrow.up")
                                    }
                                }
                            }
                    }
                }
            }
            .alert(AppStrings.errorTitle, isPresented: Binding(
                get: { exportManager.exportError != nil },
                set: { if !$0 { exportManager.exportError = nil } }
            )) {
                Button("OK", role: .cancel) {
                    exportManager.exportError = nil
                }
            } message: {
                Text(exportManager.exportError?.localizedDescription ?? "")
            }
        }
    }
    
    private var mailTemplate: MailTemplate {
        let options = ExportOptions(
            format: selectedFormat,
            dateRangePreset: selectedDateRange,
            fields: ExportField.allCases.filter { selectedFields.contains($0) },
            includeHeaders: includeHeaders
        )
        let filteredShifts = ExportValidator.filterShifts(allShifts, dateRange: options.dateRange)
        let totalHours = filteredShifts.reduce(0.0) { $0 + $1.netDuration / 3600 }
        let weeks = max(options.dateRange.duration / (7 * 86400), 1)
        let targetForRange = AppConfiguration.standardWeeklyHours * weeks
        let overtime = totalHours - targetForRange

        switch selectedDateRange {
        case .thisWeek:
            return .weeklyReport(totalHours: totalHours, overtime: overtime, shiftCount: filteredShifts.count)
        case .thisMonth, .lastMonth:
            return .monthlyReport(totalHours: totalHours, overtime: overtime, shiftCount: filteredShifts.count)
        default:
            return .custom
        }
    }

    private func performExport() {
        let options = ExportOptions(
            format: selectedFormat,
            dateRangePreset: selectedDateRange,
            fields: ExportField.allCases.filter { selectedFields.contains($0) },
            includeHeaders: includeHeaders
        )

        let filteredShifts = ExportValidator.filterShifts(allShifts, dateRange: options.dateRange)

        Task {
            let result = await exportManager.export(shifts: filteredShifts, options: options)

            switch result {
            case .success(let url):
                exportedFileURL = url
                HapticFeedback.success()

                if selectedFormat == .pdf {
                    showPDFPreview = true
                } else if MailComposerView.canSendMail() {
                    showMailComposer = true
                } else {
                    showShareSheet = true
                }

            case .failure(let error):
                HapticFeedback.error()
                ErrorHandler.shared.handle(error)
            }
        }
    }
}

#Preview {
    ExportView()
}
