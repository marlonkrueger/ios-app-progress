//
//  EditGoalView.swift
//  Progress
//
//  Created by mkrueger on 13.01.25.
//

import SwiftUI

// View for editing an existing goal
struct EditGoalView: View {
    @Binding var goal: Goal  // Binding for the goal being edited
    @State private var isPresentingSubTaskFormView = false
    @State private var editingSubTaskIndex: Int?  // Index of the subtask being edited
    @EnvironmentObject var colorManager: ColorManager

    // Local state for editing the goal details
    @State private var editedTitle: String
    @State private var editedComment: String
    @State private var editedEndDate: Date
    @State private var reminderEnabled = false
    @State private var reminderOffset: TimeInterval = -3600  // Default: 1 hour before

    // Initializes the editable fields with the goal's current values
    init(goal: Binding<Goal>) {
        _goal = goal
        _editedTitle = State(initialValue: goal.wrappedValue.title)
        _editedComment = State(initialValue: goal.wrappedValue.comment)
        _editedEndDate = State(initialValue: goal.wrappedValue.endDate)
    }

    var body: some View {
        VStack {
            // Showing the goal´s progress bar
            VStack {
                HStack {
                    Text("Progress")
                    Spacer()
                    Text("\(Int(goal.progress * 100))%")
                        .font(.footnote)
                }
                ProgressView(value: goal.progress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .background(colorManager.progressBGColor)
                    .accentColor(colorManager.progressColor)
                    .frame(height: 10)
                    .cornerRadius(5)
                    .scaleEffect(y: goal.progress == 1.0 ? 1.2 : 1.0)
                    .brightness(goal.progress == 1.0 ? 0.1 : 0)
                    .animation(.easeInOut(duration: 0.5), value: goal.progress)
            }
            .padding()

            Form {
                Section(header: Text("Details")) {
                    TextField("Title", text: $editedTitle)
                        .onChange(of: editedTitle) { newValue in
                            goal.title = newValue  // Updates title on change
                        }
                    TextField("Comment", text: $editedComment)
                        .onChange(of: editedComment) { newValue in
                            goal.comment = newValue  // Updates comment on change
                        }
                    DatePicker(
                        "Time & Date", selection: $editedEndDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .onChange(of: editedEndDate) { newValue in
                        goal.endDate = newValue  // Updates time & date on change
                    }
                    Toggle("Enable reminder", isOn: $reminderEnabled)
                    if reminderEnabled {
                        // Picker for reminder offset
                        Picker("When to remind?", selection: $reminderOffset) {
                            Text("1 hour before").tag(-3600.0)
                            Text("1 day before").tag(-86400.0)
                            Text("1 week before").tag(-604800.0)
                            Text("2 weeks before").tag(-604800.0 * 2)
                        }
                        .pickerStyle(.menu)
                    }
                }

                // Sectin for managing subtasks
                Section(header: Text("Subtasks")) {
                    ForEach(goal.subTasks.indices, id: \.self) { index in
                        HStack {
                            VStack(alignment: .leading) {
                                // Subtask row = button to edit
                                Button(action: {
                                    editingSubTaskIndex = index
                                    isPresentingSubTaskFormView = true
                                }) {
                                    VStack(alignment: .leading) {
                                        Text(goal.subTasks[index].title)
                                            .font(.headline)
                                            .foregroundColor(.primary)

                                        if !goal.subTasks[index].comment.isEmpty
                                        {
                                            Text(goal.subTasks[index].comment)
                                                .font(.footnote)
                                                .foregroundColor(.secondary)
                                        }

                                        Text(
                                            "Due: \(goal.subTasks[index].endDate, formatter: dateFormatter)"
                                        )
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())  // Removes default button styling
                            }

                            Spacer()

                            // Button for toggle completion status of the subtask
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    goal.subTasks[index].isCompleted.toggle()
                                }
                            }) {
                                Image(
                                    systemName: goal.subTasks[index].isCompleted
                                        ? "checkmark.circle.fill" : "circle"
                                )
                                .foregroundColor(
                                    goal.subTasks[index].isCompleted
                                        ? colorManager.accentColor : .gray)
                                .scaleEffect(goal.subTasks[index].isCompleted ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: goal.subTasks[index].isCompleted)
                            }
                            .buttonStyle(PlainButtonStyle())  // Removes default button styling
                        }
                    }
                    .onDelete(perform: deleteSubTask)

                    // Add Subtask Button
                    Button(action: {
                        editingSubTaskIndex = nil
                        isPresentingSubTaskFormView = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add Subtask")
                        }
                        .foregroundColor(colorManager.accentColor)
                    }
                }
            }
            .navigationTitle(goal.title)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isPresentingSubTaskFormView) {
                if let index = editingSubTaskIndex {
                    // Editing an existing SubTask
                    SubTaskFormView(
                        mode: .edit,
                        initialSubTask: goal.subTasks[index]
                    ) { updatedSubTask in
                        goal.subTasks[index] = updatedSubTask
                    }
                } else {
                    // Adding a new SubTask
                    SubTaskFormView(mode: .add) { newSubTask in
                        goal.subTasks.append(newSubTask)
                    }
                }
            }
        }
        // Update goal when the view disappears/
        .onDisappear {
            // Only update the fields that are edited directly in this view
            // Don't modify the goal's subtasks which are managed separately
            var updatedGoal = goal
            updatedGoal.title = editedTitle
            updatedGoal.comment = editedComment
            updatedGoal.endDate = editedEndDate
            // Important: Only update if these fields actually changed
            if goal.title != editedTitle || goal.comment != editedComment
                || goal.endDate != editedEndDate
            {
                goal = updatedGoal
            }
        }
    }

    // Deletes subtask
    private func deleteSubTask(at offsets: IndexSet) {
        goal.subTasks.remove(atOffsets: offsets)
    }

    // Date formatter for displaying time and date
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}

#Preview {
    EditGoalView(
        goal: .constant(
            Goal(
                title: "Ziel 1", comment: "Kommentar", endDate: Date(),
                subTasks: [SubTask(title: "Unterziel 1", isCompleted: false)]))
    )
    .environmentObject(ColorManager())
}
