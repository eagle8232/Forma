//
//  AIGenerationViewModel.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/18/26.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class AIGenerationViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    private(set) var currentStep: GenerationStep = .analyzing
    private(set) var progress: Float = 0.0
    private(set) var progressPercentage: Int = 0
    private(set) var isGenerating: Bool = false
    private(set) var isCompleted: Bool = false
    private(set) var generationError: Error?
    private(set) var phase: GenerationPhase = .thinking
    
    // MARK: - Private Properties
    
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    var userPreferences: UserPreferences
    @Published var newGeneratedRoutines: [RoutineBlock] = []
    
    // MARK: - Initialization
    
    init(userPreferences: UserPreferences) {
        self.userPreferences = userPreferences
    }

    deinit {}
    
    // MARK: - Public Methods
    
    func startGeneration() async {
        guard newGeneratedRoutines.isEmpty, !isGenerating else { return }
        await generateRoutines()
    }
    
    func stopGeneration() {
        withAnimation {
            phase = .done
        }
    }
    
    func reset() {
        stopGeneration()
        currentStep = .analyzing
        progress = 0.0
        isCompleted = false
        generationError = nil
    }
    
    // MARK: - Private Methods
    func generateRoutines() async {
        isGenerating = true
        
        do {
            let makeGenerateRoutineUseCase = DependencyContainer.shared.makeGenerateRoutineUseCase()
            var routinesBuffer: [RoutineBlock] = []
            for await routine in try await makeGenerateRoutineUseCase.execute(userPreferences: userPreferences) {
                let isFirst = newGeneratedRoutines.isEmpty
                routinesBuffer.append(routine)
                self.newGeneratedRoutines = routinesBuffer
                
                withAnimation {
                    phase = isFirst ? .firstArrived : .streaming(count: newGeneratedRoutines.count)
                }
                if isFirst {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    try? await Task.sleep(for: .seconds(0.8))
                    withAnimation { phase = .streaming(count: newGeneratedRoutines.count) }
                } else {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                
                // Check if it is the last routine
                if routine.endTime == DateManager.shared.formatTime(userPreferences.sleepTime) {
                    stopGeneration()
                }
            }
            
        } catch let err {
            print(err.localizedDescription)
            self.generationError = err
        }
        
    }
}

// MARK: - Generation Steps

extension AIGenerationViewModel {
    enum GenerationStep: Int, CaseIterable {
        case analyzing  = 0
        case mapping    = 1
        case optimizing = 2
        case curating   = 3
        case finalizing = 4
        
        var title: String {
            switch self {
            case .analyzing:  return "✨ Analyzing circadian rhythms"
            case .mapping:    return "🧠 Mapping focus blocks"
            case .optimizing: return "🎯 Optimizing energy peaks"
            case .curating:   return "📋 Curating narrative scenes"
            case .finalizing: return "⚡️ Finalizing your routine"
            }
        }
        
        var progressThreshold: Float {
            return Float(rawValue + 1) * 0.2
        }
    }
    
}
