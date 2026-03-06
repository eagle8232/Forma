//
//  RoutineInfoViewController.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/3/26.
//

import UIKit

final class RoutineInfoViewCell: UICollectionViewCell {
    
    static let identifier: String = "routineInfoViewCell"
    
    private var currentTaskView = CurrentTaskView()
    private var tasksView = TasksView(tasks: [])
    
    var onNextTask: (() -> Void)?
    
    var tasks: [RoutineTask] = [] {
        didSet { buildTasksView() }
    }
    
    var currentTask: RoutineTask? {
        didSet { buildCurrentTaskView() }
    }
    
    let mockTask = RoutineBlock.mockWork.tasks[3]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        currentTaskView.task = nil
        tasksView.tasks = []
    }
    
    private func layoutViews() {
        currentTaskView.delegate = self
        currentTaskView.translatesAutoresizingMaskIntoConstraints = false
        tasksView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(currentTaskView)
        addSubview(tasksView)
        
        NSLayoutConstraint.activate([
            currentTaskView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            currentTaskView.centerXAnchor.constraint(equalTo: centerXAnchor),
            currentTaskView.widthAnchor.constraint(equalToConstant: 280),
            currentTaskView.heightAnchor.constraint(equalToConstant: 280),
            
            tasksView.topAnchor.constraint(equalTo: currentTaskView.bottomAnchor, constant: 16),
            tasksView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            tasksView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            tasksView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
    }
}

extension RoutineInfoViewCell {
    private func buildCurrentTaskView() {
        currentTaskView.task = currentTask
    }
    private func buildTasksView() {
        tasksView.tasks = tasks
    }
}

extension RoutineInfoViewCell: CurrentTaskViewDelegate {
    func nextTask(_ view: CurrentTaskView) {
        
    }
}
