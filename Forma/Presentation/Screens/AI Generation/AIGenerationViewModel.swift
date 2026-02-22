//
//  AIGenerationViewModel.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/18/26.
//

import Foundation
import Combine

final class AIGenerationViewModel {
    
    // MARK: - Published Properties
    
    @Published private(set) var currentStep: GenerationStep = .analyzing
    @Published private(set) var progress: Float = 0.0
    @Published private(set) var progressPercentage: Int = 0
    @Published private(set) var isGenerating: Bool = false
    @Published private(set) var isCompleted: Bool = false
    @Published private(set) var generationError: Error?
    
    // MARK: - Private Properties
    
    private var timer: Timer?
    private let progressIncrement: Float = 0.008 // ~6 seconds to complete
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Generation Steps
    
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
    
    // MARK: - Initialization
    
    init() {
        setupObservers()
    }
    
    deinit {
        stopGeneration()
    }
    
    // MARK: - Setup
    
    private func setupObservers() {
        // Update percentage when progress changes
        $progress
            .map { Int($0 * 100) }
            .assign(to: &$progressPercentage)
    }
    
    // MARK: - Public Methods
    
    func startGeneration() {
        guard !isGenerating else { return }
        
        isGenerating = true
        currentStep = .analyzing
        progress = 0.0
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
    }
    
    func stopGeneration() {
        timer?.invalidate()
        timer = nil
        isGenerating = false
    }
    
    func reset() {
        stopGeneration()
        currentStep = .analyzing
        progress = 0.0
        isCompleted = false
        generationError = nil
    }
    
    // MARK: - Private Methods
    
    private func updateProgress() {
        progress += progressIncrement
        progress = min(progress, 1.0) // Cap at 100%
        
        // Update step based on progress
        updateCurrentStep()
        
        // Check completion
        if progress >= 1.0 {
            completeGeneration()
        }
    }
    
    private func updateCurrentStep() {
        for step in GenerationStep.allCases {
            if progress >= step.progressThreshold && currentStep.rawValue < step.rawValue {
                currentStep = step
                break
            }
        }
    }
    
    private func completeGeneration() {
        stopGeneration()
        isCompleted = true
        
        // Simulate API call or processing
        // In real app, this would save to backend
        print("✅ Generation completed")
    }
}

// MARK: - Helper Computed Properties

extension AIGenerationViewModel {
    
    var stepTitle: String {
        currentStep.title
    }
    
    var progressText: String {
        "\(progressPercentage)%"
    }
    
    var sequenceID: String {
        "SEQ_0482_OPTIMIZE"
    }
    
    var statusText: String {
        "● PROCESSING USER INPUTS"
    }
    
    var systemTitle: String {
        "FORMA AI SYSTEM"
    }
    
    var systemSubtitle: String {
        "Mapping focus blocks & curating narrative scenes"
    }
}
