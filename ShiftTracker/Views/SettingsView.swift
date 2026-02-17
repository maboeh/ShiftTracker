//
//  SettingsView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 17.02.26.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(AppConfiguration.weeklyHoursKey) private var weeklyTargetHours = AppConfiguration.defaultWeeklyHours
    @AppStorage("breakReminderEnabled") private var breakReminderEnabled = false
    @AppStorage("shiftReminderEnabled") private var shiftReminderEnabled = false
    @AppStorage("shiftReminderHours") private var shiftReminderHours = 8.0
    @AppStorage("forgotClockOutEnabled") private var forgotClockOutEnabled = false
    @AppStorage("weeklyReportEnabled") private var weeklyReportEnabled = false

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
                        .accessibilityLabel(AppStrings.wochenStunden)
                    Text(AppStrings.std)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text(AppStrings.arbeitszeit)
            } footer: {
                Text(AppStrings.wochenStundenInfo)
            }

            Section {
                Toggle(AppStrings.pausenErinnerung, isOn: $breakReminderEnabled)
                    .onChange(of: breakReminderEnabled) { _, newValue in
                        if newValue { requestNotificationPermission() }
                    }

                Toggle(AppStrings.schichtErinnerung, isOn: $shiftReminderEnabled)
                    .onChange(of: shiftReminderEnabled) { _, newValue in
                        if newValue { requestNotificationPermission() }
                    }

                if shiftReminderEnabled {
                    HStack {
                        Text(AppStrings.erinnerungNach)
                        Spacer()
                        TextField("", value: Binding(
                            get: { shiftReminderHours },
                            set: { shiftReminderHours = min(max($0, 1), 24) }
                        ), format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 40)
                            .accessibilityLabel(AppStrings.erinnerungNach)
                        Text(AppStrings.std)
                            .foregroundStyle(.secondary)
                    }
                }

                Toggle(AppStrings.vergessensAusstempeln, isOn: $forgotClockOutEnabled)
                    .onChange(of: forgotClockOutEnabled) { _, newValue in
                        NotificationManager.shared.isForgotClockOutEnabled = newValue
                        if newValue {
                            requestNotificationPermission()
                        } else {
                            NotificationManager.shared.cancelForgotClockOutReminder()
                        }
                    }

                Toggle(AppStrings.wochenbericht, isOn: $weeklyReportEnabled)
                    .onChange(of: weeklyReportEnabled) { _, newValue in
                        if newValue {
                            requestNotificationPermission()
                            NotificationManager.shared.isWeeklyReportEnabled = true
                            NotificationManager.shared.scheduleWeeklyReport()
                        } else {
                            NotificationManager.shared.isWeeklyReportEnabled = false
                            NotificationManager.shared.cancelWeeklyReport()
                        }
                    }
            } header: {
                Text(AppStrings.benachrichtigungen)
            } footer: {
                Text(AppStrings.pausenErinnerungInfo)
            }

            Section(AppStrings.verwaltung) {
                NavigationLink {
                    ShiftTypeManagementView()
                } label: {
                    Label(AppStrings.schichttypen, systemImage: "list.bullet.rectangle")
                }

                NavigationLink {
                    StatsView()
                } label: {
                    Label(AppStrings.statistiken, systemImage: "chart.bar.fill")
                }

                NavigationLink {
                    TemplatesView()
                } label: {
                    Label(AppStrings.vorlagen, systemImage: "doc.on.doc")
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
                NavigationLink {
                    HelpView()
                } label: {
                    Label(AppStrings.hilfe, systemImage: "questionmark.circle")
                }

                LabeledContent(AppStrings.version) {
                    Text("\(AppConfiguration.appVersion) (\(AppConfiguration.buildNumber))")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(AppStrings.einstellungen)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func requestNotificationPermission() {
        Task {
            await NotificationManager.shared.requestAuthorization()
        }
    }
}
