//
//  GoalsViewModel.swift
//  Progress
//
//  Created by mkrueger on 19.01.25.
//

import Foundation
import SwiftUI
import UserNotifications

class GoalsViewModel: ObservableObject {
    @Published var allGoals: [Goal] = []  // List of all goals (not filtered)
    @Published var filterOption: FilterOption = .all {
        didSet { filterGoals() }  // Filters goals whenever new filter is chosen
    }  // Currently selected filter option
    @Published var sortOption: GoalSortOption = .alphabetical {
        didSet { sortGoals() }  // Sorts goals whenever new sort option is chosen
    }  // Currently selected sort option
    @Published var sortAscending: Bool = true {
        didSet { sortGoals() }  // Sorts goals ascending whenever it is chosen
    }

    // Computed property for filtered and sorted goals
    @Published var goals: [Goal] = []

    // Initializes the ViewModel by loading saved goals
    init() {
        loadAllGoals()
        filterGoals()
    }

    // Loads saved goals from UserDefaults
    private func loadAllGoals() {
        if let savedGoals = UserDefaults.standard.data(forKey: "savedGoals"),
            let decodedGoals = try? JSONDecoder().decode(
                [Goal].self, from: savedGoals)
        {
            allGoals = decodedGoals
            goals = allGoals
        }
    }

    // Filters the goals based on the selected filter option
    func filterGoals() {
        let filteredByArchive: [Goal]
        
        // First apply archive filtering - only show archived goals when explicitly requested
        if filterOption == .archived {
            filteredByArchive = allGoals.filter { $0.isArchived }
        } else {
            filteredByArchive = allGoals.filter { !$0.isArchived }
        }
        
        // Then apply the specific filter to the archive-filtered list
        switch filterOption {
        case .all:
            goals = filteredByArchive // Already filtered by archive status
        case .favorites:
            goals = filteredByArchive.filter { $0.isFavorite }
        case .archived:
            goals = filteredByArchive // Already contains only archived goals
        case .incomplete:
            goals = filteredByArchive.filter { $0.progress < 1.0 }
        }
        
        sortGoals()
    }

    // Sorts the filtered goals based on the selected sort option
    func sortGoals() {
        goals.sort { first, second in
            let result: Bool

            switch sortOption {
            case .alphabetical:
                result =
                    first.title.localizedCompare(second.title)
                    == .orderedAscending
            case .progress:
                result = first.progress < second.progress
            case .dueDate:
                result = first.endDate < second.endDate
            case .favorites:
                if first.isFavorite == second.isFavorite {
                    // Sort favorites first; fallback to alphabetical order
                    result =
                        first.title.localizedCompare(second.title)
                        == .orderedAscending
                } else {
                    result = first.isFavorite && !second.isFavorite
                }
            }

            return sortAscending ? result : !result
        }
    }

    func addGoal(_ goal: Goal) {
        // Always add to allGoals
        allGoals.append(goal)

        // Only add to the filtered goals if it meets the current filter criteria
        let shouldAddToFiltered = shouldIncludeInCurrentFilter(goal)
        if shouldAddToFiltered {
            goals.append(goal)
        }

        saveGoals()
    }

    // Deletes a goal at the specified index
    func deleteGoal(at indexSet: IndexSet) {
        // Get the IDs of goals to delete
        let idsToDelete = indexSet.map { goals[$0].id }

        // Remove from filtered goals
        goals.remove(atOffsets: indexSet)

        for id in idsToDelete {
            if let index = allGoals.firstIndex(where: { $0.id == id }) {
                allGoals.remove(at: index)
            }
        }

        saveGoals()
    }

    // Updates an existing goal
    func updateGoal(_ goal: Goal) {
        // First update in the allGoals array
        if let allIndex = allGoals.firstIndex(where: { $0.id == goal.id }) {
            allGoals[allIndex] = goal
        }

        // Then update in the filtered goals array if it exists
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
        }

        //filterGoals()
        saveGoals()
    }

    // Calculates the overall progress of all displayed goals
    func calculateOverallProgress() -> Double {
        // Filter out archived goals for the progress calculation
        let activeGoals = allGoals.filter { !$0.isArchived }
        
        guard !activeGoals.isEmpty else { return 0.0 }
        let totalProgress = activeGoals.reduce(0.0) { $0 + $1.progress }
        return totalProgress / Double(activeGoals.count)
    }

    // Saves the current list of goals to UserDefaults
    private func saveGoals() {
        if let encoded = try? JSONEncoder().encode(allGoals) {
            UserDefaults.standard.set(encoded, forKey: "savedGoals")
        }
    }

    // Helper function to determine if a goal should be included in the current filter
    private func shouldIncludeInCurrentFilter(_ goal: Goal) -> Bool {
        switch filterOption {
        case .all:
            return true
        case .favorites:
            return goal.isFavorite
        case .archived:
            return goal.isArchived
        case .incomplete:
            return goal.progress < 1.0
        }
    }

    // Schedules a reminder notification for a specific goal
    func scheduleReminder(for goal: Goal, offset: TimeInterval) -> Result<
        Void, Error
    > {
        let reminderDate = goal.endDate.addingTimeInterval(offset)

        // Configure the notification content
        let content = UNMutableNotificationContent()
        content.title = "Reminder: \(goal.title)"
        content.body =
            goal.comment.isEmpty ? "Time to work on your goal!" : goal.comment
        content.sound = .default

        // Set up the notification trigger
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute], from: reminderDate),
            repeats: false
        )

        // Create and add the notification request
        let request = UNNotificationRequest(
            identifier: UUID().uuidString, content: content, trigger: trigger)

        var resultError: Error?
        let semaphore = DispatchSemaphore(value: 0)

        UNUserNotificationCenter.current().add(request) { error in
            resultError = error
            semaphore.signal()
        }

        semaphore.wait()

        // Return success or failure based on the result
        if let error = resultError {
            return .failure(error)
        }
        return .success(())
    }
}
