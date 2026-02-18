//
//  MultiSelectGoalGridView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/17/26.
//

import UIKit

protocol MultiSelectGoalGridViewDelegate: AnyObject {
    func multiSelectGoalGridView(_ view: MultiSelectGoalGridView, didUpdateSelections goals: [UltimateGoal])
    func multiSelectGoalGridView(_ view: MultiSelectGoalGridView, didReachMaxSelections maxCount: Int)
}

final class MultiSelectGoalGridView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: MultiSelectGoalGridViewDelegate?
    private(set) var selectedGoals: [UltimateGoal] = []
    private var cards: [MultiSelectGoalCard] = []
    
    let maxSelections: Int
    
    // MARK: - UI Components
    
    private lazy var selectionCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .typography(.caption)
        label.textColor = .textSecondary
        label.text = "Select up to \(maxSelections)"
        label.textAlignment = .right
        return label
    }()
    
    private lazy var gridStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .fill
        return stack
    }()
    
    // MARK: - Initialization
    
    init(maxSelections: Int = 3) {
        self.maxSelections = maxSelections
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        self.maxSelections = 3
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        
        addSubview(selectionCountLabel)
        addSubview(gridStackView)
        
        NSLayoutConstraint.activate([
            selectionCountLabel.topAnchor.constraint(equalTo: topAnchor),
            selectionCountLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            selectionCountLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            gridStackView.topAnchor.constraint(equalTo: selectionCountLabel.bottomAnchor, constant: 12),
            gridStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gridStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gridStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        setupGrid()
    }
    
    private func setupGrid() {
        UltimateGoal.allCases.forEach { goal in
            let card = createCard(for: goal)
            gridStackView.addArrangedSubview(card)
            
            NSLayoutConstraint.activate([
                card.heightAnchor.constraint(equalToConstant: 68)
            ])
        }
    }
    
    private func createCard(for goal: UltimateGoal) -> MultiSelectGoalCard {
        let card = MultiSelectGoalCard(goal: goal)
        card.onTap = { [weak self] tappedGoal in
            self?.handleCardTapped(tappedGoal)
        }
        cards.append(card)
        return card
    }
    
    // MARK: - Private Methods
    
    private func handleCardTapped(_ goal: UltimateGoal) {
        if selectedGoals.contains(goal) {
            // Deselect
            selectedGoals.removeAll { $0 == goal }
            cards.first { $0.goal == goal }?.setSelected(false)
            
            // Re-enable all cards
            updateCardInteractivity()
            
        } else {
            // Check max
            guard selectedGoals.count < maxSelections else {
                delegate?.multiSelectGoalGridView(self, didReachMaxSelections: maxSelections)
                shakeMaxReachedFeedback()
                return
            }
            
            // Select
            selectedGoals.append(goal)
            cards.first { $0.goal == goal }?.setSelected(true)
            
            // Disable other cards if max reached
            updateCardInteractivity()
        }
        
        // Update counter label
        updateCounterLabel()
        
        // Notify delegate
        delegate?.multiSelectGoalGridView(self, didUpdateSelections: selectedGoals)
        
        // Haptic
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func updateCardInteractivity() {
        let isMaxReached = selectedGoals.count >= maxSelections
        
        cards.forEach { card in
            let isSelected = selectedGoals.contains(card.goal)
            
            // Dim unselected cards when max reached
            UIView.animate(withDuration: 0.2) {
                card.alpha = (isMaxReached && !isSelected) ? 0.4 : 1.0
            }
        }
    }
    
    private func updateCounterLabel() {
        let remaining = maxSelections - selectedGoals.count
        
        UIView.transition(
            with: selectionCountLabel,
            duration: 0.2,
            options: .transitionCrossDissolve
        ) {
            if self.selectedGoals.isEmpty {
                self.selectionCountLabel.text = "Select up to \(self.maxSelections)"
                self.selectionCountLabel.textColor = .textSecondary
            } else if remaining == 0 {
                self.selectionCountLabel.text = "✓ \(self.maxSelections) selected"
                self.selectionCountLabel.textColor = .accent
            } else {
                self.selectionCountLabel.text = "\(self.selectedGoals.count) selected · \(remaining) remaining"
                self.selectionCountLabel.textColor = .textSecondary
            }
        }
    }
    
    private func shakeMaxReachedFeedback() {
        // Shake all selected cards
        cards.filter { selectedGoals.contains($0.goal) }.forEach { card in
            let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            animation.duration = 0.3
            animation.values = [-6, 6, -4, 4, -2, 2, 0]
            card.layer.add(animation, forKey: "shake")
        }
        
        // Error haptic
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    // MARK: - Public Methods
    
    func animateIn() {
        cards.enumerated().forEach { index, card in
            card.animateIn(delay: CGFloat(index))
        }
    }
    
    func clearSelections() {
        selectedGoals.removeAll()
        cards.forEach { $0.setSelected(false) }
        cards.forEach { $0.alpha = 1 }
        updateCounterLabel()
    }
}
