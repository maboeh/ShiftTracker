//
//  HelpView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 17.02.26.
//

import SwiftUI

struct HelpView: View {
    private var faqItems: [(question: String, answer: String)] {
        [
            (AppStrings.faqSchichtStarten, AppStrings.faqSchichtStartenAntwort),
            (AppStrings.faqPauseMachen, AppStrings.faqPauseMachenAntwort),
            (AppStrings.faqFarben, AppStrings.faqFarbenAntwort),
            (AppStrings.faqExport, AppStrings.faqExportAntwort),
            (AppStrings.faqPausenWarnung, AppStrings.faqPausenWarnungAntwort),
            (AppStrings.faqWochenstunden, AppStrings.faqWochenstundenAntwort),
            (AppStrings.faqSicherheit, AppStrings.faqSicherheitAntwort)
        ]
    }

    var body: some View {
        List {
            ForEach(Array(faqItems.enumerated()), id: \.offset) { _, item in
                DisclosureGroup {
                    Text(item.answer)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 4)
                } label: {
                    Text(item.question)
                        .fontWeight(.medium)
                }
            }
        }
        .navigationTitle(AppStrings.hilfe)
        .navigationBarTitleDisplayMode(.inline)
    }
}
