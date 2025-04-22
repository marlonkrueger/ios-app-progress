//
//  ContentView.swift
//  Progress
//
//  Created by mkrueger on 13.01.25.
//

import SwiftUI

// Main view of the app
struct GoalsView: View {
    @StateObject private var viewModel = GoalsViewModel()
    @State private var isPresentingAddGoalView = false
    @State private var isPresentingSettingsView = false
    @EnvironmentObject var colorManager: ColorManager
    
    var body: some View {
        NavigationView {
            VStack {
                // Displays overall progress bar
                OverallProgressView(progress: viewModel.calculateOverallProgress())
                    .padding(.horizontal)
                    .padding(.top, 48)
                    .padding(.bottom, 24)
                
                // List of goals
                VStack(spacing: 0) {
                    // Filter and Sort Menu
                    HStack {
                        FilterMenuButton(viewModel: viewModel)
                        Spacer()
                        SortMenuButton(viewModel: viewModel)
                    }
                    .padding()
                    
                    // Displays list of goals
                    GoalListView(viewModel: viewModel)
                        .onAppear {
                            viewModel.filterGoals()
                        }
                }
                
                // Opens AddGoalView to add new goal
                AddGoalButton(isPresentingAddGoalView: $isPresentingAddGoalView)
            }
            .navigationTitle("Progress")
            .toolbar {
                // Settings button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isPresentingSettingsView = true }) {
                        Image(systemName: "gearshape")
                            .foregroundColor(colorManager.accentColor)
                    }
                }
            }
            .sheet(isPresented: $isPresentingAddGoalView) {
                AddGoalView(viewModel: viewModel)
            }
            .sheet(isPresented: $isPresentingSettingsView) {
                SettingsView()
            }
        }
    }
}

#Preview {
    GoalsView()
        .environmentObject(ColorManager())
}
