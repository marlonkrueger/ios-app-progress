//
//  SortMenuButton.swift
//  Progress
//
//  Created by mkrueger on 20.01.25.
//

import SwiftUI

// Sort menu button in ContentView for goal list
struct SortMenuButton: View {
    @ObservedObject var viewModel: GoalsViewModel
    @State private var showingSortMenu = false
    @EnvironmentObject var colorManager: ColorManager
    
    var body: some View {
        Menu {
            // Loop through all sort options and create a button for each
            ForEach(GoalSortOption.allCases, id: \.self) { option in
                Button(action: {
                    viewModel.sortOption = option // Set selected sort option
                    viewModel.sortGoals() // Apply the sorting
                }) {
                    HStack {
                        Text(option.rawValue)
                        // Show checkmark of selected sort option
                        if viewModel.sortOption == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            
            Divider()
            
            // Button to toggle the sorting direction (ascending/descending)
            Button(action: {
                viewModel.sortAscending.toggle()
                viewModel.sortGoals()
            }) {
                HStack {
                    Text(viewModel.sortAscending ? "Ascending" : "Descending")
                    // Show an up or down arrow depending on the direction
                    Image(systemName: viewModel.sortAscending ? "arrow.up" : "arrow.down")
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
            .foregroundColor(colorManager.accentColor)
        }
    }
}


#Preview {
    SortMenuButton(viewModel: GoalsViewModel())
        .environmentObject(ColorManager())
}
