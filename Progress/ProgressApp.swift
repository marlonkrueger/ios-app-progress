//
//  ProgressApp.swift
//  Progress
//
//  Created by mkrueger on 13.01.25.
//

import SwiftUI
import UserNotifications

@main
struct ProgressApp: App {
    @StateObject private var colorManager = ColorManager()
    @StateObject private var settingsViewModel = SettingsViewModel()
    // A custom AppDelegate to handle app lifecycle events like notifications
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            GoalsView()
                // Provides `colorManager` and `settingsViewModel` to all views in the app
                .environmentObject(colorManager)
                .environmentObject(settingsViewModel)
                // Adjust the app's color scheme based on the user's preference
                .preferredColorScheme(
                    settingsViewModel.selectedColorScheme == .light ? .light : .dark
                )
        }
    }
}

// A custom AppDelegate to manage application lifecycle events, like notification permissions
class AppDelegate: NSObject, UIApplicationDelegate {
    // Called when the application finishes launching
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Request user permission to display notifications (alerts, badges, sounds)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission failed: \(error.localizedDescription)")
            }
        }
        return true
    }
}
