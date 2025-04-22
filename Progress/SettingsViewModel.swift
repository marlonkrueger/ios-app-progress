//
//  SettingsViewModel.swift
//  Progress
//
//  Created by mkrueger on 19.01.25.
//

import SwiftUI

// ViewModel to manage personalizations of the UI
class SettingsViewModel: ObservableObject {
    @Published var selectedColorScheme: ColorSchemeOption
    
    // Initializes the ViewModel and loads the saved color scheme from user preferences
    init() {
        self.selectedColorScheme = SettingsViewModel.loadSelectedColorScheme()
    }
    
    // Loads the saved color scheme option from UserDefaults
    private static func loadSelectedColorScheme() -> ColorSchemeOption {
        if let rawValue = UserDefaults.standard.string(forKey: "colorSchemeOption"),
           let option = ColorSchemeOption(rawValue: rawValue) {
            return option
        }
        return .dark // returns darkmode if none color scheme is safed
    }
    
    // Saves the current color scheme option to UserDefaults
    func saveSelectedColorScheme() {
        UserDefaults.standard.set(selectedColorScheme.rawValue, forKey: "colorSchemeOption")
    }
}

// Enum representing the available color scheme options
enum ColorSchemeOption: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
}
