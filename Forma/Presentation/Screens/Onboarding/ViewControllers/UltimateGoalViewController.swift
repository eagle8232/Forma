//
//  UltimateGoalViewController.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/15/26.
//

import UIKit

final class UltimateGoalViewController: OnboardingBaseViewController {
    
    // MARK: - Properties
    
    weak var coordinator: OnboardingCoordinator?
    var userPreferences: UserPreferences?
    
    var goals: [UltimateGoal] = []
    
    // MARK: - UI Components
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        scroll.alwaysBounceVertical = true
        return scroll
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .fill
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        return stack
    }()
    
    lazy var goalsGrid: MultiSelectGoalGridView = {
        let view = MultiSelectGoalGridView(maxSelections: 3)
        view.delegate = self
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func setupViews() {
        super.setupViews()
        
        setupViews(
            onboardingTitle: "Define your\nultimate goal.",
            onboardingSubtitle: "Select up to 3 intentions. We will optimize your AI-generated routines to achieve these outcomes.",
            highlightedWord: "ultimate goal.",
            buttonTitle: "✨ Generate My First Routine"
        )
        
        button.isEnabled = false // Disable the button at the first start, as nothing was selected yet
        
        delegate = self
        setupLayout()
    }
    
    
    // MARK: - Setup
    
    private func setupLayout() {
        textView.removeFromSuperview()
        
        view.insertSubview(scrollView, at: 0)
        scrollView.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(textView)
        contentStackView.addArrangedSubview(goalsGrid)
        
        NSLayoutConstraint.activate([
            // MARK: ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // MARK: ContentStack
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 8),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 8),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -8),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -80),
            
            // ✅ Vertical scroll only
            contentStackView.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor,
                constant: -16
            )
        ])
        
        goalsGrid.animateIn()
    }
}

extension UltimateGoalViewController: MultiSelectGoalGridViewDelegate {
    func multiSelectGoalGridView(_ view: MultiSelectGoalGridView, didUpdateSelections goals: [UltimateGoal]) {
        self.goals = goals
        button.isEnabled = goals.isEmpty ? false : true
    }
    
    func multiSelectGoalGridView(_ view: MultiSelectGoalGridView, didReachMaxSelections maxCount: Int) {
        
    }
}

extension UltimateGoalViewController: OnboardingBaseViewControllerDelegate {
    func didTapButton(_ view: OnboardingBaseViewController) {
        guard var userPreferences else { return }
        userPreferences.goal = goals.map {$0.rawValue}
        coordinator?.didFinishOnboarding(userPreferences)
    }
}
