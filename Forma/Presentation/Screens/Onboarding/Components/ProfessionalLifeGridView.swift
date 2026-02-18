//
//  ProfessionalLifeGridView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/17/26.
//

import UIKit

enum ProfessionalRole: String, CaseIterable {
    case developer           = "Developer"
    case designer            = "Designer"
    case medicalProfessional = "Medical Professional"
    case founderEntrepreneur = "Founder / Entrepreneur"
    case student             = "Student"
    case managerLead         = "Manager / Lead"
    case freelancer          = "Freelancer / Consultant"
    case salesMarketing      = "Sales & Marketing"
    case teacherEducator     = "Teacher / Educator"
    case parentHomemaker     = "Parent / Homemaker"
    case artistCreative      = "Artist / Creative"
    case other               = "Other"
    
    var icon: String {
        switch self {
        case .developer:           return "💻"
        case .designer:            return "🎨"
        case .medicalProfessional: return "⚕️"
        case .founderEntrepreneur: return "🚀"
        case .student:             return "📚"
        case .managerLead:         return "👥"
        case .freelancer:          return "🌐"
        case .salesMarketing:      return "📈"
        case .teacherEducator:     return "🎓"
        case .parentHomemaker:     return "🏡"
        case .artistCreative:      return "✨"
        case .other:               return "⚡️"
        }
    }
    
    var accentColor: UIColor {
        switch self {
        case .developer:           return UIColor(hex: "#4F9EF8")  // Blue
        case .designer:            return UIColor(hex: "#F86F4F")  // Orange
        case .medicalProfessional: return UIColor(hex: "#4FD1A5")  // Teal
        case .founderEntrepreneur: return UIColor(hex: "#F8C44F")  // Gold
        case .student:             return UIColor(hex: "#9B7FE8")  // Purple
        case .managerLead:         return UIColor(hex: "#4FC3F8")  // Light blue
        case .freelancer:          return UIColor(hex: "#F84F9E")  // Pink
        case .salesMarketing:      return UIColor(hex: "#F8814F")  // Deep orange
        case .teacherEducator:     return UIColor(hex: "#81C784")  // Green
        case .parentHomemaker:     return UIColor(hex: "#F8A44F")  // Amber
        case .artistCreative:      return UIColor(hex: "#CE93D8")  // Lavender
        case .other:               return UIColor.accent
        }
    }
    
    // Whether to span full width
    var isWide: Bool {
        return rawValue.count > 18
    }
}

// ProfessionalLifeGridView.swift

import UIKit

protocol ProfessionalLifeGridViewDelegate: AnyObject {
    func professionalLifeGridView(_ view: ProfessionalLifeGridView, didSelect role: ProfessionalRole)
}

final class ProfessionalLifeGridView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: ProfessionalLifeGridViewDelegate?
    private(set) var selectedRole: ProfessionalRole?
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
        let roles = ProfessionalRole.allCases
        var index = 0
        
        while index < roles.count {
            let role = roles[index]
            let nextRole: ProfessionalRole? = index + 1 < roles.count ? roles[index + 1] : nil
            
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
    
    private func createDoubleRow(left: ProfessionalRole, right: ProfessionalRole) -> UIStackView {
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
    
    private func createCard(for role: ProfessionalRole) -> ProfessionalRoleCard {
        let card = ProfessionalRoleCard(role: role)
        card.delegate = self
        cards.append(card)
        return card
    }
    
    // MARK: - Private Methods
    
    private func handleCardTapped(_ role: ProfessionalRole) {
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
    
    func selectRole(_ role: ProfessionalRole, animated: Bool = true) {
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
            card.alpha = 0
            card.transform = CGAffineTransform(translationX: 0, y: 20)
            
            UIView.animate(
                withDuration: 0.4,
                delay: Double(index) * 0.05,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.3
            ) {
                card.alpha = 1
                card.transform = .identity
            }
        }
    }
}

extension ProfessionalLifeGridView: ProfessionalRoleCardDelegate {
    func didSelectCard(_ view: ProfessionalRoleCard, profession: ProfessionalRole) {
        handleCardTapped(profession)
    }
}
