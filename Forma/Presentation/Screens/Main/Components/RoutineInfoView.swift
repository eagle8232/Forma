//
//  RoutineInfoViewController.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/24/26.
//

import UIKit

protocol RoutineInfoViewDelegate: AnyObject {
    func nextTask(_ view: RoutineInfoView)
}

final class RoutineInfoView: UIView {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont.typography(.displayMedium)
        label.textColor = UIColor.textPrimary
        return label
    }()
    
    private lazy var descriptionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.typography(.caption)
        label.textColor = UIColor.textSecondary
        return label
    }()
    
    private lazy var durationContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 0.22, alpha: 1.0)
        view.layer.cornerRadius = 10
        return view
    }()
    
    private lazy var durationIconImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        let image = UIImage(systemName: "clock.fill", withConfiguration: config)
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = UIColor(white: 0.50, alpha: 1.0)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var tasksCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.typography(.caption)
        label.textColor = UIColor.textSecondary
        return label
    }()
    
    private lazy var tasksCountContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 0.22, alpha: 1.0)
        view.layer.cornerRadius = 10
        return view
    }()
    
    private lazy var tasksCountIconImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        let image = UIImage(systemName: "list.bullet.clipboard.fill", withConfiguration: config)
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = UIColor(white: 0.50, alpha: 1.0)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var tasksStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    lazy var taskInfoViews: [TaskInfoViewCell] = []
    
    weak var delegate: RoutineInfoViewDelegate?
    var routine: RoutineBlock
    
    init(routine: RoutineBlock) {
        self.routine = routine
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setTaskState()
    }
    
    private func setup() {
        titleLabel.text = routine.title
        durationLabel.text = "\(routine.startTime)-\(routine.endTime)"
        tasksCountLabel.text = "\(routine.tasks.count) Tasks"
        
        
        durationContainer.addSubview(durationLabel)
        durationContainer.addSubview(durationIconImageView)
        descriptionStackView.addArrangedSubview(durationContainer)
        tasksCountContainer.addSubview(tasksCountLabel)
        tasksCountContainer.addSubview(tasksCountIconImageView)
        descriptionStackView.addArrangedSubview(tasksCountContainer)
        
        addSubview(titleLabel)
        addSubview(descriptionStackView)
        addSubview(tasksStackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            descriptionStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            durationIconImageView.topAnchor.constraint(equalTo: durationContainer.topAnchor, constant: 4),
            durationIconImageView.leadingAnchor.constraint(equalTo: durationContainer.leadingAnchor, constant: 8),
            
            durationLabel.topAnchor.constraint(equalTo: durationContainer.topAnchor, constant: 4),
            durationLabel.leadingAnchor.constraint(equalTo: durationIconImageView.trailingAnchor, constant: 4),
            durationLabel.trailingAnchor.constraint(equalTo: durationContainer.trailingAnchor, constant: -8),
            durationLabel.bottomAnchor.constraint(equalTo: durationContainer.bottomAnchor, constant: -4),
            
            tasksCountIconImageView.topAnchor.constraint(equalTo: tasksCountContainer.topAnchor, constant: 4),
            tasksCountIconImageView.leadingAnchor.constraint(equalTo: tasksCountContainer.leadingAnchor, constant: 8),
            
            tasksCountLabel.topAnchor.constraint(equalTo: tasksCountContainer.topAnchor, constant: 4),
            tasksCountLabel.leadingAnchor.constraint(equalTo: tasksCountIconImageView.trailingAnchor, constant: 4),
            tasksCountLabel.trailingAnchor.constraint(equalTo: tasksCountContainer.trailingAnchor, constant: -8),
            tasksCountLabel.bottomAnchor.constraint(equalTo: tasksCountContainer.bottomAnchor, constant: -4),
            
            tasksStackView.topAnchor.constraint(equalTo: descriptionStackView.bottomAnchor, constant: 16),
            tasksStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            tasksStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            tasksStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
        
        setupTaskInfoViews()
        setTaskState()
    }
    
    private func setupTaskInfoViews() {
        
        routine.tasks.enumerated().forEach { [weak self] index, task in
            guard let self else { return }
            
            let taskInfoView = TaskInfoViewCell()
            
            self.taskInfoViews.append(taskInfoView)
            
            self.tasksStackView.addArrangedSubview(taskInfoView)
            
            NSLayoutConstraint.activate([
                taskInfoView.leadingAnchor.constraint(equalTo: self.tasksStackView.leadingAnchor),
                taskInfoView.trailingAnchor.constraint(equalTo: self.tasksStackView.trailingAnchor),
                
            ])
        }
    }
    
    private func setTaskState() {
        let currentTime = DateManager.shared.getTodayTimeString()
        let currentTimeInSeconds = DateManager.shared.convertToSeconds(currentTime)
        taskInfoViews.enumerated().forEach { [weak self] index, taskView in
            guard let self else { return }
            let task = taskView.task
            
            let taskStartTimeInSeconds = DateManager.shared.convertToSeconds(task!.startTime)
            let taskEndTimeInSeconds = taskStartTimeInSeconds + CGFloat(task!.duration)
            if currentTimeInSeconds >= taskStartTimeInSeconds &&
            currentTimeInSeconds < taskEndTimeInSeconds {
//                self.taskInfoViews[index].updateState(.running)
                self.delegate?.nextTask(self)
            } else if currentTimeInSeconds > taskEndTimeInSeconds && currentTimeInSeconds > taskStartTimeInSeconds {
//                self.taskInfoViews[index].updateState(.completed)
            }
        }
    }
}
