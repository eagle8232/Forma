//
//  AIGenerationViewController.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/17/26.
//

// AIGenerationViewController.swift

import UIKit
import Combine

final class AIGenerationViewController: BaseViewController {
    
    // MARK: - Properties
    
    weak var coordinator: AIGenerationCoordinator?
    private let viewModel = AIGenerationViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Architecting Your\nDay..."
        label.font = .systemFont(ofSize: 36, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private let stepLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .typography(.bodyLarge)
        label.textColor = .accent
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    
    private lazy var loadingView: LoadingView = {
        let view = LoadingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let systemTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .textSecondary
        label.textAlignment = .center
        label.alpha = 0.6
        return label
    }()
    
    private let systemSubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .typography(.caption)
        label.textColor = .textSecondary.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var progressBar: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.progressTintColor = .accent
        progress.trackTintColor = .textSecondary.withAlphaComponent(0.2)
        progress.layer.cornerRadius = 2
        progress.clipsToBounds = true
        return progress
    }()
    
    private let progressPercentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .monospacedSystemFont(ofSize: 12, weight: .medium)
        label.textColor = .textSecondary
        return label
    }()
    
    private let sequenceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        label.textColor = .textSecondary.withAlphaComponent(0.6)
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textColor = .textSecondary.withAlphaComponent(0.7)
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func setupViews() {
        super.setupViews()
        
        view.backgroundColor = .backgroundPrimary
        
        setupLayout()
        bindViewModel()
        
        // Start generation after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.viewModel.startGeneration()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopGeneration()
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {
        // Bind current step
        viewModel.$currentStep
            .receive(on: DispatchQueue.main)
            .sink { [weak self] step in
                self?.updateStep(step)
            }
            .store(in: &cancellables)
        
        // Bind progress
        viewModel.$progress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.progressBar.setProgress(progress, animated: true)
            }
            .store(in: &cancellables)
        
        // Bind progress percentage
        viewModel.$progressPercentage
            .receive(on: DispatchQueue.main)
            .map { "\($0)%" }
            .assign(to: \.text, on: progressPercentLabel)
            .store(in: &cancellables)
        
        // Bind completion
        viewModel.$isCompleted
            .receive(on: DispatchQueue.main)
            .filter { $0 }
            .sink { [weak self] _ in
                self?.handleCompletion()
            }
            .store(in: &cancellables)
        
        // Bind generating state
        viewModel.$isGenerating
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isGenerating in
                if isGenerating {
                    self?.loadingView.startLoadingAnimation()
                } else {
                    self?.loadingView.stopLoadingAnimation()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Private Methods
    
    private func updateStep(_ step: AIGenerationViewModel.GenerationStep) {
        UIView.animate(withDuration: 0.2, animations: {
            self.stepLabel.alpha = 0
        }) { _ in
            self.stepLabel.text = step.title
            UIView.animate(withDuration: 0.3) {
                self.stepLabel.alpha = 1
            }
        }
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    private func handleCompletion() {
        // Success haptic
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Brief delay then navigate
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            let newGeneratedRoutines: [RoutineBlock] = [.mockMorning, .mockWork, .mockEvening]
            coordinator?.showResultsScreen(routines: newGeneratedRoutines)
        }
    }
}


// MARK: - Setup Layout
extension AIGenerationViewController {
    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(stepLabel)
        view.addSubview(loadingView)
        view.addSubview(systemTitleLabel)
        view.addSubview(systemSubtitleLabel)
        view.addSubview(progressBar)
        view.addSubview(progressPercentLabel)
        view.addSubview(sequenceLabel)
        view.addSubview(statusLabel)
        
        // Set static text from ViewModel
        systemTitleLabel.text = viewModel.systemTitle
        systemSubtitleLabel.text = viewModel.systemSubtitle
        sequenceLabel.text = viewModel.sequenceID
        statusLabel.text = viewModel.statusText
        
        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            // Step label
            stepLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            stepLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stepLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            // Loading view
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            loadingView.widthAnchor.constraint(equalToConstant: 280),
            loadingView.heightAnchor.constraint(equalToConstant: 150),
            
            // System title
            systemTitleLabel.topAnchor.constraint(equalTo: loadingView.bottomAnchor, constant: 60),
            systemTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // System subtitle
            systemSubtitleLabel.topAnchor.constraint(equalTo: systemTitleLabel.bottomAnchor, constant: 4),
            systemSubtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            systemSubtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Progress bar
            progressBar.topAnchor.constraint(equalTo: systemSubtitleLabel.bottomAnchor, constant: 32),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            progressBar.heightAnchor.constraint(equalToConstant: 4),
            
            // Progress info
            sequenceLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 8),
            sequenceLabel.leadingAnchor.constraint(equalTo: progressBar.leadingAnchor),
            
            progressPercentLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 8),
            progressPercentLabel.trailingAnchor.constraint(equalTo: progressBar.trailingAnchor),
            
            // Status
            statusLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
