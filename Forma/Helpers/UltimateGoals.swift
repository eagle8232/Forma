import Foundation

enum UltimateGoal: String, CaseIterable {
    case masterDailyStructure = "Master Daily Structure"
    case stopProcrastinating  = "Stop Procrastinating"
    case deepWorkFocus        = "Deep Work Focus"
    case reduceOverwhelm      = "Reduce Overwhelm"
    case improveSleepHygiene  = "Improve Sleep Hygiene"
    case buildHealthyHabits   = "Build Healthy Habits"
    case consistentExercise   = "Consistent Exercise"
    case workLifeBalance      = "Find Work-Life Balance"
    case gainClarity          = "Gain Clarity"
    
    var icon: String {
        switch self {
        case .masterDailyStructure: return "🗓️"
        case .stopProcrastinating:  return "⚡️"
        case .deepWorkFocus:        return "🎯"
        case .reduceOverwhelm:      return "🧘"
        case .improveSleepHygiene:  return "🌙"
        case .buildHealthyHabits:   return "🌱"
        case .consistentExercise:   return "💪"
        case .workLifeBalance:      return "⚖️"
        case .gainClarity:          return "✨"
        }
    }
    
    var description: String {
        switch self {
        case .masterDailyStructure: return "Build a consistent daily flow"
        case .stopProcrastinating:  return "Take action without delay"
        case .deepWorkFocus:        return "Enter your peak flow state"
        case .reduceOverwhelm:      return "Find calm in the chaos"
        case .improveSleepHygiene:  return "Wake up fully restored"
        case .buildHealthyHabits:   return "Small steps, big changes"
        case .consistentExercise:    return "Move your body every day"
        case .workLifeBalance:      return "Harmony between work and life"
        case .gainClarity:         return "Clear mind, clear purpose"
        }
    }
}
