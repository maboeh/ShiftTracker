//
//  SettingsView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 17.02.26.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(AppConfiguration.weeklyHoursKey) private var weeklyTargetHours = AppConfiguration.defaultWeeklyHours

    var body: some View {
        Form {
            Section {
                HStack {
                    Text(AppStrings.wochenStunden)
                    Spacer()
                    TextField("", value: Binding(
                        get: { weeklyTargetHours },
                        set: { weeklyTargetHours = min(max($0, 1), 168) }
                    ), format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                    Text(AppStrings.std)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text(AppStrings.arbeitszeit)
            } footer: {
                Text(AppStrings.wochenStundenInfo)
            }

            Section(AppStrings.verwaltung) {
                NavigationLink {
                    ShiftTypeManagementView()
                } label: {
                    Label(AppStrings.schichttypen, systemImage: "list.bullet.rectangle")
                }
            }

            Section(AppStrings.sicherheit) {
                NavigationLink {
                    SecuritySettingsView()
                } label: {
                    Label(AppStrings.appSperre, systemImage: "lock.shield")
                }
            }

            Section(AppStrings.ueberApp) {
                LabeledContent(AppStrings.version) {
                    Text("\(AppConfiguration.appVersion) (\(AppConfiguration.buildNumber))")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(AppStrings.einstellungen)
        .navigationBarTitleDisplayMode(.inline)
    }
}
