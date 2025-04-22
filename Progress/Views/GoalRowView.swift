//
//  GoalRowView.swift
//  Progress
//
//  Created by mkrueger on 20.01.25.
//

import SwiftUI

// GoalRow for goals in ContentView
struct GoalRowView: View {
    let goal: Goal
    @EnvironmentObject var colorManager: ColorManager
    @ObservedObject var viewModel: GoalsViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(goal.title)
                    .font(.headline)
                if goal.isFavorite { // Adds star when favorite
                    Image(systemName: "star.fill")
                        .foregroundColor(colorManager.accentColor)
                }
                if goal.isArchived { // Adds archivebox when archived
                    Image(systemName: "archivebox.fill")
                        .foregroundColor(colorManager.accentColor)
                }
                Spacer()
                Text("\(Int(goal.progress * 100))%")
                    .font(.footnote)
            }
            
            // Shows comment only when there is one
            if !goal.comment.isEmpty {
                Text(goal.comment)
                    .font(.footnote)
            }
            
            Text("Due: \(goal.endDate, formatter: dateFormatter)")
                .font(.footnote)
                .foregroundColor(.gray)
            
            ProgressView(value: goal.progress)
                .progressViewStyle(LinearProgressViewStyle())
                .background(colorManager.progressBGColor)
                .accentColor(colorManager.progressColor)
                .frame(height: 10)
        }
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
    GoalRowView(goal: Goal(
        title: "Learn Swift",
        comment: "Work on iOS development with Swift",
        endDate: Date().addingTimeInterval(60 * 60 * 24 * 7), // Eine Woche in der Zukunft
        subTasks: [
            SubTask(title: "Read Swift documentation", isCompleted: true),
            SubTask(title: "Build a simple app", isCompleted: false)
        ],
        isFavorite: true,
        isArchived: false
    ), viewModel: GoalsViewModel())
    .environmentObject(ColorManager())
}
