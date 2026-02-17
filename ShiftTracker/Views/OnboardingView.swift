//
//  OnboardingView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 17.02.26.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isComplete: Bool
    @State private var currentPage = 0

    private var pages: [(icon: String, title: String, text: String)] {
        [
            ("clock.badge.checkmark", AppStrings.onboardingTitel1, AppStrings.onboardingText1),
            ("pause.circle.fill", AppStrings.onboardingTitel2, AppStrings.onboardingText2),
            ("chart.bar.doc.horizontal", AppStrings.onboardingTitel3, AppStrings.onboardingText3),
            ("lock.shield.fill", AppStrings.onboardingTitel4, AppStrings.onboardingText4),
            ("hand.raised.fill", AppStrings.onboardingTitel5, AppStrings.onboardingText5)
        ]
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(AppStrings.ueberspringen) {
                    isComplete = true
                }
                .foregroundStyle(.secondary)
                .padding()
            }

            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    VStack(spacing: 24) {
                        Spacer()

                        Image(systemName: page.icon)
                            .font(.system(size: 72))
                            .foregroundStyle(.blue)

                        Text(page.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)

                        Text(page.text)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            Button {
                if currentPage < pages.count - 1 {
                    withAnimation { currentPage += 1 }
                } else {
                    isComplete = true
                }
            } label: {
                Text(currentPage < pages.count - 1 ? AppStrings.weiter2 : AppStrings.losgehts)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
    }
}
