//
//  ShiftTrackerApp.swift
//  ShiftTracker
//
//  Created by Matthias Böhnke on 14.12.25.
//
import SwiftUI
import SwiftData

@main
struct ShiftTrackerApp: App {
    @State private var authManager = AuthManager.shared
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("isOnboardingComplete") private var isOnboardingComplete = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                if isOnboardingComplete {
                    MainTabView()
                } else {
                    OnboardingView(isComplete: $isOnboardingComplete)
                        .transition(.opacity)
                }

                if authManager.isLocked && isOnboardingComplete {
                    AuthView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: authManager.isLocked)
            .animation(.easeInOut(duration: 0.3), value: isOnboardingComplete)
            .onChange(of: scenePhase) { _, newPhase in
                switch newPhase {
                case .background:
                    authManager.onEnteredBackground()
                case .active:
                    authManager.onEnteredForeground()
                default:
                    break
                }
            }
            .task {
                await NotificationManager.shared.checkAuthorization()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                guard !authManager.isLocked else { return }
                let context = ModelContainerProvider.shared.mainContext
                PlannedShiftAutoStartService.shared.checkAndStartDueShifts(modelContext: context)
            }
        }
        .modelContainer(ModelContainerProvider.shared)
    }
}
