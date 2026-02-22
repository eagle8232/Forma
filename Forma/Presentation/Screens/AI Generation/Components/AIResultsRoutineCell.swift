//
//  AIResultsRoutineCell.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/20/26.
//

import UIKit

final class AIResultsRoutineCell: UIView {

    // MARK: - Callbacks

    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?

    // MARK: - Public

    private(set) var routine: RoutineBlock
    private let accentColor: UIColor

    // MARK: - UI

    private let blurView: UIVisualEffectView = {
        let v = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 20
        v.clipsToBounds = true
        v.isUserInteractionEnabled = false
        return v
    }()

    private let rail = UIView()
    private let timeBadgeContainer = UIView()
    private let timeBadgeStack = UIStackView()
    private let timeBadgeIcon = UIImageView()
    private let timeBadgeLabel = UILabel()

    private let titleTextView = FormaTextView()
    private let subtitleTextView = FormaTextView()

    private let chipWrapperView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.clipsToBounds = true
        return v
    }()

    private let chipScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        sv.clipsToBounds = false
        sv.alwaysBounceHorizontal = true
        return sv
    }()

    private let chipStack: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .horizontal
        s.spacing = 8
        s.alignment = .center
        return s
    }()

    private lazy var editButton: FormaButton = {
        let conf = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let btn = FormaButton(configuration: .init(
            icon: UIImage(systemName: "pencil", withConfiguration: conf),
            iconPosition: .only,
            style: .rectangle,
            backgroundColor: UIColor(white: 1, alpha: 0.08),
            titleColor: UIColor(white: 1, alpha: 0.5),
            borderColor: UIColor(white: 1, alpha: 0.1),
            borderWidth: 1,
            cornerRadius: 10,
            contentPadding: UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7),
            iconSize: 20
        ))
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        return btn
    }()

    // MARK: - Init

    init(routine: RoutineBlock, accentColor: UIColor) {
        self.routine = routine
        self.accentColor = accentColor
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupBase()
        populate()
        addSwipeGesture()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    
    private func populate() {
        timeBadgeLabel.text = "\(routine.startTime) – \(routine.endTime)"

        titleTextView.addCustomText(
            routine.title,
            typography: .heading2,
            color: .textPrimary,
            alignment: .left
        )

        let taskCount = routine.tasks.count
        subtitleTextView.addCaption(
            "· \(taskCount) task\(taskCount == 1 ? "" : "s")",
            color: .textSecondary,
            alignment: .left
        )

        routine.tasks.enumerated().forEach { index, task in
            chipStack.addArrangedSubview(makeChip(task, index: index))
        }

        // Trailing spacer — gives breathing room before right fade
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.widthAnchor.constraint(equalToConstant: 20).isActive = true
        chipStack.addArrangedSubview(spacer)
    }

    // MARK: - Chip Builder

    private func makeChip(_ task: RoutineTask, index: Int) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.layer.cornerRadius = 10

        if index % 2 == 0 {
            container.backgroundColor = accentColor.withAlphaComponent(0.14)
            container.layer.borderWidth = 1
            container.layer.borderColor = accentColor.withAlphaComponent(0.25).cgColor
        } else {
            container.backgroundColor = UIColor(white: 1, alpha: 0.06)
            container.layer.borderWidth = 1
            container.layer.borderColor = UIColor(white: 1, alpha: 0.1).cgColor
        }

        let dot = UIView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.backgroundColor = index % 2 == 0
            ? accentColor.withAlphaComponent(0.9)
            : UIColor(white: 1, alpha: 0.3)
        dot.layer.cornerRadius = 3

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = task.title
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = index % 2 == 0
            ? accentColor.withAlphaComponent(0.95)
            : UIColor(white: 1, alpha: 0.6)
        label.numberOfLines = 1

        let innerStack = UIStackView(arrangedSubviews: [dot, label])
        innerStack.translatesAutoresizingMaskIntoConstraints = false
        innerStack.axis = .horizontal
        innerStack.spacing = 5
        innerStack.alignment = .center
        container.addSubview(innerStack)

        NSLayoutConstraint.activate([
            dot.widthAnchor.constraint(equalToConstant: 6),
            dot.heightAnchor.constraint(equalToConstant: 6),
            innerStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 7),
            innerStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            innerStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            innerStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -7)
        ])

        return container
    }

    private func addSwipeGesture() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipedLeft))
        swipe.direction = .left
        addGestureRecognizer(swipe)
    }

    // MARK: - Actions

    @objc private func editTapped() { onEdit?() }
    @objc private func swipedLeft() { onDelete?() }

    // MARK: - Animate In / Out

    func animateIn(delay: TimeInterval) {
        alpha = 0
        transform = CGAffineTransform(translationX: 0, y: 32)
        UIView.animate(withDuration: 0.6, delay: delay,
                       usingSpringWithDamping: 0.82, initialSpringVelocity: 0) {
            self.alpha = 1
            self.transform = .identity
        }
    }

    func animateOut(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(translationX: -50, y: 0)
        }, completion: { _ in completion() })
    }
}

// MARK: - UIScrollViewDelegate

extension AIResultsRoutineCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}

// MARK: - Setup Layout
extension AIResultsRoutineCell {
    private func setupBase() {
        backgroundColor = .backgroundSecondary
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.borderColor = UIColor.backgroundSecondary.withAlphaComponent(0.5).cgColor

        // Rail
        rail.translatesAutoresizingMaskIntoConstraints = false
        rail.backgroundColor = accentColor
        rail.layer.cornerRadius = 3

        // Time badge
        timeBadgeContainer.translatesAutoresizingMaskIntoConstraints = false
        timeBadgeContainer.backgroundColor = accentColor.withAlphaComponent(0.15)
        timeBadgeContainer.layer.cornerRadius = 10
        timeBadgeContainer.layer.borderWidth = 1
        timeBadgeContainer.layer.borderColor = accentColor.withAlphaComponent(0.3).cgColor

        let clockConf = UIImage.SymbolConfiguration(pointSize: 9, weight: .medium)
        timeBadgeIcon.translatesAutoresizingMaskIntoConstraints = false
        timeBadgeIcon.image = UIImage(systemName: "clock", withConfiguration: clockConf)
        timeBadgeIcon.tintColor = accentColor
        timeBadgeIcon.contentMode = .scaleAspectFit

        timeBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeBadgeLabel.font = UIFont.monospacedSystemFont(ofSize: 11, weight: .semibold)
        timeBadgeLabel.textColor = accentColor

        timeBadgeStack.translatesAutoresizingMaskIntoConstraints = false
        timeBadgeStack.axis = .horizontal
        timeBadgeStack.spacing = 4
        timeBadgeStack.alignment = .center
        timeBadgeStack.addArrangedSubview(timeBadgeIcon)
        timeBadgeStack.addArrangedSubview(timeBadgeLabel)
        timeBadgeContainer.addSubview(timeBadgeStack)

        titleTextView.translatesAutoresizingMaskIntoConstraints = false
        subtitleTextView.translatesAutoresizingMaskIntoConstraints = false

        // Scroll inside wrapper; mask on wrapper
        chipWrapperView.addSubview(chipScrollView)
        chipScrollView.addSubview(chipStack)

        // Observe scroll to update fade dynamically
        chipScrollView.delegate = self

        addSubview(blurView)
        addSubview(rail)
        addSubview(editButton)
        addSubview(timeBadgeContainer)
        addSubview(titleTextView)
        addSubview(subtitleTextView)
        addSubview(chipWrapperView)

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),

            rail.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            rail.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18),
            rail.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            rail.widthAnchor.constraint(equalToConstant: 4),

            editButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            editButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            titleTextView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleTextView.leadingAnchor.constraint(equalTo: rail.trailingAnchor, constant: 14),
            titleTextView.trailingAnchor.constraint(lessThanOrEqualTo: editButton.leadingAnchor, constant: -8),

            timeBadgeContainer.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 6),
            timeBadgeContainer.leadingAnchor.constraint(equalTo: titleTextView.leadingAnchor),

            timeBadgeStack.topAnchor.constraint(equalTo: timeBadgeContainer.topAnchor, constant: 5),
            timeBadgeStack.leadingAnchor.constraint(equalTo: timeBadgeContainer.leadingAnchor, constant: 8),
            timeBadgeStack.trailingAnchor.constraint(equalTo: timeBadgeContainer.trailingAnchor, constant: -8),
            timeBadgeStack.bottomAnchor.constraint(equalTo: timeBadgeContainer.bottomAnchor, constant: -5),
            timeBadgeIcon.widthAnchor.constraint(equalToConstant: 11),
            timeBadgeIcon.heightAnchor.constraint(equalToConstant: 11),

            subtitleTextView.centerYAnchor.constraint(equalTo: timeBadgeContainer.centerYAnchor),
            subtitleTextView.leadingAnchor.constraint(equalTo: timeBadgeContainer.trailingAnchor, constant: 8),
            subtitleTextView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -18),

            // Wrapper spans from after the rail to the card edge
            chipWrapperView.topAnchor.constraint(equalTo: timeBadgeContainer.bottomAnchor, constant: 14),
            chipWrapperView.leadingAnchor.constraint(equalTo: titleTextView.leadingAnchor),
            chipWrapperView.trailingAnchor.constraint(equalTo: trailingAnchor),
            chipWrapperView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18),
            chipWrapperView.heightAnchor.constraint(equalToConstant: 32),

            // Scroll view fills wrapper entirely
            chipScrollView.topAnchor.constraint(equalTo: chipWrapperView.topAnchor),
            chipScrollView.leadingAnchor.constraint(equalTo: chipWrapperView.leadingAnchor),
            chipScrollView.trailingAnchor.constraint(equalTo: chipWrapperView.trailingAnchor),
            chipScrollView.bottomAnchor.constraint(equalTo: chipWrapperView.bottomAnchor),

            // Stack is the scroll content
            chipStack.topAnchor.constraint(equalTo: chipScrollView.topAnchor),
            chipStack.leadingAnchor.constraint(equalTo: chipScrollView.leadingAnchor),
            chipStack.trailingAnchor.constraint(equalTo: chipScrollView.trailingAnchor),
            chipStack.bottomAnchor.constraint(equalTo: chipScrollView.bottomAnchor),
            chipStack.heightAnchor.constraint(equalTo: chipScrollView.heightAnchor)
        ])
    }

}
