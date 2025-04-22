//
//  AddGoalButton.swift
//  Progress
//
//  Created by mkrueger on 20.01.25.
//

import SwiftUI

// Used in ContentView to add Goals
struct AddGoalButton: View {
    @Binding var isPresentingAddGoalView: Bool
    @EnvironmentObject var colorManager: ColorManager
    
    var body: some View {
        Button(action: {
            isPresentingAddGoalView = true
        }) {
            Text("Add Goal")
                .frame(maxWidth: .infinity)
                .padding()
                .background(colorManager.accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .padding()
    }
}

#Preview {
    AddGoalButton(isPresentingAddGoalView: .constant(false))
        .environmentObject(ColorManager())
}
