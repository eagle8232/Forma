//
//  AIAssistantViewModel.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/21/26.
//

import SwiftUI
import Combine

// MARK: - Message Model

struct AIMessage: Identifiable, Equatable {
    let id = UUID()
    let role: Role
    var content: String
    var isStreaming: Bool = false
    let timestamp: Date = Date()

    enum Role { case user, assistant }
}

// MARK: - AIAssistantViewModel

@MainActor
final class AIAssistantViewModel: ObservableObject {

    // MARK: - Published

    @Published var messages:      [AIMessage] = []
    @Published var inputText:     String = ""
    @Published var isLoading:     Bool = false
    @Published var errorMessage:  String? = nil
    @Published var showSuggestions: Bool = true

    // MARK: - Context passed in from home

    let routine:  RoutineBlock?
    let tasks:    [RoutineTask]

    // MARK: - Suggestions

    let suggestions: [String] = [
        "Optimize my morning",
        "Why am I behind?",
        "Add a focus block",
        "Reschedule today",
        "Suggest a wind-down"
    ]

    // MARK: - Init

    init(routine: RoutineBlock? = nil, tasks: [RoutineTask] = []) {
        self.routine = routine
        self.tasks   = tasks
    }

    // MARK: - Send

    func send() {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty, !isLoading else { return }

        inputText = ""
        showSuggestions = false

        let userMsg = AIMessage(role: .user, content: text)
        messages.append(userMsg)

        Task { await ask(text) }
    }

    func sendSuggestion(_ text: String) {
        inputText = text
        send()
    }

    // MARK: - Clear

    func clearConversation() {
        messages.removeAll()
        showSuggestions = true
        errorMessage = nil
    }

    // MARK: - API call

    private func ask(_ prompt: String) async {
        isLoading = true
        errorMessage = nil

        // Placeholder streaming assistant bubble
        var assistantMsg = AIMessage(role: .assistant, content: "", isStreaming: true)
        messages.append(assistantMsg)
        let idx = messages.count - 1

        do {
            let fullPrompt = buildPrompt(userMessage: prompt)
            let response   = try await callAI(prompt: fullPrompt)

            // Simulate streaming character by character
            for char in response {
                try await Task.sleep(for: .milliseconds(12))
                messages[idx].content.append(char)
            }
            messages[idx].isStreaming = false

        } catch {
            messages[idx].content    = "Sorry, I couldn't process that. Please try again."
            messages[idx].isStreaming = false
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Prompt builder

    private func buildPrompt(userMessage: String) -> String {
        var context = "You are Forma AI, a smart assistant built into the Forma routine app. Be concise, helpful, and warm.\n\n"

        if let routine {
            context += "Current routine: \(routine.title) (\(routine.startTime) – \(routine.endTime))\n"
            if !tasks.isEmpty {
                let taskList = tasks.map { "- \($0.title) (\($0.startTime), \($0.durationText))" }.joined(separator: "\n")
                context += "Tasks:\n\(taskList)\n\n"
            }
        }

        context += "User: \(userMessage)"
        return context
    }

    // MARK: - AI call (Gemini / your existing API)
    // Replace this with your actual AI provider call

    private func callAI(prompt: String) async throws -> String {
        // Wire to your existing GenerateRoutineUseCase or a dedicated chat endpoint
        // Placeholder response for now:
        return "I can see you're working on your \(routine?.title ?? "routine"). Based on your schedule, here's what I'd suggest: try batching similar tasks together to reduce context switching. Would you like me to reorganize anything?"
    }
}
