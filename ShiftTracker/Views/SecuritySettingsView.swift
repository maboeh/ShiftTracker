//
//  SecuritySettingsView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 17.02.26.
//

import SwiftUI
import LocalAuthentication

struct SecuritySettingsView: View {
    @State private var authManager = AuthManager.shared
    @State private var showPINSetup = false
    @State private var showRemovePINConfirm = false

    var body: some View {
        Form {
            Section(AppStrings.appSperre) {
                Toggle(AppStrings.appSperre, isOn: Binding(
                    get: { authManager.isAppLockEnabled },
                    set: { newValue in
                        if newValue {
                            if !authManager.isPINSet {
                                showPINSetup = true
                            } else {
                                authManager.isAppLockEnabled = true
                            }
                        } else {
                            authManager.isAppLockEnabled = false
                        }
                    }
                ))
            }

            if authManager.isAppLockEnabled {
                Section {
                    if authManager.biometricType != .none {
                        Toggle(biometricLabel, isOn: Binding(
                            get: { authManager.isBiometricEnabled },
                            set: { newValue in
                                authManager.isBiometricEnabled = newValue
                            }
                        ))
                    }

                    if authManager.isPINSet {
                        Button(AppStrings.pinAendern) {
                            showPINSetup = true
                        }

                        Button(AppStrings.pinEntfernen, role: .destructive) {
                            showRemovePINConfirm = true
                        }
                    } else {
                        Button(AppStrings.pinEinrichten) {
                            showPINSetup = true
                        }
                    }
                } header: {
                    Text(AppStrings.sicherheit)
                }
            }
        }
        .navigationTitle(AppStrings.sicherheit)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPINSetup) {
            PINSetupView()
        }
        .errorAlert()
        .alert(AppStrings.pinEntfernen, isPresented: $showRemovePINConfirm) {
            Button(AppStrings.loeschen, role: .destructive) {
                do {
                    try authManager.removePIN()
                } catch {
                    ErrorHandler.shared.handle(error)
                }
            }
            Button(AppStrings.fertig, role: .cancel) {}
        } message: {
            Text("Der PIN-Code wird unwiderruflich entfernt.")
        }
    }

    private var biometricLabel: String {
        switch authManager.biometricType {
        case .faceID: return AppStrings.faceId
        case .touchID: return AppStrings.touchId
        default: return AppStrings.biometrieVerwenden
        }
    }
}
