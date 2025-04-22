//
//  SettingsView.swift
//  Progress
//
//  Created by mkrueger on 17.01.25.
//

import SwiftUI

// View for settings to personalize UI
struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var colorManager: ColorManager
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    // Predefined colors to choose from
    let colors: [Color] = [
        Color.green.opacity(0.8),    // Soft green
        Color.teal.opacity(0.8),     // Teal
        Color.blue.opacity(0.8),     // Soft blue
        Color.purple.opacity(0.8),   // Lavender purple
        Color.pink.opacity(0.8),     // Gentle pink
        Color.orange.opacity(0.8),   // Warm orange
        Color.yellow.opacity(0.8),   // Soft yellow
        Color.red.opacity(0.8),      // Light red
        Color.brown.opacity(0.8)     // Soft brown
    ]
        
    var body: some View {
        NavigationView {
            Form {
                // Section for appearance Settings
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $settingsViewModel.selectedColorScheme) {
                        ForEach(ColorSchemeOption.allCases, id: \.self) { option in
                            Text(option.rawValue)
                                .cornerRadius(8)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Section for color Settings
                Section(header: Text("Color Settings")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Accent Color")
                            .font(.headline)
                        HStack {
                            ForEach(colors, id: \.self) { color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: colorManager.accentColor == color ? 2 : 0)
                                    )
                                    .onTapGesture {
                                        colorManager.setAccentColor(to: color)
                                    }
                            }
                        }
                        
                        Text("Progress Color")
                            .font(.headline)
                            .padding(.top)
                        HStack {
                            ForEach(colors, id: \.self) { color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: colorManager.progressColor == color ? 2 : 0)
                                    )
                                    .onTapGesture {
                                        colorManager.setProgressColor(to: color)
                                    }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        settingsViewModel.saveSelectedColorScheme()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .preferredColorScheme(mapColorScheme(settingsViewModel.selectedColorScheme)) // Apply selected color scheme
            .tint(colorManager.accentColor)
        }
    }
    
    // Function to map selected color scheme option to ColorScheme
    private func mapColorScheme(_ option: ColorSchemeOption) -> ColorScheme? {
        switch option {
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ColorManager())
        .environmentObject(SettingsViewModel())
        .preferredColorScheme(.dark)
}
