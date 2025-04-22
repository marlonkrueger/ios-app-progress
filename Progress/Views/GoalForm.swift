//
//  GoalForm.swift
//  Progress
//
//  Created by mkrueger on 20.01.25.
//

import SwiftUI

// Form for creating or editing a goal
struct GoalForm: View {
    // Bindings to properties of the goal being edited
    @Binding var title: String
    @Binding var comment: String
    @Binding var endDate: Date
    @Binding var reminderEnabled: Bool
    @Binding var reminderOffset: TimeInterval
    
    @EnvironmentObject var colorManager: ColorManager
    
    var body: some View {
        Section(header: Text("Details")) {
            TextField("Title", text: $title)
            TextField("Comment", text: $comment)
            DatePicker("Time & Date", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
            Toggle("Enable reminder", isOn: $reminderEnabled)
            
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
}

#Preview {
    @State var title = "Test Goal"
    @State var comment = "Test Comment"
    @State var endDate = Date()
    @State var reminderEnabled = false
    @State var reminderOffset = -3600.0
    
    GoalForm(
        title: $title,
        comment: $comment,
        endDate: $endDate,
        reminderEnabled: $reminderEnabled,
        reminderOffset: $reminderOffset
    )
    .environmentObject(ColorManager())
}
