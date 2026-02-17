//
//  AuthView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 17.02.26.
//

import SwiftUI
import LocalAuthentication

struct AuthView: View {
    @State private var authManager = AuthManager.shared
    @State private var showPINEntry = false
    @State private var biometricError = false
    @State private var hasAttemptedBiometric = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 64))
                .foregroundStyle(.blue)
                .accessibilityHidden(true)

            Text(AppStrings.appName)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(AppStrings.gesperrt)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if biometricError {
                Text(AppStrings.biometrieFehler)
                    .foregroundStyle(.orange)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            VStack(spacing: 16) {
                if authManager.isBiometricEnabled && authManager.biometricType != .none {
                    Button {
                        Task {
                            await attemptBiometric()
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: biometricIcon)
                                .font(.title2)
                            Text(String(format: AppStrings.mitBiometrie, biometricName))
                                .font(.headline)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(.blue)
                        .cornerRadius(12)
                    }
                }

                if authManager.isPINSet {
                    Button {
                        showPINEntry = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "number.square.fill")
                                .font(.title2)
                            Text(AppStrings.pinEingeben)
                                .font(.headline)
                        }
                        .foregroundStyle(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .sheet(isPresented: $showPINEntry) {
            PINEntryView()
        }
        .onAppear {
            guard !hasAttemptedBiometric else { return }
            hasAttemptedBiometric = true

            if authManager.isBiometricEnabled && authManager.biometricType != .none {
                Task {
                    await attemptBiometric()
                }
            }
        }
    }

    private func attemptBiometric() async {
        biometricError = false
        let success = await authManager.authenticateWithBiometrics()
        if !success {
            biometricError = true
        }
    }

    private var biometricIcon: String {
        switch authManager.biometricType {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        case .opticID: return "opticid"
        default: return "lock.fill"
        }
    }

    private var biometricName: String {
        switch authManager.biometricType {
        case .faceID: return AppStrings.faceId
        case .touchID: return AppStrings.touchId
        default: return "Biometrie"
        }
    }
}
