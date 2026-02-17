//
//  LockScreenWidget.swift
//  ShiftTrackerWidget
//
//  Created by Matthias Böhnke on 17.02.26.
//

import SwiftUI
import WidgetKit

struct LockScreenWidget: Widget {
    let kind = "ShiftTrackerLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ShiftWidgetProvider()) { entry in
            if #available(iOSApplicationExtension 17.0, *) {
                LockScreenWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("Schicht (Sperrbildschirm)")
        .description("Schichtstatus auf dem Sperrbildschirm.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular])
    }
}

struct LockScreenWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    let entry: ShiftWidgetEntry

    var body: some View {
        switch widgetFamily {
        case .accessoryCircular:
            AccessoryCircularView(entry: entry)
        case .accessoryRectangular:
            AccessoryRectangularView(entry: entry)
        default:
            AccessoryCircularView(entry: entry)
        }
    }
}
