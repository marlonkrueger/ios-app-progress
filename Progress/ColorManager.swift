//
//  ColorManager.swift
//  Progress
//
//  Created by mkrueger on 17.01.25.
//

import SwiftUI

// Manages global color settings
class ColorManager: ObservableObject {
    @Published var accentColor: Color {
        didSet { saveColors() } // Save accent color whenever it's changed
    }
    
    @Published var progressColor: Color {
        didSet { saveColors() } // Save progress color whenever it's changed
    }
    
    @Published var progressBGColor: LinearGradient
    
    // Load saved colors from UserDefaults, or use default values if none are found
    init() {
        if let savedAccentColor = UserDefaults.standard.color(forKey: "accentColor") {
            self.accentColor = savedAccentColor
        } else {
            self.accentColor = Color.green.opacity(0.8) // Default accent color
        }
        
        if let savedProgressColor = UserDefaults.standard.color(forKey: "progressColor") {
            self.progressColor = savedProgressColor
        } else {
            self.progressColor = Color.teal.opacity(0.8) // Default progress color
        }
        
        // Set default progress background color
        self.progressBGColor = LinearGradient(
            gradient: Gradient(colors: [Color.black.opacity(0.5), Color.white.opacity(0.5)]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    // Method to set the accent color
    func setAccentColor(to color: Color) {
        accentColor = color
    }
    
    // Method to set the progress color
    func setProgressColor(to color: Color) {
        progressColor = color
    }
    
    // Private method to save the colors to UserDefaults
    private func saveColors() {
        UserDefaults.standard.setColor(accentColor, forKey: "accentColor")
        UserDefaults.standard.setColor(progressColor, forKey: "progressColor")
    }
}

// Extension to allow saving and retrieving Color objects from UserDefaults
extension UserDefaults {
    // Retrieve a saved color for the given key
    func color(forKey key: String) -> Color? {
        guard let colorData = data(forKey: key) else { return nil }
        do {
            // Try to decode the color data into a UIColor and return it as a SwiftUI Color
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)
                .map { Color($0) }
        } catch {
            print("Error retrieving color: \(error)")
            return nil
        }
    }
    
    // Save a color to UserDefaults
    func setColor(_ color: Color, forKey key: String) {
        let uiColor = UIColor(color) // Convert SwiftUI Color to UIColor
        do {
            // Try to archive the UIColor and store it in UserDefaults
            let colorData = try NSKeyedArchiver.archivedData(
                withRootObject: uiColor,
                requiringSecureCoding: false
            )
            set(colorData, forKey: key)
        } catch {
            print("Error saving color: \(error)")
        }
    }
}
