//
//  RoutineEditViewController.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/19/26.
//

import UIKit
import Combine

final class RoutineEditViewController: BaseViewController {

    // MARK: - Properties

    private var viewModel: RoutineEditViewModel
    var onSave: ((RoutineBlock) -> Void)?

    // MARK: - Scroll

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        sv.keyboardDismissMode = .interactive
        sv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 140, right: 0)
        return sv
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - Hero Header

    private lazy var heroCard: RoutineHeroCard = {
        let card = RoutineHeroCard()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.configure(
            title: viewModel.routine.title,
            description: viewModel.routine.description ?? "",
            icon: viewModel.routine.icon
        )
        return card
    }()

    // MARK: - Timeline

    private lazy var timelineCard: RoutineTimelineCard = {
        let startTimeDate = viewModel.timeDate(from: viewModel.routine.startTime) ?? viewModel.defaultTime(hour: 6, minute: 0)
        let endTimeDate = viewModel.timeDate(from: viewModel.routine.endTime) ?? viewModel.defaultTime(hour: 8, minute: 30)
        let card = RoutineTimelineCard(
            startDate: startTimeDate,
            endDate:   endTimeDate,
            tasks: viewModel.routine.tasks
        )
        card.translatesAutoresizingMaskIntoConstraints = false
        return card
    }()

    // MARK: - Tasks

    private lazy var tasksHeaderView: TasksSectionHeader = {
        let h = TasksSectionHeader()
        h.translatesAutoresizingMaskIntoConstraints = false
        h.onAddTask = { [weak self] in self?.addTaskTapped() }
        return h
    }()

    private let tasksStack: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical
        s.spacing = 12
        return s
    }()

    // MARK: - CTA

    private let ctaContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let ctaGradientLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.colors = [
            UIColor.clear.cgColor,
            UIColor(red: 0.05, green: 0.05, blue: 0.07, alpha: 0.97).cgColor,
            UIColor(red: 0.04, green: 0.05, blue: 0.07, alpha: 1).cgColor
        ]
        l.locations = [0, 0.35, 1]
        l.startPoint = CGPoint(x: 0.5, y: 0)
        l.endPoint = CGPoint(x: 0.5, y: 1)
        return l
    }()

    private lazy var saveButton: FormaButton = {
        let btn = FormaButton.primary(title: "Save Changes")
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        return btn
    }()

    // MARK: - Init

    init(vm: RoutineEditViewModel) {
        self.viewModel = vm
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        ctaGradientLayer.frame = ctaContainer.bounds
    }

    override func setupViews() {
        super.setupViews()
        applyGradientBackground()

        setupLayout()
        populateTasks()
        animateEntrance()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerKeyboardObservers()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    
    // MARK: - Tasks

    private func populateTasks() {
        viewModel.routine.tasks.enumerated().forEach { i, task in
            insertTaskRow(task, delay: 0.04 * Double(i))
        }
    }

    private func addTaskTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let newTask = RoutineTask(id: UUID().uuidString, title: "", duration: "", description: "", isCompleted: false)
        viewModel.routine.tasks.append(newTask)
        insertTaskRow(newTask, delay: 0, scrollToBottom: true)
    }

    private func insertTaskRow(_ task: RoutineTask, delay: TimeInterval, scrollToBottom: Bool = false) {
        let row = TaskEditRow(task: task)
        row.onDelete = { [weak self, weak row] in
            guard let self, let row else { return }
            self.removeTaskRow(row, task: task)
        }
        row.onDurationChanged = { [weak self] in
            self?.syncTasksToTimeline()
        }
        row.alpha = 0
        row.transform = CGAffineTransform(translationX: 0, y: 16)
        tasksStack.addArrangedSubview(row)

        // Update index badges and timeline bubbles
        reindexTaskRows()
        syncTasksToTimeline()

        UIView.animate(withDuration: 0.45, delay: delay,
                       usingSpringWithDamping: 0.78, initialSpringVelocity: 0) {
            row.alpha = 1; row.transform = .identity
        }

        if scrollToBottom {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                let bottom = self.scrollView.contentSize.height - self.scrollView.bounds.height + 140
                if bottom > 0 { self.scrollView.setContentOffset(CGPoint(x: 0, y: bottom), animated: true) }
            }
        }
    }

    private func removeTaskRow(_ row: TaskEditRow, task: RoutineTask) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        UIView.animate(withDuration: 0.28, animations: {
            row.alpha = 0
            row.transform = CGAffineTransform(translationX: -30, y: 0).scaledBy(x: 0.95, y: 0.95)
        }) { _ in
            self.tasksStack.removeArrangedSubview(row)
            row.removeFromSuperview()
            self.viewModel.routine.tasks.removeAll { $0.id == task.id }
            self.reindexTaskRows()
            self.syncTasksToTimeline()
        }
    }

    private func reindexTaskRows() {
        tasksStack.arrangedSubviews
            .compactMap { $0 as? TaskEditRow }
            .enumerated()
            .forEach { $1.setIndex($0) }
    }

    private func syncTasksToTimeline() {
        let rows = tasksStack.arrangedSubviews.compactMap { $0 as? TaskEditRow }
        let liveTasks = rows.compactMap { row -> RoutineTask? in
            guard let title = row.currentTitle, !title.isEmpty else { return nil }
            return RoutineTask(
                id: row.taskId,
                title: title,
                duration: row.currentDuration ?? "",
                description: row.currentDescription ?? "",
                isCompleted: false
            )
        }
        viewModel.routine.tasks = liveTasks
        timelineCard.updateTasks(liveTasks)
    }

    // MARK: - Animations

    private func animateEntrance() {
        let views: [UIView] = [heroCard, timelineCard, tasksHeaderView, tasksStack]
        views.enumerated().forEach { i, v in
            v.alpha = 0
            v.transform = CGAffineTransform(translationX: 0, y: 28)
            UIView.animate(withDuration: 0.58, delay: 0.07 * Double(i),
                           usingSpringWithDamping: 0.80, initialSpringVelocity: 0) {
                v.alpha = 1; v.transform = .identity
            }
        }
        ctaContainer.transform = CGAffineTransform(translationX: 0, y: 70)
        UIView.animate(withDuration: 0.65, delay: 0.28, usingSpringWithDamping: 0.78, initialSpringVelocity: 0) {
            self.ctaContainer.transform = .identity
        }
    }

    // MARK: - Keyboard

    private func registerKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView.contentInset.bottom = frame.height + 140
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 140
    }

    // MARK: - Actions

    @objc private func saveTapped() {
        guard viewModel.isDurationValid else {
            let alert = UIAlertController(
                title: "Duration Mismatch",
                message: "Total task duration exceeds the routine's time window.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        SoundManager.shared.playSound(.buttonTap)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        view.endEditing(true)

        let rows = tasksStack.arrangedSubviews.compactMap { $0 as? TaskEditRow }
        let tasks = rows.compactMap { row -> RoutineTask? in
            guard let title = row.currentTitle, !title.isEmpty else { return nil }
            return RoutineTask(id: row.taskId, title: title,
                               duration: row.currentDuration ?? "",
                               description: row.currentDescription ?? "",
                               isCompleted: false)
        }

        let updated = viewModel.buildUpdatedRoutine(
            title: heroCard.currentTitle,
            description: heroCard.currentDescription,
            icon: heroCard.currentIcon,
            startDate: timelineCard.startDate,
            endDate: timelineCard.endDate,
            tasks: tasks
        )

        onSave?(updated)
        dismiss(animated: true)
    }

    @objc private func cancelTapped() { dismiss(animated: true) }
}

// MARK: - Layout
extension RoutineEditViewController {
    private func setupLayout() {
        ctaContainer.layer.insertSublayer(ctaGradientLayer, at: 0)
        ctaContainer.addSubview(saveButton)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.addSubview(ctaContainer)
        
        [heroCard, timelineCard, tasksHeaderView, tasksStack].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            heroCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            heroCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            heroCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            timelineCard.topAnchor.constraint(equalTo: heroCard.bottomAnchor, constant: 16),
            timelineCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            timelineCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            tasksHeaderView.topAnchor.constraint(equalTo: timelineCard.bottomAnchor, constant: 28),
            tasksHeaderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tasksHeaderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            tasksStack.topAnchor.constraint(equalTo: tasksHeaderView.bottomAnchor, constant: 14),
            tasksStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tasksStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            tasksStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            ctaContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ctaContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ctaContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ctaContainer.heightAnchor.constraint(equalToConstant: 130),
            
            saveButton.leadingAnchor.constraint(equalTo: ctaContainer.leadingAnchor, constant: 24),
            saveButton.trailingAnchor.constraint(equalTo: ctaContainer.trailingAnchor, constant: -24),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            saveButton.heightAnchor.constraint(equalToConstant: 58)
        ])
    }
}
