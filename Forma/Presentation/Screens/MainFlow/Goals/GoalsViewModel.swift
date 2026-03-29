//
//  GoalsViewModel.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/21/26.
//

import SwiftUI
import Combine

// MARK: - GoalsViewModel

@MainActor
final class GoalsViewModel: ObservableObject {

    // MARK: - Published

    @Published var activeGoals:   [Goal] = []
    @Published var achievedGoals: [Goal] = []
    @Published var loadState:     LoadState = .idle
    @Published var showAddGoal:   Bool = false

    enum LoadState { case idle, loading, loaded, error(String) }

    // MARK: - Init

    init() {
        load()
    }

    // MARK: - Load

    func load() {
        loadState = .loading
        // Replace with Firestore fetch
        let all = Goal.mocks + [Goal.achievedMock]
        activeGoals   = all.filter { !$0.isAchieved }
        achievedGoals = all.filter { $0.isAchieved }
        loadState = .loaded
    }

    // MARK: - Add

    func add(_ goal: Goal) {
        activeGoals.append(goal)
    }

    // MARK: - Delete

    func delete(_ goal: Goal) {
        activeGoals.removeAll { $0.id == goal.id }
        achievedGoals.removeAll { $0.id == goal.id }
    }
}
