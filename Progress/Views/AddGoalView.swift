//
//  AddGoalView.swift
//  Progress
//
//  Created by mkrueger on 15.01.25.
//

import SwiftUI
import UserNotifications


// View to add a new goal
struct AddGoalView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: GoalsViewModel
    @EnvironmentObject var colorManager: ColorManager
    
    // State variables for user input and temporary data
    @State private var title: String = ""
    @State private var comment: String = ""
    @State private var endDate: Date = Date()
    @State private var tempSubTasks: [String] = []
    @State private var newSubTaskTitle: String = ""
    @State private var reminderEnabled: Bool = false
    @State private var reminderOffset: TimeInterval = -3600 // Default: 1 Hour before
    
    var body: some View {
        NavigationView {
            Form {
                // Section for goal details
                GoalForm(
                    title: $title,
                    comment: $comment,
                    endDate: $endDate,
                    reminderEnabled: $reminderEnabled,
                    reminderOffset: $reminderOffset
                )
                
                // Section for subtasks
                Section(header: Text("Subtasks")) {
                    ForEach(tempSubTasks, id: \.self) { subTask in
                        Text(subTask)
                    }
                    .onDelete { indexSet in
                        tempSubTasks.remove(atOffsets: indexSet)
                    }
                    
                    // Adding new subtask
                    HStack {
                        TextField("New Subtask", text: $newSubTaskTitle)
                        
                        Button(action: {
                            if !newSubTaskTitle.isEmpty {
                                tempSubTasks.append(newSubTaskTitle)
                                newSubTaskTitle = ""
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(colorManager.accentColor)
                        }
                    }
                }
            }
            .navigationTitle("Add New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveGoal()
                    }
                    .disabled(title.isEmpty) // Title must be set to be able to safe goal
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .tint(colorManager.accentColor)
        }
    }
    
    // Function to save goal
    private func saveGoal() {
        // Add the user input for new subtask to the list
        if !newSubTaskTitle.isEmpty {
            tempSubTasks.append(newSubTaskTitle)
            newSubTaskTitle = ""
        }
        
        // Convert subtask list into SubTask objects
        let subTasks = tempSubTasks.map { SubTask(title: $0, isCompleted: false) }
        
        // Create new goa with entered data
        let newGoal = Goal(title: title, comment: comment, endDate: endDate, subTasks: subTasks)
        
        // Schedule reminder if enabled
        if reminderEnabled {
            _ = viewModel.scheduleReminder(for: newGoal, offset: reminderOffset)
        }
        
        // Add the goal and dismiss the view
        viewModel.addGoal(newGoal)
        dismiss()
    }
}

#Preview {
    // Create a mock GoalsViewModel for the preview
    let previewViewModel = GoalsViewModel()
    
    // Create an example goal for the preview
    let exampleGoal = Goal(
        title: "Example Goal",
        comment: "This is a test goal",
        endDate: Date().addingTimeInterval(86400), // 1 day in the future
        subTasks: [
            SubTask(title: "First subtask", isCompleted: false),
            SubTask(title: "Second subtask", isCompleted: true)
        ]
    )
    
    // Add the example goal to the mock view model
    previewViewModel.addGoal(exampleGoal)
    
    // Return the AddGoalView with the mock data and color manager for the preview
    return AddGoalView(viewModel: previewViewModel)
        .environmentObject(ColorManager())
}
