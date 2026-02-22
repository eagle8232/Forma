//
//  ActivityCell.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/18/26.
//

import UIKit

final class RoutineTaskCell: UIView {
    
    // MARK: - Properties
    
    private let task: RoutineTask
    var onToggle: ((Bool) -> Void)?
    
    // MARK: - UI Components
    
    private lazy var checkboxButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.textSecondary.withAlphaComponent(0.3).cgColor
        button.backgroundColor = .backgroundSecondary
        button.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        return button
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.backgroundColor = .backgroundSecondary
        return imageView
    }()
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .typography(.bodyLarge)
        label.textColor = .textPrimary
        return label
    }()
    
    private let detailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .typography(.caption)
        label.textColor = .textSecondary
        return label
    }()
    
    // MARK: - Initialization
    
    init(task: RoutineTask) {
        self.task = task
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(detailLabel)
        
        addSubview(checkboxButton)
        addSubview(iconImageView)
        addSubview(contentStack)
        
        titleLabel.text = task.title
        detailLabel.text = "\(task.duration) · \(task.description)"
        
        updateCheckboxState(animated: false)
        
        NSLayoutConstraint.activate([
            // Checkbox
            checkboxButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            checkboxButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkboxButton.widthAnchor.constraint(equalToConstant: 24),
            checkboxButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Icon
            iconImageView.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 12),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            // Content
            contentStack.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // Height
            heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func checkboxTapped() {
        let newState = !task.isCompleted
        updateCheckboxState(animated: true)
        onToggle?(newState)
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func updateCheckboxState(animated: Bool) {
        let update = {
            if self.task.isCompleted {
                self.checkboxButton.backgroundColor = .accent
                self.checkboxButton.layer.borderColor = UIColor.accent.cgColor
                
                let checkmark = UIImageView(image: UIImage(systemName: "checkmark"))
                checkmark.tintColor = .white
                checkmark.frame = self.checkboxButton.bounds
                checkmark.contentMode = .center
                checkmark.tag = 999
                self.checkboxButton.viewWithTag(999)?.removeFromSuperview()
                self.checkboxButton.addSubview(checkmark)
                
                self.titleLabel.alpha = 0.5
                self.iconImageView.alpha = 0.5
            } else {
                self.checkboxButton.backgroundColor = .backgroundSecondary
                self.checkboxButton.layer.borderColor = UIColor.textSecondary.withAlphaComponent(0.3).cgColor
                self.checkboxButton.viewWithTag(999)?.removeFromSuperview()
                
                self.titleLabel.alpha = 1.0
                self.iconImageView.alpha = 1.0
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.2) { update() }
        } else {
            update()
        }
    }
}
