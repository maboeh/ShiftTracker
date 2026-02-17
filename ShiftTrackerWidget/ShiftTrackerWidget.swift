//
//  ShiftTrackerWidget.swift
//  ShiftTrackerWidget
//
//  Created by Matthias Böhnke on 17.02.26.
//

import WidgetKit
import SwiftUI

struct ShiftTrackerWidget: Widget {
    let kind = "ShiftTrackerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ShiftWidgetProvider()) { entry in
            SmallWidgetView(entry: entry)
        }
        .configurationDisplayName("Schicht Status")
        .description("Zeigt den aktuellen Schichtstatus an.")
        .supportedFamilies([.systemSmall])
    }
}

struct ShiftTrackerMediumWidget: Widget {
    let kind = "ShiftTrackerMediumWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ShiftWidgetProvider()) { entry in
            MediumWidgetView(entry: entry)
        }
        .configurationDisplayName("Schicht Steuerung")
        .description("Schichtstatus mit interaktiven Steuerelementen.")
        .supportedFamilies([.systemMedium])
    }
}

@main
struct ShiftTrackerWidgetBundle: WidgetBundle {
    var body: some Widget {
        ShiftTrackerWidget()
        ShiftTrackerMediumWidget()
        LockScreenWidget()
        ShiftLiveActivity()
    }
}
