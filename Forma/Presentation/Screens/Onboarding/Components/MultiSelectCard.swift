//
//  MultiSelectCard.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/17/26.
//

import UIKit

final class MultiSelectGoalCard: UIView {
    
    // MARK: - Properties
    
    private(set) var goal: UltimateGoal
    private(set) var isGoalSelected: Bool = false
    var onTap: ((UltimateGoal) -> Void)?
    
    // MARK: - UI Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundSecondary
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.clear.cgColor
        return view
    }()
    
    private lazy var glowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = goal.accentColor.withAlphaComponent(0.12)
        view.layer.cornerRadius = 16
        view.alpha = 0
        return view
    }()
    
    private lazy var iconLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = goal.icon
        label.font = .systemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 3
        stack.alignment = .leading
        return stack
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = goal.rawValue
        label.font = .typography(.bodyLarge)
        label.textColor = .textPrimary
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = goal.description
        label.font = .typography(.caption)
        label.textColor = .textSecondary
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var checkmarkContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundSecondary
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.textSecondary.withAlphaComponent(0.3).cgColor
        
        let imageView = UIImageView(image: UIImage(systemName: "checkmark"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0
        imageView.tag = 100
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 11),
            imageView.heightAnchor.constraint(equalToConstant: 11)
        ])
        
        return view
    }()
    
    // MARK: - Initialization
    
    init(goal: UltimateGoal) {
        self.goal = goal
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(descriptionLabel)
        
        addSubview(containerView)
        containerView.addSubview(glowView)
        containerView.addSubview(iconLabel)
        containerView.addSubview(contentStackView)
        containerView.addSubview(checkmarkContainer)
        
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
            iconLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 36),
            iconLabel.heightAnchor.constraint(equalToConstant: 36),
            
            // Content stack
            contentStackView.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            contentStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: checkmarkContainer.leadingAnchor, constant: -12),
            
            // Checkmark
            checkmarkContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            checkmarkContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            checkmarkContainer.widthAnchor.constraint(equalToConstant: 24),
            checkmarkContainer.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        setupGestures()
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }
    
    // MARK: - Public Methods
    
    func setSelected(_ selected: Bool, animated: Bool = true) {
        isGoalSelected = selected
        
        let checkImageView = checkmarkContainer.viewWithTag(100) as? UIImageView
        
        let animations = {
            if selected {
                self.containerView.backgroundColor   = self.goal.accentColor.withAlphaComponent(0.1)
                self.containerView.layer.borderColor = self.goal.accentColor.cgColor
                self.titleLabel.textColor            = self.goal.accentColor
                self.glowView.alpha                  = 1
                self.checkmarkContainer.backgroundColor  = self.goal.accentColor
                self.checkmarkContainer.layer.borderColor = self.goal.accentColor.cgColor
                checkImageView?.alpha                = 1
                
                // Glow shadow
                self.containerView.layer.shadowColor   = self.goal.accentColor.cgColor
                self.containerView.layer.shadowOpacity = 0.25
                self.containerView.layer.shadowRadius  = 10
                self.containerView.layer.shadowOffset  = .zero
                
            } else {
                self.containerView.backgroundColor   = .backgroundSecondary
                self.containerView.layer.borderColor = UIColor.clear.cgColor
                self.titleLabel.textColor            = .textPrimary
                self.glowView.alpha                  = 0
                self.checkmarkContainer.backgroundColor  = .backgroundSecondary
                self.checkmarkContainer.layer.borderColor = UIColor.textSecondary.withAlphaComponent(0.3).cgColor
                checkImageView?.alpha                = 0
                self.containerView.layer.shadowOpacity = 0
            }
        }
        
        let checkmarkAnimation = {
            self.checkmarkContainer.transform = selected
                ? .identity
                : CGAffineTransform(scaleX: 0.85, y: 0.85)
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
        onTap?(goal)
    }
}
