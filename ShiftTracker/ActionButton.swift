//
//  ActionButton.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 29.12.25.
//

import SwiftUI

enum ShiftState {
    case inactive
    case active
    case onBreak
}

struct ActionButton: View {
    let state: ShiftState
    let onToggleShift: () -> Void
    let onToggleBreak: () -> Void

    var body: some View {
        Group {
            switch state {
            case .inactive:
                singleButton(
                    text: AppStrings.einstempeln,
                    icon: "play.fill",
                    color: .green,
                    haptic: { HapticFeedback.success() },
                    action: onToggleShift,
                    hint: AppStrings.hintSchichtStarten
                )

            case .active:
                HStack(spacing: 12) {
                    actionButton(
                        text: AppStrings.pause,
                        icon: "pause.fill",
                        color: .orange,
                        haptic: { HapticFeedback.mediumImpact() },
                        action: onToggleBreak,
                        hint: AppStrings.hintPauseStarten
                    )
                    actionButton(
                        text: AppStrings.ausstempeln,
                        icon: "stop.fill",
                        color: .red,
                        haptic: { HapticFeedback.mediumImpact() },
                        action: onToggleShift,
                        hint: AppStrings.hintSchichtBeenden
                    )
                }

            case .onBreak:
                HStack(spacing: 12) {
                    actionButton(
                        text: AppStrings.weiter,
                        icon: "play.fill",
                        color: .green,
                        haptic: { HapticFeedback.success() },
                        action: onToggleBreak,
                        hint: AppStrings.hintPauseBeenden
                    )
                    actionButton(
                        text: AppStrings.ausstempeln,
                        icon: "stop.fill",
                        color: .red,
                        haptic: { HapticFeedback.mediumImpact() },
                        action: onToggleShift,
                        hint: AppStrings.hintSchichtBeenden
                    )
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemGroupedBackground))
    }

    private func singleButton(text: String, icon: String, color: Color,
                               haptic: @escaping () -> Void, action: @escaping () -> Void,
                               hint: String) -> some View {
        Button {
            haptic()
            action()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                Text(text)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(color)
            .cornerRadius(12)
        }
        .accessibilityLabel(text)
        .accessibilityHint(hint)
    }

    private func actionButton(text: String, icon: String, color: Color,
                               haptic: @escaping () -> Void, action: @escaping () -> Void,
                               hint: String) -> some View {
        Button {
            haptic()
            action()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.body)
                Text(text)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(color)
            .cornerRadius(12)
        }
        .accessibilityLabel(text)
        .accessibilityHint(hint)
    }
}

#Preview {
    VStack {
        ActionButton(state: .inactive, onToggleShift: {}, onToggleBreak: {})
        ActionButton(state: .active, onToggleShift: {}, onToggleBreak: {})
        ActionButton(state: .onBreak, onToggleShift: {}, onToggleBreak: {})
    }
}
