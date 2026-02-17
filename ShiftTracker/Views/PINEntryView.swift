//
//  PINEntryView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 17.02.26.
//

import LocalAuthentication
import SwiftUI

struct PINEntryView: View {
    @State private var authManager = AuthManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var pin = ""
    @State private var errorMessage: String?
    @State private var shakeOffset: CGFloat = 0
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                Image(systemName: "lock.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)
                    .accessibilityHidden(true)

                Text(AppStrings.pinEingeben)
                    .font(.title2)
                    .fontWeight(.semibold)

                PINDotsView(count: pin.count)
                    .offset(x: shakeOffset)

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                }

                PINKeypadView(pin: $pin, maxDigits: 6) {
                    attemptUnlock()
                }

                Spacer()
            }
            .padding()
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

    private func attemptUnlock() {
        guard pin.count >= 4 else { return }

        let result = authManager.authenticateWithPIN(pin)
        switch result {
        case .success:
            dismiss()
        case .wrongPIN(let attemptsLeft):
            errorMessage = "\(AppStrings.pinFalsch) (\(attemptsLeft) übrig)"
            shakeAndClear()
        case .locked:
            let biometricName = authManager.biometricType == .faceID ? AppStrings.faceId : AppStrings.touchId
            errorMessage = String(format: AppStrings.pinGesperrt, biometricName)
            pin = ""
        case .error(let message):
            errorMessage = message
            pin = ""
        }
    }

    private func shakeAndClear() {
        withAnimation(.default) { shakeOffset = 10 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.default) { shakeOffset = -10 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.default) { shakeOffset = 0 }
        }
        pin = ""
    }
}

// MARK: - PIN Dots

struct PINDotsView: View {
    let count: Int
    private let maxDots = 6

    var body: some View {
        HStack(spacing: 16) {
            ForEach(0..<maxDots, id: \.self) { index in
                Circle()
                    .fill(index < count ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 16, height: 16)
            }
        }
        .accessibilityLabel("\(count) Ziffern eingegeben")
    }
}

// MARK: - PIN Keypad

struct PINKeypadView: View {
    @Binding var pin: String
    let maxDigits: Int
    let onComplete: () -> Void

    private let keys: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["", "0", "delete"]
    ]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(keys, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { key in
                        if key.isEmpty {
                            Color.clear
                                .frame(width: 72, height: 56)
                        } else if key == "delete" {
                            Button {
                                if !pin.isEmpty {
                                    pin.removeLast()
                                }
                            } label: {
                                Image(systemName: "delete.backward")
                                    .font(.title2)
                                    .frame(width: 72, height: 56)
                                    .foregroundStyle(.primary)
                            }
                            .accessibilityLabel(AppStrings.loeschen)
                        } else {
                            Button {
                                guard pin.count < maxDigits else { return }
                                pin += key
                                if pin.count >= 4 {
                                    onComplete()
                                }
                            } label: {
                                Text(key)
                                    .font(.title)
                                    .fontWeight(.medium)
                                    .frame(width: 72, height: 56)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(8)
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                }
            }
        }
    }
}
