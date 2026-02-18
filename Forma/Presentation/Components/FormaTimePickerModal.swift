//
//  FormaTimePickerModal.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/17/26.
//

import UIKit

final class FormaTimePickerModal: UIView {
    
    // MARK: - Properties
    
    private let titleText: String
    private let subtitleText: String
    private var selectedDate: Date
    
    var onDateSelected: ((Date) -> Void)?
    var onDismiss: (() -> Void)?
    
    // MARK: - UI Components
    
    private lazy var dimView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.alpha = 0
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimViewTapped))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundSecondary
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 0, height: -4)
        view.layer.shadowRadius = 12
        return view
    }()
    
    private lazy var handleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray3
        view.layer.cornerRadius = 2.5
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = titleText
        label.font = .typography(.heading1)
        label.textColor = .textPrimary
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = subtitleText
        label.font = .typography(.bodyMedium)
        label.textColor = .textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.preferredDatePickerStyle = .wheels
        picker.datePickerMode = .time
        picker.date = selectedDate
        picker.minuteInterval = 5
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        // Customize appearance
        picker.tintColor = .accent
        
        return picker
    }()
    
    private lazy var doneButton: FormaButton = {
        let button = FormaButton.primary(title: "Done")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        return button
    }()
    
    private var bottomConstraint: NSLayoutConstraint!
    
    // MARK: - Initialization
    
    init(title: String, subtitle: String, initialDate: Date) {
        self.titleText = title
        self.subtitleText = subtitle
        self.selectedDate = initialDate
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func show() {
        layoutIfNeeded()
        
        bottomConstraint.constant = 0
        
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            self.dimView.alpha = 1
            self.layoutIfNeeded()
        }
    }
    
    func dismiss() {
        bottomConstraint.constant = 500
        
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.dimView.alpha = 0
                self.layoutIfNeeded()
            },
            completion: { _ in
                self.removeFromSuperview()
                self.onDismiss?()
            }
        )
    }
    
    // MARK: - Actions
    
    @objc private func dateChanged() {
        selectedDate = datePicker.date
        
        // Haptic feedback
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    @objc private func doneTapped() {
        SoundManager.shared.playSound(.buttonTap)
        
        onDateSelected?(selectedDate)
        dismiss()
    }
    
    @objc private func dimViewTapped() {
        dismiss()
    }
}

// MARK: - Setup
extension FormaTimePickerModal {
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(dimView)
        addSubview(containerView)
        
        containerView.addSubview(handleView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(datePicker)
        containerView.addSubview(doneButton)
        
        bottomConstraint = containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 500)
        
        NSLayoutConstraint.activate([
            // Dim view
            dimView.topAnchor.constraint(equalTo: topAnchor),
            dimView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Container
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomConstraint,
            
            // Handle
            handleView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            handleView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            handleView.widthAnchor.constraint(equalToConstant: 40),
            handleView.heightAnchor.constraint(equalToConstant: 5),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: handleView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            // Date picker
            datePicker.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            datePicker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // Done button
            doneButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 24),
            doneButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            doneButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            doneButton.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            doneButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
}
