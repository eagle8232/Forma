//
//  ProfessionalLifeGridView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/17/26.
//

import UIKit


import UIKit

protocol ProfessionalLifeGridViewDelegate: AnyObject {
    func professionalLifeGridView(_ view: ProfessionalLifeGridView, didSelect role: ProfessionRole)
}

final class ProfessionalLifeGridView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: ProfessionalLifeGridViewDelegate?
    private(set) var selectedRole: ProfessionRole?
    private var cards: [ProfessionalRoleCard] = []
    
    // MARK: - UI Components
    
    private lazy var gridStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        return stack
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        
        addSubview(gridStackView)
        
        NSLayoutConstraint.activate([
            gridStackView.topAnchor.constraint(equalTo: topAnchor),
            gridStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gridStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gridStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        setupGrid()
    }
    
    private func setupGrid() {
        let roles = ProfessionRole.allCases
        var index = 0
        
        while index < roles.count {
            let role = roles[index]
            let nextRole: ProfessionRole? = index + 1 < roles.count ? roles[index + 1] : nil
            
            if role.isWide || nextRole == nil {
                // Full width card
                let card = createCard(for: role)
                gridStackView.addArrangedSubview(card)
                
                NSLayoutConstraint.activate([
                    card.heightAnchor.constraint(equalToConstant: 90)
                ])
                
                index += 1
            } else {
                // Two cards side by side
                let row = createDoubleRow(left: role, right: nextRole!)
                gridStackView.addArrangedSubview(row)
                index += 2
            }
        }
    }
    
    private func createDoubleRow(left: ProfessionRole, right: ProfessionRole) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 12
        row.distribution = .fillEqually
        row.alignment = .fill
        
        let leftCard  = createCard(for: left)
        let rightCard = createCard(for: right)
        
        row.addArrangedSubview(leftCard)
        row.addArrangedSubview(rightCard)
        
        NSLayoutConstraint.activate([
            leftCard.heightAnchor.constraint(equalToConstant: 95),
            rightCard.heightAnchor.constraint(equalToConstant: 95)
        ])
        
        return row
    }
    
    private func createCard(for role: ProfessionRole) -> ProfessionalRoleCard {
        let card = ProfessionalRoleCard(role: role)
        card.delegate = self
        cards.append(card)
        return card
    }
    
    // MARK: - Private Methods
    
    private func handleCardTapped(_ role: ProfessionRole) {
        SoundManager.shared.playSound(.buttonTap)
        
        // Deselect previous
        if let previousRole = selectedRole {
            cards.first { $0.profession == previousRole }?.setSelected(false)
        }
        
        // Select new
        selectedRole = role
        cards.first { $0.profession == role }?.setSelected(true)
        
        // Notify delegate
        delegate?.professionalLifeGridView(self, didSelect: role)
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    // MARK: - Public Methods
    
    func selectRole(_ role: ProfessionRole, animated: Bool = true) {
        selectedRole = role
        cards.forEach { card in
            card.setSelected(card.profession == role, animated: animated)
        }
    }
    
    func clearSelection() {
        selectedRole = nil
        cards.forEach { $0.setSelected(false) }
    }
    
    // MARK: - Entrance Animation
    
    func animateIn() {
        cards.enumerated().forEach { index, card in
            card.animateIn(delay: CGFloat(index))
        }
    }
}

extension ProfessionalLifeGridView: ProfessionalRoleCardDelegate {
    func didSelectCard(_ view: ProfessionalRoleCard, profession: ProfessionRole) {
        handleCardTapped(profession)
    }
}

