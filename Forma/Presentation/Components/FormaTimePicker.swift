//
//  FormaTimePicker.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/16/26.
//

// FormaTimePickerView.swift

import UIKit

protocol FormaTimePickerDelegate: AnyObject {
    func timePickerDidSelectTime(_ picker: FormaTimePickerView, date: Date)
}

final class FormaTimePickerView: UIView {
    
    // MARK: - Configuration
    
    enum PickerType {
        case wakeTime
        case sleepTime
        
        var icon: String {
            switch self {
            case .wakeTime: return "☀️"
            case .sleepTime: return "🌙"
            }
        }
        
        var title: String {
            switch self {
            case .wakeTime: return "WAKE TIME"
            case .sleepTime: return "SLEEP TIME"
            }
        }
        
        var defaultHour: Int {
            switch self {
            case .wakeTime: return 6
            case .sleepTime: return 22
            }
        }
        
        var defaultMinute: Int {
            switch self {
            case .wakeTime: return 30
            case .sleepTime: return 45
            }
        }
        
        var pickerTitle: String {
            switch self {
            case .wakeTime: return "Wake Time"
            case .sleepTime: return "Sleep Time"
            }
        }
        
        var pickerSubtitle: String {
            switch self {
            case .wakeTime:
                return "Choose when you typically wake up. This helps us schedule your morning routines at the optimal time."
            case .sleepTime:
                return "Choose when you typically go to bed. This helps us schedule your evening wind-down routines."
            }
        }
    }
    
    // MARK: - Properties
    
    weak var delegate: FormaTimePickerDelegate?
    private let pickerType: PickerType
    var selectedDate: Date
    
    // MARK: - UI Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundSecondary
        view.layer.cornerRadius = 16
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }()
    
    private lazy var iconLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = pickerType.icon
        label.font = .systemFont(ofSize: 32)
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = pickerType.title
        label.font = .typography(.caption)
        label.textColor = .textSecondary
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 28, weight: .semibold)
        label.textColor = .textPrimary
        return label
    }()
    
    private lazy var periodLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .textSecondary
        return label
    }()
    
    // MARK: - Initialization
    
    init(type: PickerType) {
        self.pickerType = type
        
        // Create default date
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = type.defaultHour
        components.minute = type.defaultMinute
        self.selectedDate = Calendar.current.date(from: components) ?? Date()
        
        super.init(frame: .zero)
        setup()
        updateTimeDisplay()
    }
    
    required init?(coder: NSCoder) {
        self.pickerType = .wakeTime
        self.selectedDate = Date()
        super.init(coder: coder)
        setup()
        updateTimeDisplay()
    }
    
    // MARK: - Public Methods
    
    func setTime(_ date: Date) {
        selectedDate = date
        updateTimeDisplay()
    }
    
    // MARK: - Private Methods
    
    private func updateTimeDisplay() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: selectedDate)
        let minute = calendar.component(.minute, from: selectedDate)
        
        // Format time (12-hour format)
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        let period = hour >= 12 ? "PM" : "AM"
        
        timeLabel.text = String(format: "%d:%02d", displayHour, minute)
        periodLabel.text = period
    }
    
    @objc private func cardTapped() {
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Play sound
        SoundManager.shared.playSound(.buttonTap)
        
        // Show picker
        showTimePicker()
    }
    
    private func showTimePicker() {
        guard let window = window else { return }
        
        let pickerView = FormaTimePickerModal(
            title: pickerType.pickerTitle,
            subtitle: pickerType.pickerSubtitle,
            initialDate: selectedDate
        )
        
        pickerView.onDateSelected = { [weak self] date in
            guard let self = self else { return }
            self.selectedDate = date
            self.updateTimeDisplay()
            self.delegate?.timePickerDidSelectTime(self, date: date)
        }
        
        window.addSubview(pickerView)
        
        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: window.topAnchor),
            pickerView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            pickerView.bottomAnchor.constraint(equalTo: window.bottomAnchor)
        ])
        
        pickerView.show()
    }
}

// MARK: - Container Setup
extension FormaTimePickerView {
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        containerView.addSubview(iconLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(periodLabel)
        
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Icon
            iconLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            iconLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            // Time
            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            timeLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            // Period (AM/PM)
            periodLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 4),
            periodLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            periodLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
    }
    
}

