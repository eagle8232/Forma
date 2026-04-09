//
//  ProfessionalLifeCard.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/17/26.
//

import UIKit

protocol ProfessionalRoleCardDelegate: AnyObject {
    func didSelectCard(_ view: ProfessionalRoleCard, profession: ProfessionRole)
}

final class ProfessionalRoleCard: UIView {
    
    // MARK: - Properties
    
    private(set) var profession: ProfessionRole
    private(set) var isSelected: Bool = false
    weak var delegate: ProfessionalRoleCardDelegate?
    
    // MARK: - UI Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .adaptiveBackgroundSecondary
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.clear.cgColor
        view.clipsToBounds = false
        return view
    }()
    
    private lazy var iconLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = profession.icon
        label.font = .systemFont(ofSize: 28)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = profession.rawValue
        label.font = .typography(.bodyMedium)
        label.textColor = .adaptiveTextSecondary
        label.textAlignment = .center
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()
    
    private lazy var glowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = profession.accentColor.withAlphaComponent(0.15)
        view.layer.cornerRadius = 16
        view.alpha = 0
        return view
    }()
    
    private lazy var checkmarkView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = profession.accentColor
        view.layer.cornerRadius = 10
        view.alpha = 0
        view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        let imageView = UIImageView(image: UIImage(systemName: "checkmark"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 10),
            imageView.heightAnchor.constraint(equalToConstant: 10)
        ])
        
        return view
    }()
    
    // MARK: - Initialization
    
    init(role: ProfessionRole) {
        self.profession = role
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        containerView.addSubview(glowView)
        containerView.addSubview(iconLabel)
        containerView.addSubview(titleLabel)
        addSubview(checkmarkView)
        
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Glow
            glowView.topAnchor.constraint(equalTo: containerView.topAnchor),
            glowView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            glowView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            glowView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // Icon
            iconLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            iconLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            // Checkmark
            checkmarkView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: -8),
            checkmarkView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 8),
            checkmarkView.widthAnchor.constraint(equalToConstant: 20),
            checkmarkView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        
    }
    
    // MARK: - Public Methods
    
    func setSelected(_ selected: Bool, animated: Bool = true) {
        isSelected = selected
        
        let animations = {
            if selected {
                // Selected state
                self.containerView.backgroundColor = self.profession.accentColor.withAlphaComponent(0.12)
                self.containerView.layer.borderColor = self.profession.accentColor.cgColor
                self.titleLabel.textColor = self.profession.accentColor
                self.glowView.alpha = 1
                self.checkmarkView.alpha = 1
                
                // Shadow glow
                self.containerView.layer.shadowColor = self.profession.accentColor.cgColor
                self.containerView.layer.shadowOpacity = 0.4
                self.containerView.layer.shadowRadius = 12
                self.containerView.layer.shadowOffset = .zero
                
            } else {
                // Unselected state
                self.containerView.backgroundColor = .adaptiveBackgroundSecondary
                self.containerView.layer.borderColor = UIColor.clear.cgColor
                self.titleLabel.textColor = .adaptiveTextSecondary
                self.glowView.alpha = 0
                self.checkmarkView.alpha = 0
                self.containerView.layer.shadowOpacity = 0
            }
        }
        
        let checkmarkAnimation = {
            if selected {
                self.checkmarkView.transform = .identity
            } else {
                self.checkmarkView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }
        }
        
        if animated {
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.5
            ) {
                animations()
                checkmarkAnimation()
            }
        } else {
            animations()
            checkmarkAnimation()
        }
    }
    
    // MARK: - Actions
    
    @objc private func handleTap() {
        delegate?.didSelectCard(self, profession: profession)
    }
}
