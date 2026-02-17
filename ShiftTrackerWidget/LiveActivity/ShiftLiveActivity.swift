//
//  ShiftLiveActivity.swift
//  ShiftTrackerWidget
//
//  Created by Matthias Böhnke on 17.02.26.
//

import SwiftUI
import WidgetKit
import ActivityKit

struct ShiftLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ShiftActivityAttributes.self) { context in
            // Lock Screen / Banner UI
            ShiftLiveActivityView(state: context.state)
                .activityBackgroundTint(.black.opacity(0.7))
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.state.shiftState == .onBreak ? "cup.and.saucer.fill" : "figure.walk")
                        .font(.title2)
                        .foregroundStyle(context.state.shiftState == .onBreak ? .orange : .green)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.shiftStartTime, style: .timer)
                        .font(.title3)
                        .fontWeight(.bold)
                        .monospacedDigit()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    DynamicIslandExpanded(state: context.state)
                }
            } compactLeading: {
                DynamicIslandCompactLeading(state: context.state)
            } compactTrailing: {
                DynamicIslandCompactTrailing(state: context.state)
            } minimal: {
                DynamicIslandMinimal(state: context.state)
            }
        }
    }
}
