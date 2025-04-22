//
//  Models.swift
//  Progress
//
//  Created by mkrueger on 13.01.25.
//

import Foundation
import SwiftData

// Represents a goal with its properties
struct Goal: Identifiable, Codable {
    var id = UUID()
    var title: String
    var comment: String
    var endDate: Date
    var subTasks: [SubTask]
    var isFavorite: Bool = false
    var isArchived: Bool = false
    // Computed property to determine if the goal is fully completed
    // A goal is completed if all its subtasks are completed
    var isCompleted: Bool {
        return subTasks.allSatisfy { $0.isCompleted }
    }
    
    // Computed property to calculate the progress of the goal
    // Progress is calculated as the ratio of completed subtasks to total subtasks
    var progress: Double {
        let completed = subTasks.filter { $0.isCompleted }.count
        return subTasks.isEmpty ? 0 : Double(completed) / Double(subTasks.count)
    }
}

// Represents a SubTask, which is part of a goal
struct SubTask: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var isCompleted: Bool
    var comment: String = ""
    var endDate: Date = Date()
    var reminderEnabled: Bool = false
    var reminderOffset: TimeInterval = -3600.0
}

// Enum to define sorting options for goals
enum GoalSortOption: String, CaseIterable {
    case alphabetical = "Title"
    case progress = "Progress"
    case dueDate = "Due Date"
    case favorites = "Favorites"
}

// Enum to define filtering options for goals
enum FilterOption: String, CaseIterable {
    case all = "All"
    case favorites = "Favorites"
    case archived = "Archived"
    case incomplete = "Incomplete"
}
