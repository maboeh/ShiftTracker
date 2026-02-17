//
//  PINSetupView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 17.02.26.
//

import SwiftUI

enum PINSetupStep {
    case enterNew
    case confirm
}

struct PINSetupView: View {
    @State private var authManager = AuthManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var step: PINSetupStep = .enterNew
    @State private var firstPIN = ""
    @State private var confirmPIN = ""
    @State private var errorMessage: String?
    @State private var shakeOffset: CGFloat = 0

    private var currentPIN: Binding<String> {
        step == .enterNew ? $firstPIN : $confirmPIN
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                Image(systemName: step == .enterNew ? "lock.open.fill" : "lock.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)

                Text(step == .enterNew ? AppStrings.neuerPin : AppStrings.pinBestaetigen)
                    .font(.title2)
                    .fontWeight(.semibold)

                PINDotsView(count: currentPIN.wrappedValue.count)
                    .offset(x: shakeOffset)

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                }

                Text(AppStrings.pinMindestens)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                PINKeypadView(pin: currentPIN, maxDigits: 6) {
                    handleComplete()
                }

                Spacer()
            }
            .padding()
            .navigationTitle(AppStrings.pinEinrichten)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(AppStrings.fertig) {
                        dismiss()
                    }
                }
            }
        }
    }

    private func handleComplete() {
        switch step {
        case .enterNew:
            guard firstPIN.count >= 4 else {
                errorMessage = AppStrings.pinMindestens
                return
            }
            if AuthManager.isWeakPIN(firstPIN) {
                errorMessage = AppStrings.pinZuEinfach
                shakeAnimation()
                firstPIN = ""
                return
            }
            errorMessage = nil
            withAnimation { step = .confirm }

        case .confirm:
            guard confirmPIN == firstPIN else {
                errorMessage = AppStrings.pinStimmenNicht
                shakeAnimation()
                confirmPIN = ""
                return
            }

            do {
                try authManager.setupPIN(firstPIN)
                HapticFeedback.success()
                dismiss()
            } catch {
                ErrorHandler.shared.handle(error)
                firstPIN = ""
                confirmPIN = ""
                withAnimation { step = .enterNew }
            }
        }
    }

    private func shakeAnimation() {
        withAnimation(.default) { shakeOffset = 10 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.default) { shakeOffset = -10 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.default) { shakeOffset = 0 }
        }
    }
}
