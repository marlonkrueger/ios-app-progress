//
//  FilterMenuButton.swift
//  Progress
//
//  Created by mkrueger on 20.01.25.
//

import SwiftUI

// Filterbutton in ContentView to filter goals
struct FilterMenuButton: View {
    @ObservedObject var viewModel: GoalsViewModel
    @EnvironmentObject var colorManager: ColorManager
    
    var body: some View {
        Menu {
            Button("All") {
                viewModel.filterOption = .all
                viewModel.filterGoals() // Shows all goals
            }
            Button("Favorites") {
                viewModel.filterOption = .favorites
                viewModel.filterGoals() // Shows only favorites
            }
            Button("Incomplete") {
                viewModel.filterOption = .incomplete
                viewModel.filterGoals() // Shows only incomplete goals
            }
            Button("Archived") {
                viewModel.filterOption = .archived
                viewModel.filterGoals() // Shows archived goals
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
                .foregroundColor(colorManager.accentColor)
        }
    }
}

#Preview {
    FilterMenuButton(viewModel: GoalsViewModel())
        .environmentObject(ColorManager())
}
