import Foundation

struct AIQuestion: Identifiable, Codable {
    let id: String
    let text: String
    let type: QuestionType
    let options: [AIQuestionOption]

    enum QuestionType: String, Codable {
        case singleChoice = "single_choice"
        case multiChoice = "multi_choice"
        case yesNo = "yes_no"
    }
}

struct AIQuestionOption: Identifiable, Codable {
    let id: String
    let label: String
    var emoji: String?
}

struct AIQuestionsResponse: Codable {
    let message: String?
    let questions: [AIQuestion]
}

struct AIAnswer {
    let questionId: String
    let selectedIds: [String]
    var selectedLabels: [String] = []

    var firstLabel: String? { selectedLabels.first }
    var isAnswered: Bool { !selectedIds.isEmpty }
}
