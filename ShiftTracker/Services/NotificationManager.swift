//
//  NotificationManager.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 17.02.26.
//

import Foundation
import UserNotifications
import os.log

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()
    private let logger = Logger(subsystem: "com.maboeh.ShiftTracker", category: "Notifications")

    private(set) var isAuthorized = false

    var isBreakReminderEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "breakReminderEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "breakReminderEnabled") }
    }

    var isShiftReminderEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "shiftReminderEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "shiftReminderEnabled") }
    }

    var shiftReminderHours: Double {
        get {
            let stored = UserDefaults.standard.double(forKey: "shiftReminderHours")
            return stored > 0 ? stored : 8.0
        }
        set { UserDefaults.standard.set(newValue, forKey: "shiftReminderHours") }
    }

    var isForgotClockOutEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "forgotClockOutEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "forgotClockOutEnabled") }
    }

    var isWeeklyReportEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "weeklyReportEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "weeklyReportEnabled") }
    }

    private init() {}

    // MARK: - Authorization

    func requestAuthorization() async {
        do {
            isAuthorized = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            logger.info("Notification authorization: \(self.isAuthorized)")
        } catch {
            logger.error("Notification authorization failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    func checkAuthorization() async {
        let settings = await center.notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    // MARK: - Break Reminder

    func scheduleBreakReminder(remainingSeconds: TimeInterval = 6 * 3600) {
        guard isBreakReminderEnabled, isAuthorized else { return }
        guard remainingSeconds > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = AppStrings.pauseErinnerungTitel
        content.body = AppStrings.pauseErinnerungText
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: remainingSeconds, repeats: false)
        let request = UNNotificationRequest(identifier: "breakReminder", content: content, trigger: trigger)

        Task {
            do {
                try await center.add(request)
            } catch {
                logger.error("Failed to schedule break reminder: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    func cancelBreakReminder() {
        center.removePendingNotificationRequests(withIdentifiers: ["breakReminder"])
    }

    // MARK: - Shift Duration Reminder

    func scheduleShiftReminder(remainingSeconds: TimeInterval? = nil) {
        guard isShiftReminderEnabled, isAuthorized else { return }

        let interval = remainingSeconds ?? shiftReminderHours * 3600
        guard interval > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = AppStrings.schichtErinnerungTitel
        content.body = String(format: AppStrings.schichtErinnerungText, String(format: "%.0f", shiftReminderHours))
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: "shiftReminder", content: content, trigger: trigger)

        Task {
            do {
                try await center.add(request)
            } catch {
                logger.error("Failed to schedule shift reminder: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    func cancelShiftReminder() {
        center.removePendingNotificationRequests(withIdentifiers: ["shiftReminder"])
    }

    // MARK: - Forgot Clock-Out Reminder

    func scheduleForgotClockOutReminder() {
        guard isForgotClockOutEnabled, isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = AppStrings.vergessensAusstempelnTitel
        content.body = AppStrings.vergessensAusstempelnText
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10 * 3600, repeats: false)
        let request = UNNotificationRequest(identifier: "forgotClockOut", content: content, trigger: trigger)

        Task {
            do {
                try await center.add(request)
            } catch {
                logger.error("Failed to schedule forgot clock-out reminder: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    func cancelForgotClockOutReminder() {
        center.removePendingNotificationRequests(withIdentifiers: ["forgotClockOut"])
    }

    // MARK: - Weekly Report

    func scheduleWeeklyReport() {
        guard isWeeklyReportEnabled, isAuthorized else { return }

        cancelWeeklyReport()

        let content = UNMutableNotificationContent()
        content.title = AppStrings.wochenberichtTitel
        content.body = AppStrings.wochenberichtText
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.weekday = 6 // Freitag
        dateComponents.hour = 17
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "weeklyReport", content: content, trigger: trigger)

        Task {
            do {
                try await center.add(request)
            } catch {
                logger.error("Failed to schedule weekly report: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    func cancelWeeklyReport() {
        center.removePendingNotificationRequests(withIdentifiers: ["weeklyReport"])
    }

    // MARK: - Shift Lifecycle

    func onShiftStarted() {
        scheduleBreakReminder()
        scheduleShiftReminder()
        scheduleForgotClockOutReminder()
    }

    func onShiftEnded() {
        cancelBreakReminder()
        cancelShiftReminder()
        cancelForgotClockOutReminder()
    }

    func onBreakStarted() {
        cancelBreakReminder()
    }

    /// Schedules break reminder for remaining time until 6h net work.
    func onBreakEnded(netWorkDurationSoFar: TimeInterval) {
        let remaining = 6 * 3600 - netWorkDurationSoFar
        scheduleBreakReminder(remainingSeconds: remaining)
    }
}
