//
//  SubTaskFormView.swift
//  Progress
//
//  Created by mkrueger on 19.01.25.
//

import SwiftUI

// View for creating or editing a subtask
struct SubTaskFormView: View {
    // Enum to distinguish between add and edit modes
    enum Mode {
        case add
        case edit
    }
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var colorManager: ColorManager
    
    let mode: Mode // Current mode (add or edit)
    var initialSubTask: SubTask? // Optional initial subtask for edit mode
    var onSave: (SubTask) -> Void // Closure to handle saving the subtask
    
    // State variables to bind the UI elements
    @State private var title: String = ""
    @State private var comment: String = ""
    @State private var endDate: Date = Date()
    @State private var reminderEnabled: Bool = false
    @State private var reminderOffset: TimeInterval = -3600.0 // Default: 1 hour before

    // Initialize the view with the mode, initial subtask, and onSave closure
    init(mode: Mode, initialSubTask: SubTask? = nil, onSave: @escaping (SubTask) -> Void) {
        self.mode = mode
        self.initialSubTask = initialSubTask
        self.onSave = onSave
        
        // Set initial state values if editing
        if let subTask = initialSubTask {
            _title = State(initialValue: subTask.title)
            _comment = State(initialValue: subTask.comment)
            _endDate = State(initialValue: subTask.endDate)
            _reminderEnabled = State(initialValue: subTask.reminderEnabled)
            _reminderOffset = State(initialValue: subTask.reminderOffset)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Title", text: $title)
                    TextField("Comment", text: $comment)
                    DatePicker("Due Date", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                    Toggle("Enable Reminder", isOn: $reminderEnabled)
                    
                    if reminderEnabled {
                        Picker("When to remind?", selection: $reminderOffset) {
                            Text("1 hour before").tag(-3600.0)
                            Text("1 day before").tag(-86400.0)
                            Text("1 week before").tag(-604800.0)
                            Text("2 weeks before").tag(-604800.0 * 2)
                        }
                        .pickerStyle(.menu)
                    }
                }
            }
            .navigationTitle(mode == .add ? "Add Subtask" : "Edit Subtask")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSubTask()
                    }
                    .disabled(title.isEmpty)
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
    
    // Function to save the subtask and use onSave closure
    private func saveSubTask() {
        let subTask = SubTask(
            title: title,
            isCompleted: initialSubTask?.isCompleted ?? false,
            comment: comment,
            endDate: endDate,
            reminderEnabled: reminderEnabled,
            reminderOffset: reminderOffset // Add this to pass the offset
        )
        onSave(subTask)
        dismiss()
    }
}

#Preview {
    SubTaskFormView(mode: .add, onSave: { _ in })
        .environmentObject(ColorManager())
}
