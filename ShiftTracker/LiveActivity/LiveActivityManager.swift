//
//  LiveActivityManager.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 17.02.26.
//

import ActivityKit
import Foundation
import os.log

@MainActor
final class LiveActivityManager {
    static let shared = LiveActivityManager()
    private let logger = Logger(subsystem: "com.maboeh.ShiftTracker", category: "LiveActivity")
    private init() {}

    func startActivity(shiftId: String, startTime: Date, shiftTypeName: String?, shiftTypeColorHex: String?) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        // Bestehende Activities beenden bevor eine neue gestartet wird
        endAllActivities()

        let attributes = ShiftActivityAttributes(shiftId: shiftId)
        let state = ShiftActivityAttributes.ContentState(
            shiftState: .active,
            shiftStartTime: startTime,
            breakStartTime: nil,
            shiftTypeName: shiftTypeName,
            shiftTypeColorHex: shiftTypeColorHex
        )

        do {
            let content = ActivityContent(state: state, staleDate: nil)
            _ = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
        } catch {
            logger.error("Failed to start Live Activity: \(error.localizedDescription, privacy: .public)")
        }
    }

    func updateActivity(state: ShiftState, shiftStartTime: Date, breakStartTime: Date?, shiftTypeName: String?, shiftTypeColorHex: String?) {
        let contentState = ShiftActivityAttributes.ContentState(
            shiftState: state,
            shiftStartTime: shiftStartTime,
            breakStartTime: breakStartTime,
            shiftTypeName: shiftTypeName,
            shiftTypeColorHex: shiftTypeColorHex
        )

        Task {
            let content = ActivityContent(state: contentState, staleDate: nil)
            for activity in Activity<ShiftActivityAttributes>.activities {
                await activity.update(content)
            }
        }
    }

    func endActivity() {
        endAllActivities()
    }

    private func endAllActivities() {
        Task {
            for activity in Activity<ShiftActivityAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
}
