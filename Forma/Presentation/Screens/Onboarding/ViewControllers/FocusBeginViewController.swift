//
//  FocusBeginViewController.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/15/26.
//

import UIKit

final class FocusBeginViewController: OnboardingBaseViewController {

    // MARK: - Properties
    
    weak var coordinator: OnboardingCoordinator?
    var userPreferences: UserPreferences?
    private var selectedTime: Date?
    
    // MARK: - UI Components
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        scroll.alwaysBounceVertical = true
        return scroll
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 32
        stack.alignment = .fill
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        return stack
    }()
    
    private lazy var timePickerContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.backgroundSecondary
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        return view
    }()
    
    lazy var inlineTimePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        picker.minuteInterval = 60
        picker.tintColor = .accent
        picker.addTarget(self, action: #selector(timePickerChanged), for: .valueChanged)
        
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 9
        components.minute = 0
        picker.date = Calendar.current.date(from: components) ?? Date()
        
        return picker
    }()
    
    lazy var quickOptionsGrid: QuickOptionsGridView = {
        let view = QuickOptionsGridView()
        view.delegate = self
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func setupViews() {
        super.setupViews()
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        setupLayout()
        
        // Set default selection to 9 AM
        quickOptionsGrid.selectOption(.nine)
        selectedTime = QuickTimeOption.nine.date
    }
    
}

// MARK: - OnboardingBaseViewControllerDelegate

extension FocusBeginViewController: OnboardingBaseViewControllerDelegate {
    func didTapButton(_ view: OnboardingBaseViewController) {
        nextTapped()
    }
}

// MARK: - QuickOptionsGridViewDelegate

extension FocusBeginViewController: QuickOptionsGridViewDelegate {
    func quickOptionsGridView(_ view: QuickOptionsGridView, didSelect option: QuickTimeOption) {
        guard option != .flexible else {
            selectedTime = nil
            return
        }
        
        selectedTime = option.date
        
        // Sync inline picker
        if let date = option.date {
            UIView.animate(withDuration: 0.3) {
                self.inlineTimePicker.setDate(date, animated: true)
            }
        }
    }
}

// MARK: - Setup Layout
extension FocusBeginViewController {
    private func setupLayout() {
        setupViews(
            onboardingTitle: "When does your\nfocus begin?",
            onboardingSubtitle: "Tell us when your primary work or deep-study shift starts. We'll anchor your peak energy routines around this time.",
            highlightedWord: "focus begin?",
            buttonTitle: "Next"
        )
        
        delegate = self
        textView.removeFromSuperview()
        
        view.insertSubview(scrollView, at: 0)
        scrollView.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(textView)
        contentStackView.addArrangedSubview(timePickerContainer)
        contentStackView.addArrangedSubview(quickOptionsGrid)
        
        timePickerContainer.addSubview(inlineTimePicker)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
        
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 8),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 8),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -8),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -8),
            contentStackView.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor,
                constant: -16
            ),
        
            inlineTimePicker.topAnchor.constraint(equalTo: timePickerContainer.topAnchor, constant: 8),
            inlineTimePicker.leadingAnchor.constraint(equalTo: timePickerContainer.leadingAnchor, constant: 8),
            inlineTimePicker.trailingAnchor.constraint(equalTo: timePickerContainer.trailingAnchor, constant: -8),
            inlineTimePicker.bottomAnchor.constraint(equalTo: timePickerContainer.bottomAnchor, constant: -8),
        ])
        
        animateIn([timePickerContainer, quickOptionsGrid])
    }
}

extension FocusBeginViewController {
    
    @objc func timePickerChanged() {
        selectedTime = inlineTimePicker.date
        
        quickOptionsGrid.clearSelection()
        
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    @objc func nextTapped() {
        SoundManager.shared.playSound(.buttonTap)
        
        if let time = selectedTime {
            print("✅ Focus time saved: \(time)")
            userPreferences?.focusTime = time
        } else if quickOptionsGrid.selectedOption == .flexible {
            print("✅ Flexible schedule selected")
            userPreferences?.focusTime = nil
        }
        
        guard let userPreferences else {
            print("UserPreferences is nil")
            return
        }
        
        coordinator?.showProfessionalLifeScreen(userPreferences)
    }
}
