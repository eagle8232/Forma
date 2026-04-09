//
//  SleepScheduleEditViewModel.swift
//  Forma
//
//  Created by Vusal Nuriyev on 4/5/26.
//

import SwiftUI
import Combine

@MainActor
final class SleepScheduleEditViewModel: ObservableObject {

    // MARK: - Editable times
    @Published var wakeTime: Date
    @Published var sleepTime: Date

    // MARK: - Scope
    enum Scope: String, CaseIterable {
        case today    = "Today only"
        case everyday = "Every day"
        case weekdays = "Weekdays"

        var icon: String {
            switch self {
            case .today:    return "📅"
            case .everyday: return "♾️"
            case .weekdays: return "📆"
            }
        }

        var subtitle: String {
            switch self {
            case .today:    return "One-time"
            case .everyday: return "New schedule"
            case .weekdays: return "Mon – Fri"
            }
        }
    }
    @Published var selectedScope: Scope = .today

    // MARK: - UI State
    @Published var showImpactSheet: Bool = false
    @Published var showRebuildOverlay: Bool = false
    @Published var rebuildStep: Int = 0
    @Published var isComplete: Bool = false

    // MARK: - Original values
    private let originalWake: Date
    private let originalSleep: Date

    // MARK: - Computed
    var hasChanges: Bool {
        wakeTime != originalWake || sleepTime != originalSleep
    }

    var awakeDuration: String {
        let cal = Calendar.current
        var wakeMin = cal.component(.hour, from: wakeTime) * 60 + cal.component(.minute, from: wakeTime)
        var sleepMin = cal.component(.hour, from: sleepTime) * 60 + cal.component(.minute, from: sleepTime)
        if sleepMin <= wakeMin { sleepMin += 24 * 60 }
        let diff = sleepMin - wakeMin
        let h = diff / 60
        let m = diff % 60
        return m > 0 ? "\(h)h \(m)m" : "\(h)h"
    }

    var wakeFormatted: String { formatTime(wakeTime) }
    var sleepFormatted: String { formatTime(sleepTime) }

    var affectedRoutines: [AffectedRoutine] {
        guard hasChanges else { return [] }
        return [
            AffectedRoutine(icon: "🌅", name: "Morning Ritual",
                           before: "06:30–08:00", after: "08:00–08:30", impact: .shorter),
            AffectedRoutine(icon: "✍️", name: "Journaling",
                           before: "08:00–08:30", after: "08:30–09:00", impact: .shifted),
            AffectedRoutine(icon: "📖", name: "Mindful Reading",
                           before: "06:00–06:30", after: "Removed", impact: .removed),
        ]
    }

    // MARK: - Init
    init(preferences: UserPreferences) {
        self.wakeTime      = preferences.wakeUpTime
        self.sleepTime     = preferences.sleepTime
        self.originalWake  = preferences.wakeUpTime
        self.originalSleep = preferences.sleepTime
    }

    // MARK: - Actions
    func didTapSave() {
        guard hasChanges else { return }
        showImpactSheet = true
    }

    func startAIRebuild(onComplete: @escaping (UserPreferences) -> Void) {
        showImpactSheet  = false
        showRebuildOverlay = true
        rebuildStep = 0

        let steps = 4
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.9) {
                self.rebuildStep = i
                if i == steps {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        self.showRebuildOverlay = false
                        self.isComplete = true
                    }
                }
            }
        }
    }

    // MARK: - Helpers
    private func formatTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }
}

// MARK: - Supporting types

struct AffectedRoutine: Identifiable {
    let id = UUID()
    let icon: String
    let name: String
    let before: String
    let after: String
    let impact: Impact

    enum Impact {
        case shifted, shorter, removed

        var label: String {
            switch self {
            case .shifted:  return "Shifted"
            case .shorter:  return "Shorter"
            case .removed:  return "Removed"
            }
        }

        var color: Color {
            switch self {
            case .shifted:  return Color(hex: "#A259FF")
            case .shorter:  return Color(hex: "#E8A84A")
            case .removed:  return Color(hex: "#FF5050").opacity(0.8)
            }
        }

        var background: Color {
            switch self {
            case .shifted:  return Color(hex: "#A259FF").opacity(0.12)
            case .shorter:  return Color(hex: "#E8A84A").opacity(0.1)
            case .removed:  return Color(hex: "#FF5050").opacity(0.1)
            }
        }
    }
}
