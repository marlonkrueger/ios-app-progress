//
//  GoalListView.swift
//  Progress
//
//  Created by mkrueger on 20.01.25.
//

import SwiftUI

// Displays list of goals
struct GoalListView: View {
    @ObservedObject var viewModel: GoalsViewModel
    @EnvironmentObject var colorManager: ColorManager

    var body: some View {
        List {
            // Iterate over each goal in the view model
            ForEach(viewModel.goals) { goal in
                NavigationLink(  // Nav link to the chosen goal
                    destination: EditGoalView(
                        goal: binding(for: goal)
                    )
                ) {
                    // Displays the row for each goal
                    GoalRowView(goal: goal, viewModel: viewModel)
                }
                // Favorite or unfavorite goal
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    Button(action: {
                        toggleFavorite(goal)
                    }) {
                        Label(
                            goal.isFavorite ? "Unfavorite" : "Favorite",
                            systemImage: goal.isFavorite ? "star.fill" : "star")
                    }
                    .tint(goal.isFavorite ? .gray : .yellow)
                }
                // Delete, archive or unarchive goal
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(action: {
                        archiveGoal(goal)
                    }) {
                        Label(
                            goal.isArchived ? "Unarchive" : "Archive",
                            systemImage: "archivebox.fill")
                    }
                    .tint(goal.isArchived ? .purple : .green)

                    Button(role: .destructive) {
                        if let index = viewModel.goals.firstIndex(where: {
                            $0.id == goal.id
                        }) {
                            viewModel.deleteGoal(at: IndexSet(integer: index))
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.inset)
    }

    // Function to create a binding for a goal for both the list view and the edit view
    private func binding(for goal: Goal) -> Binding<Goal> {
        Binding(
            get: { goal },
            set: { viewModel.updateGoal($0) }  // Update after change
        )
    }

    // Toggle archived
    private func archiveGoal(_ goal: Goal) {
        var updatedGoal = goal
        updatedGoal.isArchived.toggle()
        viewModel.updateGoal(updatedGoal)

        // Use DispatchQueue.main.async to ensure UI updates are complete,
        // then apply animation to the filtering
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.3)) {
                viewModel.filterGoals()
            }
        }
    }

    // Toggle favorite
    private func toggleFavorite(_ goal: Goal) {
        var updatedGoal = goal
        updatedGoal.isFavorite.toggle()
        viewModel.updateGoal(updatedGoal)

        // Use DispatchQueue.main.async to ensure UI updates are complete,
        // then apply animation to the filtering
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.3)) {
                viewModel.filterGoals()
            }
        }
    }
}

#Preview {
    GoalListView(viewModel: GoalsViewModel())
        .environmentObject(ColorManager())
}
