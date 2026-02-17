//
//  EmptyStateView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 30.12.25.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            
            Text(AppStrings.noShifts)
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(AppStrings.tapEinstempeln)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(AppStrings.noShifts). \(AppStrings.tapEinstempeln)")
    }
}

#Preview {
    EmptyStateView()
}
