//
//  TaskEditRow.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/21/26.
//

import UIKit
final class TaskEditRow: UIView {

    var onDelete: (() -> Void)?
    var onDurationChanged: (() -> Void)?
    let taskId: String
    var currentTitle: String? { titleField.textField.text }
    var currentDescription: String? { descriptionView.text.isEmpty ? nil : descriptionView.text }
    var currentDuration: String? { durationPicker.durationString }

    private let titleField: FormaTextField
    private let durationPicker = DurationPickerView()

    private let descToggleButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        let conf = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
        b.setImage(UIImage(systemName: "text.alignleft", withConfiguration: conf), for: .normal)
        b.setTitle("  Add note", for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        b.tintColor = UIColor(white: 1, alpha: 0.3)
        b.setTitleColor(UIColor(white: 1, alpha: 0.3), for: .normal)
        return b
    }()

    private let descriptionContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.clipsToBounds = true
        return v
    }()

    private let descriptionView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor(white: 1, alpha: 0.04)
        tv.layer.cornerRadius = 10
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor(white: 1, alpha: 0.08).cgColor
        tv.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        tv.textColor = UIColor(white: 1, alpha: 0.55)
        tv.isScrollEnabled = false
        tv.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return tv
    }()

    private let descPlaceholder: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Describe this task..."
        l.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor(white: 1, alpha: 0.2)
        return l
    }()

    private var descContainerHeightConstraint: NSLayoutConstraint!
    private var isDescExpanded = false

    private lazy var deleteButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        let conf = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        b.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: conf), for: .normal)
        b.tintColor = UIColor(white: 1, alpha: 0.2)
        b.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        return b
    }()

    private let numberLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.monospacedSystemFont(ofSize: 11, weight: .bold)
        l.textColor = UIColor.accent
        l.textAlignment = .center
        return l
    }()

    init(task: RoutineTask) {
        self.taskId = task.id

        self.titleField = FormaTextField(
            placeholder: "Task name",
            configuration: .init(keyboardType: .default, returnKeyType: .next)
        )
        self.titleField.setText(task.title)
        self.titleField.translatesAutoresizingMaskIntoConstraints = false

        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        durationPicker.translatesAutoresizingMaskIntoConstraints = false
        if !task.duration.isEmpty { durationPicker.setFromString(task.duration) }

        if !task.description.isEmpty {
            descriptionView.text = task.description
            isDescExpanded = true
        }
        setupRow()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupRow() {
        backgroundColor = UIColor(white: 1, alpha: 0.04)
        layer.cornerRadius = 18
        layer.borderWidth = 1
        layer.borderColor = UIColor(white: 1, alpha: 0.08).cgColor

        let numberBadge = UIView()
        numberBadge.translatesAutoresizingMaskIntoConstraints = false
        numberBadge.backgroundColor = UIColor.accent.withAlphaComponent(0.12)
        numberBadge.layer.cornerRadius = 10
        numberBadge.layer.borderWidth = 1
        numberBadge.layer.borderColor = UIColor.accent.withAlphaComponent(0.25).cgColor
        numberBadge.addSubview(numberLabel)

        descriptionContainer.addSubview(descriptionView)
        descriptionContainer.addSubview(descPlaceholder)
        descriptionView.delegate = self
        durationPicker.delegate = self

        descContainerHeightConstraint = descriptionContainer.heightAnchor.constraint(equalToConstant: 0)
        if isDescExpanded {
            descContainerHeightConstraint.constant = 80
            descToggleButton.setTitle("  Hide note", for: .normal)
            descToggleButton.tintColor = UIColor.accent.withAlphaComponent(0.7)
            descToggleButton.setTitleColor(UIColor.accent.withAlphaComponent(0.7), for: .normal)
        }
        descPlaceholder.isHidden = !descriptionView.text.isEmpty
        descToggleButton.addTarget(self, action: #selector(toggleDesc), for: .touchUpInside)

        let topRow = UIStackView(arrangedSubviews: [numberBadge, titleField])
        topRow.translatesAutoresizingMaskIntoConstraints = false
        topRow.axis = .horizontal; topRow.spacing = 10; topRow.alignment = .center

        let bottomRow = UIStackView(arrangedSubviews: [descToggleButton, UIView(), durationPicker])
        bottomRow.translatesAutoresizingMaskIntoConstraints = false
        bottomRow.axis = .horizontal; bottomRow.spacing = 8; bottomRow.alignment = .center

        addSubview(topRow)
        addSubview(bottomRow)
        addSubview(descriptionContainer)
        addSubview(deleteButton)

        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            deleteButton.widthAnchor.constraint(equalToConstant: 24),
            deleteButton.heightAnchor.constraint(equalToConstant: 24),

            numberBadge.widthAnchor.constraint(equalToConstant: 28),
            numberBadge.heightAnchor.constraint(equalToConstant: 28),
            numberLabel.centerXAnchor.constraint(equalTo: numberBadge.centerXAnchor),
            numberLabel.centerYAnchor.constraint(equalTo: numberBadge.centerYAnchor),

            topRow.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            topRow.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            topRow.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -8),

            bottomRow.topAnchor.constraint(equalTo: topRow.bottomAnchor, constant: 10),
            bottomRow.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            bottomRow.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            durationPicker.widthAnchor.constraint(greaterThanOrEqualToConstant: 110),

            descriptionContainer.topAnchor.constraint(equalTo: bottomRow.bottomAnchor, constant: 8),
            descriptionContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            descriptionContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            descriptionContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
            descContainerHeightConstraint,

            descriptionView.topAnchor.constraint(equalTo: descriptionContainer.topAnchor),
            descriptionView.leadingAnchor.constraint(equalTo: descriptionContainer.leadingAnchor),
            descriptionView.trailingAnchor.constraint(equalTo: descriptionContainer.trailingAnchor),
            descriptionView.bottomAnchor.constraint(equalTo: descriptionContainer.bottomAnchor),

            descPlaceholder.topAnchor.constraint(equalTo: descriptionView.topAnchor, constant: 10),
            descPlaceholder.leadingAnchor.constraint(equalTo: descriptionView.leadingAnchor, constant: 14)
        ])
    }

    func setIndex(_ index: Int) { numberLabel.text = "\(index + 1)" }

    @objc private func toggleDesc() {
        isDescExpanded.toggle()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        descContainerHeightConstraint.constant = isDescExpanded ? 80 : 0

        UIView.animate(withDuration: 0.38, delay: 0, usingSpringWithDamping: 0.82, initialSpringVelocity: 0) {
            self.superview?.layoutIfNeeded()
            let e = self.isDescExpanded
            self.descToggleButton.setTitle(e ? "  Hide note" : "  Add note", for: .normal)
            self.descToggleButton.tintColor = e ? UIColor.accent.withAlphaComponent(0.7) : UIColor(white: 1, alpha: 0.3)
            self.descToggleButton.setTitleColor(e ? UIColor.accent.withAlphaComponent(0.7) : UIColor(white: 1, alpha: 0.3), for: .normal)
        }

        if isDescExpanded {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { self.descriptionView.becomeFirstResponder() }
        }
    }

    @objc private func deleteTapped() { onDelete?() }
}

extension TaskEditRow: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        descPlaceholder.isHidden = !textView.text.isEmpty
    }
}

extension TaskEditRow: DurationPickerViewDelegate {
    func durationPickerDidSelect(_ picker: DurationPickerView, hours: Int, minutes: Int) {
        onDurationChanged?()
    }
}


final class TasksSectionHeader: UIView {

    var onAddTask: (() -> Void)?

    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "TASKS"
        titleLabel.font = UIFont.monospacedSystemFont(ofSize: 11, weight: .semibold)
        titleLabel.textColor = UIColor(white: 1, alpha: 0.35)

        let addButton = FormaButton(configuration: .init(
            title: "Add Task",
            icon: UIImage(systemName: "plus.circle.fill"),
            iconPosition: .leading,
            style: .rectangle,
            backgroundColor: UIColor.accent.withAlphaComponent(0.14),
            titleColor: UIColor.accent,
            borderColor: UIColor.accent.withAlphaComponent(0.28),
            borderWidth: 1,
            cornerRadius: 12,
            contentPadding: UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14),
            iconSize: 14
        ))
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)

        addSubview(titleLabel)
        addSubview(addButton)

        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            addButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc private func addTapped() { onAddTask?() }
}
