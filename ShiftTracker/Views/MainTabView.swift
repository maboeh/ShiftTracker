//
//  MainTabView.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 07.03.26.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label(AppStrings.schichten, systemImage: "clock.fill")
                }

            CalendarContainerView()
                .tabItem {
                    Label(AppStrings.kalender, systemImage: "calendar")
                }
        }
    }
}

#Preview {
    MainTabView()
}
