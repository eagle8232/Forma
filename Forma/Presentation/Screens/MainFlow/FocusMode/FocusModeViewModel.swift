import SwiftUI

@MainActor
final class FocusModeViewModel: ObservableObject {

    // MARK: - Input
    let task: RoutineTask
    let routineName: String
    let profession: String

    // MARK: - Timer
    @Published var remainingSeconds: Int
    @Published var progressFraction: Double = 0.0
    @Published var breatheCue: String = "breathe · stay present"

    // MARK: - Sound
    enum SoundEnvironment: String, CaseIterable, Identifiable {
        case silence, rain, ocean, forest, fire, note
        var id: String { rawValue }

        var emoji: String {
            switch self {
            case .silence: return "🔇"
            case .rain:    return "🌧"
            case .ocean:   return "🌊"
            case .forest:  return "🌿"
            case .fire:     return "🔥"
            case .note:    return "📝"
            }
        }

        var label: String {
            switch self {
            case .silence: return "Silence"
            case .rain:    return "Rain"
            case .ocean:   return "Ocean"
            case .forest:  return "Forest"
            case .fire:     return "Fire"
            case .note:     return "Note"
            }
        }

        var orbInnerColor: Color {
            switch self {
            case .silence: return Color(red: 0.10, green: 0.12, blue: 0.25)
            case .rain:     return Color(red: 0.05, green: 0.11, blue: 0.17)
            case .ocean:   return Color(red: 0.04, green: 0.40, blue: 0.33)
            case .forest:  return Color(red: 0.04, green: 0.35, blue: 0.20)
            case .fire:     return Color(red: 0.49, green: 0.18, blue: 0.05)
            case .note:     return Color(red: 0.37, green: 0.30, blue: 0.22)
            }
        }

        var orbOuterColor: Color {
            switch self {
            case .silence: return Color(red: 0.06, green: 0.08, blue: 0.24)
            case .rain:     return Color(red: 0.16, green: 0.50, blue: 0.72)
            case .ocean:    return Color(red: 0.17, green: 0.73, blue: 0.61)
            case .forest:   return Color(red: 0.15, green: 0.68, blue: 0.38)
            case .fire:     return Color(red: 0.91, green: 0.30, blue: 0.24)
            case .note:     return Color(red: 0.79, green: 0.66, blue: 0.43)
            }
        }

        var ambientColor: Color {
            switch self {
            case .silence: return Color(red: 0.06, green: 0.12, blue: 0.31).opacity(0.18)
            case .rain:     return Color(red: 0.11, green: 0.34, blue: 0.55).opacity(0.20)
            case .ocean:    return Color(red: 0.10, green: 0.74, blue: 0.61).opacity(0.15)
            case .forest:   return Color(red: 0.15, green: 0.68, blue: 0.38).opacity(0.14)
            case .fire:     return Color(red: 0.71, green: 0.20, blue: 0.08).opacity(0.18)
            case .note:     return Color(red: 0.63, green: 0.47, blue: 0.24).opacity(0.16)
            }
        }

        var glowColor: Color {
            switch self {
            case .silence: return Color(red: 0.12, green: 0.20, blue: 0.50).opacity(0.35)
            case .rain:     return Color(red: 0.16, green: 0.50, blue: 0.73).opacity(0.40)
            case .ocean:    return Color(red: 0.10, green: 0.74, blue: 0.61).opacity(0.40)
            case .forest:   return Color(red: 0.15, green: 0.68, blue: 0.38).opacity(0.40)
            case .fire:     return Color(red: 0.91, green: 0.30, blue: 0.24).opacity(0.45)
            case .note:     return Color(red: 0.79, green: 0.66, blue: 0.43).opacity(0.40)
            }
        }
    }

    @Published var activeSound: SoundEnvironment = .rain
    @Published var soundMenuOpen: Bool = false

    // MARK: - Insight
    @Published var currentInsight: String = ""
    @Published var insightPhase: InsightPhase = .hidden

    enum InsightPhase: Equatable {
        case hidden, entering, floating, leaving
    }

    // MARK: - Sheets
    @Published var showStepAway: Bool = false
    @Published var showAIOverlay: Bool = false

    // MARK: - Computed
    var remainingFormatted: String {
        let totalMinutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        if totalMinutes >= 60 {
            let hours = totalMinutes / 60
            let mins = totalMinutes % 60
            return mins > 0 ? "\(hours)h \(mins)m" : "\(hours)h"
        }
        return String(format: "%02d:%02d", totalMinutes, seconds)
    }

    var elapsedMinutes: Int {
        (task.duration * 60 - remainingSeconds) / 60
    }

    var taskLine1: String {
        let words = task.title.split(separator: " ")
        return words.prefix((words.count + 1) / 2).joined(separator: " ")
    }

    var taskLine2: String {
        let words = task.title.split(separator: " ")
        let half = (words.count + 1) / 2
        return words.dropFirst(half).joined(separator: " ")
    }

    private var insights: [String] {
        let p = profession.lowercased()
        if p.contains("develop") || p.contains("engineer") {
            return [
                "Break it into\nthe next step",
                "You've solved\nharder than this",
                "Read it once more",
                "Clarity now,\nless bugs later",
                "You're in\nthe zone",
                "Trust your\ninstincts",
            ]
        }
        if p.contains("design") {
            return [
                "Constraints are\nyour best friends",
                "Step back.\nLook again.",
                "One element\nat a time",
                "Does it serve\nthe user?",
            ]
        }
        return [
            "One thing\nat a time",
            "You are capable\nof this",
            "Stay with it\na little longer",
            "Clarity comes\nthrough doing",
        ]
    }

    private let breatheCues = [
        "breathe · stay present",
        "inhale slowly",
        "exhale fully",
        "you are here",
        "let it go",
        "back to the work",
    ]

    // MARK: - Private
    private var timerTask: Task<Void, Never>?
    private var insightTask: Task<Void, Never>?
    private var insightIndex = 0
    private let totalSeconds: Int

    // MARK: - Init
    init(task: RoutineTask, routineName: String, profession: String) {
        self.task = task
        self.routineName = routineName
        self.profession = profession
        self.totalSeconds = task.duration * 60
        self.remainingSeconds = task.duration * 60
    }

    // MARK: - Lifecycle
    func onAppear() {
        startTimer()
        insightTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(4))
            await self?.showNextInsight()
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(30))
                await self?.showNextInsight()
            }
        }
    }

    func onDisappear() {
        timerTask?.cancel()
        insightTask?.cancel()
    }

    // MARK: - Timer
    private func startTimer() {
        timerTask = Task { [weak self] in
            guard let self else { return }
            while self.remainingSeconds > 0 && !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                self.remainingSeconds -= 1
                self.progressFraction = Double(self.totalSeconds - self.remainingSeconds) / Double(self.totalSeconds)
                let elapsed = self.totalSeconds - self.remainingSeconds
                self.breatheCue = self.breatheCues[(elapsed / 14) % self.breatheCues.count]
            }
        }
    }

    func addTime(_ minutes: Int) {
        remainingSeconds += minutes * 60
    }

    // MARK: - Insights
    @MainActor
    private func showNextInsight() async {
        let text = insights[insightIndex % insights.count]
        insightIndex += 1
        currentInsight = text

        withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
            insightPhase = .entering
        }
        try? await Task.sleep(for: .seconds(1.2))

        withAnimation(.easeInOut(duration: 5)) {
            insightPhase = .floating
        }
        try? await Task.sleep(for: .seconds(5.8))

        withAnimation(.easeIn(duration: 1.2)) {
            insightPhase = .leaving
        }
        try? await Task.sleep(for: .seconds(1.2))

        insightPhase = .hidden
        currentInsight = ""
    }
}
