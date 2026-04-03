//
//  ProfessionalLifeViewController.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/15/26.
//

import UIKit

final class ProfessionalLifeViewController: OnboardingBaseViewController {
    
    // MARK: - Properties
    
    weak var coordinator: OnboardingCoordinator?
    var userPreferences: UserPreferences?
    
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
    
    lazy var professionGridView: ProfessionalLifeGridView = {
        let view = ProfessionalLifeGridView()
        view.delegate = self
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func setupViews() {
        super.setupViews()
        
        setupViews(
            onboardingTitle: "What defines your\nprofessional life?",
            onboardingSubtitle: "Select the role that best fits. We use this to tailor energy requirements.",
            highlightedWord: "professional life?",
            buttonTitle: "Next"
        )
        
        delegate = self
        setupLayout()
    }
    
    // MARK: - Setup
    
    private func setupLayout() {
        textView.removeFromSuperview()
        
        view.insertSubview(scrollView, at: 0)
        scrollView.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(textView)
        contentStackView.addArrangedSubview(professionGridView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 8),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 8),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -8),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -80),
            contentStackView.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor,
                constant: -16
            ),
        ])
        professionGridView.animateIn()
    }
}

// MARK: - OnboardingBaseViewControllerDelegate

extension ProfessionalLifeViewController: OnboardingBaseViewControllerDelegate {
    func didTapButton(_ view: OnboardingBaseViewController) {
        nextTapped()
    }
}

// MARK: - ProfessionalLifeGridViewDelegate

extension ProfessionalLifeViewController: ProfessionalLifeGridViewDelegate {
    func professionalLifeGridView(_ view: ProfessionalLifeGridView, didSelect role: ProfessionRole) {
        print("✅ Role selected: \(role.rawValue)")
        userPreferences?.profession = role.rawValue
    }
}

extension ProfessionalLifeViewController {
    
    @objc func nextTapped() {
        SoundManager.shared.playSound(.buttonTap)
        
        guard let role = professionGridView.selectedRole else {
            // Shake button to indicate selection needed
            shakeNextButton()
            return
        }
        
        print("✅ Professional role saved: \(role.rawValue)")
        userPreferences?.profession = role.rawValue
        
        guard let userPreferences else {
            print("❌ UserPreferences is nil")
            return
        }
        print(userPreferences.profession)
        
        coordinator?.showUltimateGoalScreen(userPreferences)
    }
    
    private func shakeNextButton() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.4
        animation.values = [-8, 8, -6, 6, -4, 4, 0]
        
        view.layer.add(animation, forKey: "shake")
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}
