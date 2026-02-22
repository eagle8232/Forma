//
//  RoutineCard.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/18/26.
//

import UIKit

final class RoutineBlockCard: UIView {
    
    // MARK: - Properties
    
    let block: RoutineBlock
    var onEdit: (() -> Void)?
    var onTaskToggle: ((String, Bool) -> Void)?
    
    // MARK: - UI Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundSecondary
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(hex: block.accentColor).withAlphaComponent(0.3).cgColor
        return view
    }()
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(hex: block.accentColor).withAlphaComponent(0.15)
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private let iconView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let iconLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .typography(.heading2)
        label.textColor = .textPrimary
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .typography(.caption)
        label.textColor = .textSecondary
        return label
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.tintColor = .textSecondary
        button.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var intensityView: UIView? = {
        guard let intensity = block.intensity else { return UIView() }
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Projected Intensity"
        titleLabel.font = .typography(.caption)
        titleLabel.textColor = .textSecondary
        
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = intensity.rawValue
        valueLabel.font = .typography(.label)
        valueLabel.textColor = intensity.color
        
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = intensity.color
        progressView.trackTintColor = intensity.color.withAlphaComponent(0.2)
        progressView.layer.cornerRadius = 2
        progressView.clipsToBounds = true
        
        let progress: Float = {
            switch intensity {
            case .low: return 0.3
            case .medium: return 0.6
            case .high: return 0.9
            }
        }()
        progressView.setProgress(progress, animated: false)
        
        container.addSubview(titleLabel)
        container.addSubview(valueLabel)
        container.addSubview(progressView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            
            valueLabel.topAnchor.constraint(equalTo: container.topAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            progressView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            progressView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            progressView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 6)
        ])
        
        return container
    }()
    
    private lazy var tasksStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()
    
    // MARK: - Initialization
    
    init(block: RoutineBlock) {
        self.block = block
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
        containerView.addSubview(headerView)
        headerView.addSubview(iconView)
        iconView.addSubview(iconLabel)
        headerView.addSubview(titleLabel)
        headerView.addSubview(timeLabel)
        headerView.addSubview(editButton)
        
        iconView.backgroundColor = UIColor(hex: block.accentColor).withAlphaComponent(0.3)
        iconLabel.text = block.icon
        titleLabel.text = block.title
        timeLabel.text = "\(block.startTime) - \(block.endTime)"
        
        // Add intensity if available
        if let intensityView = intensityView {
            containerView.addSubview(intensityView)
        }
        
        // Add tasks
        containerView.addSubview(tasksStack)
        setupTasks()
        
        setupConstraints()
    }
    
    private func setupTasks() {
        block.tasks.forEach { task in
            let taskCell = RoutineTaskCell(task: task)
            taskCell.onToggle = { [weak self] isCompleted in
                self?.onTaskToggle?(task.id, isCompleted)
            }
            tasksStack.addArrangedSubview(taskCell)
        }
    }
    
    private func setupConstraints() {
        var constraints: [NSLayoutConstraint] = [
            // Container
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Header
            headerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 80),
            
            // Icon
            iconView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 48),
            iconView.heightAnchor.constraint(equalToConstant: 48),
            
            iconLabel.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: editButton.leadingAnchor, constant: -8),
            
            // Time
            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            // Edit button
            editButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            editButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            editButton.widthAnchor.constraint(equalToConstant: 32),
            editButton.heightAnchor.constraint(equalToConstant: 32)
        ]
        
        // Intensity view
        if let intensityView = intensityView {
            constraints.append(contentsOf: [
                intensityView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
                intensityView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
                intensityView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
                
                tasksStack.topAnchor.constraint(equalTo: intensityView.bottomAnchor, constant: 20)
            ])
        } else {
            constraints.append(
                tasksStack.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20)
            )
        }
        
        // Tasks stack
        constraints.append(contentsOf: [
            tasksStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            tasksStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            tasksStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Actions
    
    @objc private func editTapped() {
        onEdit?()
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
